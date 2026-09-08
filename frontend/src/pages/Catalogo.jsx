import { Heart, ShoppingCart } from "lucide-react";
import "./Catalogo.css";


export default function Catalogo() {

  const categories = [
    {
      name: "Abarrotes",
      active: true
    },

    {
      name: "Bebidas",
      active: false
    },

    {
      name: "Limpieza",
      active: false
    },

    {
      name: "Cuidado Personal",
      active: false
    }
  ];

  const products = [
    {
      id: 1,
      name: "Agua pura pack x24 unidades",
      image: "/agua_pura.png",
      stock: "En Stock",
      price: "S/ 33.33",
      minimum: "Mínimo 5 cajas"
    },

    {
      id: 2,
      name: "Arroz extra saco 50kg",
      image: "/arroz.png",
      stock: "En Stock",
      price: "S/ 120.00",
      minimum: "Mínimo 5 sacos"
    },

    {
      id: 3,
      name: "Atún en aceite caja x48",
      image: "/atun.png",
      stock: "En Stock",
      price: "S/ 85.00",
      minimum: "Mínimo 5 cajas"
    },

    {
      id: 4,
      name: "Gaseosas surtidas",
      image: "/gaseosas.png",
      stock: "Disponible",
      price: "S/ 65.00",
      minimum: "Mínimo 3 cajas"
    }
  ];

  return (
    <section className="catalog-page">

      <div className="catalog-container">

        {/* SIDEBAR */}

        <aside className="catalog-sidebar">

          <h2>
            Categorías
          </h2>

          <ul>
            {
              categories.map((cat, index) => (

                <li
                  key={index}
                  className={
                    cat.active
                      ? "category active"
                      : "category"
                  }
                >
                  {cat.name}
                </li>
              ))
            }
          </ul>
        </aside>

        {/* PRODUCTOS */}

        <main className="products-area">

          <div className="catalog-header">

            <h1>
              Catálogo Mayorista
            </h1>

            <p>
              Productos seleccionados para abastecer tu negocio.
            </p>
          </div>
          <div className="products-grid">
            {
              products.map(product => (

                <article
                  className="product-card"
                  key={product.id}
                >
                  <button className="favorite">
                    <Heart size={20} />
                  </button>

                  <div className="product-image">
                    <img
                      src={product.image}
                      alt={product.name}
                    />
                  </div>

                  <h3>
                    {product.name}
                  </h3>

                  <span className="stock">
                    {product.stock}
                  </span>
                  <div className="price-box">

                    <p>
                      Precio Mayorista
                    </p>

                    <strong>
                      {product.price}
                    </strong>
                    <small>
                      {product.minimum}
                    </small>
                  </div>
                  <button className="cart-button">
                    <ShoppingCart size={18} />
                    Añadir al carrito
                  </button>
                </article>
              ))
            }
          </div>
        </main>
      </div>
    </section>
  )
}