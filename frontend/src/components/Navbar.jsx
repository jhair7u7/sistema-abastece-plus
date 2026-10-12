import { Link, NavLink, useNavigate } from "react-router-dom";
import { LogIn, LogOut, Menu, X } from "lucide-react";
import { useState } from "react";
import { useAuth } from "../context/AuthContext";

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const { session, logout } = useAuth();
  const navigate = useNavigate();
  const close = () => setOpen(false);
  const exit = () => {
    logout();
    close();
    navigate("/");
  };
  return (
    <header className="navbar">
      <div className="navbar-container">
        <Link to="/" className="logo-container" onClick={close}>
          <img src="/logo.png" alt="Abastece+" className="logo" />
        </Link>
        <button
          className="mobile-menu"
          onClick={() => setOpen(!open)}
          aria-label="Abrir menú"
        >
          {open ? <X /> : <Menu />}
        </button>
        <nav className={`menu ${open ? "menu-open" : ""}`}>
          <NavLink to="/" end onClick={close}>Inicio</NavLink>
          <NavLink to="/nosotros" onClick={close}>
            Nosotros
          </NavLink>
          <NavLink to="/catalogo" onClick={close}>
            Catálogo
          </NavLink>
          <NavLink to="/como-funciona" onClick={close}>
            Cómo Funciona
          </NavLink>
          {session && (
            <NavLink
              to={session.type === "interno" ? "/admin" : "/tienda"}
              onClick={close}
            >
              Mi panel
            </NavLink>
          )}
        </nav>
        <div className="navbar-actions">
          {!session ? (
            <>
              <Link to="/ingresar" className="navbar-login">
                <LogIn size={17} /> Ingresar
              </Link>
              <Link to="/registro" className="navbar-button">
                Registra tu Bodega
              </Link>
            </>
          ) : (
            <button className="navbar-login" onClick={exit}>
              <LogOut size={17} /> Salir
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
