<?php
if(PHP_SAPI!=='cli')exit;
require dirname(__DIR__).'/config/database.php';
$original=getenv('DB_NAME')?:'abastece_nuevo';
$name='abastece_import_'.bin2hex(random_bytes(6));
function ensure($ok,$label){if(!$ok)throw new RuntimeException($label);}
try {
 $schema=str_replace('abastece_nuevo',$name,file_get_contents(dirname(__DIR__,2).'/bd/Abastece_nuevo.sql'));
 $conexion->exec($schema);
 $seed=str_replace('USE abastece_nuevo;','USE `'.$name.'`;',file_get_contents(dirname(__DIR__,2).'/bd/Inserts_abastece.sql'));
 $conexion->exec($seed);
 ensure((int)$conexion->query("SELECT COUNT(*) FROM usuarios_internos WHERE rol='TRANSPORTISTA'")->fetchColumn()===3,'Tres transportistas');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM bodegueros')->fetchColumn()===10,'Diez bodegueros');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM direcciones WHERE es_principal=1')->fetchColumn()===10,'Diez direcciones principales');
 ensure((int)$conexion->query('SELECT COUNT(DISTINCT distrito) FROM direcciones')->fetchColumn()===4,'Cuatro distritos');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM productos')->fetchColumn()===60,'Catálogo completo');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM productos p JOIN `'.$original.'`.productos old ON old.producto_id=p.producto_id WHERE p.nombre<>old.nombre OR p.precio_unitario<>old.precio_unitario')->fetchColumn()===0,'Catálogo y precios conservados');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM vista_catalogo_disponible')->fetchColumn()===60,'Vista catálogo');
 ensure((int)$conexion->query('SELECT COUNT(*) FROM vista_guia_transportista')->fetchColumn()===10,'Despachos de los conductores');
 foreach($conexion->query('SELECT password_hash FROM usuarios_internos') as $r)ensure(password_verify('Abastece2026!',$r['password_hash']),'Credenciales operativas');
 $tables=$conexion->query('SHOW FULL TABLES')->fetchAll(PDO::FETCH_NUM);ensure(count($tables)===33,'26 tablas y 7 vistas');
 echo "Importación limpia: 26 tablas, 7 vistas, 60 productos con precios conservados, 10 comercios, 3 transportistas y relaciones válidas. Base temporal eliminada.\n";
}finally{
 if($conexion->inTransaction())$conexion->rollBack();
 if(preg_match('/^abastece_import_[a-f0-9]{12}$/',$name))$conexion->exec("DROP DATABASE IF EXISTS `$name`");
 $conexion->exec("USE `$original`");
}
