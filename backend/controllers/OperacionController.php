<?php

require_once __DIR__ . "/../middleware/AuthMiddleware.php";
require_once __DIR__ . "/../utils/Response.php";

// Operaciones del proyecto: todas las consultas se autorizan en el servidor.
class OperacionController
{
    public static function ejecutar($db, $accion, $metodo, $datos)
    {
        $roles = [
            'stock' => ['LOGISTICA', 'ADMINISTRADOR'], 'ajustar_stock' => ['LOGISTICA', 'ADMINISTRADOR'],
            'despachos' => ['LOGISTICA', 'ADMINISTRADOR'], 'asignar_despacho' => ['LOGISTICA', 'ADMINISTRADOR'],
            'facturas' => ['LOGISTICA', 'ADMINISTRADOR'], 'emitir_factura' => ['LOGISTICA', 'ADMINISTRADOR'],
            'transportistas' => ['LOGISTICA', 'ADMINISTRADOR'],
            'mis_rutas' => ['TRANSPORTISTA', 'ADMINISTRADOR'], 'actualizar_entrega' => ['TRANSPORTISTA', 'ADMINISTRADOR'],
            'incidencias' => ['GESTOR_ATENCION', 'ADMINISTRADOR'], 'atender_incidencia' => ['GESTOR_ATENCION', 'ADMINISTRADOR'],
            'conformidades' => ['GESTOR_ATENCION', 'ADMINISTRADOR'], 'revisar_conformidad' => ['GESTOR_ATENCION', 'ADMINISTRADOR'],
            'mis_pedidos' => ['BODEGUERO', 'ADMINISTRADOR'], 'mis_facturas' => ['BODEGUERO', 'ADMINISTRADOR'],
            'detalle_pedido' => ['BODEGUERO', 'ADMINISTRADOR'], 'tarjetas_prueba' => ['BODEGUERO', 'ADMINISTRADOR'],
            'crear_compra' => ['BODEGUERO', 'ADMINISTRADOR'],
        ];
        if (!isset($roles[$accion])) return false;
        $user = AuthMiddleware::permitirRoles($roles[$accion]);
        $lecturas = ['stock','despachos','facturas','transportistas','mis_rutas','incidencias','conformidades','mis_pedidos','mis_facturas','detalle_pedido','tarjetas_prueba'];
        if ($metodo !== (in_array($accion, $lecturas, true) ? 'GET' : 'POST')) {
            Response::json(['mensaje'=>'Método no permitido'],405); return true;
        }
        $query = function ($sql, $params = []) use ($db) {
            $q=$db->prepare($sql); $q->execute($params); return $q;
        };
        try {
            $rows = [];
            switch ($accion) {
                case 'stock':
                    $rows=$query('SELECT l.*, p.nombre, p.marca, c.nombre AS categoria_nombre FROM inventario_lotes l JOIN productos p ON p.producto_id=l.producto_id JOIN categorias c ON c.categoria_id=p.categoria_id ORDER BY c.nombre,p.nombre')->fetchAll(); break;
                case 'transportistas':
                    $rows=$query("SELECT usuario_interno_id, nombre FROM usuarios_internos WHERE activo=1 AND rol='TRANSPORTISTA'")->fetchAll(); break;
                case 'despachos':
                    $rows=$query('SELECT c.compra_id,c.codigo_compra,c.estado_pedido,g.guia_id,g.codigo_guia,r.ruta_id,r.transportista_id,r.estado_entrega FROM compras c LEFT JOIN guias_remision g ON g.compra_id=c.compra_id LEFT JOIN rutas_despacho r ON r.guia_id=g.guia_id')->fetchAll(); break;
                case 'facturas':
                    $rows=$query('SELECT * FROM comprobantes_pago')->fetchAll(); break;
                case 'mis_rutas':
                    $rows=$query('SELECT * FROM vista_guia_transportista WHERE transportista_id=?',[$user['id']])->fetchAll();
                    foreach ($rows as &$r) $r['items']=$query('SELECT p.nombre,dc.cantidad,p.unidad_medida FROM detalle_compras dc JOIN productos p ON p.producto_id=dc.producto_id JOIN guias_remision g ON g.compra_id=dc.compra_id WHERE g.guia_id=?',[$r['guia_id']])->fetchAll();
                    unset($r); break;
                case 'incidencias':
                    $rows=$query('SELECT * FROM atencion_incidencias')->fetchAll(); break;
                case 'conformidades':
                    $rows=$query('SELECT co.*,dc.compra_id,p.nombre FROM conformidades_producto co JOIN detalle_compras dc ON dc.detalle_compra_id=co.detalle_compra_id JOIN productos p ON p.producto_id=dc.producto_id')->fetchAll(); break;
                case 'mis_pedidos':
                    $rows=$query("SELECT c.compra_id,c.codigo_compra,c.total,c.estado_pedido,c.fecha_compra,COALESCE(r.estado_entrega,'ASIGNADO') estado_entrega,COUNT(dc.detalle_compra_id) productos FROM compras c LEFT JOIN detalle_compras dc ON dc.compra_id=c.compra_id LEFT JOIN guias_remision g ON g.compra_id=c.compra_id LEFT JOIN rutas_despacho r ON r.guia_id=g.guia_id WHERE c.bodeguero_id=? GROUP BY c.compra_id,r.estado_entrega ORDER BY c.fecha_compra DESC",[$user['id']])->fetchAll(); break;
                case 'mis_facturas':
                    $rows=$query('SELECT cp.* FROM comprobantes_pago cp JOIN compras c ON c.compra_id=cp.compra_id WHERE c.bodeguero_id=?',[$user['id']])->fetchAll(); break;
                case 'tarjetas_prueba':
                    $rows=$query('SELECT tarjeta_id,banco,marca,numero,ultimos_digitos,titular,vencimiento,color_inicio,color_fin FROM tarjetas_prueba WHERE activa=1 ORDER BY tarjeta_id')->fetchAll(); break;
                case 'detalle_pedido':
                    $pedido=$query("SELECT c.*,CONCAT(b.nombre,' ',b.apellidos) comprador,b.nombre_comercial,d.direccion_exacta,d.distrito,d.provincia,d.referencia,cp.metodo_pago,cp.codigo_operacion,COALESCE(r.estado_entrega,'ASIGNADO') estado_entrega,r.hora_salida,r.hora_entrega,r.notas_entrega FROM compras c JOIN bodegueros b ON b.bodeguero_id=c.bodeguero_id JOIN direcciones d ON d.direccion_id=c.direccion_id LEFT JOIN comprobantes_pago cp ON cp.compra_id=c.compra_id LEFT JOIN guias_remision g ON g.compra_id=c.compra_id LEFT JOIN rutas_despacho r ON r.guia_id=g.guia_id WHERE c.compra_id=? AND c.bodeguero_id=?",[$_GET['id']??0,$user['id']])->fetch();
                    if (!$pedido) throw new InvalidArgumentException('Pedido no encontrado');
                    $pedido['items']=$query('SELECT p.nombre,p.marca,p.unidad_medida,dc.cantidad,dc.precio_unitario,dc.total_linea,(SELECT ruta_imagen FROM producto_imagenes pi WHERE pi.producto_id=p.producto_id AND pi.es_principal=1 LIMIT 1) imagen_url FROM detalle_compras dc JOIN productos p ON p.producto_id=dc.producto_id WHERE dc.compra_id=?',[$pedido['compra_id']])->fetchAll();
                    $rows=$pedido; break;
                case 'crear_compra':
                    $items=$datos['items']??[]; $metodo=$datos['metodo_pago']??'';
                    if (!$items || !in_array($metodo,['TARJETA','YAPE','EFECTIVO'],true)) throw new InvalidArgumentException('Pedido o método de pago no válido');
                    if ($metodo==='TARJETA' && !$query('SELECT tarjeta_id FROM tarjetas_prueba WHERE tarjeta_id=? AND activa=1',[$datos['tarjeta_id']??0])->fetch()) throw new InvalidArgumentException('Usa una tarjeta de prueba válida');
                    $direccion=$query('SELECT direccion_id FROM direcciones WHERE bodeguero_id=? ORDER BY es_principal DESC,direccion_id LIMIT 1',[$user['id']])->fetchColumn();
                    if (!$direccion) throw new InvalidArgumentException('Registra una dirección de entrega antes de comprar');
                    $db->beginTransaction(); $total=0; $lineas=[];
                    foreach ($items as $item) {
                        $cantidad=filter_var($item['cantidad']??0,FILTER_VALIDATE_INT);
                        if (!$cantidad || $cantidad<1) throw new InvalidArgumentException('Cantidad de producto no válida');
                        $producto=$query('SELECT producto_id,precio_unitario FROM productos WHERE producto_id=? AND activo=1 FOR UPDATE',[$item['producto_id']??0])->fetch();
                        $lote=$producto?$query('SELECT lote_id,stock_disponible FROM inventario_lotes WHERE producto_id=? AND stock_disponible>=? ORDER BY fecha_vencimiento,lote_id LIMIT 1 FOR UPDATE',[$producto['producto_id'],$cantidad])->fetch():false;
                        if (!$producto || !$lote) throw new InvalidArgumentException('Uno de los productos ya no tiene stock suficiente');
                        $lineTotal=round((float)$producto['precio_unitario']*$cantidad,2); $total+=$lineTotal;
                        $lineas[]=[$producto['producto_id'],$lote['lote_id'],$cantidad,$producto['precio_unitario'],$lineTotal];
                    }
                    $total=round($total,2); $subtotal=round($total/1.18,2); $igv=round($total-$subtotal,2);
                    $codigo='COM-'.date('Ymd-His').'-'.random_int(100,999);
                    $query('INSERT INTO compras (codigo_compra,bodeguero_id,direccion_id,subtotal,igv,total) VALUES (?,?,?,?,?,?)',[$codigo,$user['id'],$direccion,$subtotal,$igv,$total]);
                    $compraId=$db->lastInsertId();
                    foreach($lineas as $linea){$query('INSERT INTO detalle_compras (compra_id,producto_id,lote_id,cantidad,precio_unitario,total_linea) VALUES (?,?,?,?,?,?)',[$compraId,...$linea]);$query('UPDATE inventario_lotes SET stock_disponible=stock_disponible-? WHERE lote_id=?',[$linea[2],$linea[1]]);}
                    $bodega=$query('SELECT ruc FROM bodegueros WHERE bodeguero_id=?',[$user['id']])->fetch();
                    $operacion=($metodo==='YAPE'?'YAPE':($metodo==='EFECTIVO'?'EFECTIVO':'CARD')).'-SIM-'.str_pad($compraId,6,'0',STR_PAD_LEFT);
                    $query("INSERT INTO comprobantes_pago (compra_id,tipo_comprobante,serie,correlativo,ruc_emisor,ruc_receptor,subtotal,igv,total,metodo_pago,codigo_operacion) VALUES (?,'FACTURA_ELECTRONICA','F001',?,'20601234999',?,?,?,?,?,?)",[$compraId,$compraId,$bodega['ruc'],$subtotal,$igv,$total,$metodo,$operacion]);
                    $db->commit(); $rows=['compra_id'=>(int)$compraId,'codigo_compra'=>$codigo,'codigo_operacion'=>$operacion]; break;
                case 'ajustar_stock':
                    if (!isset($datos['stock']) || filter_var($datos['stock'],FILTER_VALIDATE_INT)===false || $datos['stock']<0) throw new InvalidArgumentException('El stock debe ser un entero no negativo');
                    $db->beginTransaction();
                    $l=$query('SELECT * FROM inventario_lotes WHERE lote_id=? FOR UPDATE',[$datos['id']??0])->fetch();
                    if (!$l) throw new InvalidArgumentException('Lote no encontrado');
                    $delta=(int)$datos['stock']-(int)$l['stock_disponible'];
                    $query('UPDATE inventario_lotes SET stock_disponible=?,stock_ingresado=stock_ingresado+? WHERE lote_id=?',[$datos['stock'],max(0,$delta),$l['lote_id']]);
                    $query('INSERT INTO movimientos_stock (lote_id,variacion,motivo,registrado_por) VALUES (?,?,?,?)',[$l['lote_id'],$delta,trim($datos['motivo']??'Ajuste de proyecto'),$user['id']]);
                    $db->commit(); break;
                case 'asignar_despacho':
                    if (empty($datos['placa']) || empty($datos['ruta'])) throw new InvalidArgumentException('Indica placa y recorrido');
                    $db->beginTransaction();
                    $c=$query('SELECT * FROM compras WHERE compra_id=? FOR UPDATE',[$datos['id']??0])->fetch();
                    if (!$c || in_array($c['estado_pedido'],['ENTREGADO','CANCELADO','DESPACHADO'])) throw new InvalidArgumentException('Pedido no disponible para asignación');
                    if (!$query("SELECT usuario_interno_id FROM usuarios_internos WHERE usuario_interno_id=? AND activo=1 AND rol='TRANSPORTISTA'",[$datos['transportista_id']??0])->fetch()) throw new InvalidArgumentException('Transportista no válido');
                    $g=$query('SELECT guia_id FROM guias_remision WHERE compra_id=?',[$c['compra_id']])->fetchColumn();
                    if (!$g) {
                        $items=$query('SELECT COALESCE(SUM(cantidad),0) FROM detalle_compras WHERE compra_id=?',[$c['compra_id']])->fetchColumn();
                        if (!$items) throw new InvalidArgumentException('El pedido no contiene productos');
                        $query('INSERT INTO guias_remision (compra_id,codigo_guia,total_bultos,peso_total_kg,costo_total,detalle_carga,emitida_por) VALUES (?,?,?,0,?,?,?)',[$c['compra_id'],'DEMO-GR-'.$c['compra_id'],$items,$c['total'],'Ver detalle de productos del pedido',$user['id']]);
                        $g=$db->lastInsertId();
                    }
                    $query("INSERT INTO rutas_despacho (guia_id,transportista_id,vehiculo_placa,punto_partida,direccion_destino_id,descripcion_ruta) VALUES (?,?,?,'Almacén demo',?,?) ON DUPLICATE KEY UPDATE transportista_id=VALUES(transportista_id),vehiculo_placa=VALUES(vehiculo_placa),descripcion_ruta=VALUES(descripcion_ruta)",[$g,$datos['transportista_id'],$datos['placa'],$c['direccion_id'],$datos['ruta']]);
                    $query("UPDATE compras SET estado_pedido='PREPARANDO' WHERE compra_id=?",[$c['compra_id']]);
                    $db->commit(); break;
                case 'actualizar_entrega':
                    $estado=$datos['estado']??'';
                    $db->beginTransaction();
                    $r=$query('SELECT r.*,g.compra_id FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id WHERE r.ruta_id=? AND r.transportista_id=? FOR UPDATE',[$datos['id']??0,$user['id']])->fetch();
                    $next=['ASIGNADO'=>['EN_TRAYECTO'],'EN_TRAYECTO'=>['ENTREGADO','FALLIDO'],'FALLIDO'=>['EN_TRAYECTO']];
                    if (!$r || !in_array($estado,$next[$r['estado_entrega']]??[],true)) throw new InvalidArgumentException('Ruta no asignada o transición no válida');
                    $query("UPDATE rutas_despacho SET estado_entrega=?,notas_entrega=?,hora_salida=IF(?='EN_TRAYECTO',NOW(),hora_salida),hora_entrega=IF(?='ENTREGADO',NOW(),hora_entrega) WHERE ruta_id=?",[$estado,$datos['notas']??null,$estado,$estado,$r['ruta_id']]);
                    $query('UPDATE compras SET estado_pedido=? WHERE compra_id=?',[$estado==='ENTREGADO'?'ENTREGADO':($estado==='FALLIDO'?'FALLIDO':'DESPACHADO'),$r['compra_id']]);
                    $db->commit(); break;
                case 'atender_incidencia':
                    $estado=$datos['estado']??'';
                    if (!in_array($estado,['ABIERTO','EN_REVISION','SOLUCIONADO','RECHAZADO'],true)) throw new InvalidArgumentException('Estado no válido');
                    if (in_array($estado,['SOLUCIONADO','RECHAZADO']) && empty(trim($datos['notas']??''))) throw new InvalidArgumentException('Describe la resolución');
                    if (!$query('SELECT incidencia_id FROM atencion_incidencias WHERE incidencia_id=?',[$datos['id']??0])->fetch()) throw new InvalidArgumentException('Incidencia no encontrada');
                    $query("UPDATE atencion_incidencias SET estado_atencion=?,conformidad_final=?,gestor_usuario_id=?,fecha_solucion=IF(? IN ('SOLUCIONADO','RECHAZADO'),NOW(),NULL) WHERE incidencia_id=?",[$estado,$datos['notas']??null,$user['id'],$estado,$datos['id']]); break;
                case 'revisar_conformidad':
                    if (!in_array($datos['estado']??'',['PENDIENTE','CONFORME','NO_CONFORME'],true)) throw new InvalidArgumentException('Estado no válido');
                    if (!$query('SELECT conformidad_id FROM conformidades_producto WHERE conformidad_id=?',[$datos['id']??0])->fetch()) throw new InvalidArgumentException('Conformidad no encontrada');
                    $query('UPDATE conformidades_producto SET estado=?,observaciones=?,revisado_por=? WHERE conformidad_id=?',[$datos['estado'],$datos['notas']??null,$user['id'],$datos['id']]); break;
                case 'emitir_factura':
                    $db->beginTransaction();
                    $c=$query('SELECT c.*,b.ruc FROM compras c JOIN bodegueros b ON b.bodeguero_id=c.bodeguero_id WHERE c.compra_id=? FOR UPDATE',[$datos['id']??0])->fetch();
                    if (!$c || $c['estado_pedido']==='CANCELADO') throw new InvalidArgumentException('Pedido no válido');
                    $existente=$query('SELECT 1 FROM comprobantes_pago WHERE compra_id=?',[$c['compra_id']])->fetch();
                    if ($existente) throw new InvalidArgumentException('Ya existe comprobante');
                    $query("INSERT INTO comprobantes_pago (compra_id,tipo_comprobante,serie,correlativo,ruc_emisor,ruc_receptor,subtotal,igv,total,metodo_pago,codigo_operacion) VALUES (?,'FACTURA_ELECTRONICA','F001',?,'20601234999',?,?,?,?,'EFECTIVO',?)",[$c['compra_id'],$c['compra_id'],$c['ruc'],$c['subtotal'],$c['igv'],$c['total'],'OP-'.str_pad($c['compra_id'],6,'0',STR_PAD_LEFT)]);
                    $db->commit(); break;
            }
            Response::json(['datos'=>$rows,'mensaje'=>in_array($accion,$lecturas,true)?'Consulta completada':'Cambios guardados']);
        } catch (InvalidArgumentException $e) {
            if ($db->inTransaction()) $db->rollBack();
            Response::json(['mensaje'=>$e->getMessage()],422);
        } catch (PDOException $e) {
            if ($db->inTransaction()) $db->rollBack();
            Response::json(['mensaje'=>'No se pudo guardar: verifica referencias o registros duplicados.'],409);
        }
        return true;
    }
}
