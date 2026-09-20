import assert from 'node:assert/strict';
const base=process.env.TEST_API_URL||'http://127.0.0.1:8001';
async function request(action,{token,body,method=body?'POST':'GET',params={}}={}) {
 const response=await fetch(`${base}/?${new URLSearchParams({accion:action,...params})}`,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},...(body?{body:JSON.stringify(body)}:{})});
 const data=await response.json();return {status:response.status,data};
}
const accounts=[['admin','admin123','ADMINISTRADOR'],['logistica','logistica123','LOGISTICA'],['transporte','transporte123','TRANSPORTISTA'],['atencion','atencion123','GESTOR_ATENCION']];
const tokens={};
for(const [user,password,role] of accounts){const r=await request('login_admin',{body:{usuario:`${user}@example.test`,password}});assert.equal(r.status,200,user);assert.equal(r.data.usuario.rol,role);tokens[role]=r.data.token;}
const b=await request('login_cliente',{body:{usuario:'bodegueros1@example.test',password:'rosa123'}});assert.equal(b.status,200);tokens.BODEGUERO=b.data.token;
const matrix={listar:['ADMINISTRADOR'],listar_bodegueros:['GESTOR_ATENCION'],stock:['LOGISTICA'],despachos:['LOGISTICA'],facturas:['LOGISTICA'],mis_rutas:['TRANSPORTISTA'],incidencias:['GESTOR_ATENCION'],conformidades:['GESTOR_ATENCION'],mis_pedidos:['BODEGUERO'],mis_facturas:['BODEGUERO']};
let checks=5;
for(const [action,allowed] of Object.entries(matrix)) {
 assert.equal((await request(action)).status,401);checks++;
 for(const [role,token] of Object.entries(tokens)){const r=await request(action,{token});assert.equal(r.status,allowed.includes(role)?200:403,`${role}: ${action}`);checks++;}
}
const catalog=await request('listar_productos');assert.equal(catalog.status,200);assert(catalog.data.productos.length>0);assert(catalog.data.productos.every(p=>Number(p.stock_disponible)>0&&!('codigo_interno' in p)));checks++;
const routes=await request('mis_rutas',{token:tokens.TRANSPORTISTA});assert(routes.data.datos.every(r=>r.transportista_id===3&&r.items.length));checks++;
const own=await request('mis_pedidos',{token:tokens.BODEGUERO});assert.deepEqual(own.data.datos.map(r=>r.compra_id),[1]);checks++;
assert.equal((await request('login_admin',{body:{usuario:'bodegueros1@example.test',password:'rosa123'}})).status,401);checks++;
assert.equal((await request('login_cliente',{body:{usuario:'admin@example.test',password:'admin123'}})).status,401);checks++;
assert.equal((await request('ajustar_stock',{token:tokens.LOGISTICA,body:{id:1,stock:-1}})).status,422);checks++;
assert.equal((await request('actualizar_entrega',{token:tokens.TRANSPORTISTA,body:{id:999999,estado:'ENTREGADO'}})).status,422);checks++;
assert.equal((await request('actualizar_entrega',{token:tokens.TRANSPORTISTA,body:{id:4,estado:'ENTREGADO'}})).status,422);checks++;
assert.equal((await request('ajustar_stock',{token:tokens.TRANSPORTISTA,body:{id:1,stock:1}})).status,403);checks++;
assert.equal((await request('listar_direcciones',{token:tokens.TRANSPORTISTA})).status,403);checks++;
console.log(`${checks} comprobaciones API/RBAC correctas.`);
