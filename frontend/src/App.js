import React, { useState, useEffect } from 'react';
import './App.css';

// Example component that demonstrates basic React patterns and can connect to a backend API
function App() {
  const [status, setStatus] = useState('Loading...');
  const [apiData, setApiData] = useState(null);

  // The backend API URL can be configured via environment variable
  // For local development: REACT_APP_API_URL=http://localhost:5000
  // For production: set REACT_APP_API_URL to your deployed backend URL
  const API_URL = process.env.REACT_APP_API_URL || '';

  useEffect(() => {
    if (API_URL) {
      fetch(`${API_URL}/health`)
        .then((res) => res.json())
        .then((data) => {
          setStatus('Connected to backend');
          setApiData(data);
        })
        .catch(() => {
          setStatus('Backend not reachable — running in standalone mode');
        });
    } else {
      setStatus('Running in standalone mode (no backend configured)');
    }
  }, [API_URL]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Cloud Infrastructure Frontend</h1>
        <p className="App-subtitle">A React application ready for cloud deployment</p>
      </header>

      <main className="App-main">
        <section className="status-card">
          <h2>Backend Status</h2>
          <p className="status-text">{status}</p>
          {apiData && (
            <pre className="api-response">{JSON.stringify(apiData, null, 2)}</pre>
          )}
        </section>

        <section className="info-card">
          <h2>Getting Started</h2>
          <ul>
            <li>Edit <code>src/App.js</code> to modify this page.</li>
            <li>Set <code>REACT_APP_API_URL</code> to connect to a backend service.</li>
            <li>Run <code>npm start</code> to develop locally.</li>
            <li>Run <code>npm run build</code> to create a production build.</li>
            <li>Use the provided <code>Dockerfile</code> to containerise the app.</li>
          </ul>
        </section>
      </main>
    </div>
  );
}

export default App;
