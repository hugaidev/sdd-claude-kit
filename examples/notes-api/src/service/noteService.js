import { ApiError, ValidationError } from '../http/errors.js';
import { InvalidCursorError } from '../repo/cursor.js';

const TITLE_MAX = 120;
const BODY_MAX = 10000;
const DEFAULT_LIMIT = 20;
const LIMIT_MAX = 100;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const length =(s) => Array.from(s).length;

// Note service: BR-001 (title), BR-004 (body), BR-005 (no update operation).
export function createNoteService(repo) {
  return {
    create(input) {
      const details = [];
      const title = typeof input.title === 'string' ? input.title.trim() : input.title;
      if (title === undefined || title === null || title === '') {
        details.push({ field: 'title', reason: 'required' });
      } else if (typeof title !== 'string') {
        details.push({ field: 'title', reason: 'must be a string' });
      } else if (length(title) > TITLE_MAX) {
        details.push({ field: 'title', reason: `must be at most ${TITLE_MAX} characters` });
      }

      const body = input.body;
      if (body === undefined || body === null) {
        details.push({ field: 'body', reason: 'required' });
      } else if (typeof body !== 'string') {
        details.push({ field: 'body', reason: 'must be a string' });
      } else if (length(body) > BODY_MAX) {
        details.push({ field: 'body', reason: `must be at most ${BODY_MAX} characters` });
      }

      if (details.length > 0) {
        throw new ValidationError(`${details[0].field} ${details[0].reason}`, details);
      }
      return repo.insert({ title, body });
    },

    // REQ-003: 400 for a non-uuid id, 404 when no such note (including already deleted)
    remove(id) {
      if (!UUID_RE.test(id)) {
        throw new ValidationError('id must be a uuid', [{ field: 'id', reason: 'must be a uuid' }]);
      }
      if (!repo.remove(id.toLowerCase())) {
        throw new ApiError(404, 'NOT_FOUND', 'note not found');
      }
    },

    // query values are raw strings (or undefined) from the HTTP layer
    list({ limit, cursor }) {
      let n = DEFAULT_LIMIT;
      if (limit !== undefined) {
        n = /^[0-9]{1,9}$/.test(limit) ? Number(limit) : NaN;
        if (!(n >= 1 && n <= LIMIT_MAX)) {
          const reason = `must be an integer from 1 to ${LIMIT_MAX}`;
          throw new ValidationError(`limit ${reason}`, [{ field: 'limit', reason }]);
        }
      }
      try {
        return repo.list({ limit: n, cursor });
      } catch (err) {
        if (err instanceof InvalidCursorError) {
          throw new ValidationError('cursor is malformed', [
            { field: 'cursor', reason: 'malformed' },
          ]);
        }
        throw err;
      }
    },
  };
}
