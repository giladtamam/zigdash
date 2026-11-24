// The owner's commands for founders' passes and Home deletion
// (docs/design/founders-pass.md, "Codes"), run in the verifier's container:
//
//   docker compose exec verifier node cli.mjs passes new --count N [--days 90] [--redeem-by 2027-01-31]
//   docker compose exec verifier node cli.mjs passes list
//   docker compose exec verifier node cli.mjs passes revoke <hash prefix or code>
//   docker compose exec verifier node cli.mjs passes unrevoke <hash prefix or code>
//   docker compose exec verifier node cli.mjs passes extend <hash prefix or code> [--redeem-by D] [--days N]
//   docker compose exec verifier node cli.mjs passes reissue <home id> [--redeem-by D]
//   docker compose exec verifier node cli.mjs passes sweep
//   docker compose exec verifier node cli.mjs homes delete <home id>
//
// It asks the running verifier over its Unix socket (ADMIN_SOCKET), so every
// broker change goes through the verifier's own per-Home locks. New codes are
// printed here once and kept nowhere (the verifier stores their keyed hash
// only, and logs nothing about them). Dates: YYYY-MM-DD, the end of that day UTC.

import http from 'node:http';

const USAGE = `usage: node cli.mjs passes new --count N [--days 90] [--redeem-by YYYY-MM-DD]
       node cli.mjs passes list
       node cli.mjs passes revoke|unrevoke <hash prefix or code>
       node cli.mjs passes extend <hash prefix or code> [--redeem-by YYYY-MM-DD] [--days N]
       node cli.mjs passes reissue <home id> [--redeem-by YYYY-MM-DD]
       node cli.mjs passes sweep
       node cli.mjs homes delete <home id>`;

/** Positional words and --flags of argv. */
export function parseArgs(argv) {
  const words = [], flags = {};
  for (let i = 0; i < argv.length; i++) {
    const m = /^--([a-z-]+)(?:=(.*))?$/.exec(argv[i]);
    if (!m) { words.push(argv[i]); continue; }
    flags[m[1]] = m[2] !== undefined ? m[2] : argv[++i];
  }
  return { words, flags };
}

/** YYYY-MM-DD as the last millisecond of that day, UTC. */
export function endOfDay(text) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(text || ''));
  const t = m ? Date.UTC(Number(m[1]), Number(m[2]) - 1, Number(m[3]) + 1) - 1 : NaN;
  if (Number.isNaN(t) || new Date(t).getUTCDate() !== Number(m[3])) throw new Error(`not a date (YYYY-MM-DD): ${text}`);
  return t;
}

/** The command to send for argv: {op, args}. */
export function commandOf(argv) {
  const { words, flags } = parseArgs(argv);
  const [group, verb, target] = words;
  const op = `${group} ${verb}`;
  const by = flags['redeem-by'] !== undefined ? endOfDay(flags['redeem-by']) : undefined;
  const need = () => { if (!target) throw new Error(USAGE); return target; };
  switch (op) {
    case 'passes new': return { op, args: { count: Number(flags.count ?? 1), days: flags.days, redeem_by: by } };
    case 'passes list': case 'passes sweep': return { op, args: {} };
    case 'passes revoke': case 'passes unrevoke': return { op, args: { pass: need() } };
    case 'passes extend': return { op, args: { pass: need(), redeem_by: by, days: flags.days } };
    case 'passes reissue': return { op, args: { home: need(), redeem_by: by } };
    case 'homes delete': return { op, args: { home: need() } };
    default: throw new Error(USAGE);
  }
}

/** Sends one command to the verifier's socket: the result, or throws its error. */
export function ask(socketPath, command) {
  return new Promise((resolve, reject) => {
    const req = http.request({ socketPath, path: '/', method: 'POST', headers: { 'Content-Type': 'application/json' } }, (res) => {
      let raw = '';
      res.on('data', (c) => { raw += c; });
      res.on('end', () => {
        let body;
        try { body = JSON.parse(raw); } catch { return reject(new Error(`the verifier answered ${res.statusCode}`)); }
        return body.ok ? resolve(body.result) : reject(new Error(body.error || `the verifier answered ${res.statusCode}`));
      });
    });
    req.on('error', (e) => reject(new Error(`could not reach the verifier at ${socketPath} (${e.code || e.message}); is it running?`)));
    req.end(JSON.stringify(command));
  });
}

const day = (t) => (t == null ? '-' : new Date(t).toISOString().slice(0, 16).replace('T', ' '));

/** What the owner reads for a command's result. */
export function format(op, r) {
  if (op === 'passes new') {
    return [...r.codes, `${r.codes.length} code(s), ${r.days} days each, to be entered by ${day(r.redeem_by)} UTC. Shown once: copy them now.`].join('\n');
  }
  if (op === 'passes reissue') return `${r.code}\nfor Home ${r.home} (pass ${r.hash}), ends ${day(r.expires_at)} UTC, to be entered by ${day(r.redeem_by)} UTC. Shown once.`;
  if (op === 'passes list') {
    if (!r.passes.length) return 'no passes';
    const head = ['hash', 'state', 'created', 'enter by', 'days', 'entered', 'ends', 'revoked', 'home'];
    const rows = r.passes.map((p) => [p.hash, p.state, day(p.created), day(p.redeem_by), String(p.days), day(p.redeemed_at), day(p.expires_at), day(p.revoked_at), p.home || '-']);
    const width = head.map((h, i) => Math.max(h.length, ...rows.map((row) => row[i].length)));
    return [head, ...rows].map((row) => row.map((c, i) => c.padEnd(width[i])).join('  ').trimEnd()).join('\n');
  }
  if (op === 'passes sweep') return Object.entries(r).map(([k, v]) => `${k}: ${v}`).join(', ');
  if (op === 'homes delete') {
    return r.outcome === 'kept' ? `Home ${r.home}: its retained messages did not settle; nothing deleted yet, run it again`
      : `Home ${r.home}: ${r.outcome}`;
  }
  return `${r.hash}  ${r.state}  ends ${day(r.expires_at)}  enter by ${day(r.redeem_by)}  home ${r.home || '-'}`;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  try {
    const command = commandOf(process.argv.slice(2));
    const result = await ask(process.env.ADMIN_SOCKET || '/tmp/zigdash-verifier.sock', command);
    console.log(format(command.op, result));
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
}
