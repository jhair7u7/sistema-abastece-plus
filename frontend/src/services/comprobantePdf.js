import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { money, numberOf, typeOf, dateOf, paymentNames } from './comprobantes.js';

export async function buildReceiptPdf(row) {
  const pdf = new jsPDF();
  const title = `${typeOf(row)} electrónica`;
  const notice = 'Documento de demostración — no válido como comprobante tributario.';
  let logo;
  try {
    const response = await fetch('/logo.png');
    if (response.ok) {
      const blob = await response.blob();
      logo = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      });
    }
  } catch { /* El PDF sigue disponible si el logo no carga. */ }
  if (logo) pdf.addImage(logo, 'PNG', 14, 13, 38, 13);
  pdf.setTextColor(37, 20, 103);
  pdf.setFont('helvetica', 'bold');
  pdf.setFontSize(15);
  pdf.text(title.toUpperCase(), 196, 19, { align: 'right' });
  pdf.setFontSize(12);
  pdf.text(numberOf(row), 196, 26, { align: 'right' });
  pdf.setFont('helvetica', 'normal');
  pdf.setTextColor(52, 65, 85);
  pdf.setFontSize(9);
  pdf.text(`Fecha de emisión: ${dateOf(row.fecha_emision)} | Moneda: PEN`, 14, 36);
  pdf.text(notice.replace('—', '-'), 14, 43);
  autoTable(pdf, {
    startY: 49, head: [['EMISOR', 'CLIENTE']],
    body: [[`${row.emisor_nombre}\nRUC: ${row.ruc_emisor}\n${row.emisor_direccion || 'Dirección no registrada'}`, `${row.cliente_nombre}\nRUC: ${row.ruc_receptor}\n${row.cliente_direccion}`]],
    theme: 'grid', styles: { fontSize: 9, cellPadding: 4 }, headStyles: { fillColor: [245, 247, 252], textColor: [44, 61, 95] },
  });
  autoTable(pdf, {
    startY: pdf.lastAutoTable.finalY + 8,
    head: [['N.°', 'DESCRIPCIÓN', 'CANT.', 'P. UNIT. (S/)', 'IMPORTE (S/)']],
    body: row.productos.map((p, i) => [i + 1, p.descripcion, p.cantidad, money(p.precio_unitario), money(p.importe)]),
    theme: 'striped', styles: { fontSize: 9, cellPadding: 3 }, headStyles: { fillColor: [244, 247, 251], textColor: [44, 61, 95] },
    columnStyles: { 2: { halign: 'center' }, 3: { halign: 'right' }, 4: { halign: 'right' } },
  });
  autoTable(pdf, {
    startY: pdf.lastAutoTable.finalY + 3, margin: { left: 122 }, theme: 'plain',
    body: [['Subtotal', money(row.subtotal)], ['IGV (18%)', money(row.igv)], ...(Number(row.costo_envio) ? [['Envío', money(row.costo_envio)]] : []), ['TOTAL', money(row.total)]],
    styles: { fontSize: 9 }, columnStyles: { 1: { halign: 'right' } },
    didParseCell: (data) => {
      if (data.row.index === data.table.body.length - 1) {
        data.cell.styles.fillColor = [37, 20, 103];
        data.cell.styles.textColor = [255, 255, 255];
        data.cell.styles.fontStyle = 'bold';
      }
    },
  });
  autoTable(pdf, {
    startY: pdf.lastAutoTable.finalY + 7, theme: 'grid', head: [['INFORMACIÓN DE PAGO', 'CÓDIGO DE OPERACIÓN', 'COMPRA']],
    body: [[paymentNames[row.metodo_pago] || row.metodo_pago, row.codigo_operacion, row.compra]],
    styles: { fontSize: 8, cellPadding: 3 }, headStyles: { fillColor: [244, 247, 251], textColor: [44, 61, 95] },
  });
  for (let page = 1; page <= pdf.getNumberOfPages(); page++) {
    pdf.setPage(page);
    pdf.setFontSize(7);
    pdf.setTextColor(90, 105, 125);
    pdf.text(notice.replace('—', '-'), 14, 288);
    pdf.text(`${page} / ${pdf.getNumberOfPages()}`, 196, 288, { align: 'right' });
  }
  return pdf;
}

export async function downloadReceipt(row) {
  const pdf = await buildReceiptPdf(row);
  const url = URL.createObjectURL(pdf.output('blob'));
  const link = document.createElement('a');
  link.href = url;
  link.download = `${numberOf(row)}.pdf`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  // La descarga necesita que el Blob siga disponible mientras el navegador lo lee.
  window.setTimeout(() => URL.revokeObjectURL(url), 30000);
}
