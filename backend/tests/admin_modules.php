<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../config/database.php';require __DIR__.'/../middleware/AuthMiddleware.php';
function checkModule($token,$action,$expected=200){
 $context=stream_context_create(['http'=>['header'=>'Authorization: Bearer '.$token,'ignore_errors'=>true,'timeout'=>45]]);
 $raw=file_get_contents((getenv('TEST_API_URL')?:'http://localhost:8000').'/?accion='.$action,false,$context);
 preg_match('/\s(\d{3})\s/',$http_response_header[0]??'',$m);$status=(int)($m[1]??0);
 if($status!==$expected||json_decode($raw,true)===null)throw new RuntimeException($action.': '.$status.' (esperado '.$expected.')');
}
$admin=$conexion->query("SELECT * FROM usuarios_internos WHERE rol='ADMINISTRADOR' AND activo=1 LIMIT 1")->fetch();$token=AuthMiddleware::crearToken($admin);
foreach(['admin_usuarios','stock','productos_internos','listar_categorias','listar_proveedores','despachos','transportistas','listar_comprobantes','rutas_transporte','consultar_incidencias','atencion_conformidades','listar_bodegueros'] as $action)checkModule($token,$action);
$driver=$conexion->query("SELECT * FROM usuarios_internos WHERE rol='TRANSPORTISTA' AND activo=1 LIMIT 1")->fetch();$driverToken=AuthMiddleware::crearToken($driver);
checkModule($driverToken,'admin_usuarios',403);checkModule($driverToken,'stock',403);checkModule($driverToken,'rutas_transporte');
echo "12 apartados accesibles al administrador. Transporte conserva su acceso y no accede a Usuarios ni Stock.\n";
