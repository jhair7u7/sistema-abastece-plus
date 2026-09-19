import { useEffect, useMemo, useState } from "react";
import {
  Building2,
  Pencil,
  Plus,
  ShieldCheck,
  Truck,
  Users,
  X,
} from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";

const configs = {
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
    roles: ["ADMINISTRADOR", "GESTOR_ATENCION"],
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
    roles: ["ADMINISTRADOR", "LOGISTICA"],
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
  const role = session.account.rol;
  const available = useMemo(
    () => Object.keys(configs).filter((k) => configs[k].roles.includes(role)),
    [role],
  );
  const [tab, setTab] = useState(available[0] || "");
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [modal, setModal] = useState(null);
  const config = configs[tab];
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
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => {
    load();
  }, [tab]);
  const openCreate = () => setModal({ mode: "create", data: blankFor(config) });
  const openEdit = (row) => {
    const data = { ...row, usuario: row.correo || row.usuario };
    setModal({ mode: "edit", data });
  };
  const save = async (e) => {
    e.preventDefault();
    const editing = modal.mode === "edit";
    try {
      await apiRequest(editing ? config.update : config.create, {
        method: editing ? "PUT" : "POST",
        token: session.token,
        params: editing ? { id: modal.data[config.id] } : undefined,
        body: modal.data,
      });
      setModal(null);
      await load();
    } catch (error) {
      setModal((v) => ({ ...v, error: error.message }));
    }
  };
  const deactivate = async (row) => {
    if (!window.confirm(`¿Confirmas esta acción sobre ${displayName(row)}?`))
      return;
    try {
      await apiRequest(config.remove, {
        method: "DELETE",
        token: session.token,
        params: { id: row[config.id] },
      });
      await load();
    } catch (e) {
      setMessage(e.message);
    }
  };
  return (
    <main className="dashboard-page">
      <div className="dashboard-wrap">
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
            value={available.length}
          />
          <Metric
            icon={<ShieldCheck />}
            label="Perfil de acceso"
            value={roleNames[role]}
          />
          <Metric icon={<Truck />} label="Operación" value="Abastece+" />
        </div>
        {!config ? (
          <section className="panel-card empty-state">
            <Truck size={42} />
            <h2>Módulo de transporte</h2>
            <p>
              El backend recibido autentica este rol, pero aún no expone rutas
              de despacho para gestionarlas.
            </p>
          </section>
        ) : (
          <>
            <div className="dashboard-tabs">
              {available.map((k) => (
                <button
                  key={k}
                  className={tab === k ? "active" : ""}
                  onClick={() => setTab(k)}
                >
                  {configs[k].title}
                </button>
              ))}
            </div>
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
              {message && <div className="form-message error">{message}</div>}
              {loading ? (
                <div className="empty-state">Cargando información...</div>
              ) : (
                <Table
                  rows={rows}
                  type={tab}
                  onEdit={openEdit}
                  onRemove={deactivate}
                  canRemove={role === "ADMINISTRADOR"}
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
    <div className="data-table-wrap">
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
          {rows.map((r) => (
            <tr key={r.usuario_interno_id || r.bodeguero_id || r.proveedor_id}>
              <td>
                <strong>{displayName(r)}</strong>
                <br />
                <small>
                  {r.razon_social && r.nombre_comercial ? r.razon_social : ""}
                </small>
              </td>
              <td>{r.ruc || `#${r.usuario_interno_id}`}</td>
              <td>
                {r.correo}
                <br />
                <small>{r.telefono}</small>
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
  return (
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
    </div>
  );
}
function Field({ name, label, type, value, onChange }) {
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
  if (type === "business")
    return (
      <label className="form-field">
        <span>{label}</span>
        <select name={name} value={value} onChange={onChange} required>
          <option value="BODEGA">Bodega</option>
          <option value="MINIMARKET">Minimarket</option>
          <option value="MARKET_LOCAL">Market local</option>
          <option value="OTROS">Otro</option>
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
        required
      />
    </label>
  );
}
