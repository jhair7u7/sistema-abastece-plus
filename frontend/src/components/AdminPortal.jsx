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
  const role = session?.account?.rol;
  const destination = paths[role] || "/admin/login";
  const allowed = role === "LOGISTICA"
    ? pathname.startsWith("/admin/logistica/")
    : pathname === destination;
  if (!allowed) return <Navigate to={destination} replace />;
  return <Admin key={role} />;
}
