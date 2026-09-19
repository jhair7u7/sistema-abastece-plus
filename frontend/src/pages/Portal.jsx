import { Building2, CircleDollarSign, ShoppingBag } from "lucide-react";
import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Portal() {
  const { session } = useAuth();
  const user = session.account;
  const max = Number(user.linea_credito_max || 0);
  const used = Number(user.credito_utilizado || 0);
  const available = Math.max(0, max - used);
  const percent = max ? Math.min(100, (used / max) * 100) : 0;
  return (
    <main className="dashboard-page">
      <div className="dashboard-wrap">
        <header className="dashboard-welcome">
          <div>
            <span className="role-badge">Comerciante afiliado</span>
            <h1>Hola, {user.nombre}</h1>
            <p>Este es el centro de control de {user.nombre_comercial}.</p>
          </div>
          <span
            className={`status-badge ${user.estado_cuenta === "BLOQUEADO" ? "blocked" : "active"}`}
          >
            {String(user.estado_cuenta).replaceAll("_", " ")}
          </span>
        </header>
        <div className="metric-grid">
          <div className="metric-card">
            <div className="metric-icon">
              <Building2 />
            </div>
            <small>Tu comercio</small>
            <strong>{user.tipo_establecimiento?.replaceAll("_", " ")}</strong>
          </div>
          <div className="metric-card">
            <div className="metric-icon">
              <CircleDollarSign />
            </div>
            <small>Crédito disponible</small>
            <strong>S/ {available.toFixed(2)}</strong>
          </div>
          <div className="metric-card">
            <div className="metric-icon">
              <ShoppingBag />
            </div>
            <small>Catálogo</small>
            <strong>Mayorista B2B</strong>
          </div>
        </div>
        <div className="portal-grid">
          <section className="panel-card business-hero">
            <h2>Abastece tu tienda</h2>
            <p>
              Explora productos seleccionados para comercios y encuentra
              presentaciones mayoristas.
            </p>
            <Link className="action-button" to="/catalogo">
              Ver catálogo
            </Link>
          </section>
          <section className="panel-card">
            <h2>Línea de crédito</h2>
            <div className="credit-bar">
              <i style={{ width: `${percent}%` }} />
            </div>
            <small>
              S/ {used.toFixed(2)} utilizados de S/ {max.toFixed(2)}
            </small>
          </section>
          <section className="panel-card">
            <h2>Datos de la tienda</h2>
            <div className="profile-list">
              <Row k="Razón social" v={user.razon_social} />
              <Row k="RUC" v={user.ruc} />
              <Row k="Correo" v={user.correo} />
              <Row k="Teléfono" v={user.telefono} />
            </div>
          </section>
          <section className="panel-card">
            <h2>Estado de afiliación</h2>
            <p style={{ color: "#64748b", lineHeight: 1.7, marginTop: 14 }}>
              Tu cuenta fue creada correctamente. La activación y el crédito son
              gestionados por el equipo de Abastece+.
            </p>
          </section>
        </div>
      </div>
    </main>
  );
}
function Row({ k, v }) {
  return (
    <div className="profile-row">
      <span>{k}</span>
      <strong>{v || "—"}</strong>
    </div>
  );
}
