import { useState } from 'react';

export default function AddItemForm({ onAdd }) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setFormError('Name is required.');
      return;
    }
    try {
      setSubmitting(true);
      setFormError('');
      await onAdd(name.trim(), description.trim());
      setName('');
      setDescription('');
    } catch (err) {
      setFormError(`Failed to add item: ${err.message}`);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '.75rem' }}>
      {formError && (
        <p style={{ color: 'var(--color-danger)', fontSize: '.9rem' }}>{formError}</p>
      )}
      <div style={{ display: 'flex', gap: '.75rem', flexWrap: 'wrap' }}>
        <input
          type="text"
          placeholder="Item name *"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={inputStyle}
          disabled={submitting}
          aria-label="Item name"
        />
        <input
          type="text"
          placeholder="Description (optional)"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          style={{ ...inputStyle, flexGrow: 2 }}
          disabled={submitting}
          aria-label="Item description"
        />
        <button
          type="submit"
          disabled={submitting}
          style={buttonStyle}
        >
          {submitting ? 'Adding…' : 'Add Item'}
        </button>
      </div>
    </form>
  );
}

const inputStyle = {
  flexGrow: 1,
  padding: '.5rem .75rem',
  border: '1px solid var(--color-border)',
  borderRadius: 'var(--radius)',
  fontSize: '1rem',
  minWidth: 0,
};

const buttonStyle = {
  padding: '.5rem 1.25rem',
  background: 'var(--color-primary)',
  color: '#fff',
  border: 'none',
  borderRadius: 'var(--radius)',
  fontSize: '1rem',
  fontWeight: 600,
  cursor: 'pointer',
  whiteSpace: 'nowrap',
};
