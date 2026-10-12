<?php
class AtencionController {
 public static function execute($db,$action,$method,$data){
  if(!in_array($action,['atencion_guardar','atencion_cuenta','atencion_password','atencion_conformidades'],true))return false;
  $user=AuthMiddleware::permitirRoles(['GESTOR_ATENCION']);
  if($method!==($action==='atencion_conformidades'?'GET':'POST')){Response::json(['mensaje'=>'Método no permitido'],405);return true;}
  try{Response::json(['datos'=>self::apply($db,$action,$data,$user['id']),'mensaje'=>'Cambios guardados correctamente.']);}
  catch(InvalidArgumentException $e){Response::json(['mensaje'=>$e->getMessage()],422);}
  catch(Throwable $e){if($db->inTransaction())$db->rollBack();Response::json(['mensaje'=>'No se pudo guardar la atención. Inténtalo nuevamente.'],500);}
  return true;
 }
 public static function apply($db,$action,$data,$gestor){
  $q=function($sql,$args=[])use($db){$s=$db->prepare($sql);$s->execute($args);return $s;};
  if($action==='atencion_conformidades')return $q("SELECT co.*,c.codigo_compra,CONCAT_WS(' ',b.nombre,b.apellidos) comprador,b.nombre_comercial,p.nombre,dc.cantidad FROM conformidades_producto co JOIN detalle_compras dc ON dc.detalle_compra_id=co.detalle_compra_id JOIN compras c ON c.compra_id=dc.compra_id JOIN bodegueros b ON b.bodeguero_id=c.bodeguero_id JOIN productos p ON p.producto_id=dc.producto_id ORDER BY co.actualizado_en DESC,co.conformidad_id DESC")->fetchAll();
  $id=filter_var($data['id']??0,FILTER_VALIDATE_INT);
  if(!$id||$id<1)throw new InvalidArgumentException('Registro no válido.');
  if(in_array($action,['atencion_cuenta','atencion_password'],true)){
   if(!$q('SELECT bodeguero_id FROM bodegueros WHERE bodeguero_id=?',[$id])->fetch())throw new InvalidArgumentException('Comercio no encontrado.');
   if($action==='atencion_cuenta'){
    if(!isset($data['activo'])||!is_bool($data['activo']))throw new InvalidArgumentException('Indica si deseas activar o desactivar el comercio.');
    $q('UPDATE bodegueros SET estado_cuenta=? WHERE bodeguero_id=?',[$data['activo']?'ACTIVO':'BLOQUEADO',$id]);return ['activo'=>$data['activo']];
   }
   $password=$data['password']??'';
   if(!is_string($password)||strlen($password)<8||strlen($password)>72||$password!==($data['confirmacion']??''))throw new InvalidArgumentException('Las contraseñas deben coincidir y tener entre 8 y 72 caracteres.');
   $q('UPDATE bodegueros SET password_hash=? WHERE bodeguero_id=?',[password_hash($password,PASSWORD_DEFAULT),$id]);return [];
  }
  $response=trim($data['respuesta']??'');$final=$data['finalizar']??false;$conforme=$data['cliente_conforme']??false;
  if(!is_bool($final)||!is_bool($conforme)||mb_strlen($response)>500)throw new InvalidArgumentException('Revisa la respuesta y la conformidad del cliente.');
  $date=function($value){if(!$value)return null;$d=DateTime::createFromFormat('!Y-m-d',$value);if(!$d||$d->format('Y-m-d')!==$value)throw new InvalidArgumentException('Fecha no válida.');return $value;};
  $replyDate=$date($data['fecha_respuesta']??null);$confirmedDate=$date($data['fecha_conformidad']??null);
  if($final&&(!$conforme||!$replyDate||!$confirmedDate||mb_strlen($response)<10))throw new InvalidArgumentException('Para finalizar registra la solución, su fecha y la conformidad del cliente.');
  if($confirmedDate&&(!$replyDate||$confirmedDate<$replyDate))throw new InvalidArgumentException('La conformidad no puede ser anterior a la respuesta.');
  if(!isset($data['requiere_reposicion'])||!is_bool($data['requiere_reposicion']))throw new InvalidArgumentException('Indica si requiere reposición.');
  $ownsTransaction=!$db->inTransaction();if($ownsTransaction)$db->beginTransaction();
  try{
   $row=$q('SELECT estado_atencion FROM atencion_incidencias WHERE incidencia_id=? FOR UPDATE',[$id])->fetch();
   if(!$row)throw new InvalidArgumentException('Incidencia no encontrada.');
   if(in_array($row['estado_atencion'],['SOLUCIONADO','RECHAZADO'],true))throw new InvalidArgumentException('Este caso ya está cerrado.');
   $q("UPDATE atencion_incidencias SET estado_atencion=?,conformidad_final=?,gestor_usuario_id=?,fecha_solucion=IF(?=1,NOW(),NULL) WHERE incidencia_id=?",[$final?'SOLUCIONADO':'EN_REVISION',$response?:null,$gestor,$final?1:0,$id]);
   $q('INSERT INTO atencion_seguimiento (incidencia_id,requiere_reposicion,fecha_respuesta,cliente_conforme,fecha_conformidad) VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE requiere_reposicion=VALUES(requiere_reposicion),fecha_respuesta=VALUES(fecha_respuesta),cliente_conforme=VALUES(cliente_conforme),fecha_conformidad=VALUES(fecha_conformidad)',[$id,$data['requiere_reposicion']?1:0,$replyDate,$final?1:0,$final?$confirmedDate:null]);
   if($ownsTransaction)$db->commit();return ['estado_atencion'=>$final?'SOLUCIONADO':'EN_REVISION'];
  }catch(Throwable $e){if($ownsTransaction&&$db->inTransaction())$db->rollBack();throw $e;}
 }
}
