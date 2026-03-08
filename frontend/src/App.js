import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || '';

function App() {
  const [info, setInfo] = useState(null);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [infoRes, itemsRes] = await Promise.all([
          axios.get(`${API_URL}/api/v1/info`),
          axios.get(`${API_URL}/api/v1/items`),
        ]);
        setInfo(infoRes.data);
        setItems(itemsRes.data.items);
      } catch (err) {
        setError('Failed to connect to backend. Please check your configuration.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>☁️ Cloud Infrastructure Dashboard</h1>
      </header>

      <main style={styles.main}>
        {loading && <p style={styles.loading}>Loading...</p>}

        {error && (
          <div style={styles.errorBox}>
            <strong>Error:</strong> {error}
          </div>
        )}

        {info && (
          <section style={styles.card}>
            <h2>Application Info</h2>
            <table style={styles.table}>
              <tbody>
                <tr>
                  <td style={styles.label}>App</td>
                  <td>{info.app}</td>
                </tr>
                <tr>
                  <td style={styles.label}>Version</td>
                  <td>{info.version}</td>
                </tr>
                <tr>
                  <td style={styles.label}>Environment</td>
                  <td>
                    <span style={{
                      ...styles.badge,
                      backgroundColor: info.environment === 'production' ? '#28a745' : '#007bff',
                    }}>
                      {info.environment}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </section>
        )}

        {items.length > 0 && (
          <section style={styles.card}>
            <h2>Items</h2>
            <ul style={styles.list}>
              {items.map((item) => (
                <li key={item.id} style={styles.listItem}>
                  <strong>{item.name}</strong>: {item.description}
                </li>
              ))}
            </ul>
          </section>
        )}
      </main>

      <footer style={styles.footer}>
        <p>Cloud Infrastructure © {new Date().getFullYear()}</p>
      </footer>
    </div>
  );
}

const styles = {
  container: { fontFamily: 'sans-serif', maxWidth: '900px', margin: '0 auto', padding: '0 20px' },
  header: { backgroundColor: '#1a1a2e', color: '#fff', padding: '20px', borderRadius: '8px', marginTop: '20px' },
  title: { margin: 0, fontSize: '1.8rem' },
  main: { marginTop: '20px' },
  loading: { textAlign: 'center', color: '#666', fontSize: '1.2rem' },
  errorBox: { backgroundColor: '#f8d7da', color: '#721c24', padding: '12px 16px', borderRadius: '6px', border: '1px solid #f5c6cb' },
  card: { backgroundColor: '#fff', border: '1px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' },
  table: { width: '100%', borderCollapse: 'collapse' },
  label: { color: '#666', fontWeight: 'bold', paddingRight: '16px', paddingBottom: '8px' },
  badge: { color: '#fff', padding: '2px 10px', borderRadius: '12px', fontSize: '0.85rem' },
  list: { paddingLeft: '20px' },
  listItem: { marginBottom: '8px' },
  footer: { textAlign: 'center', color: '#888', padding: '20px 0', borderTop: '1px solid #eee', marginTop: '20px' },
};

export default App;
