import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Login() {
  const [form, setForm] = useState({
    usuario: "",
    password: "",
    tipo: "bodeguero",
  });
  const [state, setState] = useState({ loading: false, error: "" });
  const { login } = useAuth();
  const navigate = useNavigate();
  const submit = async (e) => {
    e.preventDefault();
    setState({ loading: true, error: "" });
    try {
      const session = await login(form);
      navigate(session.type === "interno" ? "/admin" : "/mi-negocio");
    } catch (error) {
      setState({ loading: false, error: error.message });
    }
  };
  return (
    <main className="auth-page">
      <div className="auth-shell">
        <aside className="auth-aside">
          <div>
            <h1>Todo tu negocio, en un solo lugar.</h1>
            <p>
              Compra para tu tienda o administra la operación según tu perfil de
              acceso.
            </p>
          </div>
          <div className="auth-points">
            <div className="auth-point">
              <span>✓</span> Compras mayoristas
            </div>
            <div className="auth-point">
              <span>✓</span> Gestión por roles
            </div>
            <div className="auth-point">
              <span>✓</span> Información centralizada
            </div>
          </div>
        </aside>
        <section className="auth-card">
          <div className="auth-card-header">
            <h2>Bienvenido</h2>
            <p>Selecciona tu tipo de acceso.</p>
          </div>
          <form className="auth-form" onSubmit={submit}>
            <div className="account-toggle">
              <button
                type="button"
                className={form.tipo === "bodeguero" ? "active" : ""}
                onClick={() => setForm({ ...form, tipo: "bodeguero" })}
              >
                Soy comerciante
              </button>
              <button
                type="button"
                className={form.tipo === "interno" ? "active" : ""}
                onClick={() => setForm({ ...form, tipo: "interno" })}
              >
                Soy colaborador
              </button>
            </div>
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
              {state.loading ? "Ingresando..." : "Ingresar a mi cuenta"}
            </button>
          </form>
          <p className="auth-switch">
            ¿Aún no estás afiliado?{" "}
            <Link to="/registro">Registra tu bodega</Link>
          </p>
        </section>
      </div>
    </main>
  );
}
