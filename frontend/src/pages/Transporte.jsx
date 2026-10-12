import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  ArrowDown,
  ArrowRight,
  CalendarDays,
  Check,
  Clock3,
  Download,
  FileText,
  Info,
  MapPin,
  Navigation,
  Package,
  Search,
  Truck,
  UserRound,
  Warehouse,
  X,
} from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";
import RouteMap from "../components/RouteMap";
import {
  dateLabel,
  freshGps,
  pendingRoute,
  routeClosedReason,
  routeMetrics,
  statusLabels,
  statusOf,
  timeOf,
} from "../services/transport";

function Status({ row }) {
  const status = statusOf(row);
  return (
    <span className={`transport-status ${status.toLowerCase()}`}>
      {status === "ENTREGADO" ? (
        <Check size={14} />
      ) : status === "CANCELADO" || status === "FALLIDO" ? (
        <X size={14} />
      ) : status === "EN_RUTA" ? (
        <Truck size={14} />
      ) : (
        <Clock3 size={14} />
      )}
      {statusLabels[status] || status}
    </span>
  );
}

export default function Transporte() {
  const { session } = useAuth();
  const admin = session.account.rol === "ADMINISTRADOR";
  const [drivers,setDrivers]=useState([]),[driver,setDriver]=useState("");
  const [rows, setRows] = useState([]),
    [selectedId, setSelectedId] = useState(null);
  const [query, setQuery] = useState(""),
    [status, setStatus] = useState("");
  const [error, setError] = useState(""),
    [message, setMessage] = useState(""),
    [loading, setLoading] = useState(true),
    [saving, setSaving] = useState(false);
  const [trackingId, setTrackingId] = useState(null),
    [gpsError, setGpsError] = useState("");
  useEffect(()=>{if(admin)apiRequest("transportistas",{token:session.token}).then(data=>setDrivers(data.datos||[])).catch(e=>setError(e.message));},[admin,session.token]);
  const [downloading, setDownloading] = useState(false);
  const [routeError, setRouteError] = useState("");
  const [lastSync, setLastSync] = useState(null);
  const [itinerary, setItinerary] = useState(null);
  const [detailClosing, setDetailClosing] = useState(false);
  const closeTimer = useRef(null);
  useEffect(() => () => window.clearTimeout(closeTimer.current), []);
  const closeDetail = () => {
    window.clearTimeout(closeTimer.current);
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setSelectedId(-1);
      return;
    }
    setDetailClosing(true);
    closeTimer.current = window.setTimeout(() => {
      setSelectedId(-1);
      setDetailClosing(false);
    }, 360);
  };
  const counter = useRef({ value: 0 }),
    mapSection = useRef(null);
  const load = useCallback(() => {
    const version = ++counter.current.value;
    return apiRequest("rutas_transporte", {
      token: session.token,
      params: admin ? {transportista_id:driver} : undefined,
      timeoutMs: 30000,
    })
      .then((data) => {
        if (version !== counter.current.value) return;
        setRows(data.rutas || []);
        setItinerary(data.recorrido || null);
        setLastSync(Date.now());
        setError("");
      })
      .catch((e) => {
        if (version === counter.current.value) setError(e.message);
      })
      .finally(() => {
        if (version === counter.current.value) setLoading(false);
      });
  }, [session.token,admin,driver]);
  useEffect(() => {
    const requests = counter.current;
    load();
    const timer = window.setInterval(() => {
      if (document.visibilityState === "visible") load();
    }, 15000);
    const visible = () => {
      if (document.visibilityState === "visible") load();
    };
    document.addEventListener("visibilitychange", visible);
    return () => {
      requests.value++;
      window.clearInterval(timer);
      document.removeEventListener("visibilitychange", visible);
    };
  }, [load]);
  const selectedBase =
    rows.find((row) => Number(row.ruta_id) === Number(selectedId)) ||
    (selectedId === null ? rows[0] : null);
  const selected = selectedBase;
  const tracked = rows.find(
    (row) => Number(row.ruta_id) === Number(trackingId),
  );
  const trackingAllowed =
    !admin && !!trackingId &&
    tracked?.estado_entrega === "EN_TRAYECTO" &&
    pendingRoute(tracked);
  useEffect(() => {
    if (!trackingAllowed || !navigator.geolocation) return;
    let current = true,
      lastSent = 0,
      sending = false;
    let watch;
    try {
      watch = navigator.geolocation.watchPosition(
        (position) => {
          if (!current || sending || Date.now() - lastSent < 10000) return;
          sending = true;
          lastSent = Date.now();
          apiRequest("ubicacion_ruta", {
            method: "POST",
            token: session.token,
            body: {
              ruta_id: trackingId,
              latitud: position.coords.latitude,
              longitud: position.coords.longitude,
              precision_m: position.coords.accuracy,
              capturado_ms: Math.round(position.timestamp),
            },
          })
            .then(() => {
              if (current) {
                setGpsError("");
                load();
              }
            })
            .catch((e) => {
              if (current) {
                setGpsError(e.message);
                setTrackingId(null);
              }
            })
            .finally(() => {
              sending = false;
            });
        },
        (err) => {
          if (current) {
            setGpsError(
              err.code === 1
                ? "Permiso de ubicación denegado. Habilítalo para compartir el GPS."
                : "No se pudo obtener tu ubicación. Revisa el GPS y la conexión.",
            );
            setTrackingId(null);
          }
        },
        { enableHighAccuracy: true, maximumAge: 5000, timeout: 20000 },
      );
    } catch {
      queueMicrotask(() => {
        if (current) {
          setGpsError(
            "El navegador no pudo activar la ubicación. Revisa los permisos de GPS.",
          );
          setTrackingId(null);
        }
      });
    }

    return () => {
      current = false;
      if (watch !== undefined) navigator.geolocation.clearWatch(watch);
    };
  }, [trackingId, trackingAllowed, session.token, load]);
  const select = useCallback((id) => {
    window.clearTimeout(closeTimer.current);
    setDetailClosing(false);
    setSelectedId(id);
    setMessage("");
    setRouteError("");
  }, []);
  const visibleRows = useMemo(
    () =>
      rows.filter(
        (row) =>
          (!status || statusOf(row) === status) &&
          `${row.codigo_guia} ${row.transportista} ${row.destino_direccion || row.direccion_entrega}`
            .toLowerCase()
            .includes(query.trim().toLowerCase()),
      ),
    [rows, query, status],
  );
  const metrics = routeMetrics(rows);
  const update = async (action, body) => {
    setSaving(true);
    setError("");
    setMessage("");
    try {
      const data = await apiRequest(action, {
        method: "POST",
        token: session.token,
        body,
        timeoutMs: 20000,
      });
      setMessage(data.mensaje || "Cambios guardados");
      if (action === "actualizar_entrega" && body.estado === "ENTREGADO") {
        setRows((current) =>
          current.map((row) =>
            Number(row.ruta_id) === Number(body.id)
              ? {
                  ...row,
                  estado_entrega: "ENTREGADO",
                  estado_pedido: "ENTREGADO",
                  latitud: null,
                  longitud: null,
                }
              : row,
          ),
        );
        setTrackingId((current) =>
          Number(current) === Number(body.id) ? null : current,
        );
      }
      await load();
      return true;
    } catch (e) {
      setError(e.message);
      return false;
    } finally {
      setSaving(false);
    }
  };
  const showRoute = async (start = false) => {
    setSaving(true);
    setRouteError("");
    setMessage("");
    try {
      const data = await apiRequest(
        start ? "actualizar_entrega" : "preparar_recorrido",
        {
          method: "POST",
          token: session.token,
          body: {
            id: selected.ruta_id,
            ...(start ? { estado: "EN_TRAYECTO" } : {}),
          },
          timeoutMs: 20000,
        },
      );
      await load();
      setMessage(data.mensaje || "Recorrido mostrado en el mapa.");
      mapSection.current?.scrollIntoView({
        behavior: "smooth",
        block: "center",
      });
    } catch (e) {
      setRouteError(e.message);
    } finally {
      setSaving(false);
    }
  };
  const startGps = () => {
    if (!navigator.geolocation || !window.isSecureContext) {
      setGpsError(
        "El GPS requiere HTTPS o localhost y un navegador con acceso a ubicación.",
      );
      return;
    }
    setGpsError("");
    setTrackingId(selected.ruta_id);
  };
  const downloadInvoice = async () => {
    setDownloading(true);
    setError("");
    try {
      const result = await apiRequest("buscar_comprobante", {
        token: session.token,
        params: { id: selected.comprobante_id },
      });
      const { downloadReceipt } = await import("../services/comprobantePdf");
      await downloadReceipt(result.comprobante);
    } catch (e) {
      setError(e.message || "No se pudo descargar la factura.");
    } finally {
      setDownloading(false);
    }
  };
  const closedReason = routeClosedReason(selected);
  const closed = !!closedReason;
  const today = new Date();
  return (
    <main className={`transport-page ${selected ? "with-detail" : ""}`}>
      <div className="transport-main">
        <header className="transport-heading">
          <div>
            <span className="transport-eyebrow">MÓDULO DE TRANSPORTE</span>
            <h1>{admin?"Rutas de transporte":"Mis rutas"}</h1>
            <p>Gestiona y consulta el estado de tus entregas en tiempo real.</p>
          </div>
          <div className="transport-today">
            <CalendarDays size={24} />
            <div>
              <strong>
                Hoy,{" "}
                {today.toLocaleDateString("es-PE", {
                  day: "numeric",
                  month: "long",
                  year: "numeric",
                })}
              </strong>
              <span>
                {today.toLocaleDateString("es-PE", { weekday: "long" })}
              </span>
            </div>
          </div>
        </header>
        {admin && <label className="transport-admin-filter">Transportista<select value={driver} onChange={e=>{setDriver(e.target.value);setSelectedId(null);setTrackingId(null);}}><option value="">Todos los transportistas</option>{drivers.map(r=><option key={r.usuario_interno_id} value={r.usuario_interno_id}>{r.nombre}</option>)}</select></label>}
        <div className="transport-stats">
          {metrics.map(({ status: key, count, percentage }, index) => {
            const Icon = [Package, Truck, FileText, X][index];
            return (
              <article
                className={`transport-stat ${key.toLowerCase()}`}
                key={key}
              >
                <span>
                  <Icon size={25} />
                </span>
                <div>
                  <strong>{count}</strong>
                  <p>
                    {
                      ["Entregadas", "En ruta", "Pendientes", "Canceladas"][
                        index
                      ]
                    }
                  </p>
                </div>
                <small>{percentage}%</small>
              </article>
            );
          })}
        </div>
        <div className="transport-sync">
          <span>
            {lastSync
              ? `Actualizado ${new Date(lastSync).toLocaleTimeString("es-PE")} · actualización cada 15 s`
              : "Cargando rutas…"}
          </span>
        </div>
        {error && (
          <p className="transport-alert" role="alert">
            {error}
          </p>
        )}
        {message && (
          <p className="transport-message" role="status">
            {message}
          </p>
        )}
        {gpsError && (
          <p className="transport-alert" role="alert">
            {gpsError}
          </p>
        )}
        {trackingAllowed && (
          <p className="transport-message">
            GPS activo para {tracked.codigo_guia}.{" "}
            <button
              className="transport-button"
              onClick={() => setTrackingId(null)}
            >
              Detener GPS
            </button>
          </p>
        )}
        <section ref={mapSection} className="transport-map-section">
          <RouteMap
            routes={rows}
            itinerary={itinerary}
            selectedId={selected?.ruta_id}
            onSelect={select}
            tracking={trackingAllowed}
          />
        </section>
        {itinerary && (
          <div className="transport-map-itinerary">
            <strong>Recorrido de mis entregas pendientes</strong>
            {itinerary.paradas.length
              ? itinerary.paradas
                  .map((stop, index) => `${index + 1}. ${stop.codigo}`)
                  .join(" → ")
              : "Todavía no hay destinos localizados."}
            {itinerary.distancia_m != null && (
              <small>
                {(itinerary.distancia_m / 1000).toFixed(1)} km ·{" "}
                {Math.round(itinerary.duracion_s / 60)} min estimados
              </small>
            )}
            {!!itinerary.pendientes.length && (
              <small>
                Sin ubicar: {itinerary.pendientes.join(", ")}. Estas entregas
                todavía no forman parte del trazado.
              </small>
            )}
            {itinerary.paradas.some(
              (stop) => stop.precision !== "INMUEBLE",
            ) && (
              <small>
                Hay ubicaciones aproximadas a la calle; no se ha confirmado la
                puerta de esas tiendas.
              </small>
            )}
          </div>
        )}
        <section className="transport-list">
          <div className="transport-list-heading">
            <h2>Listado de rutas</h2>
            <label className="transport-search">
              <Search size={18} />
              <input
                aria-label="Buscar rutas"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Buscar por código, conductor o destino…"
              />
            </label>
            <select
              aria-label="Estado de ruta"
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option value="">Todos los estados</option>
              {Object.entries(statusLabels).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
          </div>
          <div className="transport-table-wrap">
            <table className="transport-table">
              <thead>
                <tr>
                  {[
                    "Código",
                    "Conductor",
                    "Destino",
                    "Productos",
                    "Hora estimada",
                    "Estado",
                    "Acciones",
                  ].map((label) => (
                    <th key={label}>{label}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {visibleRows.map((row) => (
                  <tr
                    key={row.ruta_id}
                    className={
                      row.ruta_id === selected?.ruta_id ? "selected" : ""
                    }
                  >
                    <td>
                      <Truck size={20} />
                      <strong>{row.codigo_guia}</strong>
                    </td>
                    <td>{row.transportista}</td>
                    <td>{row.destino_direccion || row.direccion_entrega}</td>
                    <td>{row.items.length} productos</td>
                    <td>
                      {row.entrega_hasta
                        ? `Hasta ${timeOf(row.entrega_hasta)}`
                        : "Sin horario"}
                    </td>
                    <td>
                      <Status row={row} />
                    </td>
                    <td>
                      <button
                        className={`transport-button ${row.ruta_id === selected?.ruta_id ? "primary" : ""}`}
                        onClick={() => select(row.ruta_id)}
                      >
                        Ver detalle
                        <ArrowRight size={16} />
                      </button>
                    </td>
                  </tr>
                ))}
                {!visibleRows.length && (
                  <tr>
                    <td colSpan={7} className="transport-empty">
                      {loading
                        ? "Cargando rutas…"
                        : rows.length
                          ? "No hay rutas que coincidan con los filtros."
                          : "Aún no tienes rutas asignadas."}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>
      </div>
      {selected && (
        <aside
          key={selected.ruta_id}
          className={`transport-detail ${detailClosing ? "is-closing" : ""}`}
          aria-label="Detalle de ruta"
          onAnimationEnd={(event) => {
            if (detailClosing && event.target === event.currentTarget && event.animationName === "transport-panel-close") {
              window.clearTimeout(closeTimer.current);
              setSelectedId(-1);
              setDetailClosing(false);
            }
          }}
        >
          <header>
            <h2>Detalle de la ruta</h2>
            <button
              className="transport-icon-button"
              aria-label="Cerrar detalle"
              onClick={closeDetail}
            >
              <X size={22} />
            </button>
          </header>
          <div
            className="transport-detail-body"
            role="region"
            aria-label="Contenido del detalle"
            tabIndex={0}
          >
            {routeError && (
              <p className="transport-alert" role="alert">
                {routeError}
              </p>
            )}
            <div className="transport-route-title">
              <h3>{selected.codigo_guia}</h3>
              <Status row={selected} />
            </div>
            <section className="transport-detail-section">
              <h3>
                <FileText />
                Información del pedido
              </h3>
              <div className="transport-order-grid">
                <div>
                  <FileText />
                  <span>
                    Código de ruta<strong>{selected.codigo_guia}</strong>
                  </span>
                </div>
                <div>
                  <CalendarDays />
                  <span>
                    Fecha de salida
                    <strong>{dateLabel(selected.hora_salida)}</strong>
                  </span>
                </div>
                <div>
                  <Truck />
                  <span>
                    Vehículo<strong>{selected.vehiculo_placa}</strong>
                  </span>
                </div>
                <div>
                  <UserRound />
                  <span>
                    Conductor<strong>{selected.transportista}</strong>
                  </span>
                </div>
                <div>
                  <Package />
                  <span>
                    Total de productos
                    <strong>{selected.items.length} productos</strong>
                  </span>
                </div>
              </div>
            </section>
            <section className="transport-detail-section">
              <h3>
                <Warehouse />
                Destino cargado automáticamente
              </h3>
              <p className="transport-auto-notice">
                <Info size={21} />
                <span>
                  <strong>Dirección obtenida de la tienda del bodeguero</strong>
                  El destino se carga desde la dirección registrada para este
                  pedido.
                </span>
              </p>
              <div className="transport-destination">
                <MapPin />
                <div>
                  <strong>{selected.cliente}</strong>
                  <p>
                    {selected.direccion_entrega || "Dirección no registrada"}
                  </p>
                  {selected.referencia && (
                    <small>Referencia: {selected.referencia}</small>
                  )}
                </div>
                <span>Tienda / Minimarket</span>
              </div>
              {selected.mapa_mensaje && (
                <p className="transport-map-note">{selected.mapa_mensaje}</p>
              )}
            </section>
            <section className="transport-detail-section">
              <h3>
                <Truck />
                Resumen de la ruta
              </h3>
              <div className="transport-summary-addresses">
                <Warehouse />
                <div>
                  <small>Origen</small>
                  <strong>
                    {selected.origen_direccion ||
                      "Av. Argentina N.º 2833, Callao"}
                  </strong>
                </div>
                <ArrowDown />
                <MapPin />
                <div>
                  <small>Destino</small>
                  <strong>{selected.direccion_entrega}</strong>
                </div>
              </div>
              <div className="transport-summary-metrics">
                <span>
                  <Clock3 />
                  Llegada estimada
                  <strong>
                    {selected.entrega_hasta
                      ? dateLabel(selected.entrega_hasta)
                      : "Sin horario registrado"}
                  </strong>
                </span>
                {selected.distancia_m != null && (
                  <span>
                    <Navigation />
                    Recorrido
                    <strong>
                      {(selected.distancia_m / 1000).toFixed(1)} km ·{" "}
                      {Math.round(selected.duracion_s / 60)} min
                    </strong>
                  </span>
                )}
              </div>
              {!closed && (
                <div className="transport-controls">
                  {selected.estado_entrega === "EN_TRAYECTO" ? (
                    <button
                      className="transport-button"
                      onClick={() =>
                        trackingAllowed &&
                        Number(trackingId) === Number(selected.ruta_id)
                          ? setTrackingId(null)
                          : startGps()
                      }
                    >
                      {trackingAllowed &&
                      Number(trackingId) === Number(selected.ruta_id)
                        ? "Detener GPS"
                        : "Compartir mi GPS"}
                    </button>
                  ) : (
                    <button
                      disabled={saving}
                      className="transport-button primary transport-start-button"
                      onClick={() => showRoute(true)}
                    >
                                            <Truck size={23} aria-hidden="true" />
                      <span>{saving ? "Calculando recorrido…" : "Iniciar recorrido"}</span>
                      {!saving && <ArrowRight size={21} aria-hidden="true" />}
                    </button>
                  )}
                </div>
              )}
              <div className="transport-gps-info">
                <Navigation size={16} />
                <span>
                  {trackingAllowed &&
                  Number(trackingId) === Number(selected.ruta_id)
                    ? "Compartiendo GPS desde este dispositivo"
                    : freshGps(selected) && !closed
                      ? "Ubicación GPS reciente"
                      : "Sin ubicación GPS reciente"}
                </span>
              </div>
            </section>
            <section className="transport-products transport-detail-section">
              <header>
                <h3>
                  <Package size={23} />
                  Productos de la ruta
                </h3>
                <span>{selected.items.length} productos</span>
              </header>
              <div className="transport-product-grid">
                {selected.items.map((item, index) => (
                  <article key={`${item.nombre}-${index}`}>
                    <img
                      src={item.imagen_url || "/logo.png"}
                      alt={item.nombre}
                      onError={(e) => {
                        e.currentTarget.onerror = null;
                        e.currentTarget.src = "/logo.png";
                      }}
                    />
                    <div>
                      <strong>{item.nombre}</strong>
                      <small>{item.unidad_medida}</small>
                    </div>
                    <span>
                      {item.cantidad} {item.unidad_medida}
                    </span>
                  </article>
                ))}
              </div>
            </section>
            <DeliveryRegistration
              row={selected}
              closed={closed}
              saving={saving}
              onDeliver={update}
            />
            <section className="transport-detail-section">
              <h3>
                <FileText />
                Documentos
              </h3>
              <div className="transport-invoice">
                <span className="transport-pdf-icon">PDF</span>
                <div>
                  <strong>
                    {selected.tipo_comprobante === "BOLETA_ELECTRONICA"
                      ? "Boleta"
                      : "Factura"}{" "}
                    Logística
                  </strong>
                  <small>
                    {selected.comprobante_id
                      ? `${selected.serie}-${String(selected.correlativo).padStart(6, "0")}.pdf`
                      : "Aún no hay comprobante emitido"}
                  </small>
                </div>
                <button
                  disabled={!selected.comprobante_id || downloading}
                  onClick={downloadInvoice}
                  className="transport-button"
                >
                  <Download size={18} />
                  {downloading ? "Descargando…" : "Descargar factura"}
                </button>
              </div>
            </section>
            {!closed && (
              <button
                type="submit"
                form="transport-delivery"
                className="transport-button primary transport-deliver-button"
                disabled={saving}
              >
                <Check size={22} />
                {saving ? "Guardando…" : "Marcar como entregado"}
              </button>
            )}
            <footer className="transport-detail-footer">
              <button className="transport-button" onClick={closeDetail}>
                Cerrar
              </button>
            </footer>
          </div>
        </aside>
      )}
    </main>
  );
}

function DeliveryRegistration({ row, closed, saving, onDeliver }) {
  const now = new Date();
  const local =
    row.hora_entrega ||
    `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")} ${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`;
  const [date, setDate] = useState(local.slice(0, 10));
  const [time, setTime] = useState(local.slice(11, 16));
  return (
    <form
      id="transport-delivery"
      className="transport-detail-section transport-delivery"
      onSubmit={async (e) => {
        e.preventDefault();
        await onDeliver("actualizar_entrega", {
          id: row.ruta_id,
          estado: "ENTREGADO",
          fecha_entrega: date,
          hora_entrega: time,
        });
      }}
    >
      <h3>
        <CalendarDays />
        {closed ? "Entrega registrada" : "Registrar entrega"}
      </h3>
      <div>
        <label>
          Fecha de entrega {!closed && "*"}
          <input
            aria-label="Fecha de entrega"
            type="date"
            required
            value={closed ? (row.hora_entrega || "").slice(0, 10) : date}
            disabled={closed || saving}
            onChange={(e) => setDate(e.target.value)}
          />
        </label>
        <label>
          Hora de entrega {!closed && "*"}
          <input
            aria-label="Hora de entrega"
            type="time"
            required
            value={closed ? (row.hora_entrega || "").slice(11, 16) : time}
            disabled={closed || saving}
            onChange={(e) => setTime(e.target.value)}
          />
        </label>
      </div>
    </form>
  );
}
