import React, { useState, useEffect, useCallback } from 'react';
import './App.css';

const API_BASE = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [health, setHealth] = useState(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [formError, setFormError] = useState('');

  const fetchHealth = useCallback(async () => {
    try {
      const res = await fetch(`${API_BASE}/health`);
      const data = await res.json();
      setHealth(data.status === 'ok' ? 'ok' : 'error');
    } catch {
      setHealth('error');
    }
  }, []);

  const fetchItems = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/items`);
      const data = await res.json();
      setItems(data);
    } catch {
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchHealth();
    fetchItems();
  }, [fetchHealth, fetchItems]);

  const handleAdd = async (e) => {
    e.preventDefault();
    setFormError('');
    if (!name.trim()) {
      setFormError('Name is required.');
      return;
    }
    try {
      const res = await fetch(`${API_BASE}/items`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: name.trim(), description: description.trim() }),
      });
      if (!res.ok) {
        const err = await res.json();
        setFormError(err.error || 'Failed to add item.');
        return;
      }
      const newItem = await res.json();
      setItems((prev) => [...prev, newItem]);
      setName('');
      setDescription('');
    } catch {
      setFormError('Network error. Is the backend running?');
    }
  };

  const handleDelete = async (id) => {
    try {
      await fetch(`${API_BASE}/items/${id}`, { method: 'DELETE' });
      setItems((prev) => prev.filter((item) => item.id !== id));
    } catch {
      // ignore
    }
  };

  return (
    <div>
      <header className="app-header">
        <h1>☁️ Cloud Infrastructure Demo</h1>
        <p>Full-stack app: React frontend + Flask backend, deployed with Docker &amp; Kubernetes</p>
      </header>

      <main className="app-container">
        {/* API health status */}
        <div className="status-bar">
          <span className={`status-dot ${health === 'ok' ? 'ok' : health === 'error' ? 'error' : ''}`} />
          <span>
            Backend API:{' '}
            {health === null
              ? 'Checking…'
              : health === 'ok'
              ? '✅ Connected'
              : '❌ Unreachable — make sure the backend is running'}
          </span>
        </div>

        {/* Add item form */}
        <section className="add-form">
          <h2>Add Cloud Resource</h2>
          <form onSubmit={handleAdd}>
            <div className="form-row">
              <input
                type="text"
                placeholder="Resource name *"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
              <input
                type="text"
                placeholder="Description (optional)"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
              <button type="submit" className="btn btn-primary">Add</button>
            </div>
            {formError && <p className="error-msg">{formError}</p>}
          </form>
        </section>

        {/* Items list */}
        <section className="items-section">
          <h2>Cloud Resources ({items.length})</h2>
          {loading ? (
            <div className="loading">Loading resources…</div>
          ) : items.length === 0 ? (
            <div className="empty-state">No resources yet. Add one above!</div>
          ) : (
            <div className="items-grid">
              {items.map((item) => (
                <div key={item.id} className="item-card">
                  <h3>{item.name}</h3>
                  <p>{item.description || <em>No description</em>}</p>
                  <div className="card-footer">
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDelete(item.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;
