const http = require('node:http');
const client = require('prom-client');

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2],
  registers: [register],
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests received',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const KNOWN_ROUTES = new Set(['/', '/healthz', '/metrics']);

function createServer() {
  return http.createServer((req, res) => {
    const start = process.hrtime.bigint();
    const { method } = req;
    const url = new URL(req.url, 'http://localhost').pathname;
    const route = KNOWN_ROUTES.has(url) ? url : 'unknown';

    const recordMetrics = (statusCode) => {
      const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
      const labels = { method, route, status_code: statusCode };
      httpRequestDuration.observe(labels, durationSeconds);
      httpRequestsTotal.inc(labels);
    };

    const respond = (statusCode, body, contentType) => {
      res.writeHead(statusCode, { 'Content-Type': contentType });
      res.end(body);
      recordMetrics(statusCode);
    };

    if (method !== 'GET') {
      respond(404, 'Not Found', 'text/plain');
      return;
    }

    if (url === '/') {
      respond(200, 'Hello World', 'text/plain');
      return;
    }

    if (url === '/healthz') {
      respond(200, JSON.stringify({ status: 'ok' }), 'application/json');
      return;
    }

    if (url === '/metrics') {
      register
        .metrics()
        .then((metricsText) => respond(200, metricsText, register.contentType));
      return;
    }

    respond(404, 'Not Found', 'text/plain');
  });
}

module.exports = { createServer };

if (require.main === module) {
  const port = process.env.PORT || 3000;
  const server = createServer().listen(port, () => {
    console.log(`Hello World service listening on port ${port}`);
  });

  const shutdown = (signal) => {
    console.log(`${signal} received, closing server`);
    server.close(() => process.exit(0));
  };
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}
