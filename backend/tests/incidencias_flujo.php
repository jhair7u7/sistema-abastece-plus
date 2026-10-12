<?php
if(PHP_SAPI!=='cli')exit;
require dirname(__DIR__).'/config/database.php';
require dirname(__DIR__).'/controllers/IncidenciaController.php';
require dirname(__DIR__).'/controllers/OperacionController.php';
require dirname(__DIR__).'/controllers/ComprobanteController.php';
class AuthMiddleware{public static $id=1,$role='BODEGUERO';public static function permitirRoles($roles){if(!in_array(self::$role,$roles))throw new RuntimeException('Prohibido');return ['id'=>self::$id,'rol'=>self::$role];}}
class Response{public static $data,$status;public static function json($d,$s=200){self::$data=$d;self::$status=$s;}}
class TestPDO extends PDO{public function beginTransaction():bool{return true;}public function commit():bool{return true;}public function rollBack():bool{return true;}public function start(){parent::beginTransaction();}public function finish(){parent::rollBack();}}
function check($ok,$msg){if(!$ok)throw new RuntimeException($msg.' '.json_encode(Response::$data));}
$db=new TestPDO('mysql:host='.getenv('DB_HOST').';port='.(getenv('DB_PORT')?:3306).';dbname='.getenv('DB_NAME').';charset=utf8mb4',getenv('DB_USER'),getenv('DB_PASSWORD'),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$db->start();$controller=new IncidenciaController($db);
try{
 $item=$db->query('SELECT dc.*,c.bodeguero_id FROM detalle_compras dc JOIN compras c ON c.compra_id=dc.compra_id LIMIT 1')->fetch();AuthMiddleware::$id=$item['bodeguero_id'];
 $body=['compra_id'=>$item['compra_id'],'detalle_compra_id'=>$item['detalle_compra_id'],'tipo_incidencia'=>'PRODUCTO_DANADO','prioridad'=>'ALTA','cantidad_afectada'=>1,'descripcion'=>'Prueba transaccional: empaque del producto dañado.'];
 $controller->execute('registrar_incidencia','POST',$body);check(Response::$status===201,'Alta de reporte');$id=Response::$data['incidencia_id'];
 $_GET=['id'=>$id];$controller->execute('detalle_incidencia','GET',[]);check(Response::$status===200&&Response::$data['datos']['prioridad']==='ALTA','Detalle, prioridad y producto');
 $controller->execute('panel_bodeguero','GET',[]);check(Response::$status===200&&isset(Response::$data['stats']['facturas_mes']),'Estadísticas reales');
 $controller->execute('registrar_incidencia','POST',array_replace($body,['cantidad_afectada'=>$item['cantidad']+1]));check(Response::$status===422,'Cantidad inválida rechazada');
 $_FILES=['fotos'=>['name'=>['script.svg'],'error'=>[UPLOAD_ERR_OK],'size'=>[10],'tmp_name'=>[__FILE__]]];$controller->execute('registrar_incidencia','POST',$body);check(Response::$status===422,'Archivo no subido rechazado');$_FILES=[];
 AuthMiddleware::$id=999999;$controller->execute('detalle_incidencia','GET',[]);check(Response::$status===404,'Otro bodeguero no puede leer');
 $controller->execute('registrar_incidencia','POST',$body);check(Response::$status===422,'No puede reportar productos ajenos');
 $cp=$db->query('SELECT cp.comprobante_id FROM comprobantes_pago cp JOIN compras c ON c.compra_id=cp.compra_id WHERE c.bodeguero_id='.(int)$item['bodeguero_id'].' LIMIT 1')->fetchColumn();if($cp){(new ComprobanteController($db))->consultar($cp);check(Response::$status===404,'Factura ajena rechazada');}
 AuthMiddleware::$id=4;AuthMiddleware::$role='GESTOR_ATENCION';$controller->execute('detalle_incidencia','GET',[]);check(Response::$status===200,'Gestor puede revisar');
 OperacionController::ejecutar($db,'atender_incidencia','POST',['id'=>$id,'estado'=>'SOLUCIONADO','notas'=>'Se gestionó la reposición del producto.']);check(Response::$status===200,'Gestor responde');
 AuthMiddleware::$id=$item['bodeguero_id'];AuthMiddleware::$role='BODEGUERO';$controller->execute('detalle_incidencia','GET',[]);check(Response::$data['datos']['estado_atencion']==='SOLUCIONADO'&&Response::$data['datos']['conformidad_final']==='Se gestionó la reposición del producto.','Bodeguero ve respuesta');
 echo "Alta, detalle, prioridad, producto, validación de cantidad/archivo, aislamiento por dueño, estadísticas y respuesta del gestor: correctos. Pruebas revertidas.\n";
}finally{$db->finish();}
