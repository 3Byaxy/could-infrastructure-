import { useState, useEffect, useCallback } from 'react';
import ItemList from './components/ItemList.jsx';
import AddItemForm from './components/AddItemForm.jsx';
import StatusBadge from './components/StatusBadge.jsx';

const API_BASE = '/api';

export default function App() {
  const [items, setItems] = useState([]);
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchHealth = useCallback(async () => {
    try {
      const res = await fetch('/health');
      const data = await res.json();
      setHealth(data);
    } catch {
      setHealth({ status: 'error' });
    }
  }, []);

  const fetchItems = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await fetch(`${API_BASE}/items`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setItems(data.data ?? []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchHealth();
    fetchItems();
    const interval = setInterval(fetchHealth, 30000);
    return () => clearInterval(interval);
  }, [fetchHealth, fetchItems]);

  const handleAdd = async (name, description) => {
    const res = await fetch(`${API_BASE}/items`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, description }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    await fetchItems();
  };

  return (
    <div style={{ maxWidth: 900, margin: '0 auto', padding: '2rem 1rem' }}>
      <header style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '1.75rem', fontWeight: 700, marginBottom: '.25rem' }}>
          ☁️ Cloud Infrastructure Dashboard
        </h1>
        <p style={{ color: 'var(--color-muted)' }}>
          Manage your cloud resources and monitor API health.
        </p>
      </header>

      <section style={cardStyle}>
        <h2 style={sectionTitle}>API Status</h2>
        {health ? (
          <div style={{ display: 'flex', gap: '1.5rem', alignItems: 'center', flexWrap: 'wrap' }}>
            <StatusBadge status={health.status} />
            {health.timestamp && (
              <span style={{ color: 'var(--color-muted)', fontSize: '.9rem' }}>
                Last checked: {new Date(health.timestamp).toLocaleTimeString()}
              </span>
            )}
            {health.environment && (
              <span style={pillStyle}>{health.environment}</span>
            )}
          </div>
        ) : (
          <span style={{ color: 'var(--color-muted)' }}>Checking…</span>
        )}
      </section>

      <section style={cardStyle}>
        <h2 style={sectionTitle}>Add Item</h2>
        <AddItemForm onAdd={handleAdd} />
      </section>

      <section style={cardStyle}>
        <h2 style={sectionTitle}>Items ({items.length})</h2>
        {error && (
          <p style={{ color: 'var(--color-danger)', marginBottom: '.75rem' }}>
            Error loading items: {error}
          </p>
        )}
        <ItemList items={items} loading={loading} />
      </section>
    </div>
  );
}

const cardStyle = {
  background: 'var(--color-surface)',
  borderRadius: 'var(--radius)',
  boxShadow: 'var(--shadow)',
  padding: '1.25rem 1.5rem',
  marginBottom: '1.5rem',
};

const sectionTitle = {
  fontSize: '1.1rem',
  fontWeight: 600,
  marginBottom: '1rem',
  paddingBottom: '.5rem',
  borderBottom: '1px solid var(--color-border)',
};

const pillStyle = {
  background: '#dbeafe',
  color: '#1d4ed8',
  borderRadius: 99,
  padding: '.2rem .75rem',
  fontSize: '.8rem',
  fontWeight: 600,
};
