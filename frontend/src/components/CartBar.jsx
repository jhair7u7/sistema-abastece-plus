import { ShoppingCart, X } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useCart } from "../context/CartContext";

export default function CartBar() {
  const { units, total, clearCart } = useCart();

  const navigate = useNavigate();

  if (units === 0) return null;

  return (
    <div className="cart-floating">
      <div className="cart-info">
        <ShoppingCart size={26} />

        <strong>{units} productos</strong>
      </div>

      <div className="cart-total">
        <span>Total:</span>

        <b>S/ {total.toFixed(2)}</b>
      </div>

      <div className="cart-actions">
        <button className="cancel-cart" onClick={clearCart}>
          <X size={18} />

          <span>Cancelar compra</span>
        </button>

        <button className="pay-cart" onClick={() => navigate("/checkout")}>
          <ShoppingCart size={18} />

          <span>Proceder a pagar</span>
        </button>
      </div>
    </div>
  );
}
