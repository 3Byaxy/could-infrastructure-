const request = require('supertest');
const app = require('../src/index');

describe('Health endpoint', () => {
  it('GET /health returns 200', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('Items API', () => {
  it('GET /api/items returns empty array initially', async () => {
    const res = await request(app).get('/api/items');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('POST /api/items creates an item', async () => {
    const res = await request(app)
      .post('/api/items')
      .send({ name: 'Test Item', description: 'A test item' });
    expect(res.status).toBe(201);
    expect(res.body.data.name).toBe('Test Item');
    expect(res.body.data.id).toBeDefined();
  });

  it('POST /api/items returns 400 without name', async () => {
    const res = await request(app).post('/api/items').send({});
    expect(res.status).toBe(400);
  });

  it('GET /api/items/:id returns 404 for unknown id', async () => {
    const res = await request(app).get('/api/items/99999');
    expect(res.status).toBe(404);
  });
});

describe('Unknown routes', () => {
  it('returns 404 for unknown routes', async () => {
    const res = await request(app).get('/unknown-route');
    expect(res.status).toBe(404);
  });
});
