import { Heart, PackageOpen, ShoppingCart } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { apiRequest } from "../services/api";
import { useCart } from "../context/CartContext";

const productImages = {
  1: "/productos/arroz.png",
  2: "/productos/gaseosas.png",
  3: "/productos/agua_pura.png",
};

export default function Catalogo() {
  const [products, setProducts] = useState([]);
  const [active, setActive] = useState("Todos");
  /*const [cart, setCart] = useState({});*/
  const [state, setState] = useState({ loading: true, error: "" });
  const { addProduct, decreaseProduct, cart } = useCart();

  useEffect(() => {
    apiRequest("listar_productos")
      .then((data) => setProducts(data.productos || []))
      .catch((error) => setState({ loading: false, error: error.message }))
      .finally(() => setState((current) => ({ ...current, loading: false })));
  }, []);

  const categories = useMemo(
    () => ["Todos", ...new Set(products.map((product) => product.categoria))],
    [products],
  );
  const visible =
    active === "Todos"
      ? products
      : products.filter((product) => product.categoria === active);
  const units = Object.values(cart).reduce(
    (total, quantity) => total + quantity,
    0,
  );

  return (
    <section className="catalog-page">
      <div className="catalog-container">
        <aside className="catalog-sidebar">
          <h2>Categorías</h2>
          <ul>
            {categories.map((category) => (
              <li
                key={category}
                className={`category ${active === category ? "active" : ""}`}
                onClick={() => setActive(category)}
              >
                {category}
              </li>
            ))}
          </ul>
          {units > 0 && (
            <div className="cart-summary">
              <ShoppingCart size={20} />
              <div>
                <strong>{units} productos</strong>
                <small>Solicitud en preparación</small>
              </div>
            </div>
          )}
        </aside>
        <main className="products-area">
          <div className="catalog-header">
            <span>Abastecimiento para tu negocio</span>
            <h1>Catálogo Mayorista</h1>
            <p>Productos y stock consultados directamente desde Abastece+.</p>
          </div>
          {state.loading ? (
            <div className="catalog-state">Cargando catálogo...</div>
          ) : state.error ? (
            <div className="catalog-state error">
              {state.error}
              <small>Verifica que el servidor PHP esté iniciado.</small>
            </div>
          ) : !visible.length ? (
            <div className="catalog-state">
              <PackageOpen />
              <p>No hay productos disponibles.</p>
            </div>
          ) : (
            <div className="products-grid catalog-grid-sweep" key={active}>
              {visible.map((product, index) => (
                <article
                  className="product-card"
                  style={{ "--product-delay": `${index * 90}ms` }}
                  key={product.producto_id}
                >
                  <button className="favorite" aria-label="Guardar favorito">
                    <Heart size={20} />
                  </button>
                  <div className="product-image">
                    <img
                      src={productImages[product.producto_id] || "/logo.png"}
                      alt={product.nombre}
                    />
                  </div>
                  <small className="product-brand">
                    {product.marca} · {product.codigo_sku}
                  </small>
                  <h3>{product.nombre}</h3>
                  <span className="stock">
                    {Number(product.stock_disponible) > 0
                      ? `${product.stock_disponible} disponibles`
                      : "Sin stock"}
                  </span>
                  <div className="price-box">
                    <p>Precio desde</p>
                    <strong>
                      S/{" "}
                      {Number(
                        product.precio_desde || product.precio_base_sugerido,
                      ).toFixed(2)}
                    </strong>
                    <small>
                      Mínimo {product.compra_minima || 1} ·{" "}
                      {product.unidad_medida}
                    </small>
                  </div>
                  {cart.find(
                    (item) => item.producto_id === product.producto_id,
                  ) ? (
                    <div className="quantity-control">
                      <button
                        onClick={() => decreaseProduct(product.producto_id)}
                      >
                        -
                      </button>

                      <span>
                        {
                          cart.find(
                            (item) => item.producto_id === product.producto_id,
                          ).cantidad
                        }
                      </span>

                      <button onClick={() => addProduct(product)}>+</button>
                    </div>
                  ) : (
                    <button
                      className="cart-button"
                      onClick={() => addProduct(product)}
                    >
                      <ShoppingCart size={18} />
                      Añadir al carrito
                    </button>
                  )}
                </article>
              ))}
            </div>
          )}
        </main>
      </div>
    </section>
  );
}
