<?php
require_once __DIR__ . "/FavoritoController.php";
require_once __DIR__."/../models/DireccionBodega.php";
class IncidenciaController {
 private $db;
 public function __construct($db){$this->db=$db;}
 private function q($sql,$args=[]){$s=$this->db->prepare($sql);$s->execute($args);return $s;}
 public function execute($action,$method,$data){
  if(!in_array($action,['panel_bodeguero','consultar_incidencias','detalle_incidencia','foto_incidencia','registrar_incidencia'],true))return false;
  $user=AuthMiddleware::permitirRoles(in_array($action,['panel_bodeguero','registrar_incidencia'])?['BODEGUERO']:['BODEGUERO','GESTOR_ATENCION']);
  if($method!==($action==='registrar_incidencia'?'POST':'GET')){Response::json(['mensaje'=>'Método no permitido'],405);return true;}
  $files=[];$written=[];
  try {
   if($action==='panel_bodeguero'){
    $stats=$this->q("SELECT COALESCE(SUM(IF(fecha_compra>=DATE_FORMAT(NOW(),'%Y-%m-01') AND fecha_compra<DATE_FORMAT(NOW(),'%Y-%m-01')+INTERVAL 1 MONTH AND estado_pedido<>'CANCELADO',total,0)),0) gasto_mensual,SUM(fecha_compra>=DATE_FORMAT(NOW(),'%Y-%m-01') AND fecha_compra<DATE_FORMAT(NOW(),'%Y-%m-01')+INTERVAL 1 MONTH) compras_mes,SUM(estado_pedido NOT IN ('ENTREGADO','CANCELADO')) pedidos_proceso FROM compras WHERE bodeguero_id=?",[$user['id']])->fetch();
    $stats['facturas_mes']=$this->q("SELECT COUNT(*) FROM comprobantes_pago cp JOIN compras c ON c.compra_id=cp.compra_id WHERE c.bodeguero_id=? AND cp.tipo_comprobante='FACTURA_ELECTRONICA' AND cp.fecha_emision>=DATE_FORMAT(NOW(),'%Y-%m-01') AND cp.fecha_emision<DATE_FORMAT(NOW(),'%Y-%m-01')+INTERVAL 1 MONTH",[$user['id']])->fetchColumn();
    $favorites=$this->q("SELECT v.*,v.precio_unitario precio_base_sugerido,v.stock_total stock_disponible,v.imagen_principal imagen_url,f.unidades FROM vista_catalogo_disponible v JOIN (SELECT dc.producto_id,SUM(dc.cantidad) unidades FROM detalle_compras dc JOIN compras c ON c.compra_id=dc.compra_id WHERE c.bodeguero_id=? AND c.estado_pedido<>'CANCELADO' GROUP BY dc.producto_id) f ON f.producto_id=v.producto_id ORDER BY f.unidades DESC,v.producto_id LIMIT 5",[$user['id']])->fetchAll();
    Response::json(['direccion'=>DireccionBodega::consultar($this->db,$user['id']),'stats'=>$stats,'favoritos'=>FavoritoController::listar($this->db,(int)$user['id']),'frecuentes'=>$favorites]);return true;
   }
   if($action==='registrar_incidencia'){
    $maxPost=ini_get('post_max_size');$limit=(int)$maxPost*(['g'=>1073741824,'m'=>1048576,'k'=>1024][strtolower(substr($maxPost,-1))]??1);
    if($limit>0 && (int)($_SERVER['CONTENT_LENGTH']??0)>$limit)throw new InvalidArgumentException('Las fotos exceden el límite de carga del servidor. Reduce su tamaño o revisa la configuración de PHP.');
    $description=trim($data['descripcion']??'');$type=$data['tipo_incidencia']??'';$priority=$data['prioridad']??'MEDIA';
    if(mb_strlen($description)<10||mb_strlen($description)>500)throw new InvalidArgumentException('Describe el problema entre 10 y 500 caracteres.');
    if(!in_array($type,['PRODUCTO_DANADO','PEDIDO_INCOMPLETO','PRODUCTO_PROXIMO_VENCER','DEMORA_ENTREGA','OTRO'],true)||!in_array($priority,['BAJA','MEDIA','ALTA'],true))throw new InvalidArgumentException('Categoría o prioridad no válida.');
    $item=$this->q('SELECT dc.* FROM detalle_compras dc JOIN compras c ON c.compra_id=dc.compra_id WHERE dc.detalle_compra_id=? AND c.compra_id=? AND c.bodeguero_id=?',[$data['detalle_compra_id']??0,$data['compra_id']??0,$user['id']])->fetch();
    if(!$item)throw new InvalidArgumentException('Selecciona un producto de uno de tus pedidos.');
    $qty=filter_var($data['cantidad_afectada']??0,FILTER_VALIDATE_INT);
    if(!$qty||$qty<1||$qty>(int)$item['cantidad'])throw new InvalidArgumentException('La cantidad afectada debe estar entre 1 y la cantidad comprada.');
    $upload=$_FILES['fotos']??null;
    if($upload){
     if(!is_array($upload['name'])||count($upload['name'])>5)throw new InvalidArgumentException('Puedes adjuntar hasta 5 fotos.');
     foreach($upload['name'] as $i=>$name){
      if($upload['error'][$i]===UPLOAD_ERR_NO_FILE)continue;
      if($upload['error'][$i]!==UPLOAD_ERR_OK||$upload['size'][$i]>5*1024*1024||!is_uploaded_file($upload['tmp_name'][$i]))throw new InvalidArgumentException('Cada imagen debe ser válida y pesar como máximo 5 MB.');
      $mime=(new finfo(FILEINFO_MIME_TYPE))->file($upload['tmp_name'][$i]);$ext=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$mime]??null;
      if(!$ext||!getimagesize($upload['tmp_name'][$i]))throw new InvalidArgumentException('Adjunta imágenes JPG, PNG o WEBP.');
      $files[]=['tmp'=>$upload['tmp_name'][$i],'mime'=>$mime,'file'=>bin2hex(random_bytes(20)).'.'.$ext,'name'=>mb_substr(basename($name),0,200)];
     }
    }
    $this->db->beginTransaction();
    $this->q('INSERT INTO atencion_incidencias (bodeguero_id,compra_id,tipo_incidencia,descripcion) VALUES (?,?,?,?)',[$user['id'],$item['compra_id'],$type,$description]);$id=(int)$this->db->lastInsertId();
    $this->q('INSERT INTO incidencia_detalles (incidencia_id,detalle_compra_id,prioridad,cantidad_afectada) VALUES (?,?,?,?)',[$id,$item['detalle_compra_id'],$priority,$qty]);
    $dir=__DIR__.'/../storage/incidencias';
    if($files&&!is_dir($dir)&&!mkdir($dir,0755,true))throw new RuntimeException('No se pudo preparar el almacenamiento.');
    foreach($files as $file){$target=$dir.'/'.$file['file'];if(!move_uploaded_file($file['tmp'],$target))throw new RuntimeException('No se pudo guardar una foto.');$written[]=$target;$this->q('INSERT INTO incidencia_evidencias (incidencia_id,archivo,mime,nombre_original) VALUES (?,?,?,?)',[$id,$file['file'],$file['mime'],$file['name']]);}
    $this->db->commit();Response::json(['mensaje'=>'Incidencia enviada. El equipo de atención revisará tu caso.','incidencia_id'=>$id],201);return true;
   }
   $condition=$user['rol']==='BODEGUERO'?' AND i.bodeguero_id=?':'';$args=$user['rol']==='BODEGUERO'?[$user['id']]:[];
   $sql="SELECT i.*,c.codigo_compra,CONCAT_WS(' ',b.nombre,b.apellidos) comprador,b.nombre_comercial,d.prioridad,d.cantidad_afectada,p.nombre producto_nombre,s.requiere_reposicion,s.fecha_respuesta,s.cliente_conforme,s.fecha_conformidad FROM atencion_incidencias i JOIN bodegueros b ON b.bodeguero_id=i.bodeguero_id LEFT JOIN compras c ON c.compra_id=i.compra_id LEFT JOIN incidencia_detalles d ON d.incidencia_id=i.incidencia_id LEFT JOIN atencion_seguimiento s ON s.incidencia_id=i.incidencia_id LEFT JOIN detalle_compras dc ON dc.detalle_compra_id=d.detalle_compra_id LEFT JOIN productos p ON p.producto_id=dc.producto_id WHERE 1=1".$condition;
   if($action==='consultar_incidencias'){Response::json(['datos'=>$this->q($sql.' ORDER BY i.fecha_reporte DESC,i.incidencia_id DESC',$args)->fetchAll()]);return true;}
   $args[]=$_GET['id']??0;$row=$this->q($sql.' AND i.incidencia_id=?',$args)->fetch();
   if(!$row){Response::json(['mensaje'=>'Incidencia no encontrada'],404);return true;}
   if($action==='foto_incidencia'){
    $file=$this->q('SELECT archivo,mime FROM incidencia_evidencias WHERE incidencia_id=? AND evidencia_id=?',[$row['incidencia_id'],$_GET['foto']??0])->fetch();
    $path=$file?__DIR__.'/../storage/incidencias/'.basename($file['archivo']):null;
    if(!$path||!is_file($path)){Response::json(['mensaje'=>'Foto no encontrada'],404);return true;}
    header('Content-Type: '.$file['mime']);header('X-Content-Type-Options: nosniff');header('Cache-Control: private, no-store');readfile($path);return true;
   }
   $row['evidencias']=$this->q('SELECT evidencia_id,nombre_original FROM incidencia_evidencias WHERE incidencia_id=?',[$row['incidencia_id']])->fetchAll();Response::json(['datos'=>$row]);
  }catch(InvalidArgumentException $e){if($this->db->inTransaction())$this->db->rollBack();Response::json(['mensaje'=>$e->getMessage()],422);}
  catch(Throwable $e){if($this->db->inTransaction())$this->db->rollBack();foreach($written as $path)if(is_file($path))unlink($path);Response::json(['mensaje'=>'No se pudo guardar la incidencia. Inténtalo nuevamente.'],500);}
  return true;
 }
}
