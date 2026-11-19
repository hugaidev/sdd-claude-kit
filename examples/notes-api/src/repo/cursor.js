// Pagination cursor (BR-002, ADR-0002): base64url of the JSON array
// [created_at, id] of the last returned note. Opaque to clients.
export class InvalidCursorError extends Error {}

export function encodeCursor({ created_at, id }) {
  return Buffer.from(JSON.stringify([created_at, id]), 'utf8').toString('base64url');
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

// Returns { created_at, id } or throws InvalidCursorError.
export function decodeCursor(cursor) {
  if (typeof cursor !== 'string' || !/^[A-Za-z0-9_-]+$/.test(cursor)) {
    throw new InvalidCursorError('cursor is malformed');
  }
  let parsed;
  try {
    parsed = JSON.parse(Buffer.from(cursor, 'base64url').toString('utf8'));
  } catch {
    throw new InvalidCursorError('cursor is malformed');
  }
  if (!Array.isArray(parsed) || parsed.length !== 2) {
    throw new InvalidCursorError('cursor is malformed');
  }
  const [created_at, id] = parsed;
  const validTime =
    typeof created_at === 'string' &&
    !Number.isNaN(Date.parse(created_at)) &&
    new Date(created_at).toISOString() === created_at;
  if (!validTime || typeof id !== 'string' || !UUID.test(id)) {
    throw new InvalidCursorError('cursor is malformed');
  }
  return { created_at, id };
}
