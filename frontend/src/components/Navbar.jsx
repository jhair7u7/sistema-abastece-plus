import { Link, useNavigate } from "react-router-dom";
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
          <Link to="/nosotros" onClick={close}>
            Nosotros
          </Link>
          <Link to="/catalogo" onClick={close}>
            Catálogo
          </Link>
          <Link to="/como-funciona" onClick={close}>
            Cómo Funciona
          </Link>
          {session && (
            <Link
              to={session.type === "interno" ? "/admin" : "/mi-negocio"}
              onClick={close}
            >
              Mi panel
            </Link>
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
