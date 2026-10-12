<?php
require_once __DIR__.'/TransportMapService.php';
class TransporteController
{
    public static function ejecutar($db, $accion, $metodo, $datos)
    {
        $acciones = ['rutas_transporte' => 'GET', 'preparar_recorrido' => 'POST', 'ubicacion_ruta' => 'POST', 'llegada_ruta' => 'POST', 'actualizar_entrega' => 'POST'];
        if (!isset($acciones[$accion])) return false;
        $user = AuthMiddleware::permitirRoles(['TRANSPORTISTA']);
        if ($metodo !== $acciones[$accion]) { Response::json(['mensaje' => 'Método no permitido'], 405); return true; }
        $admin=$user['rol']==='ADMINISTRADOR';
        $driver=$admin ? (int)($_GET['transportista_id']??0) : $user['id'];
        $query = function ($sql, $params = []) use ($db) { $q=$db->prepare($sql); $q->execute($params); return $q; };
        try {
            if ($accion === 'rutas_transporte') {
                $rows=$query("SELECT v.*, c.estado_pedido, m.origen_direccion, m.destino_direccion AS mapa_direccion,
                    CONCAT_WS(', ',d.direccion_exacta,d.distrito,d.provincia,d.departamento) AS direccion_entrega,
                    b.nombre_comercial AS cliente, d.referencia, d.direccion_exacta, d.distrito, d.provincia, d.departamento,
                    cp.comprobante_id,cp.serie,cp.correlativo,cp.tipo_comprobante,
                    m.origen_lat, m.origen_lng, m.destino_lat, m.destino_lng, m.entrega_hasta,
                    m.llegada_en, m.geometria, m.distancia_m, m.duracion_s,
                    p.latitud, p.longitud, p.precision_m, p.capturado_ms,
                    UNIX_TIMESTAMP(p.actualizado_en)*1000 AS gps_actualizado_ms
                    FROM vista_guia_transportista v JOIN guias_remision g ON g.guia_id=v.guia_id
                    JOIN compras c ON c.compra_id=g.compra_id
                    JOIN direcciones d ON d.direccion_id=c.direccion_id AND d.bodeguero_id=c.bodeguero_id
                    JOIN bodegueros b ON b.bodeguero_id=c.bodeguero_id
                    LEFT JOIN comprobantes_pago cp ON cp.comprobante_id=(SELECT MAX(cp2.comprobante_id) FROM comprobantes_pago cp2 WHERE cp2.compra_id=c.compra_id AND cp2.tipo_comprobante='FACTURA_ELECTRONICA' AND cp2.metodo_pago IN ('YAPE','EFECTIVO','TARJETA'))
                    LEFT JOIN rutas_mapa m ON m.ruta_id=v.ruta_id
                    LEFT JOIN rutas_gps p ON p.ruta_id=v.ruta_id AND p.transportista_id=v.transportista_id
                    WHERE (?=1 OR v.transportista_id=?) ORDER BY COALESCE(v.hora_salida,g.fecha_emision) DESC", [$admin && !$driver ? 1 : 0,$driver])->fetchAll();
                $items=$query("SELECT g.guia_id, p.nombre, p.unidad_medida, d.cantidad,
                    (SELECT co.estado FROM conformidades_producto co WHERE co.detalle_compra_id=d.detalle_compra_id ORDER BY co.conformidad_id DESC LIMIT 1) AS conformidad_estado,
                    (SELECT pi.ruta_imagen FROM producto_imagenes pi WHERE pi.producto_id=p.producto_id ORDER BY pi.es_principal DESC,pi.imagen_id LIMIT 1) AS imagen_url
                    FROM detalle_compras d JOIN productos p ON p.producto_id=d.producto_id
                    JOIN guias_remision g ON g.compra_id=d.compra_id
                    JOIN rutas_despacho r ON r.guia_id=g.guia_id WHERE (?=1 OR r.transportista_id=?)
                    ORDER BY d.detalle_compra_id", [$admin && !$driver ? 1 : 0,$driver])->fetchAll();
                $group=[];
                foreach ($items as $item) $group[$item['guia_id']][]=$item;
                $mapService=new TransportMapService($db);
                foreach ($rows as &$row) { $mapService->destination($row); $row['items']=$group[$row['guia_id']]??[]; $row['conformidad_completa']=count($row['items'])>0 && count(array_filter($row['items'],fn($item)=>$item['conformidad_estado']==='CONFORME'))===count($row['items']) ? 1 : 0; $row['geometria']=$row['geometria'] ? json_decode($row['geometria'],true) : null; }
                unset($row);
                Response::json(['rutas'=>$rows, 'recorrido'=>($admin&&!$driver?null:$mapService->itinerary($rows)), 'servidor_ms'=>(int)round(microtime(true)*1000)]);
                return true;
            }
            $id=filter_var($datos['ruta_id']??$datos['id']??null,FILTER_VALIDATE_INT);
            if ($accion==='preparar_recorrido' || ($accion==='actualizar_entrega' && ($datos['estado']??'')==='EN_TRAYECTO')) {
                $mapRow=$id ? $query("SELECT r.*,c.estado_pedido,d.direccion_exacta,d.distrito,d.provincia,d.departamento,
                    m.destino_direccion AS mapa_direccion,m.origen_direccion,m.origen_lat,m.origen_lng,m.destino_lat,m.destino_lng,m.geometria,m.distancia_m,m.duracion_s
                    FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id JOIN compras c ON c.compra_id=g.compra_id
                    JOIN direcciones d ON d.direccion_id=c.direccion_id AND d.bodeguero_id=c.bodeguero_id
                    LEFT JOIN rutas_mapa m ON m.ruta_id=r.ruta_id WHERE r.ruta_id=? AND (?=1 OR r.transportista_id=?)",[$id,$admin?1:0,$driver])->fetch() : false;
                if (!$mapRow) {Response::json(['mensaje'=>'Ruta no asignada a este usuario'],404);return true;}
                if (in_array($mapRow['estado_pedido'],['CANCELADO','ENTREGADO'],true) || $mapRow['estado_entrega']==='ENTREGADO') throw new InvalidArgumentException('Esta ruta ya está cerrada');
                $mapService=new TransportMapService($db);$mapService->destination($mapRow);
                if (!$mapRow['geometria']) {
                    $reason=$mapRow['destino_lat']!==null ? 'El proveedor de carreteras no pudo calcular el recorrido. Inténtalo más tarde.' : $mapRow['mapa_mensaje'];
                    Response::json(['mensaje'=>'No se pudo mostrar el recorrido. '.$reason,'recorrido_listo'=>false],422);return true;
                }
                if ($accion==='preparar_recorrido' || $mapRow['estado_entrega']==='EN_TRAYECTO') {
                    Response::json(['mensaje'=>'Recorrido calculado; se muestra en el mapa.','recorrido_listo'=>true]);return true;
                }
            }
            $db->beginTransaction();
            $route=$id ? $query('SELECT r.*,g.compra_id,c.estado_pedido FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id JOIN compras c ON c.compra_id=g.compra_id WHERE r.ruta_id=? AND r.transportista_id=? FOR UPDATE',[$id,$user['id']])->fetch() : false;
            if (!$route) { $db->rollBack(); Response::json(['mensaje'=>'Ruta no asignada a este usuario'],404); return true; }
            if (in_array($route['estado_pedido'],['CANCELADO','ENTREGADO'],true) || $route['estado_entrega']==='ENTREGADO') throw new InvalidArgumentException('Esta ruta ya está cerrada');
            if ($accion === 'actualizar_entrega') {
                $state=$datos['estado']??'';
                $next=['ASIGNADO'=>['EN_TRAYECTO','ENTREGADO'],'EN_TRAYECTO'=>['ENTREGADO'],'FALLIDO'=>['EN_TRAYECTO','ENTREGADO']];
                if (!in_array($state,$next[$route['estado_entrega']]??[],true)) throw new InvalidArgumentException('Transición de entrega no válida');
                $notes=trim($datos['notas']??'');
                $delivered = $state==='ENTREGADO' ? self::deliveryDate($datos,$route['hora_salida']) : null;
                $query("UPDATE rutas_despacho SET estado_entrega=?,notas_entrega=?,hora_salida=IF(?='EN_TRAYECTO',COALESCE(hora_salida,NOW()),hora_salida),hora_entrega=IF(?='ENTREGADO',?,hora_entrega) WHERE ruta_id=?",[$state,$notes,$state,$state,$delivered,$id]);
                $query('UPDATE compras SET estado_pedido=? WHERE compra_id=?',[$state==='ENTREGADO'?'ENTREGADO':'DESPACHADO',$route['compra_id']]);
                $query('DELETE FROM rutas_gps WHERE ruta_id=?',[$id]);
                if ($state==='EN_TRAYECTO') $query('UPDATE rutas_mapa SET llegada_en=NULL WHERE ruta_id=?',[$id]);
                $db->commit(); Response::json(['mensaje'=>'Estado de entrega actualizado']); return true;
            }
            if ($route['estado_entrega']!=='EN_TRAYECTO') throw new InvalidArgumentException('Inicia el recorrido antes de enviar ubicación o registrar llegada');
            if ($accion === 'llegada_ruta') {
                $query('UPDATE rutas_mapa SET llegada_en=COALESCE(llegada_en,NOW()) WHERE ruta_id=?',[$id]);
                if (!$query('SELECT ruta_id FROM rutas_mapa WHERE ruta_id=?',[$id])->fetch()) throw new InvalidArgumentException('El destino todavía no ha podido localizarse');
            } else {
                $lat=self::coordinate($datos['latitud']??null,90); $lng=self::coordinate($datos['longitud']??null,180);
                $accuracy=filter_var($datos['precision_m']??null,FILTER_VALIDATE_FLOAT); $captured=filter_var($datos['capturado_ms']??null,FILTER_VALIDATE_INT);
                if ($accuracy===false || $accuracy<0 || $accuracy>10000 || !$captured || abs(round(microtime(true)*1000)-$captured)>120000) throw new InvalidArgumentException('La ubicación es inválida o está desactualizada');
                $query('INSERT INTO rutas_gps (ruta_id,transportista_id,latitud,longitud,precision_m,capturado_ms) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE transportista_id=IF(VALUES(capturado_ms)>=capturado_ms,VALUES(transportista_id),transportista_id),latitud=IF(VALUES(capturado_ms)>=capturado_ms,VALUES(latitud),latitud),longitud=IF(VALUES(capturado_ms)>=capturado_ms,VALUES(longitud),longitud),precision_m=IF(VALUES(capturado_ms)>=capturado_ms,VALUES(precision_m),precision_m),capturado_ms=GREATEST(capturado_ms,VALUES(capturado_ms))',[$id,$route['transportista_id'],$lat,$lng,$accuracy,$captured]);
            }
            $db->commit();
            Response::json(['mensaje'=>'Seguimiento actualizado']);
        } catch (InvalidArgumentException $e) { if ($db->inTransaction()) $db->rollBack(); Response::json(['mensaje'=>$e->getMessage()],400); }
        catch (Throwable $e) { if ($db->inTransaction()) $db->rollBack(); Response::json(['mensaje'=>'No se pudo consultar o actualizar el seguimiento'],500); }
        return true;
    }
    public static function deliveryDate($data, $departure) {
        $raw=($data['fecha_entrega']??'').' '.($data['hora_entrega']??'');
        $zone=new DateTimeZone('America/Lima');
        $date=DateTimeImmutable::createFromFormat('!Y-m-d H:i',$raw,$zone);
        if (!$date || $date->format('Y-m-d H:i')!==$raw) throw new InvalidArgumentException('Indica una fecha y hora de entrega válidas');
        if ($date > new DateTimeImmutable('now',$zone)) throw new InvalidArgumentException('La entrega no puede registrarse en el futuro');
        if ($departure && $date->getTimestamp() < (new DateTimeImmutable($departure,$zone))->getTimestamp()-59) throw new InvalidArgumentException('La entrega no puede ser anterior a la salida');
        return $date->format('Y-m-d H:i:s');
    }
    public static function coordinate($value, $limit) {
        $number=filter_var($value,FILTER_VALIDATE_FLOAT);
        if ($number===false || $value===null || !is_finite($number) || abs($number)>$limit) throw new InvalidArgumentException('Coordenadas inválidas');
        return $number;
    }
}
