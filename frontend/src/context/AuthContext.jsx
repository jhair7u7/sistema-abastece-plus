import { createContext, useContext, useMemo, useState } from "react";
import { apiRequest } from "../services/api";

const AuthContext = createContext(null);
const STORAGE_KEY = "abastece_session";

function readSession() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }) {
  const [session, setSession] = useState(readSession);

  const login = async ({ usuario, password, tipo }) => {
    const data = await apiRequest(
      tipo === "interno" ? "login" : "login_bodeguero",
      {
        method: "POST",
        body: { usuario, password },
      },
    );
    const next = {
      token: data.token,
      account: data.usuario || data.bodeguero,
      type: data.usuario ? "interno" : "bodeguero",
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    setSession(next);
    return next;
  };

  const logout = () => {
    localStorage.removeItem(STORAGE_KEY);
    setSession(null);
  };

  const value = useMemo(() => ({ session, login, logout }), [session]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// El proveedor y su hook comparten este módulo para mantener una única sesión.
// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => useContext(AuthContext);
