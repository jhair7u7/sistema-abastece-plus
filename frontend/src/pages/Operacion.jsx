import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { Search } from 'lucide-react';
import { apiRequest } from '../services/api';
import { useAuth } from '../context/AuthContext';

const modules = {
  LOGISTICA: [['stock', 'Stock por lote'], ['despachos', 'Despachos'], ['facturas', 'Facturas de prueba']],
  TRANSPORTISTA: [['mis_rutas', 'Mis rutas']],
  GESTOR_ATENCION: [['incidencias', 'Incidencias'], ['conformidades', 'Conformidad de productos']],
  BODEGUERO: [['mis_pedidos', 'Mis pedidos'], ['mis_facturas', 'Mis comprobantes']],
};
const columns = {
  stock: ['lote_id','nombre','numero_lote','stock_disponible','fecha_vencimiento'],
  despachos: ['compra_id','codigo_compra','estado_pedido','codigo_guia','transportista_id','estado_entrega'],
  facturas: ['comprobante_id','serie','correlativo','compra_id','total','fecha_emision'],
  mis_facturas: ['serie','correlativo','compra_id','total','fecha_emision'],
  mis_pedidos: ['codigo_compra','total','estado_pedido','fecha_compra'],
  incidencias: ['incidencia_id','compra_id','tipo_incidencia','descripcion','estado_atencion','conformidad_final'],
  conformidades: ['conformidad_id','compra_id','nombre','estado','observaciones'],
};
export default function Operacion({ role, module }) {
  const available = module ? (modules[role] || []).filter(([key])=>key===module) : (modules[role] || []);
  const [tab, setTab] = useState(available[0]?.[0] || '');
  const [rows,setRows] = useState([]);
  const [error,setError] = useState('');
  const [loading,setLoading] = useState(false);
  const [revision,setRevision] = useState(0);
  const [editor,setEditor] = useState(null);
  const [saving,setSaving] = useState(false);
  const [search,setSearch] = useState('');
  const [category,setCategory] = useState('Todas');
  const { session } = useAuth();
  useEffect(()=>{if(module)setTab(module);},[module]);
  useEffect(()=>{
    if (!tab) return;
    let current=true;
    setLoading(true); setError('');
    apiRequest(tab,{token:session.token}).then(d=>{if(current)setRows(d.datos);}).catch(e=>{if(current)setError(e.message);}).finally(()=>{if(current)setLoading(false);});
    return ()=>{current=false;};
  },[tab,session.token,revision]);
  const categories=useMemo(()=>['Todas',...new Set(rows.map(r=>r.categoria_nombre).filter(Boolean))],[rows]);
  const visibleRows=useMemo(()=>rows.filter(r=>{
    const matchesText=`${r.nombre||''} ${r.marca||''} ${r.numero_lote||''}`.toLowerCase().includes(search.toLowerCase());
    return matchesText&&(category==='Todas'||r.categoria_nombre===category);
  }),[rows,search,category]);
  if (!available.length) return null;
  const open = (action, row) => {
    const id=row.lote_id || row.ruta_id || row.incidencia_id || row.conformidad_id || row.compra_id;
    setEditor({action,id,stock:row.stock_disponible,estado:action==='actualizar_entrega'?'EN_TRAYECTO':action==='atender_incidencia'?'EN_REVISION':'CONFORME',notas:'',transportista_id:row.transportista_id||'',placa:'DEMO-01',ruta:'',motivo:''});
  };
  const save = async e => {
    e.preventDefault(); setSaving(true); setError('');
    try { await apiRequest(editor.action,{method:'POST',token:session.token,body:editor}); setEditor(null); setRevision(n=>n+1); }
    catch(e){setError(e.message);} finally {setSaving(false);}
  };
  const input = (name,label,type='text') => <label className="form-field"><span>{label}</span><input type={type} required value={editor[name]??''} onChange={e=>setEditor({...editor,[name]:e.target.value})} /></label>;
  const title=available.find(([key])=>key===tab)?.[1]||'Operación';
  return <section className="panel-card operation-panel" style={{marginBottom:24}}>
    <div className="operation-heading"><span className="eyebrow">MÓDULO DE LOGÍSTICA</span><h2>{title}</h2><p>Gestiona y consulta la información operativa de Abastece+.</p></div>
    {!module&&<div className="dashboard-tabs">{available.map(([key,label])=><button key={key} className={tab===key?'active':''} onClick={()=>{setTab(key);setEditor(null);}}>{label}</button>)}</div>}
    {tab==='stock'&&<div className="product-admin-filters stock-filters"><label><Search size={18}/><input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Buscar producto, marca o lote..."/></label><select value={category} onChange={e=>setCategory(e.target.value)}>{categories.map(item=><option key={item}>{item}</option>)}</select></div>}
    {error && <p role="alert" className="form-message error">{error}</p>}
    {loading ? <p>Cargando…</p> : visibleRows.length===0 ? <div className="empty-state">No se encontraron registros.</div> : tab==='mis_rutas' ? visibleRows.map(r=><article className="panel-card" key={r.ruta_id}>
      <h3>{r.codigo_guia} · {r.estado_entrega}</h3><p>{r.cliente} · {r.direccion_entrega}</p><p>{r.descripcion_ruta}</p>
      <ul>{r.items.map((i,n)=><li key={n}>{i.cantidad} × {i.nombre} ({i.unidad_medida})</li>)}</ul>
      <p>{r.observaciones}</p>{r.estado_entrega!=='ENTREGADO'&&<button className="action-button" onClick={()=>open('actualizar_entrega',r)}>Actualizar entrega</button>}
    </article>) : <div className="data-table-wrap animated-table"><table className="data-table"><thead><tr>{columns[tab].map(c=><th key={c}>{c.replaceAll('_',' ')}</th>)}{['stock','despachos','incidencias','conformidades'].includes(tab)&&<th>Acciones</th>}</tr></thead><tbody>{visibleRows.map((r,i)=><tr key={r.lote_id||r.compra_id||r.comprobante_id||i} style={{'--row-delay':`${Math.min(i,12)*35}ms`}}>{columns[tab].map(c=><td key={c}>{r[c]??'—'}</td>)}
      {tab==='stock'&&<td><button className="table-action-button" onClick={()=>open('ajustar_stock',r)}>Ajustar stock</button></td>}
      {tab==='despachos'&&<td><div className="table-actions"><button className="table-action-button" onClick={()=>open('asignar_despacho',{...r,ruta_id:null})}>Asignar despacho</button><button className="table-action-button secondary" onClick={()=>open('emitir_factura',{...r,ruta_id:null})}>Emitir comprobante</button></div></td>}
      {tab==='incidencias'&&<td><button className="table-action-button" onClick={()=>open('atender_incidencia',r)}>Atender</button></td>}
      {tab==='conformidades'&&<td><button className="table-action-button" onClick={()=>open('revisar_conformidad',r)}>Revisar</button></td>}
    </tr>)}</tbody></table></div>}
    {editor&&createPortal(<div className="modal-backdrop"><form className="modal-card operation-modal" onSubmit={save}>
      <div className="modal-head"><div><span className="eyebrow">ACCIÓN OPERATIVA</span><h3>{editor.action.replaceAll('_',' ')} #{editor.id}</h3></div><button type="button" className="icon-button" onClick={()=>setEditor(null)}>×</button></div><div className="modal-form">
      {editor.action==='ajustar_stock'&&<>{input('stock','Stock disponible','number')}{input('motivo','Motivo del ajuste')}</>}
      {editor.action==='asignar_despacho'&&<><Transportistas value={editor.transportista_id} onChange={v=>setEditor({...editor,transportista_id:v})} token={session.token}/>{input('placa','Placa de prueba')}{input('ruta','Recorrido')}</>}
      {['actualizar_entrega','atender_incidencia','revisar_conformidad'].includes(editor.action)&&<><label className="form-field"><span>Estado</span><select value={editor.estado} onChange={e=>setEditor({...editor,estado:e.target.value})}>{(editor.action==='actualizar_entrega'?['EN_TRAYECTO','ENTREGADO','FALLIDO']:editor.action==='atender_incidencia'?['ABIERTO','EN_REVISION','SOLUCIONADO','RECHAZADO']:['PENDIENTE','CONFORME','NO_CONFORME']).map(s=><option key={s}>{s}</option>)}</select></label>{input('notas','Observaciones')}</>}
      {editor.action==='emitir_factura'&&<p>Se generará un comprobante simulado para este pedido, sin validez tributaria.</p>}
      <div className="modal-actions"><button type="button" disabled={saving} className="action-button secondary" onClick={()=>setEditor(null)}>Cancelar</button><button disabled={saving} className="action-button">{saving?'Guardando…':'Guardar cambios'}</button></div></div>
    </form></div>,document.body)}
  </section>;
}
function Transportistas({value,onChange,token}) {
 const [rows,setRows]=useState([]); const [error,setError]=useState('');
 useEffect(()=>{apiRequest('transportistas',{token}).then(d=>setRows(d.datos)).catch(e=>setError(e.message));},[token]);
 return <label className="form-field"><span>Transportista</span><select required value={value} onChange={e=>onChange(e.target.value)}><option value="">Selecciona</option>{rows.map(r=><option key={r.usuario_interno_id} value={r.usuario_interno_id}>{r.nombre}</option>)}</select>{error&&<span role="alert">{error}</span>}</label>;
}
