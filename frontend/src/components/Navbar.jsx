import { Link } from "react-router-dom";
import "./Navbar.css";

export default function Navbar() {
  return (
    <header className="navbar">
      <div className="navbar-container">

        {/* LOGO */}
        <Link to="/" className="logo-container">
          <img
            src="/logo.png"
            alt="Abastece+"
            className="logo"
          />
        </Link>


        {/* MENU */}
        <nav className="menu">

          <Link to="/nosotros">
            Nosotros
          </Link>

          <Link to="/catalogo">
            Catálogo
          </Link>

          <Link to="/como-funciona">
            Cómo Funciona
          </Link>

          <Link to="/">
            Blog
          </Link>

          <Link to="/">
            Contacto
          </Link>

        </nav>


        {/* BOTÓN */}
        <Link
          to="/registro"
          className="navbar-button"
        >
          Registra tu Bodega
        </Link>


      </div>
    </header>
  );
}