// Where ZigDash ranks in Google Play search, per term and country.
// Usage: env -u NODE_OPTIONS node tool/play_rank.mjs [--csv]
// Play returns the first ~30 apps without a session; "-" means not in them.

const app = 'com.giladtamam.zigdash';
// Held today (watch for losses): the first five. Targets: where setup works
// (Zigbee2MQTT, alone or in Home Assistant). Reference only: searches whose
// people mostly can't finish setup (plain MQTT, ZHA), kept to see drift.
const terms = [
  'zigbee2mqtt', 'zigbee2mqtt dashboard', 'zigbee dashboard', 'zigbee app', 'zigbee',
  'zigbee2mqtt app', 'zigbee2mqtt android', 'zigbee2mqtt home assistant',
  'zigbee control', 'zigbee wall tablet', 'smlight', 'sonoff zigbee',
  // German phrases the German listing uses (read in the DE column).
  'zigbee wandtablet', 'zigbee2mqtt fernzugriff', 'smart home wandtablet',
  'mqtt dashboard', 'home assistant dashboard',
];
// German results in German: [gl, hl].
const countries = [['US', 'en'], ['DE', 'de']];
const csv = process.argv.includes('--csv');
const day = new Date().toISOString().slice(0, 10);

async function rank(q, gl, hl) {
  const url = `https://play.google.com/store/search?q=${encodeURIComponent(q)}&c=apps&hl=${hl}&gl=${gl}`;
  const html = await (await fetch(url, { headers: { 'user-agent': 'Mozilla/5.0' } })).text();
  const ids = [...new Set([...html.matchAll(/\/store\/apps\/details\?id=([\w.]+)/g)].map((m) => m[1]))];
  const i = ids.indexOf(app);
  return { pos: i < 0 ? '-' : String(i + 1), of: ids.length };
}

if (csv) console.log('date,term,country,position,results');
for (const q of terms) {
  const row = [];
  for (const [gl, hl] of countries) {
    const r = await rank(q, gl, hl);
    if (csv) console.log(`${day},"${q}",${gl},${r.pos},${r.of}`);
    else row.push(`${gl} ${r.pos.padStart(2)}/${r.of}`);
    await new Promise((res) => setTimeout(res, 800));
  }
  if (!csv) console.log(q.padEnd(26), row.join('   '));
}
