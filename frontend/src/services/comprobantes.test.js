import test from 'node:test';
import assert from 'node:assert/strict';
import { dateOf, filterReceipts, money, numberOf } from './comprobantes.js';
import { buildReceiptPdf } from './comprobantePdf.js';

const rows = [
  { serie: 'F001', numero: '1', tipo_comprobante: 'FACTURA_ELECTRONICA', compra: 'COM-2026-0001', fecha_emision: '2026-10-09 12:05:00' },
  { serie: 'B001', numero: '2', tipo_comprobante: 'BOLETA_ELECTRONICA', compra: 'COM-2026-0002', fecha_emision: '2026-10-03 08:00:00' },
  { serie: 'F001', numero: '3', tipo_comprobante: 'FACTURA_ELECTRONICA', compra: 'COM-2026-0003', fecha_emision: '2026-10-02 23:59:59' },
  { serie: 'F001', numero: '4', tipo_comprobante: 'FACTURA_ELECTRONICA', compra: 'COM-2026-0004', fecha_emision: '2026-09-30 12:00:00' },
];
const defaults = { type: '', range: '', query: '', from: '', to: '' };
const today = new Date(2026, 9, 9, 12);
const filter = (values) => filterReceipts(rows, { ...defaults, ...values }, today);

test('comprobante, moneda y fecha conservan el formato de la referencia', () => {
  assert.equal(numberOf(rows[0]), 'F001-000001');
  assert.equal(money(1156), 'S/ 1,156.00');
  assert.equal(dateOf(rows[0].fecha_emision), '09/10/2026 12:05');
});
test('búsqueda por comprobante y compra combina el filtro de tipo', () => {
  assert.deepEqual(filter({ query: ' f001-000001 ' }), [rows[0]]);
  assert.deepEqual(filter({ query: 'com-2026-0002', type: 'BOLETA_ELECTRONICA' }), [rows[1]]);
  assert.deepEqual(filter({ query: 'com-2026-0002', type: 'FACTURA_ELECTRONICA' }), []);
});
test('rangos de fechas incluyen ambos extremos sin desfase de zona horaria', () => {
  assert.deepEqual(filter({ range: 'today' }), [rows[0]]);
  assert.deepEqual(filter({ range: '7' }), rows.slice(0, 2));
  assert.deepEqual(filter({ range: 'month' }), rows.slice(0, 3));
  assert.deepEqual(filter({ range: 'custom', from: '2026-10-02', to: '2026-10-03' }), rows.slice(1, 3));
  assert.deepEqual(filter({ range: 'custom', from: '2026-10-09', to: '2026-10-01' }), []);
});

const receipt = {
  ...rows[0], emisor_nombre: 'Abastece+ S.A.C.', ruc_emisor: '00000000999',
  emisor_direccion: 'Lima, Peru', cliente_nombre: 'Demo bodegueros 1',
  ruc_receptor: '00000000001', cliente_direccion: 'Rimac, Lima',
  subtotal: 979.66, igv: 176.34, total: 1156, costo_envio: 0,
  metodo_pago: 'YAPE', codigo_operacion: 'YAPE-OP-98341209',
  productos: [{ descripcion: 'Aceite Primor Premium', cantidad: 4, precio_unitario: 128, importe: 512 }],
};
test('PDF contiene datos de cliente, productos, importes y operación', async () => {
  const pdf = await buildReceiptPdf(receipt);
  const contents = pdf.output();
  for (const value of ['F001-000001', 'Demo bodegueros 1', 'Aceite Primor Premium', '979.66', '176.34', '1,156.00', 'YAPE-OP-98341209']) assert.ok(contents.includes(value), value);
  assert.equal(pdf.getNumberOfPages(), 1);
});
test('PDF pagina documentos largos y conserva el último producto y los totales', async () => {
  const pdf = await buildReceiptPdf({ ...receipt, productos: Array.from({ length: 140 }, (_, i) => ({ ...receipt.productos[0], descripcion: `Producto ${i + 1}` })) });
  assert.ok(pdf.getNumberOfPages() > 2);
  assert.ok(pdf.output().includes('Producto 140'));
  assert.ok(pdf.output().includes('1,156.00'));
});
