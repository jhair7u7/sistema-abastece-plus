<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../config/database.php';
require __DIR__.'/../controllers/AtencionController.php';
require __DIR__.'/../controllers/AuthController.php';
class Response{public static $data,$status;public static function json($d,$s=200){self::$data=$d;self::$status=$s;}}
function verify($ok,$message){if(!$ok)throw new RuntimeException($message);}
$db=$conexion;$db->beginTransaction();
try{
 $b=$db->query('SELECT * FROM bodegueros LIMIT 1')->fetch();$gestor=$db->query("SELECT usuario_interno_id FROM usuarios_internos WHERE rol='GESTOR_ATENCION' AND activo=1 LIMIT 1")->fetchColumn();
 $id=$b['bodeguero_id'];$new='PruebaTemporal8!';
 AtencionController::apply($db,'atencion_password',['id'=>$id,'password'=>$new,'confirmacion'=>$new],$gestor);
 $hash=$db->query('SELECT password_hash FROM bodegueros WHERE bodeguero_id='.(int)$id)->fetchColumn();verify(password_verify($new,$hash)&&$hash!==$new,'Hash de contraseña');
 AtencionController::apply($db,'atencion_cuenta',['id'=>$id,'activo'=>false],$gestor);
 $auth=new AuthController($db);$auth->loginCliente(['usuario'=>$b['correo'],'password'=>$new]);verify(Response::$status===403,'Cuenta inactiva no puede ingresar');
 AtencionController::apply($db,'atencion_cuenta',['id'=>$id,'activo'=>true],$gestor);$auth->loginCliente(['usuario'=>$b['correo'],'password'=>$new]);verify(Response::$status===200,'Cuenta reactivada puede ingresar');
 $auth->loginCliente(['usuario'=>$b['correo'],'password'=>'Incorrecta1!']);verify(Response::$status===401,'Contraseña incorrecta rechazada');
 $s=$db->prepare("INSERT INTO atencion_incidencias (bodeguero_id,tipo_incidencia,descripcion) VALUES (?,'OTRO','Prueba transaccional de seguimiento.')");$s->execute([$id]);$incident=$db->lastInsertId();
 $body=['id'=>$incident,'respuesta'=>'Se coordinó la solución con el cliente.','requiere_reposicion'=>true,'fecha_respuesta'=>date('Y-m-d'),'cliente_conforme'=>false,'fecha_conformidad'=>'','finalizar'=>false];
 AtencionController::apply($db,'atencion_guardar',$body,$gestor);verify($db->query('SELECT estado_atencion FROM atencion_incidencias WHERE incidencia_id='.(int)$incident)->fetchColumn()==='EN_REVISION','Borrador queda en revisión');
 $rejected=false;try{AtencionController::apply($db,'atencion_guardar',array_replace($body,['finalizar'=>true]),$gestor);}catch(InvalidArgumentException $e){$rejected=true;}verify($rejected,'No finaliza sin conformidad');
 AtencionController::apply($db,'atencion_guardar',array_replace($body,['finalizar'=>true,'cliente_conforme'=>true,'fecha_conformidad'=>date('Y-m-d')]),$gestor);
 $row=$db->query('SELECT i.*,s.cliente_conforme,s.requiere_reposicion FROM atencion_incidencias i JOIN atencion_seguimiento s USING(incidencia_id) WHERE incidencia_id='.(int)$incident)->fetch();verify($row['estado_atencion']==='SOLUCIONADO'&&$row['cliente_conforme']==1&&$row['requiere_reposicion']==1&&$row['conformidad_final']===$body['respuesta'],'Resolución y seguimiento persistidos');
 echo "Contraseña cifrada, acceso rechazado al desactivar, reactivación, borrador, validación de conformidad y resolución: correctos. Datos revertidos.\n";
}finally{if($db->inTransaction())$db->rollBack();}
