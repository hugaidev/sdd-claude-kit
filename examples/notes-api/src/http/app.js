import http from 'node:http';
import { ApiError, ValidationError, mapError } from './errors.js';
import { logRequest } from './requestLogger.js';

const MAX_BODY_BYTES = 1024 * 1024;

function send(res, status, payload) {
  const text = JSON.stringify(payload);
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(text),
  });
  res.end(text);
}

async function readJson(req) {
  const type = (req.headers['content-type'] ?? '').split(';')[0].trim().toLowerCase();
  if (type !== 'application/json') {
    throw new ApiError(415, 'UNSUPPORTED_MEDIA_TYPE', 'content type must be application/json');
  }
  const chunks = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) {
      throw new ApiError(413, 'PAYLOAD_TOO_LARGE', 'request body must be at most 1 MiB');
    }
    chunks.push(chunk);
  }
  let parsed;
  try {
    parsed = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    throw new ValidationError('malformed JSON', [{ field: 'body', reason: 'malformed JSON' }]);
  }
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new ValidationError('body must be a JSON object', [
      { field: 'body', reason: 'must be an object' },
    ]);
  }
  return parsed;
}

// HTTP layer: routing, input shape validation, error mapping.
export function createApp(noteService, { log } = {}) {
  return http.createServer(async (req, res) => {
    logRequest(req, res, log);
    try {
      const url = new URL(req.url, 'http://localhost');
      const path = url.pathname;
      if (req.method === 'GET' && path === '/v1/notes') {
        const q = url.searchParams;
        const cursor = q.has('cursor') ? q.get('cursor') : undefined;
        const limit = q.has('limit') ? q.get('limit') : undefined;
        return send(res, 200, noteService.list({ limit, cursor }));
      }
      if (req.method === 'POST' && path === '/v1/notes') {
        const input = await readJson(req);
        return send(res, 201, noteService.create(input));
      }
      const m = /^\/v1\/notes\/([^/]+)$/.exec(path);
      if (req.method === 'DELETE' && m) {
        let id;
        try {
          id = decodeURIComponent(m[1]);
        } catch {
          id = m[1]; // undecodable: fails uuid validation in the service
        }
        noteService.remove(id);
        res.writeHead(204);
        return res.end();
      }
      throw new ApiError(404, 'NOT_FOUND', 'resource not found');
    } catch (err) {
      const { status, body } = mapError(err);
      send(res, status, body);
    }
  });
}
