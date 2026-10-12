import { useCallback, useEffect, useMemo, useState } from "react";
import { createPortal } from "react-dom";
import {
  ArrowLeft,
  ArrowRight,
  CalendarDays,
  CheckCircle2,
  Clock3,
  FileText,
  Filter,
  MapPin,
  Package,
  Pencil,
  Plus,
  Save,
  Search,
  Truck,
  X,
} from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";
import RouteMap from "../components/RouteMap";

const labels = {
  PENDIENTE: "Pendiente",
  PREPARANDO: "Preparando",
  DESPACHADO: "Despachado",
  ENTREGADO: "Entregado",
  CANCELADO: "Cancelado",
  ASIGNADO: "Asignado",
  EN_TRAYECTO: "En ruta",
  FALLIDO: "Fallido",
};
function Badge({ state }) {
  const Icon =
    state === "ENTREGADO"
      ? CheckCircle2
      : state === "ASIGNADO" || state === "EN_TRAYECTO"
        ? Truck
        : Clock3;
  return (
    <span className={`log-badge ${state?.toLowerCase() || "none"}`}>
      <Icon size={15} />
      {labels[state] || "Sin asignar"}
    </span>
  );
}
export default function LogisticaOperacion({ module }) {
  const { session } = useAuth();
  const [rows, setRows] = useState([]),
    [loading, setLoading] = useState(true),
    [error, setError] = useState(""),
    [notice, setNotice] = useState("");
  const [search, setSearch] = useState(""),
    [filter, setFilter] = useState(""),
    [page, setPage] = useState(1),
    [editor, setEditor] = useState(null),
    [busy, setBusy] = useState(false);
  const load = useCallback(
    () =>
      apiRequest(module, { token: session.token, timeoutMs: 30000 })
        .then((data) => {
          setRows(data.datos || []);
          setError("");
        })
        .catch((e) => setError(e.message))
        .finally(() => setLoading(false)),
    [module, session.token],
  );
  useEffect(() => {
    load();
  }, [load]);
  const stock = module === "stock";
  const filtered = useMemo(
    () =>
      rows.filter(
        (row) =>
          Object.values(row)
            .join(" ")
            .toLowerCase()
            .includes(search.toLowerCase()) &&
          (!filter ||
            (stock
              ? row.categoria_nombre === filter
              : row.estado_pedido === filter)),
      ),
    [rows, search, filter, stock],
  );
  const pages = Math.max(1, Math.ceil(filtered.length / 8)),
    current = Math.min(page, pages),
    visible = filtered.slice((current - 1) * 8, current * 8);
  const open = (action, row) => {
    setEditor({
      action,
      row,
      id: stock ? row.lote_id : row.compra_id,
      stock: row.stock_disponible,
      motivo: "",
      transportista_id: row.transportista_id || "",
      ruta: row.descripcion_ruta || "",
      metodo_pago: row.metodo_pago || "",
      codigo_operacion: row.codigo_operacion || "",
    });
  };
  const save = async (event) => {
    event.preventDefault();
    setBusy(true);
    try {
      const result = await apiRequest(editor.action, {
        method: "POST",
        token: session.token,
        body: editor.action === "emitir_factura" ? { id: editor.id } : editor,
        timeoutMs: 25000,
      });
      setNotice(result.mensaje);
      setEditor(null);
      await load();
    } catch (e) {
      setEditor((v) => ({ ...v, error: e.message }));
    } finally {
      setBusy(false);
    }
  };
  const title = stock ? "Stock por lote" : "Despachos";
  return (
    <>
      {!stock && (
        <div className="log-dispatch-metrics">
          {[
            ["Total de despachos", rows.length, Package, "purple"],
            [
              "En preparación",
              rows.filter((r) => r.estado_pedido === "PREPARANDO").length,
              Truck,
              "orange",
            ],
            [
              "Entregados",
              rows.filter((r) => r.estado_pedido === "ENTREGADO").length,
              CheckCircle2,
              "green",
            ],
          ].map(([label, count, Icon, tone]) => (
            <article className={`metric-card ${tone}`} key={label}>
              <div className="metric-icon">
                <Icon />
              </div>
              <div>
                <small>{label}</small>
                <strong>{count}</strong>
              </div>
              <span className={`log-badge ${tone}`}>
                {rows.length ? Math.round((count / rows.length) * 100) : 0}%{" "}
                <small>del total</small>
              </span>
            </article>
          ))}
        </div>
      )}
      <section
        className={`panel-card log-panel ${stock ? "" : "log-dispatch-panel"}`}
      >
        <header className="log-heading">
          <div>
            <h2>{title}</h2>
            <p>Gestiona y consulta la información operativa de Abastece+.</p>
          </div>
          {!stock && (
            <button
              className="log-pink"
              onClick={() => setEditor({ action: "elegir_pedido" })}
            >
              <Plus size={19} />
              Nuevo despacho
            </button>
          )}
        </header>
        <div className="log-filters">
          <label>
            <Search size={20} />
            <input
              aria-label={`Buscar ${title}`}
              placeholder={
                stock
                  ? "Buscar producto, marca o lote…"
                  : "Buscar por código de compra, guía o transportista…"
              }
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
            />
          </label>
          <label className="log-select">
            <Filter size={19} />
            <select
              aria-label="Filtrar registros"
              value={filter}
              onChange={(e) => {
                setFilter(e.target.value);
                setPage(1);
              }}
            >
              <option value="">
                {stock ? "Todas las categorías" : "Todos los estados"}
              </option>
              {(stock
                ? [...new Set(rows.map((r) => r.categoria_nombre))]
                : Object.keys(labels).slice(0, 5)
              ).map((v) => (
                <option key={v} value={v}>
                  {stock ? v : labels[v]}
                </option>
              ))}
            </select>
          </label>
        </div>
        {error && (
          <p className="form-message error" role="alert">
            {error}
          </p>
        )}
        {notice && (
          <p className="log-notice" role="status">
            {notice}
          </p>
        )}
        <div className="data-table-wrap animated-table">
          <table className="data-table log-table">
            <thead>
              <tr>
                {(stock
                  ? [
                      "Lote",
                      "Nombre",
                      "Número de lote",
                      "Stock disponible",
                      "Fecha de vencimiento",
                      "Acciones",
                    ]
                  : [
                      "Código de compra",
                      "Estado del pedido",
                      "Código de guía",
                      "Transportista",
                      "Estado de entrega",
                      "Acciones",
                    ]
                ).map((v) => (
                  <th key={v}>{v}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {visible.map((row, index) => (
                <tr
                  key={row.lote_id || row.compra_id}
                  style={{ "--row-delay": `${index * 30}ms` }}
                >
                  {stock ? (
                    <>
                      <td>{row.lote_id}</td>
                      <td>
                        <div className="log-product">
                          <img src={row.imagen_url || "/logo.png"} alt="" />
                          <strong>{row.nombre}</strong>
                        </div>
                      </td>
                      <td>{row.numero_lote}</td>
                      <td>
                        <span className="log-stock">
                          {row.stock_disponible}
                        </span>
                      </td>
                      <td>
                        <span className="log-date">
                          <CalendarDays size={17} />
                          {row.fecha_vencimiento || "—"}
                        </span>
                      </td>
                      <td>
                        <button
                          className="log-soft"
                          onClick={() => open("ajustar_stock", row)}
                        >
                          <Pencil size={16} />
                          Ajustar stock
                        </button>
                      </td>
                    </>
                  ) : (
                    <>
                      <td>
                        <strong>{row.codigo_compra}</strong>
                      </td>
                      <td>
                        <Badge state={row.estado_pedido} />
                      </td>
                      <td>{row.codigo_guia || "—"}</td>
                      <td>{row.transportista_nombre || "Sin asignar"}</td>
                      <td>
                        <Badge state={row.estado_entrega} />
                      </td>
                      <td>
                        <div className="table-actions">
                          <button
                            className="log-purple"
                            disabled={[
                              "ENTREGADO",
                              "CANCELADO",
                              "DESPACHADO",
                            ].includes(row.estado_pedido)}
                            onClick={() => open("asignar_despacho", row)}
                          >
                            <Truck size={16} />
                            Asignar despacho
                          </button>
                          <button
                            className="log-soft"
                            disabled={
                              !!row.comprobante_id || !row.ruta_id || !row.transportista_id ||
                              row.estado_pedido === "CANCELADO"
                            }
                            title={!row.comprobante_id && !row.transportista_id ? "Asigna el despacho antes de emitir la factura" : undefined}
                            onClick={() => open("emitir_factura", row)}
                          >
                            <FileText size={16} />
                            {row.comprobante_id
                              ? "Factura emitida"
                              : "Emitir factura"}
                          </button>
                        </div>
                      </td>
                    </>
                  )}
                </tr>
              ))}
              {!visible.length && (
                <tr>
                  <td colSpan={6}>
                    {loading ? "Cargando…" : "No hay registros que coincidan."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        <footer className="log-pagination">
          <small>
            Mostrando {visible.length} de {filtered.length} registros
          </small>
          <div>
            <button
              aria-label="Página anterior"
              disabled={current === 1}
              onClick={() => setPage(current - 1)}
            >
              <ArrowLeft size={16} />
            </button>
            {Array.from({ length: pages }, (_, index) => index + 1)
              .filter(
                (n) => n === 1 || n === pages || Math.abs(n - current) < 2,
              )
              .map((n) => (
                <button
                  key={n}
                  className={current === n ? "active" : ""}
                  onClick={() => setPage(n)}
                >
                  {n}
                </button>
              ))}
            <button
              aria-label="Página siguiente"
              disabled={current === pages}
              onClick={() => setPage(current + 1)}
            >
              <ArrowRight size={16} />
            </button>
          </div>
        </footer>
      </section>
      {editor &&
        createPortal(
          <div className="modal-backdrop log-backdrop">
            <form
              className={`modal-card log-modal ${editor.action === "asignar_despacho" ? "log-dispatch-modal" : ""}`}
              onSubmit={save}
              role="dialog"
              aria-modal="true"
              aria-labelledby="log-modal-title"
            >
              <header className="modal-head">
                <div>
                  <span className="eyebrow">ACCIÓN OPERATIVA</span>
                  <h2 id="log-modal-title">
                    {editor.action === "ajustar_stock"
                      ? "Ajustar stock"
                      : editor.action === "asignar_despacho"
                        ? "Asignar despacho"
                        : editor.action === "emitir_factura"
                          ? "Emitir factura"
                          : "Nuevo despacho"}
                  </h2>
                  <p>
                    {editor.action === "asignar_despacho"
                      ? "Consulta las rutas del conductor y asigna esta entrega."
                      : editor.action === "ajustar_stock"
                        ? "Modifica la cantidad disponible y registra el motivo del ajuste."
                        : editor.action === "emitir_factura"
                          ? "Confirma la emisión para el transportista asignado."
                          : "Selecciona el pedido y registra su documento."}
                  </p>
                </div>
                <button
                  type="button"
                  aria-label="Cerrar"
                  className="icon-button"
                  disabled={busy}
                  onClick={() => setEditor(null)}
                >
                  <X />
                </button>
              </header>
              {editor.action === "elegir_pedido" ? (
                <div className="log-order-picker">
                  {rows
                    .filter(
                      (r) =>
                        !["ENTREGADO", "CANCELADO", "DESPACHADO"].includes(
                          r.estado_pedido,
                        ),
                    )
                    .map((r) => (
                      <button
                        type="button"
                        key={r.compra_id}
                        onClick={() => open("asignar_despacho", r)}
                      >
                        <Package />
                        {r.codigo_compra}
                        <ArrowRight />
                      </button>
                    ))}
                </div>
              ) : (
                <>
                  {editor.action === "ajustar_stock" && (
                    <>
                      <div className="log-summary">
                        <Package />
                        <div>
                          <small>Producto</small>
                          <strong>{editor.row.nombre}</strong>
                        </div>
                        <div>
                          <small>N.º de lote</small>
                          <strong>{editor.row.numero_lote}</strong>
                        </div>
                      </div>
                      <div className="log-form-grid">
                        <label>
                          Stock disponible
                          <input
                            required
                            min="0"
                            step="1"
                            type="number"
                            value={editor.stock}
                            onChange={(e) =>
                              setEditor({ ...editor, stock: e.target.value })
                            }
                          />
                        </label>
                        <label>
                          Motivo del ajuste
                          <input
                            required
                            placeholder="Ej. merma, conteo físico, daño…"
                            value={editor.motivo}
                            onChange={(e) =>
                              setEditor({ ...editor, motivo: e.target.value })
                            }
                          />
                        </label>
                      </div>
                    </>
                  )}
                  {editor.action === "asignar_despacho" && (
                    <DispatchFields
                      editor={editor}
                      setEditor={setEditor}
                      token={session.token}
                    />
                  )}
                  {editor.action === "emitir_factura" && (
                    <>
                      <div className="log-summary">
                        <FileText />
                        <div>
                          <small>Pedido</small>
                          <strong>{editor.row.codigo_compra}</strong>
                        </div>
                        <div>
                          <small>Total de la factura</small>
                          <strong>
                            S/ {Number(editor.row.total).toFixed(2)}
                          </strong>
                        </div>
                      </div>
                      <p>
                        La factura quedará disponible en Facturas y para el
                        transportista asignado.
                      </p>
                      <div className="log-summary">
                        <Truck />
                        <div>
                          <small>Transportista asignado</small>
                          <strong>{editor.row.transportista_nombre}</strong>
                        </div>
                        <div>
                          <small>Guía de remisión</small>
                          <strong>{editor.row.codigo_guia}</strong>
                        </div>
                      </div>
                      <p>El pago registrado en la compra se incorporará automáticamente a la factura.</p>
                    </>
                  )}
                  {editor.error && (
                    <p className="form-message error" role="alert">
                      {editor.error}
                    </p>
                  )}
                  <footer className="modal-actions">
                    <button
                      type="button"
                      className="log-soft"
                      disabled={busy}
                      onClick={() => setEditor(null)}
                    >
                      Cancelar
                    </button>
                    <button disabled={busy} className="log-pink">
                      <Save size={18} />
                      {busy
                        ? "Guardando…"
                        : editor.action === "emitir_factura"
                          ? "Emitir factura"
                          : "Guardar cambios"}
                    </button>
                  </footer>
                </>
              )}
            </form>
          </div>,
          document.body,
        )}
    </>
  );
}
function DispatchFields({ editor, setEditor, token }) {
  const [drivers, setDrivers] = useState([]),
    [preview, setPreview] = useState(null),
    [loading, setLoading] = useState(!!editor.transportista_id),
    [error, setError] = useState("");
  useEffect(() => {
    let live = true;
    apiRequest("transportistas", { token })
      .then((d) => {
        if (live) setDrivers(d.datos);
      })
      .catch((e) => {
        if (live) setError(e.message);
      });
    return () => {
      live = false;
    };
  }, [token]);
  const id = editor.transportista_id,
    purchase = editor.id;
  useEffect(() => {
    if (!id) return;
    let live = true;
    apiRequest("previsualizar_despacho", {
      token,
      params: { transportista_id: id, compra_id: purchase },
      timeoutMs: 40000,
    })
      .then((data) => {
        if (live) setPreview(data.datos);
      })
      .catch((e) => {
        if (live) setError(e.message);
      })
      .finally(() => {
        if (live) setLoading(false);
      });
    return () => {
      live = false;
    };
  }, [id, purchase, token]);
  const driver = drivers.find(
    (d) => Number(d.usuario_interno_id) === Number(id),
  );
  return (
    <>
      <div className="log-form-grid">
        <label>
          Transportista
          <select
            required
            value={id}
            onChange={(e) => {
              setLoading(!!e.target.value);
              setError("");
              setPreview(null);
              setEditor({ ...editor, transportista_id: e.target.value });
            }}
          >
            <option value="">Selecciona un transportista</option>
            {drivers.map((d) => (
              <option key={d.usuario_interno_id} value={d.usuario_interno_id}>
                {d.nombre} · {d.pendientes} pendientes
              </option>
            ))}
          </select>
        </label>
        <label>
          Placa del transporte
          <input
            readOnly
            value={driver?.placa || ""}
            placeholder="Se carga al seleccionar el conductor"
          />
        </label>
        <label className="log-full">
          Recorrido / indicaciones
          <input
            required
            value={editor.ruta}
            placeholder="Indicaciones para esta entrega…"
            onChange={(e) => setEditor({ ...editor, ruta: e.target.value })}
          />
        </label>
      </div>
      <div className="log-route-preview">
        <h3>
          <MapPin size={20} />
          Ruta del transportista y nueva entrega
        </h3>
        {loading ? (
          <p>Calculando las rutas del conductor…</p>
        ) : error ? (
          <p role="alert" className="form-message error">
            {error}
          </p>
        ) : preview ? (
          <>
            <RouteMap
              routes={preview.rutas}
              itinerary={preview.recorrido}
              selectedId={preview.propuesta_id}
              onSelect={() => {}}
              small
            />
            <p>
              <strong>Destino: </strong>
              {preview.destino}
            </p>
            <small>{preview.mensaje}</small>
            <ol>
              {preview.recorrido.paradas.map((p) => (
                <li key={p.ruta_id}>
                  {p.codigo} · {p.direccion}
                </li>
              ))}
            </ol>
            {preview.recorrido.distancia_m != null && (
              <div className="log-route-distance">
                <strong>
                  {(preview.recorrido.distancia_m / 1000).toFixed(1)} km
                </strong>
                <span>
                  {Math.round(preview.recorrido.duracion_s / 60)} min estimados
                </span>
              </div>
            )}
            {preview.recorrido.pendientes.length > 0 && (
              <p className="log-notice">
                Sin localizar: {preview.recorrido.pendientes.join(", ")}. La
                ruta aparecerá cuando la dirección pueda localizarse.
              </p>
            )}
          </>
        ) : (
          <p>
            Selecciona un transportista para consultar sus entregas pendientes.
          </p>
        )}
      </div>
    </>
  );
}
