import test from 'node:test';
import assert from 'node:assert/strict';
import {freshGps,hasCoordinates,pendingRoute,routeMetrics,statusOf,routeClosedReason} from './transport.js';
test('Una compra cancelada prevalece sobre la entrega en ruta',()=>assert.equal(statusOf({estado_entrega:'EN_TRAYECTO',estado_pedido:'CANCELADO'}),'CANCELADO'));
test('Las entregas fallidas no cuentan como canceladas',()=>assert.equal(routeMetrics([{estado_entrega:'FALLIDO'}])[3].count,0));
test('Coordenadas ausentes o fuera del mapa no crean recorridos',()=>{assert(!hasCoordinates({}));assert(!hasCoordinates({origen_lat:100,origen_lng:0,destino_lat:0,destino_lng:0}));});
test('GPS reciente requiere puntos y caduca a los dos minutos',()=>{const row={capturado_ms:1000000,latitud:-12,longitud:-77};assert(freshGps(row,1000001));assert(!freshGps(row,1120001));assert(!freshGps(row,950000));assert(!freshGps({...row,latitud:null},1000001));});

test('El trazado termina al entregar, cancelar o confirmar todos los productos',()=>{
 const row={estado_pedido:'DESPACHADO',estado_entrega:'EN_TRAYECTO'};
 assert(pendingRoute(row));
 assert(!pendingRoute({...row,estado_entrega:'ENTREGADO'}));
 assert(!pendingRoute({...row,estado_pedido:'ENTREGADO'}));
 assert(!pendingRoute({...row,estado_pedido:'CANCELADO'}));
 assert(!pendingRoute({...row,conformidad_completa:'1'}));
 assert(pendingRoute({...row,conformidad_completa:0}));
});
test('Un GPS fuera del rango geográfico no se dibuja',()=>assert(!freshGps({capturado_ms:1000000,latitud:100,longitud:-77},1000001)));

test('Un reinicio incompleto explica la compra que sigue entregada',()=>{
 const row={estado_pedido:'ENTREGADO',estado_entrega:'ASIGNADO'};
 assert.equal(statusOf(row),'ENTREGADO');
 assert.match(routeClosedReason(row),/compra sigue ENTREGADO/);
 assert.equal(routeClosedReason({...row,estado_pedido:'PREPARANDO',hora_entrega:null}),'');
});
