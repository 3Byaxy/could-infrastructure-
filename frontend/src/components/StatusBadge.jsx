const STATUS_CONFIG = {
  ok: { label: 'Healthy', bg: '#dcfce7', color: '#15803d' },
  error: { label: 'Error', bg: '#fee2e2', color: '#b91c1c' },
  degraded: { label: 'Degraded', bg: '#fef9c3', color: '#a16207' },
};

export default function StatusBadge({ status }) {
  const config = STATUS_CONFIG[status] ?? STATUS_CONFIG.error;
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '.35rem',
        background: config.bg,
        color: config.color,
        borderRadius: 99,
        padding: '.25rem .85rem',
        fontWeight: 700,
        fontSize: '.9rem',
      }}
      aria-label={`API status: ${config.label}`}
    >
      <span style={{ fontSize: '.55rem' }}>●</span>
      {config.label}
    </span>
  );
}
