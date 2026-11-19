import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';
import { createNoteRepo } from '../src/repo/noteRepo.js';
import { createNoteService } from '../src/service/noteService.js';
import { createApp } from '../src/http/app.js';

let dir, repo, server, base;

before(async () => {
  dir = mkdtempSync(join(tmpdir(), 'notes-delete-test-'));
  repo = createNoteRepo(join(dir, 'notes.db'));
  server = createApp(createNoteService(repo));
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  base = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((r) => server.close(r));
  repo.close();
  rmSync(dir, { recursive: true, force: true });
});

const del = (id) => fetch(`${base}/v1/notes/${id}`, { method: 'DELETE' });

async function expectError(res, status, code) {
  assert.equal(res.status, status);
  const body = await res.json();
  assert.equal(body.error.code, code);
  assert.ok(Array.isArray(body.error.details));
  return body;
}

test('TEST-003 delete removes the note, then 404, 404, 400, and the list is empty', async () => {
  const created = await fetch(`${base}/v1/notes`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: 'synthetic title', body: 'lorem ipsum' }),
  });
  assert.equal(created.status, 201);
  const { id } = await created.json();

  const first = await del(id);
  assert.equal(first.status, 204);
  assert.equal(await first.text(), '');

  await expectError(await del(id), 404, 'NOT_FOUND');
  await expectError(await del(randomUUID()), 404, 'NOT_FOUND');

  const bad = await expectError(await del('not-a-uuid'), 400, 'VALIDATION_ERROR');
  assert.equal(bad.error.details[0].field, 'id');

  const listed = await (await fetch(`${base}/v1/notes`)).json();
  assert.deepEqual(listed, { items: [], next_cursor: null });
});

test('TEST-003 delete leaves other notes in place', async () => {
  const make = async (title) =>
    (
      await fetch(`${base}/v1/notes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, body: '' }),
      })
    ).json();
  const a = await make('keep');
  const b = await make('drop');
  assert.equal((await del(b.id)).status, 204);
  const listed = await (await fetch(`${base}/v1/notes`)).json();
  assert.deepEqual(
    listed.items.map((n) => n.id),
    [a.id],
  );
});
