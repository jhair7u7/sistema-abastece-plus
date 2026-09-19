import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { apiRequest } from "../services/api";

const initial = {
  nombre: "",
  apellidos: "",
  usuario: "",
  password: "",
  telefono: "",
  ruc: "",
  tipo_establecimiento: "BODEGA",
  nombre_comercial: "",
  razon_social: "",
};
export default function Registro() {
  const [form, setForm] = useState(initial);
  const [status, setStatus] = useState({
    loading: false,
    message: "",
    error: false,
  });
  const navigate = useNavigate();
  const change = ({ target }) =>
    setForm((v) => ({ ...v, [target.name]: target.value }));
  const submit = async (event) => {
    event.preventDefault();
    setStatus({ loading: true, message: "", error: false });
    try {
      const data = await apiRequest("registrar_bodeguero", {
        method: "POST",
        body: form,
      });
      setStatus({ loading: false, message: data.mensaje, error: false });
      setTimeout(() => navigate("/ingresar"), 1200);
    } catch (error) {
      setStatus({ loading: false, message: error.message, error: true });
    }
  };
  return (
    <main className="auth-page">
      <div className="auth-shell">
        <aside className="auth-aside">
          <div>
            <h1>Haz crecer tu negocio.</h1>
            <p>
              Únete a la red B2B que conecta tu tienda con abastecimiento
              mayorista y gestión inteligente.
            </p>
          </div>
          <div className="auth-points">
            <div className="auth-point">
              <span>1</span> Registra al titular
            </div>
            <div className="auth-point">
              <span>2</span> Identifica tu comercio
            </div>
            <div className="auth-point">
              <span>3</span> Espera la validación
            </div>
          </div>
        </aside>
        <section className="auth-card">
          <div className="auth-card-header">
            <h2>Registra tu bodega</h2>
            <p>Completa los datos personales y comerciales.</p>
          </div>
          <form className="auth-form" onSubmit={submit}>
            <Field
              label="Nombres"
              name="nombre"
              value={form.nombre}
              onChange={change}
            />
            <Field
              label="Apellidos"
              name="apellidos"
              value={form.apellidos}
              onChange={change}
            />
            <Field
              label="Correo"
              name="usuario"
              type="email"
              value={form.usuario}
              onChange={change}
            />
            <Field
              label="Teléfono"
              name="telefono"
              value={form.telefono}
              onChange={change}
              pattern="[0-9]{9}"
            />
            <Field
              label="Contraseña"
              name="password"
              type="password"
              value={form.password}
              onChange={change}
              minLength="6"
            />
            <Field
              label="RUC"
              name="ruc"
              value={form.ruc}
              onChange={change}
              pattern="[0-9]{11}"
            />
            <Field
              label="Nombre comercial"
              name="nombre_comercial"
              value={form.nombre_comercial}
              onChange={change}
            />
            <Field
              label="Razón social"
              name="razon_social"
              value={form.razon_social}
              onChange={change}
            />
            <label className="form-field full">
              <span>Tipo de establecimiento</span>
              <select
                name="tipo_establecimiento"
                value={form.tipo_establecimiento}
                onChange={change}
              >
                <option value="BODEGA">Bodega</option>
                <option value="MINIMARKET">Minimarket</option>
                <option value="MARKET_LOCAL">Market local</option>
                <option value="OTROS">Otro</option>
              </select>
            </label>
            {status.message && (
              <div
                className={`form-message ${status.error ? "error" : "success"}`}
              >
                {status.message}
              </div>
            )}
            <button className="form-submit" disabled={status.loading}>
              {status.loading ? "Registrando..." : "Crear cuenta de negocio"}
            </button>
          </form>
          <p className="auth-switch">
            ¿Ya tienes una cuenta? <Link to="/ingresar">Ingresa aquí</Link>
          </p>
        </section>
      </div>
    </main>
  );
}
function Field({ label, ...props }) {
  return (
    <label className="form-field">
      <span>{label}</span>
      <input required {...props} />
    </label>
  );
}
