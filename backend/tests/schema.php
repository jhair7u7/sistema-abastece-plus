<?php
// Valida una importación limpia y restricciones usando una base temporal propia.
if (PHP_SAPI !== 'cli') exit;
require __DIR__.'/../config/database.php';
$testDb='abastece_test_'.bin2hex(random_bytes(6));
$sql=str_replace('abastece_nuevo',$testDb,file_get_contents(__DIR__.'/../../bd/Abastece_nuevo.sql'));
try {
 $conexion->exec($sql);
 if ((int)$conexion->query('SELECT COUNT(*) FROM productos')->fetchColumn()!==60) throw new Exception('Catálogo incompleto');
 foreach([
   'UPDATE inventario_lotes SET stock_disponible=-1 WHERE lote_id=1',
   'UPDATE detalle_compras SET lote_id=2 WHERE detalle_compra_id=1',
   'UPDATE atencion_incidencias SET compra_id=2 WHERE incidencia_id=1',
   'UPDATE compras SET direccion_id=2 WHERE compra_id=1',
 ] as $invalid) {
  $conexion->beginTransaction();$rejected=false;
  try {$conexion->exec($invalid);} catch(PDOException $e) {$rejected=true;}
  $conexion->rollBack(); if(!$rejected)throw new Exception('Restricción faltante: '.$invalid);
 }
 require __DIR__.'/../models/Bodeguero.php';
 require __DIR__.'/../models/Proveedor.php';
 require __DIR__.'/../models/Producto.php';
 require __DIR__.'/../models/Direccion.php';
 $conexion->beginTransaction();
 $b=new Bodeguero($conexion);
 $b->registrar('Demo','Prueba','registro@example.test',password_hash('demo123',PASSWORD_DEFAULT),'000000099','00000000998','OTRO','Demo','Demo');
 $d=new Direccion($conexion);$d->crear(['bodeguero_id'=>1,'distrito'=>'Demo','direccion_exacta'=>'Demo','zona_reparto'=>'LIMA_CENTRO']);
 $p=new Proveedor($conexion);$p->registrar('00000000997','Demo','Demo','Demo','proveedor-test@example.test','000000099');
 $conexion->rollBack();
 $product=new Producto($conexion);
 $data=['categoria_id'=>1,'codigo_sku'=>'TEST-DEMO','nombre'=>'Demo','descripcion'=>'Demo','imagen_url'=>'/logo.png','marca'=>'Demo','unidad_medida'=>'Caja','peso_kg'=>1,'precio_base_sugerido'=>10];
 $product->registrar($data);$id=$conexion->query("SELECT producto_id FROM productos WHERE codigo_interno='TEST-DEMO'")->fetchColumn();
 $data['precio_base_sugerido']=12;$product->actualizar($id,$data);
 if ((float)$product->buscarPorId($id)['precio_base_sugerido']!==12.0)throw new Exception('Producto no actualizado');
 // La autenticación se comprueba por HTTP en rbac.mjs; aquí se ejercitan las escrituras.
 require __DIR__.'/../controllers/OperacionController.php';
 function operation($action,$data) {
  global $conexion;
  Response::$result=null;Response::$status=200;
  OperacionController::ejecutar($conexion,$action,'POST',$data);
  if(Response::$status!==200)throw new Exception($action.': '.json_encode(Response::$result));
 }
 operation('ajustar_stock',['id'=>1,'stock'=>70,'motivo'=>'Prueba automática']);
 if((int)$conexion->query('SELECT stock_disponible FROM inventario_lotes WHERE lote_id=1')->fetchColumn()!==70)throw new Exception('Stock');
 operation('asignar_despacho',['id'=>4,'transportista_id'=>3,'placa'=>'DEMO-02','ruta'=>'Recorrido demo']);
 operation('actualizar_entrega',['id'=>4,'estado'=>'EN_TRAYECTO']);
 operation('actualizar_entrega',['id'=>4,'estado'=>'ENTREGADO']);
 if($conexion->query('SELECT estado_pedido FROM compras WHERE compra_id=4')->fetchColumn()!=='ENTREGADO')throw new Exception('Entrega');
 operation('atender_incidencia',['id'=>2,'estado'=>'SOLUCIONADO','notas'=>'Resolución demo']);
 operation('revisar_conformidad',['id'=>1,'estado'=>'CONFORME','notas'=>'Demo']);
 $conexion->exec("INSERT INTO compras (compra_id,codigo_compra,bodeguero_id,direccion_id,subtotal,igv,total) VALUES (99,'TEST-99',1,1,10,1.8,11.8)");
 operation('emitir_factura',['id'=>99]);
 echo "Importación limpia, 60 productos, 4 restricciones y modelos CRUD: correctos.\n";
 echo "Stock, despacho, entrega, incidencia, conformidad y factura: escrituras correctas.\n";
} finally {
 if($conexion->inTransaction())$conexion->rollBack();
 $conexion->exec('USE abastece_nuevo');
 // Nombre aleatorio generado arriba, exclusivamente para esta prueba.
 $conexion->exec('DROP DATABASE IF EXISTS `'.$testDb.'`');
}

class AuthMiddleware {
 public static function permitirRoles($roles) {return ['id'=>$roles[0]==='TRANSPORTISTA'?3:($roles[0]==='GESTOR_ATENCION'?4:2)];}
}
class Response {
 public static $result; public static $status;
 public static function json($data,$status=200){self::$result=$data;self::$status=$status;}
}
