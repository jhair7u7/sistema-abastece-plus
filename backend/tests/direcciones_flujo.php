<?php
require dirname(__DIR__).'/config/database.php';
require dirname(__DIR__).'/models/Bodeguero.php';
function verify($ok,$message){if(!$ok)throw new RuntimeException($message);}
$conexion->beginTransaction();
try {
 $model=new Bodeguero($conexion);
 $a=DireccionBodega::validar(['direccion_exacta'=>'Av. Carlos Izaguirre 813','distrito'=>'Los Olivos']);
 $model->registrar('Rosa','Huamán','address.'.uniqid().'@example.com',password_hash('Abastece2026!',PASSWORD_BCRYPT),'900000101','10999999991','BODEGA','Las Palmeras','Rosa Huamán',$a);
 $id=$conexion->query("SELECT bodeguero_id FROM bodegueros WHERE ruc='10999999991'")->fetchColumn();$first=DireccionBodega::consultar($conexion,$id);verify($first['direccion_exacta']===$a['direccion_exacta'],'Registro con dirección');
 $b=DireccionBodega::validar(['direccion_exacta'=>'Av. Universitaria 2086','distrito'=>'Los Olivos']);
 $merchant=$model->buscarPorId($id);$model->actualizar($id,$merchant['nombre'],$merchant['apellidos'],$merchant['correo'],$merchant['telefono'],$merchant['ruc'],$merchant['tipo_establecimiento'],$merchant['nombre_comercial'],$merchant['razon_social'],$b);$second=DireccionBodega::consultar($conexion,$id);verify($second['direccion_exacta']===$b['direccion_exacta'],'Dirección actualizada');verify($first['direccion_id']!==$second['direccion_id'],'Historial conservado');
 $q=$conexion->prepare('SELECT COUNT(*) FROM direcciones WHERE bodeguero_id=? AND es_principal=1');$q->execute([$id]);verify((int)$q->fetchColumn()===1,'Una principal');
 verify(count(array_filter($model->listar(),fn($r)=>$r['bodeguero_id']==$id && $r['direccion_exacta']===$b['direccion_exacta']))===1,'Atención recibe dirección actual');
 try {DireccionBodega::validar(['distrito'=>'Los Olivos']);throw new RuntimeException('Aceptó dirección vacía');}catch(InvalidArgumentException $e){}
 echo "Registro, edición, dirección principal e historial: correctos. Cambios revertidos.\n";
}finally{$conexion->rollBack();}
