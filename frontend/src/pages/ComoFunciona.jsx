import "./ComoFunciona.css";


export default function ComoFunciona() {

  const steps = [
    {
      number: "01",
      title: "Registra tu bodega",
      description:
        "Crea tu perfil y valida la información de tu negocio.",
      image: "/paso1.png"
    },

    {
      number: "02",
      title: "Explora productos",
      description:
        "Accede al catálogo con precios mayoristas.",
      image: "/paso2.png"
    },

    {
      number: "03",
      title: "Realiza pedidos",
      description:
        "Selecciona cantidades y recibe confirmación.",
      image: "/paso3.png"
    },

    {
      number: "04",
      title: "Recibe tu abastecimiento",
      description:
        "Gestiona tus productos con despacho organizado.",
      image: "/paso4.png"
    }
  ];

  return (
    <section className="how-page">
      <div className="how-container">
        <header className="how-header">
          <h1>
            ¿Cómo funciona Abastece+?
          </h1>
          <p>
            Un sistema sencillo para conectar bodegas con proveedores mayoristas.
          </p>
        </header>
        <div className="process-line"></div>
        <div className="process-grid">
          {
            steps.map((step, index) => (
              <article
                className="process-card"
                key={index}
              >
                <div className="process-image">
                  <img
                    src={step.image}
                    alt={step.title}
                  />
                </div>
                <div className="process-step">
                  <span className="process-number">
                    {step.number}
                  </span>
                </div>
                <h3>
                  {step.title}
                </h3>
                <p>
                  {step.description}
                </p>
              </article>
            ))
          }
        </div>
      </div>
    </section>
  )
}