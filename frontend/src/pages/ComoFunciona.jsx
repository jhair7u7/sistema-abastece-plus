import {
  ArrowDown,
  BadgeCheck,
  Boxes,
  PackageCheck,
  ShoppingCart,
} from "lucide-react";
import { Link } from "react-router-dom";

const steps = [
  {
    number: "01",
    title: "Registra tu bodega",
    description:
      "Cuéntanos sobre ti y tu comercio. Registramos los datos esenciales para darte una experiencia pensada para tu tipo de negocio.",
    detail: "Un perfil comercial claro desde el inicio",
    image: "/comoFunciona/paso1.png",
    icon: <BadgeCheck />,
  },
  {
    number: "02",
    title: "Explora productos",
    description:
      "Revisa un catálogo organizado con productos para tu tienda, presentaciones mayoristas e información disponible en un solo lugar.",
    detail: "Productos y precios fáciles de comparar",
    image: "/comoFunciona/paso2.png",
    icon: <ShoppingCart />,
  },
  {
    number: "03",
    title: "Prepara tu solicitud",
    description:
      "Elige lo que necesitas, define las cantidades y envía tu solicitud. Nuestro equipo organiza cada producto antes del despacho.",
    detail: "Una compra ordenada y sin listas dispersas",
    image: "/comoFunciona/paso3.png",
    icon: <Boxes />,
  },
  {
    number: "04",
    title: "Recibe tu abastecimiento",
    description:
      "Coordinamos la entrega para que recibas tus productos y vuelvas a concentrarte en lo más importante: atender y hacer crecer tu negocio.",
    detail: "Tu tienda lista para seguir vendiendo",
    image: "/comoFunciona/paso4.png",
    icon: <PackageCheck />,
  },
];

export default function ComoFunciona() {
  return (
    <main className="how-page">
      <header className="how-hero">
        <div className="how-container" data-reveal="up">
          <span className="how-kicker">Simple de principio a fin</span>
          <h1>De tu pantalla a los estantes de tu negocio.</h1>
          <p>
            Cuatro pasos conectados para que abastecerte deje de ser una tarea
            complicada.
          </p>
          <a
            href="#recorrido"
            onClick={(event) => {
              event.preventDefault();
              document
                .querySelector("#recorrido")
                ?.scrollIntoView({ behavior: "smooth" });
            }}
          >
            Ver el recorrido <ArrowDown />
          </a>
        </div>
      </header>
      <section className="how-journey" id="recorrido">
        <div className="how-container">
          {steps.map((step, index) => (
            <article
              className={`journey-step ${index % 2 ? "journey-step-reverse" : ""}`}
              key={step.number}
            >
              <div
                className="journey-image"
                data-reveal={index % 2 ? "wipe-right" : "wipe-left"}
              >
                <img src={step.image} alt={step.title} />
                <span>Paso {step.number}</span>
              </div>
              <div
                className="journey-copy"
                data-reveal={index % 2 ? "left" : "right"}
              >
                <div className="journey-icon">{step.icon}</div>
                <span className="how-kicker">Paso {step.number} de 04</span>
                <h2>{step.title}</h2>
                <p>{step.description}</p>
                <strong>
                  <BadgeCheck /> {step.detail}
                </strong>
              </div>
            </article>
          ))}
        </div>
      </section>
      <section className="how-finish">
        <div className="how-container" data-reveal="scale">
          <span className="how-kicker light">Así de sencillo</span>
          <h2>Tu próxima compra puede empezar hoy.</h2>
          <p>
            Registra tu negocio y descubre una forma más clara de abastecer tu
            tienda.
          </p>
          <Link to="/registro">Comenzar ahora</Link>
        </div>
      </section>
    </main>
  );
}
