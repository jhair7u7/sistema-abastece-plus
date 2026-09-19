import { CreditCard, CheckCircle, ShoppingCart } from "lucide-react";
import { useState } from "react";
import { useCart } from "../context/CartContext";

export default function Pago() {
  const { total, clearCart } = useCart();

  const [status, setStatus] = useState("form");

  function pagar(e) {
    e.preventDefault();

    setStatus("loading");

    setTimeout(() => {
      clearCart();

      setStatus("success");
    }, 3000);
  }

  if (status === "loading") {
    return (
      <main className="payment-page">
        <div className="payment-animation">
          <div className="loader-circle"></div>

          <h1>Verificando compra...</h1>

          <p>Estamos validando los datos de tu pago</p>

          <div className="payment-steps">
            <span className="active">✓ Datos recibidos</span>

            <span>✓ Validando tarjeta</span>

            <span>✓ Confirmando operación</span>
          </div>
        </div>
      </main>
    );
  }

  if (status === "success") {
    return (
      <main className="payment-page">
        <div className="payment-success-animation">
          <div className="success-circle">
            <CheckCircle size={65} />
          </div>

          <h1>¡Pago exitoso!</h1>

          <p>Tu compra fue procesada correctamente.</p>

          <div className="order-message">🛒 Pedido generado correctamente</div>

          <button onClick={() => (window.location.href = "/catalogo")}>
            Continuar comprando
          </button>
        </div>
      </main>
    );
  }

  return (
    <main className="payment-page">
      <form className="payment-card" onSubmit={pagar}>
        <div className="payment-header">
          <CreditCard size={35} />

          <h1>Método de pago</h1>
        </div>

        <select>
          <option>Tarjeta débito/crédito</option>
        </select>

        <input required placeholder="Número de tarjeta" />

        <input required placeholder="Nombre del titular" />

        <div className="payment-row">
          <input required placeholder="MM/AA" />

          <input required placeholder="CVV" />
        </div>

        <div className="payment-total">
          <span>Total:</span>

          <strong>S/ {total.toFixed(2)}</strong>
        </div>

        <button>
          <ShoppingCart size={18} />
          Pagar compra
        </button>
      </form>
    </main>
  );
}
