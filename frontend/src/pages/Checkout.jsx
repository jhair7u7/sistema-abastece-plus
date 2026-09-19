import { ShoppingCart, PackageCheck } from "lucide-react";
import { useCart } from "../context/CartContext";
import { useNavigate } from "react-router-dom";

export default function Checkout() {
  const { cart, total } = useCart();

  const navigate = useNavigate();

  return (
    <main className="checkout-page">
      <div className="checkout-container">
        <div className="checkout-title">
          <PackageCheck size={34} />

          <h1>Resumen del pedido</h1>
        </div>

        <div className="checkout-card">
          {cart.map((item) => (
            <div className="checkout-product" key={item.producto_id}>
              <div>
                <h3>{item.nombre}</h3>

                <p>Cantidad: {item.cantidad}</p>
              </div>

              <strong>
                S/
                {(item.precio_base_sugerido * item.cantidad).toFixed(2)}
              </strong>
            </div>
          ))}

          <div className="checkout-total">
            <span>Total:</span>

            <strong>S/ {total.toFixed(2)}</strong>
          </div>

          <button
            className="continue-payment"
            onClick={() => navigate("/pago")}
          >
            <ShoppingCart size={20} />
            Continuar pago
          </button>
        </div>
      </div>
    </main>
  );
}
