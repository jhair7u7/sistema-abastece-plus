<?php
if(PHP_SAPI!=='cli')exit;
require dirname(__DIR__).'/config/database.php';
require dirname(__DIR__).'/controllers/FavoritoController.php';
require dirname(__DIR__).'/controllers/IncidenciaController.php';
class AuthMiddleware{public static $id,$role='BODEGUERO';public static function permitirRoles($roles){if(!in_array(self::$role,$roles))throw new RuntimeException('Prohibido');return ['id'=>self::$id,'rol'=>self::$role];}}
class Response{public static $data,$status;public static function json($d,$s=200){self::$data=$d;self::$status=$s;}}
function check($ok,$message){if(!$ok)throw new RuntimeException($message);}
$conexion->beginTransaction();
try{
 $owners=$conexion->query('SELECT bodeguero_id FROM bodegueros LIMIT 2')->fetchAll(PDO::FETCH_COLUMN);
 $product=$conexion->query('SELECT producto_id FROM vista_catalogo_disponible LIMIT 1')->fetchColumn();
 check(count($owners)===2&&$product,'Datos de prueba disponibles');
 $conexion->prepare('DELETE FROM productos_favoritos WHERE bodeguero_id IN (?,?) AND producto_id=?')->execute([$owners[0],$owners[1],$product]);
 AuthMiddleware::$id=$owners[0];$controller=new FavoritoController($conexion);
 $body=['producto_id'=>(int)$product,'favorito'=>true];
 $controller->execute('guardar_favorito','POST',$body);check(Response::$status===200,'Guardar favorito');
 $controller->execute('guardar_favorito','POST',$body);check(Response::$status===200,'Repetición idempotente');
 $controller->execute('listar_favoritos','GET',[]);check(count(array_filter(Response::$data['favoritos'],fn($p)=>$p['producto_id']==$product))===1,'Persistencia sin duplicados');
 (new IncidenciaController($conexion))->execute('panel_bodeguero','GET',[]);check(count(array_filter(Response::$data['favoritos'],fn($p)=>$p['producto_id']==$product))===1&&isset(Response::$data['frecuentes']),'Favoritos del panel conectados');
 AuthMiddleware::$id=$owners[1];$controller->execute('listar_favoritos','GET',[]);check(!array_filter(Response::$data['favoritos'],fn($p)=>$p['producto_id']==$product),'Aislamiento entre usuarios');
 $controller->execute('guardar_favorito','POST',['producto_id'=>(int)$product,'favorito'=>false]);
 AuthMiddleware::$id=$owners[0];$controller->execute('listar_favoritos','GET',[]);check((bool)array_filter(Response::$data['favoritos'],fn($p)=>$p['producto_id']==$product),'Otro usuario no puede eliminarlo');
 $controller->execute('guardar_favorito','POST',['producto_id'=>-1,'favorito'=>true]);check(Response::$status===422,'Validación de producto');
 $controller->execute('guardar_favorito','POST',['producto_id'=>(int)$product,'favorito'=>'true']);check(Response::$status===422,'Validación de selección');
 $controller->execute('guardar_favorito','POST',['producto_id'=>(int)$product,'favorito'=>false]);
 $controller->execute('listar_favoritos','GET',[]);check(!array_filter(Response::$data['favoritos'],fn($p)=>$p['producto_id']==$product),'Quitar favorito');
 AuthMiddleware::$role='LOGISTICA';try{$controller->execute('listar_favoritos','GET',[]);throw new RuntimeException('Rol interno admitido');}catch(RuntimeException $e){check($e->getMessage()==='Prohibido','Restricción de rol');}
 echo "Favoritos: persistencia, aislamiento, idempotencia, validaciones y conexión al panel correctos. Pruebas revertidas.\n";
}finally{$conexion->rollBack();}
