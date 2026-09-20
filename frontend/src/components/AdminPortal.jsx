import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import Admin from "../pages/Admin";

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
  const allowed = session.account.rol === "LOGISTICA"
    ? pathname.startsWith("/admin/logistica/")
    : pathname === destination;
  if (!allowed) return <Navigate to={destination} replace />;
  return <Admin key={session.account.rol} />;
}
