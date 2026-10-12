<?php
class InternalUsersController {
 public static function execute($db,$action,$method,$data){
  if(!in_array($action,['admin_usuarios','admin_guardar_usuario','admin_estado_usuario'],true))return false;
  $user=AuthMiddleware::permitirRoles(['ADMINISTRADOR']);
  if($method!==($action==='admin_usuarios'?'GET':'POST')){Response::json(['mensaje'=>'Método no permitido'],405);return true;}
  try{Response::json(['datos'=>self::apply($db,$action,$data,$user['id']),'mensaje'=>'Cambios guardados correctamente.']);}
  catch(InvalidArgumentException $e){Response::json(['mensaje'=>$e->getMessage()],422);}
  catch(Throwable $e){Response::json(['mensaje'=>'No se pudo guardar el usuario. Inténtalo nuevamente.'],500);}return true;
 }
 public static function apply($db,$action,$data,$actor){
  $q=function($sql,$args=[])use($db){$s=$db->prepare($sql);$s->execute($args);return $s;};
  if($action==='admin_usuarios')return $q('SELECT usuario_interno_id,nombre,apellidos,correo,telefono,rol,activo,ultimo_acceso FROM usuarios_internos ORDER BY usuario_interno_id')->fetchAll();
  $id=filter_var($data['id']??0,FILTER_VALIDATE_INT);if($id===false||$id<0)throw new InvalidArgumentException('Usuario no válido.');
  $own=!$db->inTransaction();if($own)$db->beginTransaction();
  try{
   $admins=$q("SELECT usuario_interno_id FROM usuarios_internos WHERE rol='ADMINISTRADOR' AND activo=1 FOR UPDATE")->fetchAll(PDO::FETCH_COLUMN);
   $row=$id?$q('SELECT * FROM usuarios_internos WHERE usuario_interno_id=? FOR UPDATE',[$id])->fetch():null;
   if($id&&!$row)throw new InvalidArgumentException('Usuario no encontrado.');
   if($action==='admin_estado_usuario'){
    if(!$id||!isset($data['activo'])||!is_bool($data['activo']))throw new InvalidArgumentException('Indica el estado del usuario.');
    if(!$data['activo']&&($id===$actor||($row['rol']==='ADMINISTRADOR'&&$row['activo']&&count($admins)<=1)))throw new InvalidArgumentException('No puedes desactivar tu propia cuenta ni la última cuenta administradora activa.');
    $q('UPDATE usuarios_internos SET activo=? WHERE usuario_interno_id=?',[$data['activo']?1:0,$id]);
   }else{
    $values=[];foreach(['nombre','apellidos','usuario','telefono','rol'] as $field){if(!isset($data[$field])||!is_string($data[$field])||!trim($data[$field]))throw new InvalidArgumentException('Completa todos los campos obligatorios.');$values[$field]=trim($data[$field]);}
    if(mb_strlen($values['nombre'])>100||mb_strlen($values['apellidos'])>100||strlen($values['telefono'])>20||strlen($values['usuario'])>150||!filter_var($values['usuario'],FILTER_VALIDATE_EMAIL))throw new InvalidArgumentException('Revisa el nombre, el correo y el teléfono.');
    if(!in_array($values['rol'],['ADMINISTRADOR','LOGISTICA','TRANSPORTISTA','GESTOR_ATENCION'],true))throw new InvalidArgumentException('Selecciona un rol válido.');
    if($row&&$row['rol']==='ADMINISTRADOR'&&$values['rol']!=='ADMINISTRADOR'&&($id===$actor||($row['activo']&&count($admins)<=1)))throw new InvalidArgumentException('No puedes quitar el rol de tu cuenta ni de la última cuenta administradora activa.');
    if($q('SELECT usuario_interno_id FROM usuarios_internos WHERE correo=? AND usuario_interno_id<>?',[$values['usuario'],$id])->fetch())throw new InvalidArgumentException('Este correo ya pertenece a otro usuario.');
    $args=array_values($values);
    if($id){$args[]=$id;$q('UPDATE usuarios_internos SET nombre=?,apellidos=?,correo=?,telefono=?,rol=? WHERE usuario_interno_id=?',$args);}
    else{$password=$data['password']??'';if(!is_string($password)||strlen($password)<8||strlen($password)>72||$password!==($data['confirmacion']??''))throw new InvalidArgumentException('Las contraseñas deben coincidir y tener entre 8 y 72 caracteres.');$args[]=password_hash($password,PASSWORD_DEFAULT);$q('INSERT INTO usuarios_internos (nombre,apellidos,correo,telefono,rol,password_hash) VALUES (?,?,?,?,?,?)',$args);$id=(int)$db->lastInsertId();}
   }
   if($own)$db->commit();return ['id'=>$id];
  }catch(Throwable $e){if($own&&$db->inTransaction())$db->rollBack();throw $e;}
 }
}
