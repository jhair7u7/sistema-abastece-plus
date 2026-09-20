import { LogOut, Menu, X } from "lucide-react";
import { useState } from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const roleNames = {
  ADMINISTRADOR: "Administrador",
  TRANSPORTISTA: "Transportista",
  GESTOR_ATENCION: "Gestor de atención",
  LOGISTICA: "Logística",
};

const roleModules = {
  ADMINISTRADOR: [{ label: "Usuarios internos", to: "/admin/usuarios" }],
  LOGISTICA: [
    { label: "Stock", to: "/admin/logistica/stock" },
    { label: "Productos", to: "/admin/logistica/productos" },
    { label: "Proveedores", to: "/admin/logistica/proveedores" },
    { label: "Despachos", to: "/admin/logistica/despachos" },
    { label: "Facturas", to: "/admin/logistica/facturas" },
  ],
  TRANSPORTISTA: [{ label: "Mis rutas", to: "/admin/transporte" }],
  GESTOR_ATENCION: [
    { label: "Atención", to: "/admin/atencion" },
  ],
};

export default function AdminNavbar() {
  const [open, setOpen] = useState(false);
  const { session, logout } = useAuth();
  const navigate = useNavigate();
  const account = session.account;
  const modules = roleModules[account.rol] || [];
  const name = `${account.nombre || ""} ${account.apellidos || ""}`.trim();

  const exit = () => {
    logout();
    navigate("/admin/login", { replace: true });
  };

  return (
    <header className="admin-navbar">
      <div
        className="admin-navbar__brand"
        aria-label="Portal interno Abastece+"
      >
        <img src="/logo.png" alt="Abastece+" />
        <div>
          <span>Portal interno</span>
        </div>
      </div>

      <button
        type="button"
        className="admin-navbar__toggle"
        onClick={() => setOpen((value) => !value)}
        aria-label="Abrir módulos administrativos"
        aria-expanded={open}
      >
        {open ? <X /> : <Menu />}
      </button>

      <nav
        className={`admin-navbar__modules ${open ? "is-open" : ""}`}
        aria-label="Módulos habilitados"
      >
        {modules.map((module) => (
          <NavLink
            key={module.label}
            to={module.to}
            onClick={() => setOpen(false)}
            className={({ isActive }) => (isActive ? "active" : "")}
          >
            {module.label}
          </NavLink>
        ))}
      </nav>

      <div className="admin-navbar__account">
        <span className="admin-navbar__avatar" aria-hidden="true">
          {(account.nombre || "U").charAt(0).toUpperCase()}
        </span>
        <div className="admin-navbar__identity">
          <strong>{name}</strong>
          <span>{roleNames[account.rol] || account.rol}</span>
        </div>
        <button
          type="button"
          className="admin-navbar__logout"
          onClick={exit}
          title="Cerrar sesión"
        >
          <LogOut size={19} />
          <span>Salir</span>
        </button>
      </div>
    </header>
  );
}
