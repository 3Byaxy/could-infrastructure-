export default function ItemList({ items, loading }) {
  if (loading) {
    return <p style={{ color: 'var(--color-muted)' }}>Loading items…</p>;
  }

  if (items.length === 0) {
    return (
      <p style={{ color: 'var(--color-muted)' }}>
        No items yet. Add your first item above!
      </p>
    );
  }

  return (
    <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '.75rem' }}>
      {items.map((item) => (
        <li
          key={item.id}
          style={{
            border: '1px solid var(--color-border)',
            borderRadius: 'var(--radius)',
            padding: '.75rem 1rem',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'flex-start',
          }}
        >
          <div>
            <strong>{item.name}</strong>
            {item.description && (
              <p style={{ color: 'var(--color-muted)', fontSize: '.9rem', marginTop: '.15rem' }}>
                {item.description}
              </p>
            )}
          </div>
          <span style={{ color: 'var(--color-muted)', fontSize: '.8rem', whiteSpace: 'nowrap', marginLeft: '1rem' }}>
            #{item.id}
          </span>
        </li>
      ))}
    </ul>
  );
}
