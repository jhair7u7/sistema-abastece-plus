import { useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import {
  Building2,
  Image as ImageIcon,
  Pencil,
  Plus,
  Search,
  ShieldCheck,
  Truck,
  UploadCloud,
  Users,
  X,
} from "lucide-react";
import { useLocation } from "react-router-dom";
import Operacion from "./Operacion";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";

const configs = {
  productos: {
    title: "Productos",
    list: "productos_internos",
    key: "productos",
    id: "producto_id",
    create: "registrar_producto",
    update: "actualizar_producto",
    remove: "eliminar_producto",
    roles: ["LOGISTICA"],
    fields: [
      ["nombre", "Nombre"],
      ["codigo_sku", "Código interno"],
      ["categoria_id", "Categoría", "category"],
      ["marca", "Marca"],
      ["unidad_medida", "Presentación"],
      ["peso_kg", "Peso en kg", "number"],
      ["precio_base_sugerido", "Precio unitario", "number"],
      ["descripcion", "Descripción"],
      ["imagen_archivo", "Imagen del producto", "file"],
    ],
  },
  usuarios: {
    title: "Usuarios internos",
    list: "listar",
    key: "usuarios",
    id: "usuario_interno_id",
    create: "registrar",
    update: "actualizar",
    remove: "eliminar",
    roles: ["ADMINISTRADOR"],
    fields: [
      ["nombre", "Nombres"],
      ["apellidos", "Apellidos"],
      ["usuario", "Correo", "email"],
      ["telefono", "Teléfono"],
      ["password", "Contraseña", "password", "create"],
      ["rol", "Rol", "role"],
    ],
  },
  bodegueros: {
    title: "Comercios afiliados",
    list: "listar_bodegueros",
    key: "bodegueros",
    id: "bodeguero_id",
    update: "actualizar_bodeguero",
    remove: "bloquear_bodeguero",
    roles: ["GESTOR_ATENCION"],
    fields: [
      ["nombre", "Nombres"],
      ["apellidos", "Apellidos"],
      ["usuario", "Correo", "email"],
      ["telefono", "Teléfono"],
      ["ruc", "RUC"],
      ["nombre_comercial", "Nombre comercial"],
      ["razon_social", "Razón social"],
      ["tipo_establecimiento", "Tipo de establecimiento", "business"],
    ],
  },
  proveedores: {
    title: "Proveedores",
    list: "listar_proveedores",
    key: "proveedores",
    id: "proveedor_id",
    create: "registrar_proveedor",
    update: "actualizar_proveedor",
    remove: "desactivar_proveedor",
    roles: ["LOGISTICA"],
    fields: [
      ["ruc", "RUC"],
      ["razon_social", "Razón social"],
      ["nombre_comercial", "Nombre comercial"],
      ["contacto_nombre", "Nombre de contacto"],
      ["correo", "Correo", "email"],
      ["telefono", "Teléfono"],
    ],
  },
};
const blankFor = (c) => ({
  ...Object.fromEntries(c.fields.map(([name]) => [name, ""])),
  rol: "ADMINISTRADOR",
  tipo_establecimiento: "BODEGA",
});
const roleNames = {
  ADMINISTRADOR: "Administrador",
  TRANSPORTISTA: "Transportista",
  GESTOR_ATENCION: "Gestor de atención",
  LOGISTICA: "Logística",
};

export default function Admin() {
  const { session } = useAuth();
  const { pathname } = useLocation();
  const role = session.account.rol;
  const available = useMemo(
    () => Object.keys(configs).filter((k) => configs[k].roles.includes(role)),
    [role],
  );
  const logisticsModule = role === "LOGISTICA" ? pathname.split("/").pop() : "";
  const managementModule = ["productos", "proveedores"].includes(logisticsModule) ? logisticsModule : "";
  const operationModule = ["stock", "despachos", "facturas"].includes(logisticsModule) ? logisticsModule : "";
  const [tab, setTab] = useState(managementModule || available[0] || "");
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [modal, setModal] = useState(null);
  const [confirmRow, setConfirmRow] = useState(null);
  const [notice, setNotice] = useState("");
  const [deactivating, setDeactivating] = useState(false);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("Todas");
  const config = configs[tab];
  useEffect(() => {
    if (managementModule) setTab(managementModule);
  }, [managementModule]);
  const load = async () => {
    if (!config) return;
    setLoading(true);
    setMessage("");
    try {
      const data = await apiRequest(config.list, { token: session.token });
      setRows(data[config.key] || []);
    } catch (e) {
      setMessage(e.message);
    } finally {
      setLoading(false);
    }
  };
  // La pestaña determina el contrato de carga; la sesión permanece estable.
  useEffect(() => {
    load();
    // La carga se repite al cambiar pestaña o identidad autenticada.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tab, session.token]);
  const filteredRows = useMemo(() => rows.filter((row) => {
    const matchesSearch = `${row.nombre || ""} ${row.marca || ""} ${row.codigo_sku || ""}`.toLowerCase().includes(search.toLowerCase());
    const matchesCategory = category === "Todas" || row.categoria_nombre === category;
    return matchesSearch && matchesCategory;
  }), [rows, search, category]);
  const categories = useMemo(() => ["Todas", ...new Set(rows.map((row) => row.categoria_nombre).filter(Boolean))], [rows]);
  const openCreate = () => setModal({ mode: "create", data: blankFor(config) });
  const openEdit = (row) => {
    const data = { ...row, usuario: row.correo || row.usuario };
    setModal({ mode: "edit", data });
  };
  const save = async (e) => {
    e.preventDefault();
    const editing = modal.mode === "edit";
    try {
      const { imagen_archivo: imagenArchivo, ...payload } = modal.data;
      const result = await apiRequest(editing ? config.update : config.create, {
        method: editing ? "PUT" : "POST",
        token: session.token,
        params: editing ? { id: modal.data[config.id] } : undefined,
        body: payload,
      });
      const productoId = editing ? modal.data[config.id] : result.producto_id;
      if (tab === "productos" && imagenArchivo) {
        const formData = new FormData();
        formData.append("imagen", imagenArchivo);
        await apiRequest("subir_imagen_producto", {
          method: "POST",
          token: session.token,
          params: { id: productoId },
          body: formData,
        });
      }
      setModal(null);
      await load();
    } catch (error) {
      setModal((v) => ({ ...v, error: error.message }));
    }
  };
  const deactivate = async (row) => {
    setConfirmRow(row);
  };
  const confirmDeactivate = async () => {
    const row = confirmRow;
    setDeactivating(true);
    try {
      await apiRequest(config.remove, {
        method: "DELETE",
        token: session.token,
        params: { id: row[config.id] },
      });
      setConfirmRow(null);
      setNotice(`${displayName(row)} fue desactivado correctamente.`);
      window.setTimeout(() => setNotice(""), 3200);
      await load();
    } catch (e) {
      setMessage(e.message);
    } finally {
      setDeactivating(false);
    }
  };
  return (
    <main className="dashboard-page admin-module-page" key={pathname}>
      <div className="dashboard-wrap">
        {notice && <div className="admin-toast"><span>✓</span><div><strong>Listo</strong><small>{notice}</small></div></div>}
        <header className="dashboard-welcome">
          <div>
            <span className="role-badge">{roleNames[role]}</span>
            <h1>Panel de administración</h1>
            <p>
              Bienvenido, {session.account.nombre}. Administra la operación
              según tu nivel de acceso.
            </p>
          </div>
        </header>
        <div className="metric-grid">
          <Metric
            icon={<Users />}
            label="Módulos habilitados"
            value={role === "LOGISTICA" ? 5 : available.length}
          />
          <Metric
            icon={<ShieldCheck />}
            label="Perfil de acceso"
            value={roleNames[role]}
          />
          <Metric icon={<Truck />} label="Operación" value="Abastece+" />
        </div>
        {(role !== "LOGISTICA" || operationModule) && <div id="modulo-operacion" className="admin-module-anchor">
          <Operacion key={operationModule} role={role} module={operationModule} />
        </div>}
        {role === "LOGISTICA" && operationModule ? null : !config ? (
          <section className="panel-card empty-state">
            <Truck size={42} />
            <h2>Acceso de transporte</h2>
            <p>Consulta arriba las rutas asignadas a tu usuario.</p>
          </section>
        ) : (
          <>
            {role !== "LOGISTICA" && <div
              id="modulo-gestion"
              className="dashboard-tabs admin-module-anchor"
            >
              {available.map((k) => (
                <button
                  key={k}
                  className={tab === k ? "active" : ""}
                  onClick={() => setTab(k)}
                >
                  {configs[k].title}
                </button>
              ))}
            </div>}
            <section className="panel-card">
              <div className="panel-head">
                <div>
                  <h2>{config.title}</h2>
                  <p style={{ color: "#64748b" }}>
                    {rows.length} registros encontrados
                  </p>
                </div>
                {config.create && (
                  <button className="action-button" onClick={openCreate}>
                    <Plus size={18} /> Nuevo registro
                  </button>
                )}
              </div>
              {tab === "productos" && <div className="product-admin-filters"><label><Search size={18}/><input value={search} onChange={(e)=>setSearch(e.target.value)} placeholder="Buscar por nombre, marca o código..."/></label><select value={category} onChange={(e)=>setCategory(e.target.value)}>{categories.map((item)=><option key={item}>{item}</option>)}</select></div>}
              {message && <div className="form-message error">{message}</div>}
              {loading ? (
                <div className="empty-state">Cargando información...</div>
              ) : (
                <Table
                  rows={filteredRows}
                  type={tab}
                  onEdit={openEdit}
                  onRemove={deactivate}
                  canRemove={Boolean(config.remove)}
                />
              )}
            </section>
          </>
        )}
        {modal && (
          <Editor
            config={config}
            modal={modal}
            setModal={setModal}
            onSave={save}
          />
        )}
        {confirmRow && <ConfirmDeactivate row={confirmRow} busy={deactivating} onCancel={()=>setConfirmRow(null)} onConfirm={confirmDeactivate}/>} 
      </div>
    </main>
  );
}
function Metric({ icon, label, value }) {
  return (
    <div className="metric-card">
      <div className="metric-icon">{icon}</div>
      <small>{label}</small>
      <strong>{value}</strong>
    </div>
  );
}
function ConfirmDeactivate({ row, busy, onCancel, onConfirm }) {
  return createPortal(<div className="modal-backdrop confirmation-backdrop"><section className="modal-card confirmation-modal"><div className="confirmation-icon">!</div><span className="eyebrow">CONFIRMAR ACCIÓN</span><h2>¿Desactivar este registro?</h2><p><strong>{displayName(row)}</strong> dejará de estar disponible. Podrás conservar su información histórica.</p><div className="modal-actions"><button className="action-button secondary" onClick={onCancel} disabled={busy}>Cancelar</button><button className="action-button danger-solid" onClick={onConfirm} disabled={busy}>{busy ? "Desactivando…" : "Sí, desactivar"}</button></div></section></div>, document.body);
}
function displayName(r) {
  return (
    r.nombre_comercial ||
    `${r.nombre || ""} ${r.apellidos || ""}`.trim() ||
    r.razon_social
  );
}
function Table({ rows, type, onEdit, onRemove, canRemove }) {
  if (!rows.length)
    return (
      <div className="empty-state">
        <Building2 size={42} />
        <p>Aún no hay registros en este módulo.</p>
      </div>
    );
  return (
    <div className="data-table-wrap animated-table">
      <table className="data-table">
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Identificación</th>
            <th>Contacto</th>
            <th>Estado / rol</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r, index) => (
            <tr
              style={{ "--row-delay": `${Math.min(index, 12) * 35}ms` }}
              key={
                r.usuario_interno_id ||
                r.bodeguero_id ||
                r.proveedor_id ||
                r.producto_id
              }
            >
              <td>
                <strong>{displayName(r)}</strong>
                <br />
                <small>
                  {r.razon_social && r.nombre_comercial ? r.razon_social : ""}
                </small>
              </td>
              <td>{r.codigo_sku || r.ruc || `#${r.usuario_interno_id}`}</td>
              <td>
                {r.producto_id
                  ? `S/ ${Number(r.precio_base_sugerido).toFixed(2)}`
                  : r.correo}
                <br />
                <small>{r.producto_id ? r.categoria_nombre : r.telefono}</small>
              </td>
              <td>
                <span
                  className={`status-badge ${r.activo === "0" || r.estado_cuenta === "BLOQUEADO" ? "blocked" : "active"}`}
                >
                  {r.rol
                    ? roleNames[r.rol]
                    : (
                        r.estado_cuenta ||
                        (r.activo === "0" || r.activo === 0
                          ? "Inactivo"
                          : "Activo")
                      ).replaceAll("_", " ")}
                </span>
              </td>
              <td>
                <div className="table-actions">
                  <button
                    className="action-button secondary"
                    onClick={() => onEdit(r)}
                  >
                    <Pencil size={15} /> Editar
                  </button>
                  {canRemove && (
                    <button
                      className="action-button danger"
                      onClick={() => onRemove(r)}
                    >
                      {type === "bodegueros" ? "Bloquear" : "Desactivar"}
                    </button>
                  )}
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
function Editor({ config, modal, setModal, onSave }) {
  const change = (e) =>
    setModal((v) => ({
      ...v,
      data: { ...v.data, [e.target.name]: e.target.value },
      error: "",
    }));
  return createPortal(
    <div className="modal-backdrop">
      <section className="modal-card">
        <div className="modal-head">
          <h2>
            {modal.mode === "create" ? "Nuevo registro" : "Editar registro"}
          </h2>
          <button className="icon-button" onClick={() => setModal(null)}>
            <X />
          </button>
        </div>
        <form className="modal-form" onSubmit={onSave}>
          {config.fields
            .filter(
              ([, , , mode]) => !(mode === "create" && modal.mode !== "create"),
            )
            .map(([name, label, type]) => (
              <Field
                key={name}
                name={name}
                label={label}
                type={type}
                value={modal.data[name] ?? ""}
                onChange={change}
                currentImage={modal.data.imagen_url}
              />
            ))}
          {modal.error && (
            <div className="form-message error">{modal.error}</div>
          )}
          <div className="modal-actions">
            <button
              type="button"
              className="action-button secondary"
              onClick={() => setModal(null)}
            >
              Cancelar
            </button>
            <button className="action-button">Guardar cambios</button>
          </div>
        </form>
      </section>
    </div>, document.body
  );
}
function Field({ name, label, type, value, onChange, currentImage }) {
  if (type === "file")
    return (
      <ImageDropZone name={name} label={label} file={value} currentImage={currentImage} onChange={onChange} />
    );
  if (type === "role")
    return (
      <label className="form-field">
        <span>{label}</span>
        <select name={name} value={value} onChange={onChange} required>
          {Object.entries(roleNames).map(([v, l]) => (
            <option key={v} value={v}>
              {l}
            </option>
          ))}
        </select>
      </label>
    );
  if (type === "category")
    return (
      <label className="form-field"><span>{label}</span><select name={name} value={value} onChange={onChange} required><option value="">Selecciona una categoría</option><option value="1">Abarrotes</option><option value="2">Bebidas</option><option value="3">Limpieza</option><option value="4">Cuidado Personal</option></select></label>
    );
  if (type === "business")
    return (
      <label className="form-field">
        <span>{label}</span>
        <select name={name} value={value} onChange={onChange} required>
          <option value="BODEGA">Bodega</option>
          <option value="MINIMARKET">Minimarket</option>
          <option value="MARKET_LOCAL">Market local</option>
          <option value="OTRO">Otro</option>
        </select>
      </label>
    );
  return (
    <label className="form-field">
      <span>{label}</span>
      <input
        name={name}
        value={value}
        onChange={onChange}
        type={type || "text"}
        step={type === "number" ? "any" : undefined}
        required
      />
    </label>
  );
}

function ImageDropZone({ name, label, file, currentImage, onChange }) {
  const inputRef = useRef(null);
  const [dragging, setDragging] = useState(false);
  const preview = useMemo(
    () =>
      file instanceof File ? URL.createObjectURL(file) : currentImage || "",
    [file, currentImage],
  );

  useEffect(() => {
    if (!(file instanceof File)) return undefined;
    return () => URL.revokeObjectURL(preview);
  }, [file, preview]);

  const selectFile = (selected) => {
    if (selected) onChange({ target: { name, value: selected } });
  };
  const drop = (event) => {
    event.preventDefault();
    setDragging(false);
    selectFile(event.dataTransfer.files?.[0]);
  };

  return (
    <div className="form-field image-upload-field">
      <span>{label}</span>
      <div
        className={`image-drop-zone ${dragging ? "is-dragging" : ""} ${preview ? "has-preview" : ""}`}
        onClick={() => inputRef.current?.click()}
        onDragEnter={(event) => { event.preventDefault(); setDragging(true); }}
        onDragOver={(event) => event.preventDefault()}
        onDragLeave={() => setDragging(false)}
        onDrop={drop}
        onKeyDown={(event) => {
          if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            inputRef.current?.click();
          }
        }}
        role="button"
        tabIndex={0}
      >
        <input
          ref={inputRef}
          className="image-drop-zone__input"
          name={name}
          onChange={(event) => selectFile(event.target.files?.[0])}
          type="file"
          accept="image/png,image/jpeg,image/webp"
        />
        {preview ? (
          <div className="image-drop-zone__preview">
            <img src={preview} alt="Vista previa del producto" />
            <div>
              <ImageIcon size={22} />
              <strong>{file?.name || "Imagen actual del producto"}</strong>
              <small>Haz clic o arrastra otra imagen para reemplazarla</small>
            </div>
          </div>
        ) : (
          <div className="image-drop-zone__empty">
            <span className="image-drop-zone__icon"><UploadCloud size={28} /></span>
            <strong>Arrastra y suelta la imagen aquí</strong>
            <small>o haz clic para seleccionarla desde tu equipo</small>
          </div>
        )}
      </div>
      <small className="image-upload-field__help">PNG, JPG o WEBP · máximo 5 MB</small>
    </div>
  );
}
