import { useEffect, useLayoutEffect } from "react";
import {
  BrowserRouter as Router,
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
import Admin from "./pages/Admin";
import ProtectedRoute from "./components/ProtectedRoute";
import { AuthProvider } from "./context/AuthContext";
import Footer from "./components/Footer";
import { CartProvider } from "./context/CartContext";
import CartBar from "./components/CartBar";
import Checkout from "./pages/Checkout";
import Pago from "./pages/Pago";

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
          <Navbar />
          <CartBar />
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/catalogo" element={<Catalogo />} />
            <Route path="/nosotros" element={<Nosotros />} />
            <Route path="/como-funciona" element={<ComoFunciona />} />
            <Route path="/registro" element={<Registro />} />
            <Route path="/ingresar" element={<Login />} />
            <Route
              path="/mi-negocio"
              element={
                <ProtectedRoute>
                  <Portal />
                </ProtectedRoute>
              }
            />
            <Route
              path="/admin"
              element={
                <ProtectedRoute internal>
                  <Admin />
                </ProtectedRoute>
              }
            />
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
          <Footer />
        </CartProvider>
      </AuthProvider>
    </Router>
  );
}

export default App;
