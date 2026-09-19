import {
  ArrowRight,
  HeartHandshake,
  Lightbulb,
  Network,
  Quote,
} from "lucide-react";
import { Link } from "react-router-dom";

const stories = [
  {
    image: "/nosotros/equipo.jpg",
    eyebrow: "Donde todo comienza",
    title: "Una bodega es mucho más que un punto de venta.",
    text: [
      "Cada mañana, miles de comerciantes levantan la puerta de su negocio antes que el resto del barrio. Conocen a sus vecinos, saben qué producto hace falta y convierten un espacio pequeño en un lugar imprescindible.",
      "Abastece+ nació al observar ese esfuerzo cotidiano y preguntarnos cómo podíamos devolverles tiempo, orden y nuevas oportunidades.",
    ],
    note: "Estar cerca de quien atiende detrás del mostrador es el inicio de cada decisión que tomamos.",
  },
  {
    image: "/nosotros/seño2.jpg",
    eyebrow: "La historia de Rosa",
    title: "Más tiempo para atender, menos tiempo buscando proveedores.",
    text: [
      "Rosa construyó su clientela producto a producto. Durante años, abastecer su tienda significó llamadas, listas en papel y recorridos para comparar precios.",
      "Con una alternativa digital puede revisar opciones con calma, preparar su compra y mantener sus estantes listos. La tecnología no reemplaza su experiencia: la acompaña.",
    ],
    note: "Cuando el abastecimiento se vuelve simple, el negocio recupera tiempo para sus clientes.",
  },
  {
    image: "/nosotros/seño3.jpg",
    eyebrow: "La historia de Elena",
    title: "Crecer también significa decidir con más claridad.",
    text: [
      "Elena representa a una nueva generación de comerciantes: conserva el trato cercano de la bodega y suma herramientas para organizar mejor cada compra.",
      "Con información centralizada puede anticiparse a lo que se vende, descubrir nuevas oportunidades y hacer crecer su negocio sin perder su esencia.",
    ],
    note: "Queremos que cada comerciante sienta que la innovación también fue creada para su realidad.",
  },
];

const values = [
  {
    icon: <Network />,
    title: "Conexión",
    text: "Acercamos comercios, productos y proveedores en una misma red.",
  },
  {
    icon: <HeartHandshake />,
    title: "Confianza",
    text: "Construimos relaciones claras que respetan el trabajo de cada negocio.",
  },
  {
    icon: <Lightbulb />,
    title: "Innovación útil",
    text: "Creamos tecnología sencilla que resuelve necesidades del día a día.",
  },
];

export default function Nosotros() {
  return (
    <main className="about-page">
      <header className="about-hero">
        <div className="about-container" data-reveal="up">
          <span className="about-kicker">Somos Abastece+</span>
          <h1>Creemos en quienes hacen avanzar cada barrio.</h1>
          <p>
            Nuestra historia se escribe junto a comerciantes que abren sus
            puertas cada día, sostienen a sus familias y mantienen en movimiento
            a su comunidad.
          </p>
        </div>
        <div className="about-scroll-cue" aria-hidden="true">
          <span /> Conoce nuestras historias
        </div>
      </header>
      <section
        className="about-stories"
        aria-label="Historias que nos inspiran"
      >
        <div className="about-container">
          {stories.map((story, index) => (
            <article
              className={`story-row ${index % 2 ? "story-row-reverse" : ""}`}
              key={story.title}
            >
              <div
                className="story-visual"
                data-reveal={index % 2 ? "right" : "left"}
              >
                <span className="story-index">0{index + 1}</span>
                <img src={story.image} alt={story.title} />
              </div>
              <div
                className="story-copy"
                data-reveal={index % 2 ? "left" : "right"}
              >
                <span className="about-kicker">{story.eyebrow}</span>
                <h2>{story.title}</h2>
                {story.text.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
                <blockquote>
                  <Quote size={22} />
                  {story.note}
                </blockquote>
              </div>
            </article>
          ))}
        </div>
      </section>
      <section className="about-purpose">
        <div className="about-container purpose-grid">
          <div data-reveal="left">
            <span className="about-kicker light">Nuestro propósito</span>
            <h2>Hacer que crecer sea una posibilidad cotidiana.</h2>
          </div>
          <div className="purpose-statements" data-reveal="right">
            <article>
              <span>01</span>
              <div>
                <h3>Misión</h3>
                <p>
                  Simplificar el abastecimiento con una experiencia digital
                  eficiente, cercana y confiable.
                </p>
              </div>
            </article>
            <article>
              <span>02</span>
              <div>
                <h3>Visión</h3>
                <p>
                  Construir la red que impulse el crecimiento de los comercios
                  locales en todo el país.
                </p>
              </div>
            </article>
          </div>
        </div>
      </section>
      <section className="about-values about-container">
        <header data-reveal="up">
          <span className="about-kicker">Lo que nos guía</span>
          <h2>Valores que se convierten en acciones.</h2>
        </header>
        <div className="values-grid">
          {values.map((value, index) => (
            <article
              className="value-card"
              data-reveal="up"
              style={{ "--reveal-delay": `${index * 100}ms` }}
              key={value.title}
            >
              <span>{value.icon}</span>
              <h3>{value.title}</h3>
              <p>{value.text}</p>
            </article>
          ))}
        </div>
        <div className="about-cta" data-reveal="scale">
          <div>
            <span>Tu historia también puede ser parte de esta red.</span>
            <h2>Hagamos crecer tu negocio.</h2>
          </div>
          <Link to="/registro">
            Registra tu bodega <ArrowRight />
          </Link>
        </div>
      </section>
    </main>
  );
}
