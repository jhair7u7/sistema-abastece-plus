import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  Banknote,
  CalendarDays,
  CircleDollarSign,
  CreditCard,
  Download,
  Eye,
  FileText,
  Info,
  RefreshCw,
  Search,
  X,
} from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";
import {
  dateOf,
  filterReceipts,
  money,
  numberOf,
  paymentNames,
  typeOf,
} from "../services/comprobantes";

function Payment({ method }) {
  const Icon = method === "EFECTIVO" ? Banknote : CreditCard;
  return (
    <span className="receipt-payment">
      <span className={`payment-symbol ${method?.toLowerCase()}`}>
        {method === "YAPE" ? (
          <img src="/payments/yape.png" alt="" />
        ) : (
          <Icon size={20} />
        )}
      </span>
      {paymentNames[method] || "—"}
    </span>
  );
}

export default function Facturas() {
  const { session } = useAuth();
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selected, setSelected] = useState(null);
  const [busy, setBusy] = useState(null);
  const [filters, setFilters] = useState({
    type: "",
    range: "",
    query: "",
    from: "",
    to: "",
  });
  const requestId = useRef(0);
  const load = useCallback(() => {
    return apiRequest("listar_comprobantes", { token: session.token })
      .then((result) => {
        setRows(result.comprobantes || []);
        setError("");
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, [session.token]);
  useEffect(() => {
    load();
  }, [load]);
  const refresh = () => {
    setLoading(true);
    setError("");
    load();
  };
  const visible = useMemo(() => filterReceipts(rows, filters), [rows, filters]);
  const change = (e) =>
    setFilters((value) => ({ ...value, [e.target.name]: e.target.value }));
  const close = useCallback(() => {
    requestId.current++;
    setSelected(null);
    setBusy(null);
  }, []);
  const detail = async (row, download = false) => {
    const id = ++requestId.current;
    setBusy(row.comprobante_id);
    setError("");
    try {
      const result = await apiRequest("buscar_comprobante", {
        token: session.token,
        params: { id: row.comprobante_id },
      });
      if (id !== requestId.current) return;
      if (download) {
        const { downloadReceipt } = await import("../services/comprobantePdf");
        await downloadReceipt(result.comprobante);
      } else setSelected(result.comprobante);
    } catch (e) {
      if (id === requestId.current) setError(e.message);
    } finally {
      if (id === requestId.current) setBusy(null);
    }
  };
  const downloadSelected = async () => {
    setBusy(selected.comprobante_id);
    try {
      const { downloadReceipt } = await import("../services/comprobantePdf");
      await downloadReceipt(selected);
    } catch {
      setError("No se pudo generar el PDF. Intenta nuevamente.");
    } finally {
      setBusy(null);
    }
  };
  return (
    <main className="receipts-page">
      <section className="receipts-panel">
        <header className="receipts-heading">
          <h1>Comprobantes</h1>
          <p>Gestiona y consulta los comprobantes emitidos por Abastece+.</p>
        </header>
        <div className="receipt-stats">
          {[
            ["Total de comprobantes", rows.length, FileText, "purple"],
            [
              "Facturas",
              rows.filter((r) => typeOf(r) === "Factura").length,
              FileText,
              "blue",
            ],
            [
              "Boletas",
              rows.filter((r) => typeOf(r) === "Boleta").length,
              FileText,
              "pink",
            ],
            [
              "Total facturado",
              money(rows.reduce((sum, r) => sum + Number(r.total), 0)),
              CircleDollarSign,
              "green",
            ],
          ].map(([label, value, Icon, color]) => (
            <div className={`receipt-stat ${color}`} key={label}>
              <span className="receipt-stat-icon">
                <Icon size={23} />
              </span>
              <div>
                <small>{label}</small>
                <strong>{loading && !rows.length ? "—" : value}</strong>
              </div>
            </div>
          ))}
        </div>
        <div className="receipt-filters">
          <label>
            Tipo de comprobante
            <select name="type" value={filters.type} onChange={change}>
              <option value="">Todos</option>
              <option value="FACTURA_ELECTRONICA">Factura</option>
              <option value="BOLETA_ELECTRONICA">Boleta</option>
            </select>
          </label>
          <label>
            Rango de fechas
            <div className="receipt-input-icon">
              <CalendarDays size={16} />
              <select name="range" value={filters.range} onChange={change}>
                <option value="">Todos los rangos</option>
                <option value="today">Hoy</option>
                <option value="7">Últimos 7 días</option>
                <option value="30">Últimos 30 días</option>
                <option value="month">Este mes</option>
                <option value="custom">Rango personalizado</option>
              </select>
            </div>
          </label>
          <label className="receipt-search">
            Buscar por número de comprobante o n.° de compra
            <div className="receipt-input-icon">
              <input
                name="query"
                value={filters.query}
                onChange={change}
                placeholder="Ej. F001-000001 o COM-2026-0001"
              />
              <Search size={17} />
            </div>
          </label>
          <button
            className="receipt-button primary"
            onClick={refresh}
            disabled={loading || busy !== null}
          >
            <RefreshCw
              size={16}
              className={loading ? "receipt-spinning" : ""}
            />
            {loading ? "Cargando…" : "Actualizar"}
          </button>
          {filters.range === "custom" && (
            <div className="receipt-custom-dates">
              <label>
                Desde
                <input
                  type="date"
                  name="from"
                  value={filters.from}
                  max={filters.to || undefined}
                  onChange={change}
                />
              </label>
              <label>
                Hasta
                <input
                  type="date"
                  name="to"
                  value={filters.to}
                  min={filters.from || undefined}
                  onChange={change}
                />
              </label>
              {filters.from && filters.to && filters.from > filters.to && (
                <span role="alert">
                  La fecha inicial debe ser anterior a la final.
                </span>
              )}
            </div>
          )}
        </div>
        {error && (
          <div className="receipt-error" role="alert">
            {error}
          </div>
        )}
        <div className="receipt-table-wrap" aria-busy={loading}>
          <table className="receipt-table">
            <thead>
              <tr>
                {[
                  "Comprobante",
                  "Tipo",
                  "Compra",
                  "RUC receptor",
                  "Total",
                  "Método de pago",
                  "Fecha emisión",
                  "Acciones",
                ].map((label) => (
                  <th key={label}>{label}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {visible.map((row, index) => (
                <tr
                  key={row.comprobante_id}
                  style={{ "--receipt-delay": `${Math.min(index, 10) * 35}ms` }}
                >
                  <td>{numberOf(row)}</td>
                  <td>
                    <span
                      className={`receipt-type ${typeOf(row).toLowerCase()}`}
                    >
                      {typeOf(row)}
                    </span>
                  </td>
                  <td>{row.compra}</td>
                  <td>{row.ruc_receptor}</td>
                  <td>{money(row.total)}</td>
                  <td>
                    <Payment method={row.metodo_pago} />
                  </td>
                  <td>{row.fecha_emision}</td>
                  <td>
                    <div className="receipt-row-actions">
                      <button
                        className="receipt-button view"
                        disabled={busy !== null}
                        onClick={() => detail(row)}
                        aria-label={`Ver ${numberOf(row)}`}
                      >
                        <Eye size={14} />
                        Ver
                      </button>
                      <button
                        className="receipt-button download"
                        disabled={busy !== null}
                        onClick={() => detail(row, true)}
                        aria-label={`Descargar ${numberOf(row)}`}
                      >
                        <Download size={14} />
                        {busy === row.comprobante_id
                          ? "Cargando…"
                          : "Descargar"}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {!visible.length && (
                <tr>
                  <td colSpan={8} className="receipt-empty">
                    {loading
                      ? "Cargando comprobantes…"
                      : error
                        ? "No se pudo cargar la información. Pulsa Actualizar para reintentar."
                        : rows.length
                          ? "No hay comprobantes que coincidan con los filtros."
                          : "Aún no hay comprobantes registrados."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        <p className="receipt-result-count" aria-live="polite">
          Mostrando {visible.length} de {rows.length} comprobantes
        </p>
      </section>
      {selected && (
        <ReceiptModal
          row={selected}
          onClose={close}
          onDownload={downloadSelected}
          busy={busy !== null}
          error={error}
        />
      )}
    </main>
  );
}

function ReceiptModal({ row, onClose, onDownload, busy, error }) {
  const dialog = useRef(null);
  const closeButton = useRef(null);
  useEffect(() => {
    const previous = document.activeElement;
    const overflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    closeButton.current.focus();
    const keydown = (e) => {
      if (e.key === "Escape") onClose();
      if (e.key === "Tab") {
        const elements = dialog.current.querySelectorAll(
          'button:not(:disabled), [href], input, select, [tabindex="0"]',
        );
        const first = elements[0],
          last = elements[elements.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        }
        if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    document.addEventListener("keydown", keydown);
    return () => {
      document.body.style.overflow = overflow;
      document.removeEventListener("keydown", keydown);
      previous?.focus();
    };
  }, [onClose]);
  const title = `${typeOf(row)} electrónica`;
  const notice =
    "Documento de demostración — no válido como comprobante tributario.";
  return (
    <div
      className="receipt-backdrop"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <section
        ref={dialog}
        className="receipt-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="receipt-title"
      >
        <header className="receipt-modal-heading">
          <span className="receipt-document-icon">
            <FileText size={20} />
          </span>
          <div>
            <h2 id="receipt-title">{title}</h2>
            <p>{numberOf(row)}</p>
          </div>
          <span className="receipt-issued">EMITIDA</span>
          <button
            ref={closeButton}
            className="receipt-close"
            onClick={onClose}
            aria-label="Cerrar comprobante"
          >
            <X size={19} />
          </button>
        </header>
        <div className="receipt-document-header">
          <img src="/logo.png" alt="Abastece+" />
          <div>
            <strong>{row.emisor_nombre}</strong>
            <span>RUC: {row.ruc_emisor}</span>
            <span>{row.emisor_direccion || "Dirección no registrada"}</span>
          </div>
          <div className="receipt-document-number">
            <strong>{title.toUpperCase()}</strong>
            <b>{numberOf(row)}</b>
          </div>
          <div>
            <span>Fecha de emisión:</span>
            <span>{dateOf(row.fecha_emision)}</span>
            <span>Moneda: {row.moneda}</span>
          </div>
        </div>
        <p className="receipt-notice">
          <Info size={13} />
          {notice}
        </p>
        <div className="receipt-parties">
          <div>
            <h3>EMISOR</h3>
            <strong>{row.emisor_nombre}</strong>
            <p>RUC: {row.ruc_emisor}</p>
            <p>{row.emisor_direccion || "Dirección no registrada"}</p>
          </div>
          <div>
            <h3>CLIENTE</h3>
            <strong>{row.cliente_nombre}</strong>
            <p>RUC: {row.ruc_receptor}</p>
            <p>{row.cliente_direccion}</p>
          </div>
        </div>
        <h3 className="receipt-section-title">DETALLE DE PRODUCTOS</h3>
        <div className="receipt-products-wrap">
          <table className="receipt-products">
            <thead>
              <tr>
                <th>N.°</th>
                <th>Descripción</th>
                <th>Cant.</th>
                <th>P. unit. (S/)</th>
                <th>Importe (S/)</th>
              </tr>
            </thead>
            <tbody>
              {row.productos.map((p, i) => (
                <tr key={i}>
                  <td>{i + 1}</td>
                  <td>{p.descripcion}</td>
                  <td>{p.cantidad}</td>
                  <td>{money(p.precio_unitario)}</td>
                  <td>{money(p.importe)}</td>
                </tr>
              ))}
              {!row.productos.length && (
                <tr>
                  <td colSpan={5}>
                    Sin productos registrados para esta compra.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        <dl className="receipt-totals">
          <div>
            <dt>Subtotal</dt>
            <dd>{money(row.subtotal)}</dd>
          </div>
          <div>
            <dt>IGV (18%)</dt>
            <dd>{money(row.igv)}</dd>
          </div>
          {Number(row.costo_envio) > 0 && (
            <div>
              <dt>Envío</dt>
              <dd>{money(row.costo_envio)}</dd>
            </div>
          )}
          <div className="receipt-grand-total">
            <dt>TOTAL</dt>
            <dd>{money(row.total)}</dd>
          </div>
        </dl>
        <section className="receipt-payment-info">
          <span className="receipt-document-icon">
            <CreditCard size={17} />
          </span>
          <div>
            <h3>INFORMACIÓN DE PAGO</h3>
            <div className="receipt-payment-fields">
              <div>
                <span>Método de pago:</span>
                <p>
                  <Payment method={row.metodo_pago} />
                </p>
              </div>
              <div>
                <span>Código de operación:</span>
                <p>{row.codigo_operacion}</p>
              </div>
              <div>
                <span>Fecha de emisión:</span>
                <p>{dateOf(row.fecha_emision)}</p>
              </div>
              <div>
                <span>N.° de compra:</span>
                <p>{row.compra}</p>
              </div>
            </div>
          </div>
        </section>
        {error && (
          <p className="receipt-error" role="alert">
            {error}
          </p>
        )}
        <footer className="receipt-modal-footer">
          <span>
            <Info size={12} />
            {notice}
          </span>
          <button
            className="receipt-button primary"
            disabled={busy}
            onClick={onDownload}
          >
            <Download size={16} />
            {busy ? "Generando…" : "Descargar PDF"}
          </button>
          <button className="receipt-button secondary" onClick={onClose}>
            Cerrar
          </button>
        </footer>
      </section>
    </div>
  );
}
