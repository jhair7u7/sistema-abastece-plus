<?php
require dirname(__DIR__).'/config/database.php';
require dirname(__DIR__).'/controllers/OperacionController.php';
require dirname(__DIR__).'/controllers/TransporteController.php';
require dirname(__DIR__).'/controllers/ComprobanteController.php';
class AuthMiddleware { public static $id=1;public static $role='BODEGUERO';public static function permitirRoles($roles){if(!in_array(self::$role,$roles,true))throw new RuntimeException('Acceso no permitido');return ['id'=>self::$id,'rol'=>self::$role];} }
class Response {public static $data;public static $status;public static function json($data,$status=200){self::$data=$data;self::$status=$status;}}
class TestPDO extends PDO {public function beginTransaction():bool{return true;}public function commit():bool{return true;}public function rollBack():bool{return true;}public function start(){parent::beginTransaction();}public function finish(){parent::rollBack();}}
function check($ok,$msg){if(!$ok)throw new RuntimeException($msg);}
function action($db,$name,$body=[]){OperacionController::ejecutar($db,$name,'POST',$body);check(Response::$status===200,$name.': '.json_encode(Response::$data));return Response::$data['datos'];}
$db=new TestPDO('mysql:host='.getenv('DB_HOST').';port='.(getenv('DB_PORT')?:3306).';dbname='.getenv('DB_NAME').';charset=utf8mb4',getenv('DB_USER'),getenv('DB_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$oldPhoton=getenv('PHOTON_URL');$oldRouting=getenv('ROUTING_URL');
$db->start();
try {
 putenv('PHOTON_URL');putenv('GEOCODING_URL');putenv('ROUTING_URL=http://fixture-routing.invalid');
 $product=$db->query('SELECT p.producto_id FROM productos p JOIN inventario_lotes l ON l.producto_id=p.producto_id WHERE p.activo=1 AND l.stock_disponible>0 LIMIT 1')->fetchColumn();
 $result=action($db,'crear_compra',['items'=>[['producto_id'=>$product,'cantidad'=>1]],'metodo_pago'=>'EFECTIVO']);$id=(int)$result['compra_id'];
 check((int)$db->query("SELECT COUNT(*) FROM comprobantes_pago WHERE compra_id=$id")->fetchColumn()===0,'No se emite factura al comprar');
 check((int)$db->query("SELECT COUNT(*) FROM pagos_compra WHERE compra_id=$id")->fetchColumn()===1,'El pago se conserva sin factura');
 AuthMiddleware::$id=2;AuthMiddleware::$role='LOGISTICA';$service=new LogisticaService($db);
 try { $service->issue($id); throw new RuntimeException('Permitió emitir sin despacho'); } catch (InvalidArgumentException $e) { check(str_contains($e->getMessage(),'despacho'),'Exige despacho antes de emitir'); }
 $drivers=$service->drivers();check(str_contains($drivers[0]['nombre'],' '),'Nombre completo');
 putenv('PHOTON_URL=http://fixture-photon.invalid');
 $addressId=$db->query("SELECT direccion_id FROM compras WHERE compra_id=$id")->fetchColumn();
 $savedAddress=$db->query("SELECT direccion_exacta FROM direcciones WHERE direccion_id=$addressId")->fetchColumn();
 $db->exec("UPDATE direcciones SET direccion_exacta='Av. Canta 180' WHERE direccion_id=$addressId");
 $fetch=function($url){
  if(str_contains($url,'fixture-photon'))return ['features'=>[['geometry'=>['coordinates'=>[-77.05,-12.02]],'properties'=>['street'=>'Avenida Canta','housenumber'=>'180']]]];
  $coords=explode(';',explode('?',explode('/driving/',$url)[1])[0]);$points=array_map(fn($p)=>array_map('floatval',explode(',',$p)),$coords);$legs=[];
  for($i=1;$i<count($points);$i++)$legs[]=['steps'=>[['geometry'=>['coordinates'=>[$points[$i-1],$points[$i]]]]]];
  return ['code'=>'Ok','routes'=>[['distance'=>1200,'duration'=>300,'geometry'=>['type'=>'LineString','coordinates'=>$points],'legs'=>$legs]]];
 };
 $preview=(new LogisticaService($db,$fetch))->preview(3,$id);
 check(count(array_filter($preview['rutas'],fn($r)=>(int)$r['ruta_id']===2147483647))===1,'Nueva entrega incluida en previsualización');
 check(count($preview['recorrido']['tramos'])>0,'Previsualización dibuja recorrido real del proveedor');
 check((int)$db->query('SELECT COUNT(*) FROM rutas_mapa WHERE ruta_id=2147483647')->fetchColumn()===0,'Previsualizar no registra un despacho ficticio');
 foreach($preview['rutas'] as $previewRow)if((int)$previewRow['ruta_id']!==2147483647)check((int)$db->query('SELECT transportista_id FROM rutas_despacho WHERE ruta_id='.(int)$previewRow['ruta_id'])->fetchColumn()===3,'Previsualización aislada por transportista');
 $restore=$db->prepare('UPDATE direcciones SET direccion_exacta=? WHERE direccion_id=?');$restore->execute([$savedAddress,$addressId]);putenv('PHOTON_URL');

 action($db,'asignar_despacho',['id'=>$id,'transportista_id'=>3,'placa'=>'PLACA-INVENTADA','ruta'=>'Indicaciones de prueba']);
 check($db->query("SELECT r.vehiculo_placa FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id WHERE g.compra_id=$id")->fetchColumn()!== 'PLACA-INVENTADA','Placa automática validada por servidor');
 AuthMiddleware::$id=3;AuthMiddleware::$role='TRANSPORTISTA';
 TransporteController::ejecutar($db,'rutas_transporte','GET',[]);check(Response::$status===200,'Lectura de rutas');
 $routeId=(int)$db->query("SELECT r.ruta_id FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id WHERE g.compra_id=$id")->fetchColumn();
 $matches=array_values(array_filter(Response::$data['rutas'],fn($r)=>(int)$r['ruta_id']===$routeId));check(count($matches)===1,'Ruta asignada visible para su conductor');$row=$matches[0];check($row['comprobante_id']===null,'Transportista no ve factura antes de emisión');
 AuthMiddleware::$id=2;AuthMiddleware::$role='LOGISTICA';$first=action($db,'emitir_factura',['id'=>$id,'metodo_pago'=>'YAPE']);$second=action($db,'emitir_factura',['id'=>$id]);
 check($db->query("SELECT codigo_operacion FROM comprobantes_pago WHERE compra_id=$id")->fetchColumn()===$result['codigo_operacion'],'Código de operación original conservado');
 check($first['comprobante_id']===$second['comprobante_id'],'Emisión idempotente');check($first['serie']==='F001','Serie de factura');
 check((int)$db->query("SELECT COUNT(*) FROM comprobantes_pago WHERE compra_id=$id")->fetchColumn()===1,'Una única factura');
 check($db->query("SELECT metodo_pago FROM comprobantes_pago WHERE compra_id=$id")->fetchColumn()==='EFECTIVO','Pago real sin reemplazo por datos del cliente');
 AuthMiddleware::$id=3;AuthMiddleware::$role='TRANSPORTISTA';(new ComprobanteController($db))->consultar($first['comprobante_id']);check(Response::$status===200,'Conductor asignado puede ver factura emitida');
 AuthMiddleware::$id=9999;(new ComprobanteController($db))->consultar($first['comprobante_id']);check(Response::$status===404,'Otro conductor no accede a factura');
 echo "Compra sin factura, pago conservado, placa automática, emisión única y acceso exclusivo del transportista: correctos. Todos los cambios revertidos.\n";
} finally {$db->finish();putenv($oldPhoton===false?'PHOTON_URL':'PHOTON_URL='.$oldPhoton);putenv($oldRouting===false?'ROUTING_URL':'ROUTING_URL='.$oldRouting);}
