<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../config/database.php';
require __DIR__.'/../middleware/AuthMiddleware.php';
require __DIR__.'/../controllers/InternalUsersController.php';
require __DIR__.'/../controllers/AuthController.php';
class Response{public static $status,$data;public static function json($data,$status=200){self::$status=$status;self::$data=$data;if(isset($GLOBALS['child']))echo $status;}}
function verify($ok,$message){if(!$ok)throw new RuntimeException($message);}
if(($argv[1]??'')==='permission'){
 $GLOBALS['child']=true;$row=$conexion->query("SELECT * FROM usuarios_internos WHERE rol=".$conexion->quote($argv[2])." AND activo=1 LIMIT 1")->fetch();
 $_SERVER['HTTP_AUTHORIZATION']='Bearer '.AuthMiddleware::crearToken($row);
 if(($argv[4]??'')==='inactive'){$conexion->beginTransaction();$conexion->prepare('UPDATE usuarios_internos SET activo=0 WHERE usuario_interno_id=?')->execute([$row['usuario_interno_id']]);}
 AuthMiddleware::permitirRoles([$argv[3]]);echo '200';exit;
}
$db=$conexion;$db->beginTransaction();
try{
 $admin=(int)$db->query("SELECT usuario_interno_id FROM usuarios_internos WHERE rol='ADMINISTRADOR' AND activo=1 LIMIT 1")->fetchColumn();
 $service=fn($action,$data)=>InternalUsersController::apply($db,$action,$data,$admin);
 $form=['nombre'=>'Prueba','apellidos'=>'Temporal','usuario'=>'admin-test-'.bin2hex(random_bytes(5)).'@example.test','telefono'=>'900000000','rol'=>'LOGISTICA','password'=>'Temporal123!','confirmacion'=>'Temporal123!'];
 $id=$service('admin_guardar_usuario',$form)['id'];$auth=new AuthController($db);
 $auth->loginAdmin(['usuario'=>$form['usuario'],'password'=>$form['password']]);verify(Response::$status===200,'Usuario nuevo inicia sesión');
 $service('admin_estado_usuario',['id'=>$id,'activo'=>false]);$auth->loginAdmin(['usuario'=>$form['usuario'],'password'=>$form['password']]);verify(Response::$status===401,'Inactivo no ingresa');
 $service('admin_estado_usuario',['id'=>$id,'activo'=>true]);$auth->loginAdmin(['usuario'=>$form['usuario'],'password'=>$form['password']]);verify(Response::$status===200,'Reactivado ingresa');
 $service('admin_guardar_usuario',array_replace($form,['id'=>$id,'nombre'=>'Actualizado','rol'=>'GESTOR_ATENCION']));$r=$db->query('SELECT * FROM usuarios_internos WHERE usuario_interno_id='.(int)$id)->fetch();verify($r['nombre']==='Actualizado'&&$r['rol']==='GESTOR_ATENCION'&&$r['ultimo_acceso'],'Edición y fecha de acceso reales');
 foreach([['admin_estado_usuario',['id'=>$admin,'activo'=>false]],['admin_guardar_usuario',array_replace($form,['id'=>$admin,'usuario'=>'another@example.test','rol'=>'LOGISTICA'])]] as [$action,$data]){$rejected=false;try{$service($action,$data);}catch(InvalidArgumentException $e){$rejected=true;}verify($rejected,'Protección de la propia cuenta administradora');}
 $adminForm=array_replace($form,['usuario'=>'second-'.bin2hex(random_bytes(4)).'@example.test','rol'=>'ADMINISTRADOR']);$second=$service('admin_guardar_usuario',$adminForm)['id'];
 $db->exec("UPDATE usuarios_internos SET activo=0 WHERE rol='ADMINISTRADOR' AND usuario_interno_id<>".(int)$second);$rejected=false;try{$service('admin_estado_usuario',['id'=>$second,'activo'=>false]);}catch(InvalidArgumentException $e){$rejected=true;}verify($rejected,'Protección de último administrador');
 echo "Alta, edición, desactivación, reactivación, login y protección de administradores: correctos. Datos revertidos.\n";
}finally{if($db->inTransaction())$db->rollBack();}
$cases=[['ADMINISTRADOR','LOGISTICA',200],['ADMINISTRADOR','TRANSPORTISTA',200],['ADMINISTRADOR','GESTOR_ATENCION',200],['ADMINISTRADOR','BODEGUERO',403],['LOGISTICA','ADMINISTRADOR',403],['TRANSPORTISTA','GESTOR_ATENCION',403],['GESTOR_ATENCION','LOGISTICA',403],['LOGISTICA','LOGISTICA',401,'inactive']];
foreach($cases as $case){[$role,$allowed,$expected]=$case;$cmd=escapeshellarg(PHP_BINARY).' '.escapeshellarg(__FILE__).' permission '.escapeshellarg($role).' '.escapeshellarg($allowed).' '.escapeshellarg($case[3]??'');$out=shell_exec($cmd);verify(trim($out)===(string)$expected,'Permisos '.$role.' -> '.$allowed.' ('.$out.')');}
echo "Acceso total del administrador, aislamiento de otros roles y revocación de sesión inactiva: correctos.\n";
