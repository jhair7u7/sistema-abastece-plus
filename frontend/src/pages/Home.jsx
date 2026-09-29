import {
  ArrowRight,
  BadgeCheck,
  Boxes,
  Clock3,
  PackageCheck,
  ShoppingBasket,
  Store,
  Truck,
} from "lucide-react";
import { Link } from "react-router-dom";

const brands = [
  ["coca-cola.jpg", "Coca-Cola"],
  ["ajinomoto.png", "Ajinomoto"],
  ["alicorp.png", "Alicorp"],
  ["backus.png", "Backus"],
  ["unilever.jpg", "Unilever"],
  ["nestle.jpg", "Nestlé"],
  ["primor.png", "Primor"],
  ["gloria.jpg", "Gloria"],
  ["san-mateo.png", "San Mateo"],
  ["aje.jpg", "AJE"],
  ["colgate-palmolive.png", "Colgate-Palmolive"],
  ["aval.png", "AVAL"],
  ["san-jorge.jpg", "San Jorge"],
  ["paramonga.png", "Paramonga"],
  ["pg.png", "P&G"],
];
const benefits = [
  {
    icon: <ShoppingBasket />,
    title: "Compra pensada para bodegas",
    text: "Presentaciones mayoristas y precios por volumen para que cada sol rinda más.",
  },
  {
    icon: <Boxes />,
    title: "Todo en un solo catálogo",
    text: "Compara productos esenciales y arma tu abastecimiento desde un solo lugar.",
  },
  {
    icon: <Truck />,
    title: "Operación más ordenada",
    text: "Solicitudes, proveedores y entregas conectados para simplificar tu día a día.",
  },
];
const steps = [
  [
    "01",
    "Registra tu negocio",
    "Completa los datos del titular y de tu establecimiento.",
  ],
  [
    "02",
    "Explora el catálogo",
    "Encuentra marcas conocidas y formatos para comercio.",
  ],
  [
    "03",
    "Prepara tu solicitud",
    "Selecciona los productos que necesita tu tienda.",
  ],
  [
    "04",
    "Recibe y sigue creciendo",
    "Nuestro equipo coordina el abastecimiento de tu negocio.",
  ],
];

export default function Home() {
  return (
    <main className="landing-home">
      <section className="landing-hero">
        <div className="site-shell hero-grid">
          <div className="hero-copy reveal-up">
            <span className="eyebrow">
              <BadgeCheck size={17} /> Abastecimiento B2B para comercios
            </span>
            <h1>
              Tu tienda llena.
              <br />
              <em>Tu negocio en movimiento.</em>
            </h1>
            <p>
              Conectamos bodegas y comercios con productos mayoristas de marcas
              reconocidas, en una experiencia simple y diseñada para vender más.
            </p>
            <div className="hero-actions">
              <Link to="/registro" className="web-button web-button-primary">
                Registra tu bodega <ArrowRight size={19} />
              </Link>
              <Link to="/catalogo" className="web-button web-button-ghost">
                Explorar catálogo
              </Link>
            </div>
            <div className="hero-trust">
              <div>
                <strong>+15</strong>
                <span>marcas aliadas</span>
              </div>
              <div>
                <strong>100%</strong>
                <span>enfocado en negocios</span>
              </div>
              <div>
                <strong>Lima</strong>
                <span>zona de operación</span>
              </div>
            </div>
          </div>
          <div className="hero-visual reveal-scale">
            <div className="hero-image-frame">
              <img
                src="/bodega-main.jpg"
                alt="Comerciante atendiendo una bodega abastecida"
              />
              <span className="image-tag">
                <Store size={18} /> Hecho para tu tienda
              </span>
            </div>
            <div className="floating-order">
              <div className="floating-icon">
                <PackageCheck />
              </div>
              <div>
                <small>Abastecimiento simple</small>
                <strong>Todo listo para vender</strong>
              </div>
            </div>
            <div className="hero-orbit" aria-hidden="true" />
          </div>
        </div>
      </section>

      <section className="brand-section" aria-labelledby="brands-title">
        <div className="site-shell section-heading compact" data-reveal="up">
          <span className="eyebrow neutral">MARCAS QUE NOS RESPALDAN</span>
          <h2 id="brands-title">Lo mejor para abastecer tu negocio</h2>
          <p>
            Trabajamos con marcas presentes en el día a día de las familias
            peruanas.
          </p>
        </div>
        <div className="brand-marquee" data-reveal="scale">
          <div className="brand-track">
            {[...brands, ...brands].map(([src, name], i) => (
              <div className="brand-card" key={`${name}-${i}`}>
                <img
                  src={`/marcas/${src}`}
                  alt={i < brands.length ? name : ""}
                  aria-hidden={i >= brands.length}
                />
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="web-section benefits-section">
        <div className="site-shell">
          <div className="section-heading split" data-reveal="left">
            <div>
              <span className="eyebrow neutral">MÁS SIMPLE. MÁS RENTABLE.</span>
              <h2>Una nueva forma de abastecer tu tienda</h2>
            </div>
            <p>
              Menos tiempo coordinando compras y más tiempo atendiendo a tus
              clientes.
            </p>
          </div>
          <div className="benefit-grid">
            {benefits.map((item, index) => (
              <article
                className="benefit-card"
                data-reveal="up"
                key={item.title}
              >
                <span className="card-index">0{index + 1}</span>
                <div className="benefit-icon">{item.icon}</div>
                <h3>{item.title}</h3>
                <p>{item.text}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="web-section dark-showcase">
        <div className="site-shell showcase-grid">
          <div className="showcase-copy" data-reveal="left">
            <span className="eyebrow light">TECNOLOGÍA QUE ACOMPAÑA</span>
            <h2>Tu operación, clara desde el primer pedido.</h2>
            <p>
              Abastece+ reúne el catálogo, tu perfil comercial y el seguimiento
              de la operación para que tomes mejores decisiones.
            </p>
            <Link to="/como-funciona" className="text-link">
              Conoce cómo funciona <ArrowRight />
            </Link>
          </div>
          <div className="showcase-image" data-reveal="right">
            <img src="/tablet.png" alt="Vista del panel digital de Abastece+" />
            <div className="showcase-pill">
              <Clock3 />
              <span>
                <strong>Información centralizada</strong>
                <small>Disponible cuando la necesitas</small>
              </span>
            </div>
          </div>
        </div>
      </section>

      <section className="web-section process-section">
        <div className="site-shell">
          <div className="section-heading centered" data-reveal="up">
            <span className="eyebrow neutral">EMPEZAR ES FÁCIL</span>
            <h2>De tu registro al abastecimiento</h2>
          </div>
          <div className="process-grid">
            {steps.map(([number, title, text]) => (
              <article className="process-step" data-reveal="up" key={number}>
                <span>{number}</span>
                <h3>{title}</h3>
                <p>{text}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="home-cta">
        <div className="site-shell cta-panel" data-reveal="scale">
          <div>
            <span className="eyebrow light">TU PRÓXIMO PASO</span>
            <h2>Convierte cada compra en una oportunidad para crecer.</h2>
          </div>
          <Link to="/registro" className="web-button web-button-light">
            Quiero registrar mi negocio <ArrowRight />
          </Link>
        </div>
      </section>
    </main>
  );
}
