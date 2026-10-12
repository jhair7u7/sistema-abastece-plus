import { ArrowRight, ChevronRight, ReceiptText, ShoppingCart, Truck, X } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';

export default function CartBar() {
 const { units, total, clearCart }=useCart();
 const navigate=useNavigate(), location=useLocation();
 if(!units||['/checkout','/tienda/checkout','/pago','/tienda/pago'].includes(location.pathname))return null;
 return <aside className="cart-checkout-bar" aria-label="Resumen de tu compra">
  <div className="cart-checkout-info"><span className="cart-checkout-icon"><ShoppingCart size={32}/><b>{units}</b></span><div><strong>{units} {units===1?'producto':'productos'}</strong><span>Sigue comprando y aprovecha más ofertas</span></div><button aria-label="Seguir comprando en el catálogo" onClick={()=>navigate('/catalogo')}><ChevronRight/></button></div>
  <div className="cart-checkout-total"><span className="cart-checkout-icon"><ReceiptText size={30}/></span><div><span>Resumen de compra</span><strong>{total.toLocaleString('es-PE',{style:'currency',currency:'PEN'})}</strong></div></div>
  <div className="cart-checkout-actions"><div><button className="cart-checkout-cancel" onClick={clearCart}><X size={21}/>Cancelar compra</button><button className="cart-checkout-pay" onClick={()=>navigate('/checkout')}><ShoppingCart size={23}/>Proceder a pagar<ArrowRight size={23}/></button></div><small><Truck size={17}/>Entrega según la programación de tu pedido</small></div>
 </aside>;
}
