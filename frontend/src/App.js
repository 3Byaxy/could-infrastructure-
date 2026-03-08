import React, { useState, useEffect } from 'react';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || '';

function App() {
  const [items, setItems] = useState([]);
  const [status, setStatus] = useState('loading');
  const [newItem, setNewItem] = useState({ name: '', description: '' });
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      setStatus('loading');
      const response = await fetch(`${API_URL}/api/items`);
      if (!response.ok) throw new Error('Failed to fetch items');
      const data = await response.json();
      setItems(data.items);
      setStatus('loaded');
    } catch (err) {
      setError(err.message);
      setStatus('error');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!newItem.name.trim()) return;
    try {
      const response = await fetch(`${API_URL}/api/items`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newItem),
      });
      if (!response.ok) throw new Error('Failed to create item');
      const data = await response.json();
      setItems((prev) => [...prev, data.item]);
      setNewItem({ name: '', description: '' });
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>☁️ Cloud Infrastructure Dashboard</h1>
        <p className="subtitle">Terraform · Ansible · Kubernetes · Docker</p>
      </header>

      <main className="App-main">
        <section className="card">
          <h2>Add Item</h2>
          <form onSubmit={handleSubmit} className="form">
            <input
              type="text"
              placeholder="Item name"
              value={newItem.name}
              onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
              required
            />
            <input
              type="text"
              placeholder="Description (optional)"
              value={newItem.description}
              onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
            />
            <button type="submit">Add Item</button>
          </form>
        </section>

        <section className="card">
          <h2>Items</h2>
          {status === 'loading' && <p>Loading...</p>}
          {status === 'error' && <p className="error">Error: {error}</p>}
          {status === 'loaded' && items.length === 0 && <p>No items yet.</p>}
          <ul className="item-list">
            {items.map((item) => (
              <li key={item.id} className="item">
                <strong>{item.name}</strong>
                {item.description && <span> — {item.description}</span>}
              </li>
            ))}
          </ul>
        </section>
      </main>

      <footer className="App-footer">
        <p>Cloud Infrastructure Project &copy; {new Date().getFullYear()}</p>
      </footer>
    </div>
  );
}

export default App;
