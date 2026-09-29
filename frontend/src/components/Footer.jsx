import { ArrowUpRight, Mail, MapPin } from "lucide-react";
import { Link, useLocation } from "react-router-dom";

export default function Footer() {
  const { pathname } = useLocation();
  if (pathname.startsWith("/admin") || pathname.startsWith("/mi-negocio"))
    return null;
  return (
    <footer className="site-footer">
      <div className="site-shell footer-top">
        <div className="footer-statement">
          <img src="/logo.png" alt="Abastece+" />
          <p>Una red. Todo lo que tu tienda necesita.</p>
        </div>
        <Link to="/registro" className="footer-cta">
          Haz crecer tu negocio <ArrowUpRight size={20} />
        </Link>
      </div>
      <div className="site-shell footer-main">
        <div className="footer-social">
          <span className="footer-label">SÍGUENOS</span>
          <div>
            <a href="#instagram" aria-label="Instagram">
              ig
            </a>
            <a href="#linkedin" aria-label="LinkedIn">
              in
            </a>
          </div>
        </div>
        <nav className="footer-links" aria-label="Enlaces del pie de página">
          <div>
            <span className="footer-label">EMPRESA</span>
            <Link to="/">Inicio</Link>
            <Link to="/nosotros">Nosotros</Link>
            <Link to="/como-funciona">Cómo funciona</Link>
          </div>
          <div>
            <span className="footer-label">PARA TU NEGOCIO</span>
            <Link to="/catalogo">Catálogo</Link>
            <Link to="/registro">Registra tu bodega</Link>
            <Link to="/ingresar">Ingresar</Link>
          </div>
        </nav>
        <div className="footer-contact">
          <span className="footer-label">CONTACTO</span>
          <p>
            <MapPin size={18} /> Lima, Perú
          </p>
          <a href="mailto:contacto@abasteceplus.pe">
            <Mail size={18} /> contacto@abasteceplus.pe
          </a>
          <small>Atención de lunes a viernes</small>
        </div>
      </div>
      <div className="site-shell footer-bottom">
        <span>
          © {new Date().getFullYear()} Abastece+. Todos los derechos reservados.
        </span>
        <div>
          <a href="#privacidad">Privacidad</a>
          <a href="#terminos">Términos y condiciones</a>
        </div>
      </div>
      <div className="footer-wordmark" aria-hidden="true">
        ABASTECE+
      </div>
    </footer>
  );
}
