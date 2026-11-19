import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import net from 'node:net';

const server = join(import.meta.dirname, '..', 'src', 'server.js');

const freePort = () =>
  new Promise((resolve) => {
    const s = net.createServer().listen(0, '127.0.0.1', () => {
      const { port } = s.address();
      s.close(() => resolve(port));
    });
  });

async function start(port, dbFile, extraEnv = {}) {
  const env = { ...process.env, PORT: String(port), DB_FILE: dbFile, ...extraEnv };
  if (!('HOST' in extraEnv)) delete env.HOST;
  const child = spawn(process.execPath, [server], { env, stdio: ['ignore', 'pipe', 'pipe'] });
  const lines = [];
  let buf = '';
  child.stdout.on('data', (d) => {
    buf += d;
    const parts = buf.split('\n');
    buf = parts.pop();
    lines.push(...parts.filter(Boolean));
  });
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('did not start')), 15000);
    const poll = setInterval(() => {
      if (lines.some((l) => l.includes('listening'))) {
        clearInterval(poll);
        clearTimeout(timer);
        resolve();
      }
    }, 20);
    child.on('exit', (c) => reject(new Error(`exited early: ${c}`)));
  });
  return { child, lines };
}

const kill = (child) =>
  new Promise((resolve) => {
    child.removeAllListeners('exit');
    child.once('exit', resolve);
    child.kill('SIGKILL'); // abrupt stop, no graceful shutdown
  });

const post = (port, note) =>
  fetch(`http://127.0.0.1:${port}/v1/notes`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(note),
  });

test('TEST-005: acknowledged notes survive an abrupt restart (NFR-003)', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'notes-t5-'));
  const db = join(dir, 'notes.db');
  const port = await freePort();
  try {
    let svc = await start(port, db);
    for (let i = 0; i < 10; i++) {
      const res = await post(port, { title: `note-${i}`, body: `body-${i}` });
      assert.equal(res.status, 201);
    }
    await kill(svc.child);
    svc = await start(port, db);
    const res = await fetch(`http://127.0.0.1:${port}/v1/notes?limit=100`);
    const { items } = await res.json();
    assert.equal(items.length, 10);
    assert.deepEqual(
      items.map((n) => n.title).sort(),
      Array.from({ length: 10 }, (_, i) => `note-${i}`).sort(),
    );
    await kill(svc.child);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('TEST-006: logs carry method, path, status and never note text (NFR-002)', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'notes-t6-'));
  const port = await freePort();
  const marker = 'MARKER-7f3a9c1e-unique';
  try {
    const svc = await start(port, join(dir, 'notes.db'));
    const res = await post(port, { title: `t-${marker}`, body: `b-${marker}` });
    assert.equal(res.status, 201);
    await fetch(`http://127.0.0.1:${port}/v1/notes?limit=5`);
    await new Promise((r) => setTimeout(r, 200));
    const all = svc.lines.join('\n');
    assert.ok(!all.includes(marker), 'note text leaked into logs');
    const entries = svc.lines.map((l) => JSON.parse(l)).filter((e) => e.event === 'request');
    const created = entries.find((e) => e.method === 'POST');
    assert.equal(created.path, '/v1/notes');
    assert.equal(created.status, 201);
    assert.ok(created.request_id);
    assert.ok(entries.some((e) => e.method === 'GET' && e.status === 200));
    await kill(svc.child);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('TASK-005: default bind address is loopback, not public', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'notes-bind-'));
  const port = await freePort();
  try {
    const svc = await start(port, join(dir, 'notes.db'));
    const listening = JSON.parse(svc.lines.find((l) => l.includes('listening')));
    assert.equal(listening.host, '127.0.0.1');
    await kill(svc.child);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});
