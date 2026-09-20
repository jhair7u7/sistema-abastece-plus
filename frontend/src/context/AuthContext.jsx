import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { apiRequest } from "../services/api";

const AuthContext = createContext(null);
const STORAGE_KEY = "abastece_session";
const IDLE_TIMEOUT_MS = 5 * 60 * 1000;
const ACTIVITY_WRITE_INTERVAL_MS = 1000;

function readSession() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY)) || null;
    if (!stored) return null;

    // Las sesiones antiguas no tienen lastActivity: se invalidan para empezar
    // a aplicar el límite de inactividad de forma consistente.
    if (
      !Number.isFinite(stored.lastActivity) ||
      Date.now() - stored.lastActivity >= IDLE_TIMEOUT_MS
    ) {
      localStorage.removeItem(STORAGE_KEY);
      return null;
    }
    return stored;
  } catch {
    localStorage.removeItem(STORAGE_KEY);
    return null;
  }
}

export function AuthProvider({ children }) {
  const [session, setSession] = useState(readSession);
  const lastActivityRef = useRef(session?.lastActivity || 0);

  const login = async ({ usuario, password, tipo }) => {
    const data = await apiRequest(
      tipo === "interno" ? "login_admin" : "login_cliente",
      {
        method: "POST",
        body: { usuario, password },
      },
    );
    const next = {
      token: data.token,
      account: data.usuario || data.bodeguero,
      type: data.usuario ? "interno" : "bodeguero",
      lastActivity: Date.now(),
    };
    lastActivityRef.current = next.lastActivity;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    setSession(next);
    return next;
  };

  const logout = useCallback(() => {
    lastActivityRef.current = 0;
    localStorage.removeItem(STORAGE_KEY);
    setSession(null);
  }, []);

  useEffect(() => {
    if (!session) return undefined;

    let timeoutId;
    const scheduleLogout = () => {
      window.clearTimeout(timeoutId);
      const remaining = Math.max(
        0,
        IDLE_TIMEOUT_MS - (Date.now() - lastActivityRef.current),
      );
      timeoutId = window.setTimeout(logout, remaining);
    };
    const registerActivity = () => {
      const now = Date.now();
      if (now - lastActivityRef.current < ACTIVITY_WRITE_INTERVAL_MS) return;

      lastActivityRef.current = now;
      const stored = readSession();
      if (!stored) {
        logout();
        return;
      }
      localStorage.setItem(
        STORAGE_KEY,
        JSON.stringify({ ...stored, lastActivity: now }),
      );
      scheduleLogout();
    };
    const syncSession = (event) => {
      if (event.key !== STORAGE_KEY) return;
      const next = readSession();
      lastActivityRef.current = next?.lastActivity || 0;
      setSession(next);
      if (next) scheduleLogout();
      else window.clearTimeout(timeoutId);
    };
    const activityEvents = [
      "pointerdown",
      "pointermove",
      "keydown",
      "scroll",
      "touchstart",
    ];
    activityEvents.forEach((event) =>
      window.addEventListener(event, registerActivity, { passive: true }),
    );
    window.addEventListener("storage", syncSession);
    window.addEventListener("auth:unauthorized", logout);
    scheduleLogout();

    return () => {
      window.clearTimeout(timeoutId);
      activityEvents.forEach((event) =>
        window.removeEventListener(event, registerActivity),
      );
      window.removeEventListener("storage", syncSession);
      window.removeEventListener("auth:unauthorized", logout);
    };
  }, [session, logout]);

  const value = useMemo(() => ({ session, login, logout }), [session, logout]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// El proveedor y su hook comparten este módulo para mantener una única sesión.
// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => useContext(AuthContext);
