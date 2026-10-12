import { Navigate, useLocation, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import Admin from "../pages/Admin";
import Facturas from "../pages/Facturas";
import Atencion from "../pages/Atencion";
import UsuariosInternos from "../pages/UsuariosInternos";
import { lazy, Suspense } from "react";
const Transporte = lazy(() => import("../pages/Transporte"));

export default function AdminPortal() {
  const { session } = useAuth();
  const { pathname } = useLocation();
  const paths = {
    ADMINISTRADOR: "/admin/usuarios",
    LOGISTICA: "/admin/logistica/stock",
    TRANSPORTISTA: "/admin/transporte",
    GESTOR_ATENCION: "/admin/atencion",
  };
  const destination = paths[session.account.rol];
  const admin = session.account.rol === "ADMINISTRADOR";
  const allowed = admin ? ["/admin/usuarios", "/admin/logistica", "/admin/transporte", "/admin/atencion", "/admin/logistica/stock", "/admin/logistica/productos", "/admin/logistica/proveedores", "/admin/logistica/despachos", "/admin/logistica/facturas"].includes(pathname) : session.account.rol === "LOGISTICA"
    ? pathname.startsWith("/admin/logistica/")
    : pathname === destination;
  if ((admin || session.account.rol === "LOGISTICA") && pathname === "/admin/facturas") return <Navigate to="/admin/logistica/facturas" replace />;
  if (admin && pathname === "/admin/logistica") return <Navigate to="/admin/logistica/stock" replace />;
  if (!allowed) return <Navigate to={destination} replace />;
  const subnav = admin && pathname.startsWith('/admin/logistica/') ? <div className="logistics-subnav-wrap"><nav className="logistics-subnav" aria-label="Apartados de logística">{Object.entries({stock:'Stock',productos:'Productos',proveedores:'Proveedores',despachos:'Despachos',facturas:'Facturas'}).map(([key,label])=><Link key={key} to={`/admin/logistica/${key}`} className={pathname.endsWith('/'+key)?'active':''} aria-current={pathname.endsWith('/'+key)?'page':undefined}>{label}</Link>)}</nav></div> : null;
  if (pathname === "/admin/logistica/facturas") return <>{subnav}<Facturas /></>;
  if (pathname === "/admin/transporte") return <Suspense fallback={<main className="transport-page">Cargando mis rutas…</main>}><Transporte /></Suspense>;
  if (pathname === "/admin/atencion") return <Atencion />;
  if (pathname === "/admin/usuarios") return <UsuariosInternos />;
  return <>{subnav}<Admin key={`${session.account.rol}:${pathname}`} /></>;
}
