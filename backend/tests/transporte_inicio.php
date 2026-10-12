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
try {
  putenv('PHOTON_URL');putenv('GEOCODING_URL');
  $r=$db->query('SELECT r.*,g.compra_id,d.direccion_exacta,d.distrito,d.provincia,d.departamento FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id JOIN compras c ON c.compra_id=g.compra_id JOIN direcciones d ON d.direccion_id=c.direccion_id LIMIT 1')->fetch();
  $id=(int)$r['ruta_id'];AuthMiddleware::$id=(int)$r['transportista_id'];
  $db->exec("UPDATE rutas_despacho SET estado_entrega='ASIGNADO' WHERE ruta_id=$id");
  $db->exec("UPDATE compras SET estado_pedido='DESPACHADO' WHERE compra_id=".(int)$r['compra_id']);
  $db->exec("DELETE FROM rutas_mapa WHERE ruta_id=$id");
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'EN_TRAYECTO']);
  expect(Response::$status===422,'No iniciar sin un recorrido calculado');
  expect($db->query("SELECT estado_entrega FROM rutas_despacho WHERE ruta_id=$id")->fetchColumn()==='ASIGNADO','Error de mapa no modifica el estado');
  callEndpoint($db,'preparar_recorrido',['id'=>$id]);expect(Response::$status===422,'Recalcular informa el motivo de mapa faltante');
  $address=TransportMapService::address($r);
  $stmt=$db->prepare('INSERT INTO rutas_mapa (ruta_id,origen_direccion,destino_direccion,origen_lat,origen_lng,destino_lat,destino_lng,geometria,distancia_m,duracion_s) VALUES (?,?,?,?,?,?,?,?,?,?)');
  $stmt->execute([$id,'Almacén de fixture',$address,-12.0491321,-77.1145179,-12.02,-77.05,json_encode(['type'=>'LineString','coordinates'=>[[-77.1145179,-12.0491321],[-77.05,-12.02]]]),1000,300]);
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'EN_TRAYECTO']);expect(Response::$status===200,'Iniciar con geometría disponible');
  expect($db->query("SELECT estado_entrega FROM rutas_despacho WHERE ruta_id=$id")->fetchColumn()==='EN_TRAYECTO','Inicio válido cambia el estado');
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'EN_TRAYECTO']);expect(Response::$status===200,'Reintentar inicio no falla por transición duplicada');
  callEndpoint($db,'preparar_recorrido',['id'=>$id]);expect(Response::$status===200 && Response::$data['recorrido_listo'],'Mostrar ruta ya iniciada');
  AuthMiddleware::$id=999999;callEndpoint($db,'preparar_recorrido',['id'=>$id]);expect(Response::$status===404,'No calcular rutas ajenas');
  echo "Inicio y recálculo de ruta, estado intacto ante error y aislamiento: correctos. Fixtures revertidos y sin envío a proveedores.\n";
} finally {$db->finish();}
