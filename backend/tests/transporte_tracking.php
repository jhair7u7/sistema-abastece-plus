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
  $r=$db->query('SELECT r.*,g.compra_id FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id LIMIT 1')->fetch();
  expect(!!$r,'Se necesita una ruta para la prueba');
  $id=(int)$r['ruta_id']; AuthMiddleware::$id=(int)$r['transportista_id'];
  $db->exec("UPDATE rutas_despacho SET estado_entrega='EN_TRAYECTO' WHERE ruta_id=$id");
  $db->exec("UPDATE compras SET estado_pedido='DESPACHADO' WHERE compra_id=".(int)$r['compra_id']);
  $now=(int)round(microtime(true)*1000);
  $body=['ruta_id'=>$id,'latitud'=>-12.0464,'longitud'=>-77.0428,'precision_m'=>10,'capturado_ms'=>$now];
  callEndpoint($db,'ubicacion_ruta',$body); expect(Response::$status===200,'GPS válido');
  callEndpoint($db,'ubicacion_ruta',array_merge($body,['latitud'=>-12.1,'capturado_ms'=>$now-1000]));
  expect((float)$db->query("SELECT latitud FROM rutas_gps WHERE ruta_id=$id")->fetchColumn()===-12.0464,'GPS antiguo no reemplaza posición nueva');
  callEndpoint($db,'ubicacion_ruta',array_merge($body,['capturado_ms'=>1])); expect(Response::$status===400,'GPS desactualizado rechazado');
  $originalUser=AuthMiddleware::$id;
  AuthMiddleware::$id=999999;
  expect(count(callEndpoint($db,'rutas_transporte')['rutas'])===0,'Otro usuario no ve rutas');
  foreach (['ubicacion_ruta','llegada_ruta','actualizar_entrega','preparar_recorrido'] as $action) { callEndpoint($db,$action,$body); expect(Response::$status===404,'Acceso ajeno rechazado: '.$action); }
  AuthMiddleware::$id=$originalUser;
  $rows=callEndpoint($db,'rutas_transporte')['rutas'];
  $row=array_values(array_filter($rows,fn($row)=>(int)$row['ruta_id']===$id))[0];
  $expected=$db->query('SELECT CONCAT_WS(", ",d.direccion_exacta,d.distrito,d.provincia,d.departamento) FROM direcciones d JOIN compras c ON c.direccion_id=d.direccion_id WHERE c.compra_id='.(int)$r['compra_id'])->fetchColumn();
  expect($row['destino_direccion']===TransportMapService::address(['direccion_entrega'=>$expected]),'Destino tomado de la dirección del pedido sin partes repetidas');
  if ($row['comprobante_id']) {
    (new ComprobanteController($db))->consultar($row['comprobante_id']);expect(Response::$status===200 && isset(Response::$data['comprobante']['productos']),'Factura propia con productos');
    AuthMiddleware::$id=999999;
    (new ComprobanteController($db))->consultar($row['comprobante_id']);expect(Response::$status===404,'Factura ajena rechazada');
    (new ComprobanteController($db))->consultar();expect(Response::$status===403,'No listar facturas de Logística');
    AuthMiddleware::$id=$originalUser;
  }
  foreach (['configurar_mapa_ruta','buscar_direccion_mapa','previsualizar_mapa_ruta'] as $action) expect(TransporteController::ejecutar($db,$action,'POST',$body)===false,'No editar destino desde transporte');
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'ENTREGADO']);expect(Response::$status===400,'Fecha y hora obligatorias');
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'ENTREGADO','fecha_entrega'=>'2026-02-30','hora_entrega'=>'10:00']);expect(Response::$status===400,'Fecha imposible rechazada');
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'ENTREGADO','fecha_entrega'=>'2099-01-01','hora_entrega'=>'10:00']);expect(Response::$status===400,'Entrega futura rechazada');
  callEndpoint($db,'actualizar_entrega',['id'=>$id,'estado'=>'FALLIDO','notas'=>'test']);expect(Response::$status===400,'Sin reporte de incidencias');
  $db->exec("UPDATE rutas_despacho SET hora_salida='2020-01-01 08:00:00' WHERE ruta_id=$id");
  $db->exec("UPDATE compras SET estado_pedido='CANCELADO' WHERE compra_id=".(int)$r['compra_id']);
  callEndpoint($db,'actualizar_entrega',['ruta_id'=>$id,'estado'=>'ENTREGADO']); expect(Response::$status===400,'No reactivar una compra cancelada');
  $db->exec("UPDATE compras SET estado_pedido='DESPACHADO' WHERE compra_id=".(int)$r['compra_id']);
  callEndpoint($db,'actualizar_entrega',['ruta_id'=>$id,'estado'=>'ENTREGADO','fecha_entrega'=>'2020-01-02','hora_entrega'=>'12:35']); expect(Response::$status===200,'Entrega confirmada');
  expect($db->query("SELECT hora_entrega FROM rutas_despacho WHERE ruta_id=$id")->fetchColumn()==='2020-01-02 12:35:00','Fecha y hora elegidas persistidas');
  expect(!$db->query("SELECT ruta_id FROM rutas_gps WHERE ruta_id=$id")->fetch(),'GPS eliminado al cerrar entrega');
  callEndpoint($db,'ubicacion_ruta',$body); expect(Response::$status===400,'No GPS para una ruta cerrada');
  echo "Aislamiento entre usuarios, GPS desactualizado, orden de posiciones, cancelación y cierre de entrega: correctos. Todos los cambios de prueba se revierten.\n";
} finally { $db->finish(); }
