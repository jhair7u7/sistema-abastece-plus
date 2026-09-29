import { useEffect, useState } from "react";
import { Plus, Pencil, Trash2, MapPin, X } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { apiRequest } from "../services/api";

const initialForm = {
  departamento: "Lima",
  provincia: "Lima",
  distrito: "",
  direccion_exacta: "",
  referencia: "",
  zona_reparto: "",
  codigo_postal: "",
};

export default function Direcciones() {
  const { session } = useAuth();
  const [direcciones, setDirecciones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(initialForm);
  const [formLoading, setFormLoading] = useState(false);
  const [formError, setFormError] = useState("");
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let ignore = false;
    apiRequest("listar_direcciones", { token: session?.token })
      .then((res) => {
        if (!ignore) {
          setDirecciones(res.data || []);
          setError("");
        }
      })
      .catch((e) => {
        if (!ignore) {
          setError(e.message);
        }
      })
      .finally(() => {
        if (!ignore) {
          setLoading(false);
        }
      });

    return () => {
      ignore = true;
    };
  }, [session, reloadKey]);

  const handleDelete = async (id) => {
    if (!window.confirm("¿Seguro que deseas eliminar esta dirección?")) return;
    try {
      await apiRequest("eliminar_direccion", {
        method: "POST",
        token: session?.token,
        params: { id },
      });
      setReloadKey((k) => k + 1);
    } catch (e) {
      alert(e.message);
    }
  };

  const openAdd = () => {
    setForm(initialForm);
    setEditingId(null);
    setFormError("");
    setIsModalOpen(true);
  };

  const openEdit = (dir) => {
    setForm({
      departamento: dir.departamento || "Lima",
      provincia: dir.provincia || "Lima",
      distrito: dir.distrito || "",
      direccion_exacta: dir.direccion_exacta || "",
      referencia: dir.referencia || "",
      zona_reparto: dir.zona_reparto || "",
      codigo_postal: dir.codigo_postal || "",
    });
    setEditingId(dir.direccion_id);
    setFormError("");
    setIsModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormLoading(true);
    setFormError("");
    try {
      if (editingId) {
        await apiRequest("actualizar_direccion", {
          method: "POST",
          token: session?.token,
          params: { id: editingId },
          body: form,
        });
      } else {
        await apiRequest("registrar_direccion", {
          method: "POST",
          token: session?.token,
          body: form,
        });
      }
      setIsModalOpen(false);
      setReloadKey((k) => k + 1);
    } catch (e) {
      setFormError(e.message);
    } finally {
      setFormLoading(false);
    }
  };

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  return (
    <main className="dashboard-page merchant-dashboard">
      <div className="dashboard-wrap">
        <header className="merchant-hero">
          <div>
            <span className="role-badge"><MapPin size={14}/> Mis Direcciones</span>
            <h1>Direcciones de entrega</h1>
            <p>Gestiona los lugares donde recibirás tus pedidos de Abastece+.</p>
          </div>
          <div className="merchant-hero__badge">
            <button className="action-button" onClick={openAdd}>
              <Plus size={18}/> Agregar Dirección
            </button>
          </div>
        </header>

        <section className="panel-card">
          {error && <div className="form-message error">{error}</div>}
          {loading ? (
            <p>Cargando direcciones...</p>
          ) : direcciones.length === 0 ? (
            <div className="empty-state">No tienes direcciones registradas.</div>
          ) : (
            <div className="data-table-wrap">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Distrito</th>
                    <th>Dirección Exacta</th>
                    <th>Zona Reparto</th>
                    <th>Referencia</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {direcciones.map(dir => (
                    <tr key={dir.direccion_id}>
                      <td>{dir.distrito}</td>
                      <td>{dir.direccion_exacta}</td>
                      <td>{dir.zona_reparto}</td>
                      <td>{dir.referencia}</td>
                      <td>
                        <div className="table-actions">
                          <button className="icon-button" onClick={() => openEdit(dir)} title="Editar"><Pencil size={18}/></button>
                          <button className="icon-button delete-button" style={{color: 'red'}} onClick={() => handleDelete(dir.direccion_id)} title="Eliminar"><Trash2 size={18}/></button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </div>

      {isModalOpen && (
        <div className="modal-backdrop">
          <section className="modal-card">
            <div className="modal-head">
              <div>
                <span className="eyebrow">DIRECCIÓN</span>
                <h2>{editingId ? "Editar Dirección" : "Nueva Dirección"}</h2>
              </div>
              <button className="icon-button" onClick={() => setIsModalOpen(false)}><X/></button>
            </div>
            <form className="modal-form" onSubmit={handleSubmit}>
              <label className="form-field">
                <span>Distrito *</span>
                <input required name="distrito" value={form.distrito} onChange={handleChange} />
              </label>
              <label className="form-field">
                <span>Dirección Exacta *</span>
                <input required name="direccion_exacta" value={form.direccion_exacta} onChange={handleChange} />
              </label>
              <label className="form-field">
                <span>Zona de Reparto *</span>
                <select required name="zona_reparto" value={form.zona_reparto} onChange={handleChange}>
                  <option value="">Selecciona</option>
                  <option value="NORTE">Norte</option>
                  <option value="SUR">Sur</option>
                  <option value="ESTE">Este</option>
                  <option value="OESTE">Oeste</option>
                  <option value="CENTRO">Centro</option>
                </select>
              </label>
              <label className="form-field">
                <span>Referencia</span>
                <input name="referencia" value={form.referencia} onChange={handleChange} />
              </label>
              <div style={{display: 'flex', gap: '1rem'}}>
                <label className="form-field" style={{flex: 1}}>
                  <span>Departamento</span>
                  <input name="departamento" value={form.departamento} onChange={handleChange} />
                </label>
                <label className="form-field" style={{flex: 1}}>
                  <span>Provincia</span>
                  <input name="provincia" value={form.provincia} onChange={handleChange} />
                </label>
              </div>
              <label className="form-field">
                <span>Código Postal</span>
                <input name="codigo_postal" value={form.codigo_postal} onChange={handleChange} />
              </label>

              {formError && <div className="form-message error">{formError}</div>}
              
              <div className="modal-actions">
                <button type="button" className="action-button secondary" onClick={() => setIsModalOpen(false)}>Cancelar</button>
                <button type="submit" className="action-button" disabled={formLoading}>
                  {formLoading ? "Guardando..." : "Guardar"}
                </button>
              </div>
            </form>
          </section>
        </div>
      )}
    </main>
  );
}
