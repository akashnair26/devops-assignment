const test = require('node:test');
const assert = require('node:assert/strict');
const { createServer } = require('./server');

async function withServer(fn) {
  const server = createServer();
  await new Promise((resolve) => server.listen(0, resolve));
  const { port } = server.address();
  try {
    await fn(`http://127.0.0.1:${port}`);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

test('GET / returns Hello World', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/`);
    assert.equal(res.status, 200);
    assert.equal(await res.text(), 'Hello World');
  });
});

test('GET /healthz returns ok status', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/healthz`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'ok');
  });
});

test('GET /metrics returns prometheus formatted metrics including request counter', async () => {
  await withServer(async (baseUrl) => {
    await fetch(`${baseUrl}/`);
    const res = await fetch(`${baseUrl}/metrics`);
    assert.equal(res.status, 200);
    const text = await res.text();
    assert.match(text, /http_requests_total/);
    assert.match(text, /http_request_duration_seconds/);
  });
});

test('GET /healthz?x=1 still matches ignoring the query string', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/healthz?x=1`);
    assert.equal(res.status, 200);
  });
});

test('unknown route returns 404', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/nope`);
    assert.equal(res.status, 404);
  });
});

test('non-GET method on / returns 404', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/`, { method: 'POST' });
    assert.equal(res.status, 404);
  });
});
