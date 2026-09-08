import { Link } from "react-router-dom";
import "./Home.css";

export default function Home() {

  const steps = [

    {
      number: "01",
      title: "Registro y Validación",
      description: "Crea tu cuenta de bodega y valida tus datos.",
      image: "/paso1.png"
    },

    {
      number: "02",
      title: "Explora el Catálogo",
      description: "Encuentra productos con precios mayoristas.",
      image: "/paso2.png"
    },

    {
      number: "03",
      title: "Realiza tu Pedido",
      description: "Compra cajas y sacos según tu necesidad.",
      image: "/paso3.png"
    },

    {
      number: "04",
      title: "Despacho FIFO",
      description: "Recibe productos organizados y controlados.",
      image: "/paso4.png"
    }
  ];
  return (

    <main className="home">
      {/* HERO */}
      <section className="hero">
        <div className="hero-container">
          {/* TEXTO */}
          <div className="hero-content">
            <h1>
              Digitaliza tu
              <br />
              <span>Bodega.</span>
              <br />
              Abastece
              <br />
              Inteligente.
            </h1>
            <p>
              Tu tienda siempre surtida con
              productos mayoristas y gestión inteligente.
            </p>
            <div className="hero-buttons">
              <Link
                to="/registro"
                className="btn-primary"
              >
                Registra tu Bodega
              </Link>
              <Link
                to="/proveedor"
                className="btn-secondary"
              >
                Soy Proveedor
              </Link>
            </div>
          </div>
          {/* IMAGEN + DASHBOARD */}
          <div className="hero-image">
            <img
              src="/bodega-main.jpg"
              alt="Bodega"
              className="main-image"
            />
            <div className="dashboard-preview">
              <div className="dashboard-header">
                <strong>
                  Panel
                </strong>
                <span>
                  Abastece+
                </span>
              </div>
              <div className="dashboard-cards">
                <div>
                  <small>
                    Ventas
                  </small>
                  <b>
                    $3,360
                  </b>
                </div>
                <div>
                  <small>
                    Inventario
                  </small>
                  <b>
                    187
                  </b>F
                </div>
                <div>
                  <small>
                    Proveedores
                  </small>
                  <b>
                    45
                  </b>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}