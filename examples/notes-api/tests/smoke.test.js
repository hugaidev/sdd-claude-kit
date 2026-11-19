import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, readdirSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import net from 'node:net';

const root = join(import.meta.dirname, '..');

function sourceFiles(dir) {
  return readdirSync(dir).flatMap((name) => {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) return sourceFiles(full);
    return full.endsWith('.js') ? [full] : [];
  });
}

const freePort = () =>
  new Promise((resolve) => {
    const s = net.createServer().listen(0, '127.0.0.1', () => {
      const { port } = s.address();
      s.close(() => resolve(port));
    });
  });

test('node --check passes on every source file', () => {
  const files = sourceFiles(join(root, 'src'));
  assert.ok(files.length > 0);
  for (const f of files) {
    const r = spawnSync(process.execPath, ['--check', f], { encoding: 'utf8' });
    assert.equal(r.status, 0, `${f}: ${r.stderr}`);
  }
});

test('npm start smoke: service starts on PORT and POST /v1/notes returns 201', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'notes-smoke-'));
  const port = await freePort();
  const child = spawn('npm start', {
    cwd: root,
    shell: true,
    stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env, PORT: String(port), HOST: '127.0.0.1', DB_FILE: join(dir, 'notes.db') },
  });
  try {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('service did not start')), 15000);
      child.stdout.on('data', (d) => {
        if (String(d).includes('listening')) {
          clearTimeout(timer);
          resolve();
        }
      });
      child.on('exit', (c) => {
        clearTimeout(timer);
        reject(new Error(`exited early: ${c}`));
      });
    });
    const res = await fetch(`http://127.0.0.1:${port}/v1/notes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'smoke', body: 'ok' }),
    });
    assert.equal(res.status, 201);
  } finally {
    if (process.platform === 'win32') spawnSync('taskkill', ['/pid', String(child.pid), '/t', '/f']);
    else child.kill('SIGTERM');
    await new Promise((r) => setTimeout(r, 500));
    rmSync(dir, { recursive: true, force: true });
  }
});
