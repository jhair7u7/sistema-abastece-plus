import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Login({ internal = false }) {
  const [form, setForm] = useState({
    usuario: "",
    password: "",
    tipo: internal ? "interno" : "bodeguero",
  });
  const [state, setState] = useState({ loading: false, error: "" });
  const { login } = useAuth();
  const navigate = useNavigate();
  const submit = async (e) => {
    e.preventDefault();
    setState({ loading: true, error: "" });
    try {
      const session = await login({
        ...form,
        tipo: internal ? "interno" : "bodeguero",
      });
      navigate(session.type === "interno" ? "/admin" : "/tienda");
    } catch (error) {
      setState({ loading: false, error: error.message });
    }
  };
  return (
    <main className={`auth-page ${internal ? "auth-page--internal" : ""}`}>
      {internal && (
        <div className="internal-login-brand">
          <img
            src="/logo.png"
            alt="Abastece+"
            className="internal-login-logo"
          />
          <small>Portal interno</small>
        </div>
      )}
      <div className={`auth-shell ${internal ? "auth-shell--internal" : ""}`}>
        <aside
          className={`auth-aside ${internal ? "auth-aside--internal" : ""}`}
        >
          <div>
            <h1>
              {internal
                ? "Gestión interna de Abastece+"
                : "Todo tu negocio, en un solo lugar."}
            </h1>
            <p>
              {internal
                ? "Acceso reservado para el equipo autorizado. Cada colaborador verá únicamente las herramientas de su rol."
                : "Compra para tu tienda y administra tus pedidos desde un solo lugar."}
            </p>
          </div>
          <div className="auth-points">
            <div className="auth-point">
              <span>✓</span>{" "}
              {internal ? "Acceso controlado por rol" : "Compras mayoristas"}
            </div>
            <div className="auth-point">
              <span>✓</span>{" "}
              {internal ? "Operación centralizada" : "Catálogo para tu negocio"}
            </div>
            <div className="auth-point">
              <span>✓</span>{" "}
              {internal
                ? "Sesión exclusiva para colaboradores"
                : "Información centralizada"}
            </div>
          </div>
        </aside>
        <section className="auth-card">
          <div className="auth-card-header">
            <h2>{internal ? "Iniciar sesión" : "Bienvenido"}</h2>
            <p>
              {internal ? "Acceso de colaboradores" : "Acceso de comerciantes"}
            </p>
          </div>
          <form className="auth-form" onSubmit={submit}>
            <label className="form-field full">
              <span>Correo</span>
              <input
                type="email"
                required
                value={form.usuario}
                onChange={(e) => setForm({ ...form, usuario: e.target.value })}
              />
            </label>
            <label className="form-field full">
              <span>Contraseña</span>
              <input
                type="password"
                required
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
              />
            </label>
            {state.error && (
              <div className="form-message error">{state.error}</div>
            )}
            <button className="form-submit" disabled={state.loading}>
              {state.loading
                ? "Ingresando..."
                : internal
                  ? "Ingresar al portal interno"
                  : "Ingresar a mi cuenta"}
            </button>
          </form>
          {!internal && (
            <p className="auth-switch">
              ¿Aún no estás afiliado?{" "}
              <Link to="/registro">Registra tu bodega</Link>
            </p>
          )}
        </section>
      </div>
    </main>
  );
}
