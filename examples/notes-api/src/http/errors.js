// Standard error envelope (API contract section 2).
export class ApiError extends Error {
  constructor(status, code, message, details = []) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export class ValidationError extends ApiError {
  constructor(message, details = []) {
    super(400, 'VALIDATION_ERROR', message, details);
  }
}

// Maps any thrown value to { status, body }; unexpected errors become 500
// with a generic message (never echoes input or internals).
export function mapError(err) {
  if (err instanceof ApiError) {
    return {
      status: err.status,
      body: { error: { code: err.code, message: err.message, details: err.details } },
    };
  }
  return {
    status: 500,
    body: { error: { code: 'INTERNAL_ERROR', message: 'internal error', details: [] } },
  };
}
