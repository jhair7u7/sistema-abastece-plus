import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute({ children, internal = false }) {
  const { session } = useAuth();
  if (!session)
    return <Navigate to={internal ? "/admin/login" : "/ingresar"} replace />;
  if (internal && session.type !== "interno")
    return <Navigate to="/tienda" replace />;
  if (!internal && session.type === "interno")
    return <Navigate to="/admin" replace />;
  if (
    internal &&
    ![
      "ADMINISTRADOR",
      "TRANSPORTISTA",
      "GESTOR_ATENCION",
      "LOGISTICA",
    ].includes(session?.account?.rol)
  )
    return <Navigate to="/admin/login" replace />;
  return children;
}
