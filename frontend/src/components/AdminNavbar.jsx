import { LogOut, Menu, X, Box, Package, UsersRound, Truck, FileText, Headset } from "lucide-react";
import { useLayoutEffect, useRef, useState } from "react";
import { NavLink, useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const moduleIcons = { Stock: Package, Productos: Box, Proveedores: UsersRound, Despachos: Truck, Facturas: FileText, "Mis rutas": Truck, Logística: Truck, Transporte: Truck, Atención: Headset, "Usuarios internos": UsersRound };

const roleNames = {
  ADMINISTRADOR: "Administrador",
  TRANSPORTISTA: "Transportista",
  GESTOR_ATENCION: "Gestor de atención",
  LOGISTICA: "Logística",
};

const roleModules = {
  ADMINISTRADOR: [{ label: "Usuarios internos", to: "/admin/usuarios" },{ label: "Logística", to: "/admin/logistica" },{ label: "Transporte", to: "/admin/transporte" },{ label: "Atención", to: "/admin/atencion" }],
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
  const navRef = useRef(null), dropRef = useRef(null), positionRef = useRef(null);
  const { pathname } = useLocation();
  useLayoutEffect(() => {
    const nav = navRef.current, drop = dropRef.current;
    let animation;
    const move = () => {
      const active = nav.querySelector("a.active");
      if (!active || !nav.offsetWidth) return;
      const next = { left: active.offsetLeft, top: active.offsetTop, width: active.offsetWidth, height: active.offsetHeight };
      const old = positionRef.current;
      if (old && old.left === next.left && old.top === next.top && old.width === next.width && old.height === next.height) return;
      Object.assign(drop.style, { left: `${next.left}px`, top: `${next.top}px`, width: `${next.width}px`, height: `${next.height}px`, opacity: "1" });
      animation?.cancel();
      if (old && Math.abs(old.left - next.left) > 1 && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
        const distance = next.left - old.left;
        animation = drop.animate([
          { left: `${old.left}px`, width: `${old.width}px`, borderRadius: "28px" },
          { left: `${old.left + distance * .42 - Math.abs(distance) * .08}px`, width: `${next.width + Math.min(Math.abs(distance) * .32, 90)}px`, borderRadius: distance > 0 ? "36% 64% 62% 38% / 48% 52% 48% 52%" : "64% 36% 38% 62% / 52% 48% 52% 48%", offset: .48 },
          { left: `${next.left + Math.sign(distance) * 5}px`, width: `${next.width - 4}px`, borderRadius: "45% 55% 48% 52% / 55% 45% 55% 45%", offset: .8 },
          { left: `${next.left}px`, width: `${next.width}px`, borderRadius: "28px" }
        ], { duration: 580, easing: "cubic-bezier(.22,.75,.25,1)" });
      }
      positionRef.current = next;
    };
    move();
    const observer = new ResizeObserver(move);observer.observe(nav);
    document.fonts.ready.then(move);
    return () => { observer.disconnect();animation?.cancel(); };
  }, [pathname, open]);
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
        aria-controls="internal-modules"
      >
        {open ? <X /> : <Menu />}
      </button>

      <nav
        ref={navRef}
        id="internal-modules"
        className={`admin-navbar__modules ${open ? "is-open" : ""}`}
        aria-label="Módulos habilitados"
      >
        <span ref={dropRef} className="admin-navbar__drop" aria-hidden="true" />
        {modules.map((module) => { const Icon = moduleIcons[module.label] || Package; return (
          <NavLink
            key={module.label}
            to={module.to}
            onClick={() => setOpen(false)}
            className={({ isActive }) => (isActive ? "active" : "")}
          >
            <Icon size={21} strokeWidth={1.8} aria-hidden="true" /><span>{module.label}</span>
          </NavLink>
        ); })}
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
