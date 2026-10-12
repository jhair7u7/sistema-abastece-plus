import { useEffect } from 'react';
import { createPortal } from 'react-dom';
import { Link } from 'react-router-dom';
import { CalendarDays, Check, CreditCard, Headphones, MapPin, Package, ReceiptText, Truck, UserRound, X } from 'lucide-react';

const money = value => Number(value || 0).toLocaleString('es-PE', { style: 'currency', currency: 'PEN' });
const stages = ['ASIGNADO', 'EN_TRAYECTO', 'ENTREGADO'];
const stageLabels = ['Asignado', 'En trayecto', 'Entregado'];

export default function OrderModal({ order, close }) {
  useEffect(() => {
    const overflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    const keydown = event => { if (event.key === 'Escape') close(); };
    document.addEventListener('keydown', keydown);
    return () => { document.body.style.overflow = overflow; document.removeEventListener('keydown', keydown); };
  }, [close]);
  const failed = order.estado_entrega === 'FALLIDO';
  const activeIndex = failed ? 1 : stages.indexOf(order.estado_entrega);
  const status = order.estado_entrega || order.estado_pedido || 'PENDIENTE';
  const icons = [Package, Truck, Check];
  const metadata = [
    [UserRound, 'Comprador', order.comprador],
    [CalendarDays, 'Fecha y hora', new Date(order.fecha_compra).toLocaleString('es-PE')],
    [MapPin, 'Dirección de entrega', [order.direccion_exacta, order.distrito].filter(Boolean).join(', ') || 'Sin dirección registrada'],
    [CreditCard, 'Método de pago', order.metodo_pago || 'Sin registrar'],
  ];
  return createPortal(
    <div className="purchase-backdrop" onClick={event => { if (event.target === event.currentTarget) close(); }}>
      <section className="purchase-modal" role="dialog" aria-modal="true" aria-labelledby="purchase-title" tabIndex={-1} ref={node => node?.focus()}>
        <header className="purchase-header">
          <span className="purchase-heading-icon"><ReceiptText size={27}/></span>
          <div><span className="eyebrow">DETALLE DE COMPRA</span><h2 id="purchase-title">{order.codigo_compra}</h2><p>Información de tu pedido y sus productos.</p></div>
          <button autoFocus className="purchase-close" onClick={close} aria-label="Cerrar detalle de compra"><X size={21}/></button>
        </header>
        <div className="purchase-body">
          <div className="purchase-section-title"><h3><Package size={20}/>Resumen del pedido</h3><span className={`purchase-status ${status === 'ENTREGADO' ? 'delivered' : status === 'CANCELADO' || failed ? 'cancelled' : ''}`}>{status.replaceAll('_', ' ')}</span></div>
          <div className="purchase-meta">{metadata.map(([Icon, label, value]) => <div key={label}><span className="purchase-meta-icon"><Icon size={20}/></span><div><small>{label}</small><strong>{value || 'Sin registrar'}</strong></div></div>)}</div>
          <div className="purchase-timeline" aria-label="Seguimiento de entrega">{stages.map((step, index) => { const Icon = icons[index]; return <div key={step} className={activeIndex >= index ? 'done' : ''}><span><Icon size={19}/></span><strong>{stageLabels[index]}</strong></div>; })}</div>
          {failed && <p className="purchase-alert">La entrega requiere atención. Puedes reportar una incidencia.</p>}
          <div className="purchase-section-title"><h3><Package size={20}/>Productos de tu compra</h3><span className="purchase-count">{order.items.length} productos</span></div>
          <div className="purchase-products">{order.items.map((item, index) => <article key={item.detalle_compra_id || index}><div className="purchase-product-image"><img src={item.imagen_url || '/logo.png'} alt=""/></div><div><strong>{item.nombre}</strong><small>{item.cantidad} × {money(item.precio_unitario)}</small></div><b>{money(item.total_linea)}</b></article>)}</div>
          <div className="purchase-totals"><div><span>Subtotal</span><strong>{money(order.subtotal)}</strong></div><div><span>IGV (18%)</span><strong>{money(order.igv)}</strong></div><div className="purchase-grand-total"><span>Total de tu compra</span><strong>{money(order.total)}</strong></div></div>
        </div>
        <footer className="purchase-footer"><button className="merchant-button muted" onClick={close}>Cerrar</button><Link className="merchant-button primary" onClick={close} to={`/tienda?vista=incidencias&compra=${order.compra_id}`}><Headphones size={18}/>Reportar incidencia</Link></footer>
      </section>
    </div>, document.body
  );
}
