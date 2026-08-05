const http = require('http');

let requests = 0;
const started = Date.now();

// no prom client lib, just fake the text format by hand, good enough here
function metrics() {
  return [
    '# HELP app_requests_total Total HTTP requests handled',
    '# TYPE app_requests_total counter',
    `app_requests_total ${requests}`,
    '# HELP app_uptime_seconds Seconds since process start',
    '# TYPE app_uptime_seconds gauge',
    `app_uptime_seconds ${(Date.now() - started) / 1000}`,
  ].join('\n');
}

const server = http.createServer((req, res) => {
  requests += 1;
  if (req.url === '/healthz') return res.end('ok');
  if (req.url === '/metrics') {
    res.setHeader('content-type', 'text/plain; version=0.0.4');
    return res.end(metrics());
  }
  res.setHeader('content-type', 'application/json');
  res.end(JSON.stringify({ service: '${{ values.name }}', message: 'Hello from the golden path' }));
});

server.listen(8080, () => console.log('listening on :8080'));
