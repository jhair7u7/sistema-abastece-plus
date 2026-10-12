import { ArrowDownUp, ArrowRight, Cookie, Crown, Gift, Heart, House, Layers, Milk, Package, PackageOpen, Search, ShieldCheck, ShoppingBasket, ShoppingCart, SprayCan, Tag, Tags, X } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { apiRequest } from "../services/api";
import { useAuth } from "../context/AuthContext";
import { useNavigate } from "react-router-dom";
import { useCart } from "../context/CartContext";

export default function Catalogo() {
  const [products, setProducts] = useState([]);
  const [active, setActive] = useState("Todos");
  const { session }=useAuth();
  const navigate=useNavigate();
  const token=session?.type==='bodeguero'?session.token:'';
  const [favoriteState,setFavoriteState]=useState({token:'',ids:[]});
  const [favoritePending,setFavoritePending]=useState(null);
  const [favoriteMessage,setFavoriteMessage]=useState('');
  const favoriteIds=favoriteState.token===token?favoriteState.ids:[];
  useEffect(()=>{if(!token)return;let live=true;apiRequest('listar_favoritos',{token}).then(d=>{if(live)setFavoriteState({token,ids:d.favoritos.map(p=>Number(p.producto_id))});}).catch(e=>{if(live)setFavoriteMessage(e.message);});return()=>{live=false;};},[token]);
  const toggleFavorite=async product=>{
    if(!token){setFavoriteMessage('Inicia sesión como bodeguero para guardar tus favoritos.');if(!session)navigate('/ingresar');return;}
    const id=Number(product.producto_id),selected=!favoriteIds.includes(id);
    setFavoritePending(id);setFavoriteMessage('');
    try{await apiRequest('guardar_favorito',{method:'POST',token,body:{producto_id:id,favorito:selected},timeoutMs:15000});setFavoriteState(current=>({token,ids:selected?[...current.ids,id]:current.ids.filter(value=>value!==id)}));}
    catch(error){setFavoriteMessage(error.message);}finally{setFavoritePending(null);}
  };
  const [state, setState] = useState({ loading: true, error: "" });
  const { addProduct, decreaseProduct, cart } = useCart();

  useEffect(() => {
    apiRequest("listar_productos")
      .then((data) => setProducts(data.productos || []))
      .catch((error) => setState({ loading: false, error: error.message }))
      .finally(() => setState((current) => ({ ...current, loading: false })));
  }, []);

  const [query,setQuery]=useState('');
  const [mode,setMode]=useState('all');
  const [sort,setSort]=useState('relevance');
  const [stockOnly,setStockOnly]=useState(true);
  const categories=useMemo(()=>['Todos',...new Set(products.map(p=>p.categoria).filter(Boolean))],[products]);
  const visible=useMemo(()=>{
    const text=normalize(query.trim());
    const filtered=products.filter(p=>(active==='Todos'||p.categoria===active)&&(!stockOnly||Number(p.stock_disponible)>0)&&(!text||normalize(`${p.nombre} ${p.marca} ${p.categoria}`).includes(text))&&(mode!=='offers'||discount(p)>0));
    return filtered.sort((a,b)=>mode==='stock'||sort==='stock'?Number(b.stock_disponible)-Number(a.stock_disponible):mode==='price'||sort==='price'?price(a)-price(b):sort==='name'?a.nombre.localeCompare(b.nombre,'es'):sort==='popular'?Number(b.unidades_vendidas)-Number(a.unidades_vendidas):0);
  },[products,active,stockOnly,query,mode,sort]);
  const bestSellers=useMemo(()=>[...products].filter(p=>Number(p.unidades_vendidas)>0&&(!stockOnly||Number(p.stock_disponible)>0)).sort((a,b)=>Number(b.unidades_vendidas)-Number(a.unidades_vendidas)).slice(0,5),[products,stockOnly]);
  const featured=visible.filter(p=>visualPromotion(p)).sort((a,b)=>visualPromotion(a).order-visualPromotion(b).order);
  const featuredIds=new Set(featured.map(p=>p.producto_id));
  const remaining=visible.filter(p=>!featuredIds.has(p.producto_id));
  const filteredView=active!=='Todos'||query.trim()||mode!=='all'||sort!=='relevance';
  const tile=(product,compact=false,index=0)=> <CatalogProduct key={product.producto_id} product={product} compact={compact} index={index} quantity={cart.find(item=>item.producto_id===product.producto_id)?.cantidad||0} favorite={favoriteIds.includes(Number(product.producto_id))} pending={favoritePending!==null||!!token&&favoriteState.token!==token} toggleFavorite={toggleFavorite} addProduct={addProduct} decreaseProduct={decreaseProduct}/>;
  const focusProducts=()=>document.getElementById('catalog-products')?.scrollIntoView({behavior:window.matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth',block:'start'});
  return <section className="catalog-page catalog-showcase"><div className="catalog-container">
    <aside className="catalog-sidebar" aria-label="Categorías del catálogo"><h2 className="catalog-category-label">Categorías</h2><ul>{categories.map(category=>{const Icon=categoryIcon(category);return <li key={category}><button type="button" className={`category ${active===category?'active':''}`} aria-pressed={active===category} onClick={()=>setActive(category)}><span><Icon size={19}/></span>{category}</button></li>;})}</ul><div className="catalog-side-note"><Tags size={24}/><div><strong>Precios mayoristas</strong><small>Todo para abastecer tu bodega</small></div></div></aside>
    <main className="products-area">
      <section className="catalog-promo catalog-promo-reference"><div className="catalog-promo-copy"><span className="catalog-promo-badge">PROMOCIÓN</span><h1>Precios que hacen <br/>crecer tu bodega</h1><p>Ahorra más en productos seleccionados <br/>de las mejores marcas.</p><button onClick={()=>{setMode('offers');focusProducts();}}>Ver ofertas<ArrowRight size={16}/></button></div></section>
      <div className="catalog-toolbar"><label className="catalog-search"><Search size={20}/><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Buscar productos, marcas o categorías…" aria-label="Buscar productos, marcas o categorías"/>{query&&<button onClick={()=>setQuery('')} aria-label="Limpiar búsqueda"><X size={16}/></button>}</label><div className="catalog-filter-pills" aria-label="Filtros de productos">{[['all','Todos',null],['offers','En oferta',Tag],['stock','Más stock',Layers],['price','Menor precio',ArrowDownUp]].map(([key,label,Icon])=><button key={key} className={mode===key?'active':''} aria-pressed={mode===key} onClick={()=>{setMode(key);setSort('relevance');}}>{Icon&&<Icon size={18}/>} {label}</button>)}</div><label className="catalog-sort"><span>Ordenar por</span><select aria-label="Ordenar productos" value={sort} onChange={e=>{setSort(e.target.value);if(mode!=='offers')setMode('all');}}><option value="relevance">Más relevantes</option><option value="popular">Más vendidos</option><option value="price">Menor precio</option><option value="stock">Más stock</option><option value="name">Nombre A–Z</option></select></label><label className="catalog-stock-switch">Solo con stock<input type="checkbox" checked={stockOnly} onChange={e=>setStockOnly(e.target.checked)}/><span aria-hidden="true"/></label></div>
      {favoriteMessage&&<p className="catalog-favorite-message" role="status">{favoriteMessage}</p>}
      {state.loading?<div className="catalog-state">Cargando catálogo…</div>:state.error?<div className="catalog-state error">{state.error}</div>:<>
        <section id="catalog-products" className="catalog-product-section"><header className="catalog-section-heading"><Gift size={28}/><h2>{mode==='offers'?'Ofertas para tu bodega':filteredView?'Productos del catálogo':'Ofertas para tu bodega'}</h2><span className={!filteredView||mode==='offers'?'catalog-offer-capsule':undefined}>{!filteredView||mode==='offers'?'Precios especiales por tiempo limitado':`${visible.length} productos encontrados`}</span>{!filteredView&&visible.length>5&&<button onClick={()=>{setQuery('');setMode('offers');focusProducts();}}>Ver todas las ofertas<ArrowRight size={16}/></button>}</header>{!visible.length?<div className="catalog-state"><PackageOpen/><p>{mode==='offers'?'No hay ofertas vigentes registradas.':'No encontramos productos con estos filtros.'}</p><button className="merchant-button soft" onClick={()=>{setActive('Todos');setQuery('');setMode('all');setStockOnly(false);}}>Ver el catálogo completo</button></div>:<div key={`${active}-${mode}-${sort}-${query}`} className="products-grid catalog-grid-sweep">{(filteredView?visible:featured).map((p,index)=>tile(p,false,index))}</div>}</section>
        {!filteredView&&bestSellers.length>0&&<section className="catalog-product-section"><header className="catalog-section-heading"><Crown size={27}/><h2>Más vendidos</h2><span>Los productos preferidos por las bodegas como la tuya.</span><button onClick={()=>{setSort('popular');focusProducts();}}>Ver más vendidos<ArrowRight size={16}/></button></header><div className="products-grid catalog-bestsellers catalog-grid-sweep">{bestSellers.map((p,index)=>tile(p,true,index))}</div></section>}
        {!filteredView&&remaining.length>0&&<section id="catalog-all" className="catalog-product-section"><header className="catalog-section-heading"><PackageOpen size={26}/><h2>Todos los productos</h2><span>{visible.length} productos disponibles</span></header><div className="products-grid catalog-grid-sweep">{remaining.map((p,index)=>tile(p,false,index))}</div></section>}
      </>}
    </main></div></section>;
}
const normalize=value=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
const price=p=>Number(p.precio_desde||p.precio_base_sugerido||p.precio_unitario||0);
// Presentation-only promotions never change product objects or cart prices.
const VISUAL_PROMOTIONS=[
  {name:'Ajinomen Gallina',percent:20,previous:36},
  {name:'Aceite Primor Premium',percent:15,previous:150},
  {name:'Avena 3 Ositos Tradicional',percent:25,previous:144},
  {name:'Arroz Costeño Extra',percent:18,previous:225},
  {name:'Atún Primor Trozos en Aceite',percent:12,previous:175},
];
const visualPromotion=p=>{const order=VISUAL_PROMOTIONS.findIndex(item=>normalize(item.name)===normalize(p.nombre));return order<0?null:{...VISUAL_PROMOTIONS[order],order};};
const discount=p=>visualPromotion(p)?.percent||0;
function categoryIcon(category){return {'Todos':ShoppingBasket,'Abarrotes':Package,'Bebidas':Milk,'Limpieza':SprayCan,'Cuidado Personal':ShieldCheck,'Snacks':Cookie,'Lácteos':Milk,'Conservas':Package,'Cuidado del Hogar':House}[category]||Package;}
function CatalogProduct({product,compact,index,quantity,favorite,pending,toggleFavorite,addProduct,decreaseProduct}){
 const inStock=Number(product.stock_disponible)>0,promotion=compact?null:visualPromotion(product),offer=promotion?.percent||0;
 return <article className={`product-card ${compact?'catalog-product-compact':''}`} style={{'--product-delay':`${Math.min(index,7)*60}ms`}}>
  {!inStock&&<span className="sold-out-ribbon">Agotado</span>}
  {offer>0&&<span className="catalog-discount" title="Descuento visual de demostración">-{offer}%</span>}
  <button type="button" className={`favorite ${favorite?'is-favorite':''}`} aria-label={`${favorite?'Quitar':'Guardar'} favorito: ${product.nombre}`} aria-pressed={favorite} disabled={pending} onClick={()=>toggleFavorite(product)}><Heart size={18}/></button>
  <div className="product-image"><img src={product.imagen_url||'/logo.png'} alt={product.nombre}/></div>
  <div className="catalog-product-details"><small className="product-brand">{product.marca}</small><h3>{product.nombre}</h3><span className={`stock ${inStock?'':'out'}`}>{inStock?`${product.stock_disponible} disponibles`:'Sin stock'}</span><div className="price-box"><strong>S/ {price(product).toFixed(2)}</strong>{offer>0&&<del>S/ {Number(promotion.previous).toFixed(2)}</del>}<small>Mín. {product.compra_minima||1} · {product.unidad_medida}</small></div></div>
  {quantity>0?<div className="quantity-control"><button aria-label={`Reducir cantidad de ${product.nombre}`} onClick={()=>decreaseProduct(product.producto_id)}>−</button><span>{quantity}</span><button aria-label={`Aumentar cantidad de ${product.nombre}`} disabled={quantity>=Number(product.stock_disponible)} onClick={()=>addProduct(product)}>+</button></div>:<button className="cart-button" disabled={!inStock} onClick={()=>addProduct(product)}><ShoppingCart size={16}/>{inStock?'Añadir al carrito':'Producto agotado'}</button>}
 </article>;
}
