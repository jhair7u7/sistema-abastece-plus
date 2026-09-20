import { useEffect, useLayoutEffect } from "react";
import {
  BrowserRouter as Router,
  Navigate,
  Routes,
  Route,
  useLocation,
} from "react-router-dom";
import Navbar from "./components/Navbar";
import Home from "./pages/Home";
import Catalogo from "./pages/Catalogo";
import Nosotros from "./pages/Nosotros";
import ComoFunciona from "./pages/ComoFunciona";
import Login from "./pages/Login";
import Registro from "./pages/Registro";
import Portal from "./pages/Portal";
import AdminPortal from "./components/AdminPortal";
import ProtectedRoute from "./components/ProtectedRoute";
import { AuthProvider, useAuth } from "./context/AuthContext";
import Footer from "./components/Footer";
import { CartProvider } from "./context/CartContext";
import CartBar from "./components/CartBar";
import Checkout from "./pages/Checkout";
import Pago from "./pages/Pago";
import AdminNavbar from "./components/AdminNavbar";

function PageMotion() {
  const { pathname } = useLocation();

  useLayoutEffect(() => {
    if ("scrollRestoration" in window.history)
      window.history.scrollRestoration = "manual";
    window.scrollTo(0, 0);
    const frame = window.requestAnimationFrame(() => window.scrollTo(0, 0));
    return () => window.cancelAnimationFrame(frame);
  }, [pathname]);

  useEffect(() => {
    const elements = document.querySelectorAll("[data-reveal]");
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      elements.forEach((element) => element.classList.add("is-visible"));
      return undefined;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting || entry.boundingClientRect.top < 0) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.08, rootMargin: "0px 0px -4% 0px" },
    );

    elements.forEach((element) => observer.observe(element));
    return () => observer.disconnect();
  }, [pathname]);
  return null;
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <CartProvider>
          <PageMotion />
          <ApplicationShell />
        </CartProvider>
      </AuthProvider>
    </Router>
  );
}

function ApplicationShell() {
  const { pathname } = useLocation();
  const { session } = useAuth();
  const isAdmin = pathname.startsWith("/admin");
  const showAdminNavbar = isAdmin && pathname !== "/admin/login" && session?.type === "interno";

  return (
    <>
      {showAdminNavbar ? <AdminNavbar /> : !isAdmin && <Navbar />}
      {!isAdmin && <CartBar />}
      <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/catalogo" element={<Catalogo />} />
            <Route path="/nosotros" element={<Nosotros />} />
            <Route path="/como-funciona" element={<ComoFunciona />} />
            <Route path="/registro" element={<Registro />} />
            <Route path="/ingresar" element={<Login />} />
            <Route path="/admin/login" element={<Login internal />} />
            <Route path="/mi-negocio" element={<Navigate to="/tienda" replace />} />
            <Route
              path="/tienda"
              element={
                <ProtectedRoute>
                  <Portal />
                </ProtectedRoute>
              }
            />
            <Route
              path="/admin/*"
              element={
                <ProtectedRoute internal>
                  <AdminPortal />
                </ProtectedRoute>
              }
            />
            <Route path="/tienda/catalogo" element={<ProtectedRoute><Catalogo /></ProtectedRoute>} />
            <Route path="/tienda/checkout" element={<ProtectedRoute><Checkout /></ProtectedRoute>} />
            <Route path="/tienda/pago" element={<ProtectedRoute><Pago /></ProtectedRoute>} />
            <Route
              path="/checkout"
              element={
                <ProtectedRoute>
                  <Checkout />
                </ProtectedRoute>
              }
            />

            <Route
              path="/pago"
              element={
                <ProtectedRoute>
                  <Pago />
                </ProtectedRoute>
              }
            />
            <Route path="*" element={<Home />} />
      </Routes>
      {!isAdmin && <Footer />}
    </>
  );
}

export default App;
