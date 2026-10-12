<?php
require dirname(__DIR__).'/config/database.php';
require dirname(__DIR__).'/controllers/TransporteController.php';
require dirname(__DIR__).'/controllers/ComprobanteController.php';
class AuthMiddleware { public static $id=3; public static function permitirRoles($roles) { return ['id'=>self::$id,'rol'=>'TRANSPORTISTA']; } }
class Response { public static $status; public static $data; public static function json($data,$status=200) { self::$data=$data; self::$status=$status; } }
class FixturePDO extends PDO {
  public function beginTransaction():bool { return true; }
  public function commit():bool { return true; }
  public function rollBack():bool { return true; }
  public function start():void { parent::beginTransaction(); }
  public function finish():void { parent::rollBack(); }
}
function expect($condition,$message) { if (!$condition) throw new RuntimeException($message); }
function callEndpoint($db,$action,$body=[]) { TransporteController::ejecutar($db,$action,$action==='rutas_transporte'?'GET':'POST',$body); return Response::$data; }
$db=new FixturePDO('mysql:host='.getenv('DB_HOST').';port='.(getenv('DB_PORT')?:3306).';dbname='.(getenv('DB_NAME')?:'abastece_nuevo').';charset=utf8mb4',getenv('DB_USER')?:'root',getenv('DB_PASSWORD')?:'1234',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$db->start();
$oldPhoton=getenv('PHOTON_URL');$oldRouting=getenv('ROUTING_URL');
try {
  expect(TransportMapService::address(['direccion_exacta'=>'Av. Canta 180, San Martín de Porres, Lima, Perú','distrito'=>'San Martin de Porres','provincia'=>'Lima','departamento'=>'Lima'])==='Av. Canta 180, San Martín de Porres, Lima, Perú','Dirección normalizada sin distrito o ciudad duplicados');
  $feature=['geometry'=>['coordinates'=>[-77.05,-12.02]],'properties'=>['street'=>'Avenida Canta','housenumber'=>'180']];
  expect(TransportMapService::photonPoint([$feature],'Av. Canta 180, Lima')['precision']==='INMUEBLE','Número correcto localizado');
  $wrong=$feature;$wrong['properties']['housenumber']='181';
  expect(TransportMapService::photonPoint([$wrong],'Av. Canta 180, Lima')===null,'No aceptar otro número');
  $wrong=$feature;$wrong['geometry']['coordinates']=[10,50];
  expect(TransportMapService::photonPoint([$wrong],'Av. Canta 180, Lima')===null,'No aceptar otro país');
  $street=$feature;unset($street['properties']['housenumber']);$street['properties']['type']='street';
  expect(TransportMapService::photonPoint([$street],'Av. Canta 180, Lima')['precision']==='CALLE','La calle no se declara puerta exacta');
  $base=['estado_pedido'=>'DESPACHADO','estado_entrega'=>'ASIGNADO','destino_direccion'=>'Av. Canta 180, Lima','destino_lat'=>-12.02,'destino_lng'=>-77.05,'mapa_precision'=>'INMUEBLE'];
  $rows=[array_merge($base,['ruta_id'=>2,'codigo_guia'=>'GR-2']),array_merge($base,['ruta_id'=>1,'codigo_guia'=>'GR-1','estado_entrega'=>'EN_TRAYECTO']),array_merge($base,['ruta_id'=>3,'codigo_guia'=>'GR-3','estado_entrega'=>'ENTREGADO']),array_merge($base,['ruta_id'=>4,'codigo_guia'=>'GR-4','estado_pedido'=>'CANCELADO'])];
  expect(TransportMapService::stops([array_merge($base,['ruta_id'=>5,'conformidad_completa'=>1])])===[],'Una entrega conforme ya no forma parte del trazado');
  expect(TransportMapService::stops([array_merge($base,['ruta_id'=>5,'estado_pedido'=>'ENTREGADO'])])===[],'Un pedido entregado no reaparece como parada');
  expect(array_column(TransportMapService::stops($rows),'ruta_id')===[1,2],'Solo paradas pendientes y primero el recorrido activo');
  putenv('ROUTING_URL=http://fixture-routing.invalid');$calls=[];
  $fetch=function($url) use (&$calls) { $calls[]=$url;return ['code'=>'Ok','routes'=>[['distance'=>1200,'duration'=>300,'geometry'=>['type'=>'LineString','coordinates'=>[[-77.1145,-12.0491],[-77.05,-12.02]]],'legs'=>[['steps'=>[['geometry'=>['coordinates'=>[[-77.1145,-12.0491],[-77.05,-12.02]]]]]],['steps'=>[['geometry'=>['coordinates'=>[[-77.05,-12.02],[-77.04,-12.01]]]]]]]]]]; };
  $service=new TransportMapService($db,$fetch);$trip=$service->itinerary($rows);
  expect(count($trip['tramos'])===2 && array_column($trip['tramos'],'ruta_id')===[1,2],'Tramos de almacén a parada 1 y parada 1 a parada 2');
  expect(substr_count($calls[0],';')===2,'Una solicitud con almacén y dos paradas');
  $service->itinerary($rows);expect(count($calls)===1,'No repetir el cálculo en cada actualización');
  $rows[1]['destino_lat']=null;$trip=$service->itinerary($rows);expect($trip['pendientes']===['GR-1'],'No inventar ubicaciones para paradas desconocidas');
  putenv('PHOTON_URL=http://fixture-photon.invalid');
  $r=$db->query('SELECT r.ruta_id FROM rutas_despacho r LIMIT 1')->fetch();
  $row=array_merge($r,['direccion_exacta'=>'Av. Canta 180','distrito'=>'San Martín de Porres','provincia'=>'Lima','departamento'=>'Lima','destino_lat'=>null,'destino_lng'=>null,'mapa_direccion'=>null,'geometria'=>null]);
  $service=new TransportMapService($db,function($url) use ($fetch,$feature) { return str_contains($url,'fixture-photon') ? ['features'=>[$feature]] : $fetch($url); });
  $service->destination($row);expect($row['mapa_estado']==='LISTO' && $row['mapa_precision']==='INMUEBLE','Dirección del pedido se convierte automáticamente en destino');
  echo "Direcciones sin duplicados, precisión, paradas, geometrías, caché y destinos automáticos: correctos. Pruebas sin conexión a proveedores y con rollback.\n";
} finally { $db->finish();putenv($oldPhoton===false?'PHOTON_URL':'PHOTON_URL='.$oldPhoton);putenv($oldRouting===false?'ROUTING_URL':'ROUTING_URL='.$oldRouting); }
