import { randomUUID } from 'node:crypto';

// Structured request logging (NFR-002): request id, method, path (no query) and
// status only. Never reads or logs request/response bodies.
export function logRequest(req, res, write = (line) => console.log(line)) {
  const request_id = randomUUID();
  const method = req.method;
  const path = (req.url ?? '').split('?')[0];
  res.on('finish', () => {
    write(JSON.stringify({ event: 'request', request_id, method, path, status: res.statusCode }));
  });
}
