export const money = (value) => `S/ ${Number(value || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
export const numberOf = (row) => `${row.serie}-${String(row.numero).padStart(6, '0')}`;
export const typeOf = (row) => row.tipo_comprobante === 'BOLETA_ELECTRONICA' ? 'Boleta' : 'Factura';
export const paymentNames = { YAPE: 'Yape', EFECTIVO: 'Efectivo', TARJETA: 'Tarjeta' };
export const dateOf = (value) => {
  const [date, time = ''] = String(value || '').split(' ');
  const parts = date.split('-');
  return parts.length === 3 ? `${parts[2]}/${parts[1]}/${parts[0]} ${time.slice(0, 5)}` : '—';
};

export function filterReceipts(rows, { type, range, query, from, to }, today = new Date()) {
  const localDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const dayString = (date) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  let start = '', end = '';
  if (range === 'today') start = end = dayString(localDay);
  if (range === '7' || range === '30') {
    end = dayString(localDay);
    localDay.setDate(localDay.getDate() - Number(range) + 1);
    start = dayString(localDay);
  }
  if (range === 'month') {
    start = dayString(new Date(today.getFullYear(), today.getMonth(), 1));
    end = dayString(new Date(today.getFullYear(), today.getMonth() + 1, 0));
  }
  if (range === 'custom') { start = from; end = to; }
  const term = query.trim().toLowerCase();
  return rows.filter((row) => {
    const date = String(row.fecha_emision).slice(0, 10);
    return (!type || row.tipo_comprobante === type) && (!start || date >= start) && (!end || date <= end)
      && (!term || `${numberOf(row)} ${row.compra}`.toLowerCase().includes(term));
  });
}
