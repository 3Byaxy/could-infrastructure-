require('dotenv').config();

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { version } = require('../package.json');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ───────────────────────────────────────────────────────────────

app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// ─── Routes ───────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version,
    environment: process.env.NODE_ENV || 'development',
  });
});

app.get('/api', (_req, res) => {
  res.json({
    message: 'Cloud Infrastructure API',
    version: '1.0.0',
    endpoints: [
      'GET  /health       – Health check',
      'GET  /api          – API info',
      'GET  /api/items    – List items',
      'POST /api/items    – Create item',
      'GET  /api/items/:id – Get item by ID',
    ],
  });
});

// In-memory store (replace with a real DB via pg in production)
const items = [];
let nextId = 1;

app.get('/api/items', (_req, res) => {
  res.json({ data: items, total: items.length });
});

app.post('/api/items', (req, res) => {
  const { name, description } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'name is required' });
  }
  const item = {
    id: nextId++,
    name,
    description: description || '',
    createdAt: new Date().toISOString(),
  };
  items.push(item);
  return res.status(201).json({ data: item });
});

app.get('/api/items/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const item = items.find((i) => i.id === id);
  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }
  return res.json({ data: item });
});

// ─── 404 & Error Handlers ─────────────────────────────────────────────────────

app.use((_req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

// ─── Start ────────────────────────────────────────────────────────────────────

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Backend API listening on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;
