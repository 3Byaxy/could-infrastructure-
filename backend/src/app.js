const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.get('/api', (req, res) => {
  res.json({ message: 'Cloud Infrastructure API', version: '1.0.0' });
});

app.get('/api/items', (req, res) => {
  const items = [
    { id: 1, name: 'Item One', description: 'First example item' },
    { id: 2, name: 'Item Two', description: 'Second example item' },
    { id: 3, name: 'Item Three', description: 'Third example item' },
  ];
  res.json({ items });
});

app.post('/api/items', (req, res) => {
  const { name, description } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'Name is required' });
  }
  const newItem = { id: Date.now(), name, description: description || '' };
  res.status(201).json({ item: newItem });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
