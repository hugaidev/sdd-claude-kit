// TEST-004 (REQ-002, NFR-001): load test, run on demand: `node tests/load004.js`
// Not named *.test.js on purpose, so `node --test` (CI) does not run the 60 s load.
// Env: DURATION_S (default 60), RATE (default 50), SEED (default 1000).
import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import net from 'node:net';

const root = join(import.meta.dirname, '..');
const DURATION_S = Number(process.env.DURATION_S ?? 60);
const RATE = Number(process.env.RATE ?? 50);
const SEED = Number(process.env.SEED ?? 1000);
const LIMIT_MS = 200;

const freePort = () =>
  new Promise((resolve) => {
    const s = net.createServer().listen(0, '127.0.0.1', () => {
      const { port } = s.address();
      s.close(() => resolve(port));
    });
  });

const lorem = 'lorem ipsum dolor sit amet consectetur adipiscing elit '.repeat(8);
const pad = (n) => String(n).padStart(3, '0');
const post = (base, i) =>
  fetch(`${base}/v1/notes`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: `note-${pad(i)}`, body: lorem }),
  });

const p95 = (xs) => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? s[Math.ceil(0.95 * s.length) - 1] : NaN;
};

const dir = mkdtempSync(join(tmpdir(), 'notes-load-'));
const port = await freePort();
const base = `http://127.0.0.1:${port}`;
const child = spawn(process.execPath, ['src/server.js'], {
  cwd: root,
  stdio: ['ignore', 'pipe', 'ignore'],
  env: { ...process.env, PORT: String(port), HOST: '127.0.0.1', DB_FILE: join(dir, 'notes.db') },
});

let failed = false;
try {
  await new Promise((resolve, reject) => {
    const t = setTimeout(() => reject(new Error('service did not start')), 15000);
    child.stdout.on('data', (d) => String(d).includes('listening') && (clearTimeout(t), resolve()));
    child.on('exit', (c) => reject(new Error(`exited early: ${c}`)));
  });
  child.stdout.resume();

  for (let i = 1; i <= SEED; i++) {
    const r = await post(base, i);
    if (r.status !== 201) throw new Error(`seed failed at ${i}: ${r.status}`);
  }

  const total = RATE * DURATION_S;
  const lat = { create: [], list: [] };
  const statuses = { create: {}, list: {} };
  const inflight = [];
  const start = performance.now();

  for (let n = 0; n < total; n++) {
    const wait = start + (n * 1000) / RATE - performance.now();
    if (wait > 0) await new Promise((r) => setTimeout(r, wait));
    const kind = n % 5 === 4 ? 'create' : 'list'; // 20 percent create, 80 percent list
    const t0 = performance.now();
    inflight.push(
      (kind === 'create' ? post(base, SEED + n) : fetch(`${base}/v1/notes?limit=20`))
        .then(async (r) => {
          await r.arrayBuffer();
          lat[kind].push(performance.now() - t0);
          statuses[kind][r.status] = (statuses[kind][r.status] ?? 0) + 1;
        })
        .catch(() => {
          statuses[kind].error = (statuses[kind].error ?? 0) + 1;
        }),
    );
  }
  await Promise.all(inflight);
  const elapsed = (performance.now() - start) / 1000;

  const report = { rate: RATE, duration_s: DURATION_S, seeded: SEED, achieved_rps: +(total / elapsed).toFixed(2) };
  for (const k of ['create', 'list']) {
    const xs = lat[k];
    const bad = Object.entries(statuses[k]).filter(([s]) => s === 'error' || Number(s) >= 500);
    report[k] = {
      count: xs.length,
      p50_ms: +[...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)].toFixed(2),
      p95_ms: +p95(xs).toFixed(2),
      max_ms: +Math.max(...xs).toFixed(2),
      statuses: statuses[k],
    };
    if (!(p95(xs) < LIMIT_MS) || bad.length) failed = true;
  }
  report.pass = !failed;
  console.log(JSON.stringify(report, null, 2));
} catch (e) {
  failed = true;
  console.error(e.message);
} finally {
  if (process.platform === 'win32') spawnSync('taskkill', ['/pid', String(child.pid), '/t', '/f']);
  else child.kill('SIGTERM');
  await new Promise((r) => setTimeout(r, 500));
  rmSync(dir, { recursive: true, force: true });
}
process.exit(failed ? 1 : 0);
