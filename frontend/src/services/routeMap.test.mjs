import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { freshGps, pendingRoute, hasCoordinates, routeColors, warehouse } from './transport.js';
// Ejecutar el bloque real que dibuja capas, con un adaptador Leaflet en memoria.
// No se solicitan permisos GPS ni se guardan posiciones o entregas reales.
const source=readFileSync(new URL('../components/RouteMap.jsx', import.meta.url),'utf8');
const block=source.slice(source.indexOf('    layers.clearLayers();'),source.indexOf('    const key = routes.filter'));
const draw=new Function('routes','itinerary','selectedId','tracking','map','layers','L','document','icon','onSelect','freshGps','pendingRoute','hasCoordinates','routeColors','warehouse',block);
const geometry={type:'LineString',coordinates:[[-77.11,-12.04],[-77.08,-12.02]]};
const row={ruta_id:1,codigo_guia:'GR-TEST',estado_entrega:'EN_TRAYECTO',estado_pedido:'DESPACHADO',origen_lat:-12.04,origen_lng:-77.11,destino_lat:-12.02,destino_lng:-77.08,geometria:geometry,latitud:-12.03,longitud:-77.09,precision_m:8,capturado_ms:Date.now()};
function render(rows,itinerary=null,tracking=true) {
 const layers={items:[],clearLayers(){this.items=[];}};
 const map={follow:[],panTo(point){this.follow.push(point);}};
 const item=(kind,data,options)=>({kind,data,options,bindTooltip(){return this;},bindPopup(){return this;},on(){return this;},addTo(group){group.items.push(this);return this;}});
 const L={marker:(...args)=>item('marker',...args),polyline:(...args)=>item('line',...args)};
 draw(rows,itinerary,1,tracking,map,layers,L,{createElement:()=>({textContent:''})},(color,label,vehicle)=>({color,label,vehicle}),()=>{},freshGps,pendingRoute,hasCoordinates,routeColors,warehouse);
 return {layers:layers.items,follow:map.follow};
}
const gps=render([row]);
assert.equal(gps.layers.filter(x=>x.options?.icon?.vehicle).length,1);
assert.equal(gps.follow.length,1);
assert.equal(gps.layers.filter(x=>x.kind==='line').length,1);
const unlocated=render([{...row,destino_lat:null}]);
assert.equal(unlocated.layers.filter(x=>x.options?.icon?.vehicle).length,1);
assert.equal(unlocated.follow.length,1);
const staleTrip={tramos:[{ruta_id:1,geometria:geometry}],paradas:[{ruta_id:1}]};
for(const close of [{estado_entrega:'ENTREGADO'},{estado_pedido:'ENTREGADO'},{estado_pedido:'CANCELADO'},{conformidad_completa:1}]) {
 const result=render([{...row,...close}],staleTrip);
 assert.equal(result.layers.filter(x=>x.kind==='line').length,0);
 assert.equal(result.layers.filter(x=>x.options?.icon?.vehicle).length,0);
}
const another={...row,ruta_id:2,codigo_guia:'GR-TEST-2'};
const otherTrip={tramos:[{ruta_id:1,geometria:geometry},{ruta_id:2,geometria:geometry}],paradas:[{ruta_id:1},{ruta_id:2}]};
const remaining=render([{...row,estado_entrega:'ENTREGADO'},another],otherTrip);
assert.equal(remaining.layers.filter(x=>x.kind==='line').length,1);
console.log('GPS con/sin destino, seguimiento, entrega/conformidad, itinerario antiguo y otras entregas: correctos.');
