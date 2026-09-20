import { ArrowRight, PackageCheck, ShieldCheck, Truck } from "lucide-react";
import { useCart } from "../context/CartContext";
import { useNavigate } from "react-router-dom";

export default function Checkout() {
  const { cart, total, units } = useCart();
  const navigate = useNavigate();
  const subtotal = total / 1.18;
  return <main className="checkout-page"><div className="checkout-container checkout-container--wide">
    <div className="checkout-title"><PackageCheck size={34}/><div><small>ÚLTIMO PASO ANTES DEL PAGO</small><h1>Resumen del pedido</h1></div></div>
    <div className="checkout-layout"><section className="checkout-card checkout-items-card"><div className="checkout-section-head"><h2>{units} unidades en tu pedido</h2><span>Precios mayoristas</span></div>
      {cart.map(item=><article className="checkout-product checkout-product--rich" key={item.producto_id}><img src={item.imagen_url||"/logo.png"} alt={item.nombre}/><div><small>{item.marca}</small><h3>{item.nombre}</h3><p>{item.cantidad} × S/ {Number(item.precio_base_sugerido).toFixed(2)}</p><em>{item.unidad_medida}</em></div><strong>S/ {(item.precio_base_sugerido*item.cantidad).toFixed(2)}</strong></article>)}
    </section><aside className="checkout-card checkout-summary-card"><h2>Detalle del pago</h2><div><span>Subtotal</span><b>S/ {subtotal.toFixed(2)}</b></div><div><span>IGV (18%)</span><b>S/ {(total-subtotal).toFixed(2)}</b></div><div><span>Entrega</span><b className="free-label">Incluida</b></div><div className="checkout-total"><span>Total</span><strong>S/ {total.toFixed(2)}</strong></div><button className="continue-payment" disabled={!cart.length} onClick={()=>navigate("/tienda/pago")}>Continuar al pago <ArrowRight size={19}/></button><p className="checkout-trust"><ShieldCheck size={17}/> Entorno de demostración, sin cobros reales</p><p className="checkout-trust"><Truck size={17}/> Entrega en la dirección principal registrada</p></aside></div>
  </div></main>;
}
