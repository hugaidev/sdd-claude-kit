import { createNoteRepo } from './repo/noteRepo.js';
import { createNoteService } from './service/noteService.js';
import { createApp } from './http/app.js';

const port = Number(process.env.PORT ?? 3000);
const host = process.env.HOST ?? '127.0.0.1';
const dbFile = process.env.DB_FILE ?? './notes.db';

const repo = createNoteRepo(dbFile);
const server = createApp(createNoteService(repo));
server.listen(port, host, () => {
  console.log(JSON.stringify({ event: 'listening', host, port }));
});

for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => {
    server.close(() => {
      repo.close();
      process.exit(0);
    });
  });
}
