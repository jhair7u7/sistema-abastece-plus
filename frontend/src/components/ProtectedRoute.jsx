import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute({ children, internal = false }) {
  const { session } = useAuth();
  if (!session) return <Navigate to="/ingresar" replace />;
  if (internal && session.type !== "interno")
    return <Navigate to="/mi-negocio" replace />;
  return children;
}
