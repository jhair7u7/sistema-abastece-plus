<?php
require_once __DIR__.'/TransportMapService.php';
class LogisticaService {
    private $db;
    private $mapFetch;
    public function __construct($db,$mapFetch=null) { $this->db=$db;$this->mapFetch=$mapFetch; }
    private function q($sql,$params=[]) { $s=$this->db->prepare($sql);$s->execute($params);return $s; }
    public function drivers() {
        return $this->q("SELECT u.usuario_interno_id,CONCAT_WS(' ',u.nombre,u.apellidos) AS nombre,
            (SELECT r.vehiculo_placa FROM rutas_despacho r WHERE r.transportista_id=u.usuario_interno_id AND TRIM(r.vehiculo_placa)<>'' ORDER BY r.ruta_id DESC LIMIT 1) AS placa,
            (SELECT COUNT(*) FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id JOIN compras c ON c.compra_id=g.compra_id WHERE r.transportista_id=u.usuario_interno_id AND r.estado_entrega IN ('ASIGNADO','EN_TRAYECTO') AND c.estado_pedido NOT IN ('CANCELADO','ENTREGADO')) AS pendientes
            FROM usuarios_internos u WHERE u.activo=1 AND u.rol='TRANSPORTISTA' ORDER BY u.nombre,u.apellidos")->fetchAll();
    }
    public function plate($id) {
        foreach($this->drivers() as $driver) if((int)$driver['usuario_interno_id']===(int)$id) {
            if (!$driver['placa']) throw new InvalidArgumentException('Este transportista todavía no tiene un vehículo registrado en sus despachos.');
            return $driver['placa'];
        }
        throw new InvalidArgumentException('Transportista no válido');
    }
    public function preview($id,$purchase) {
        $plate=$this->plate($id);
        $candidate=$this->q("SELECT c.compra_id,c.estado_pedido,d.direccion_exacta,d.distrito,d.provincia,d.departamento FROM compras c JOIN direcciones d ON d.direccion_id=c.direccion_id AND d.bodeguero_id=c.bodeguero_id WHERE c.compra_id=?",[$purchase])->fetch();
        if (!$candidate || in_array($candidate['estado_pedido'],['ENTREGADO','CANCELADO','DESPACHADO'],true)) throw new InvalidArgumentException('Pedido no disponible para asignación');
        $rows=$this->q("SELECT r.ruta_id,r.estado_entrega,c.estado_pedido,g.codigo_guia,d.direccion_exacta,d.distrito,d.provincia,d.departamento,
            m.origen_direccion,m.destino_direccion AS mapa_direccion,m.origen_lat,m.origen_lng,m.destino_lat,m.destino_lng,m.geometria,m.distancia_m,m.duracion_s,
            gps.latitud,gps.longitud,gps.precision_m,gps.capturado_ms,
            EXISTS(SELECT 1 FROM detalle_compras dc WHERE dc.compra_id=c.compra_id) AND NOT EXISTS(SELECT 1 FROM detalle_compras dc LEFT JOIN conformidades_producto co ON co.detalle_compra_id=dc.detalle_compra_id WHERE dc.compra_id=c.compra_id AND (co.estado IS NULL OR co.estado<>'CONFORME')) AS conformidad_completa
            FROM rutas_despacho r JOIN guias_remision g ON g.guia_id=r.guia_id JOIN compras c ON c.compra_id=g.compra_id JOIN direcciones d ON d.direccion_id=c.direccion_id AND d.bodeguero_id=c.bodeguero_id
            LEFT JOIN rutas_mapa m ON m.ruta_id=r.ruta_id LEFT JOIN rutas_gps gps ON gps.ruta_id=r.ruta_id AND gps.transportista_id=r.transportista_id
            WHERE r.transportista_id=? AND c.compra_id<>? AND c.estado_pedido NOT IN ('CANCELADO','ENTREGADO') AND r.estado_entrega IN ('ASIGNADO','EN_TRAYECTO')",[$id,$purchase])->fetchAll();
        $map=new TransportMapService($this->db,$this->mapFetch);
        foreach($rows as &$row) { $map->destination($row);$row['geometria']=$row['geometria']?json_decode($row['geometria'],true):null; } unset($row);
        $candidate=array_merge($candidate,['ruta_id'=>2147483647,'codigo_guia'=>'Nueva entrega','estado_entrega'=>'ASIGNADO','destino_lat'=>null,'destino_lng'=>null,'mapa_direccion'=>null,'geometria'=>null,'conformidad_completa'=>0]);
        $map->destination($candidate,false);$candidate['geometria']=$candidate['geometria']?json_decode($candidate['geometria'],true):null;
        $rows[]=$candidate;
        return ['rutas'=>$rows,'recorrido'=>$map->itinerary($rows),'placa'=>$plate,'propuesta_id'=>2147483647,'destino'=>$candidate['direccion_entrega'],'mensaje'=>$candidate['mapa_mensaje']];
    }
    public function issue($purchase) {
        // La fila de compra serializa reintentos; la secuencia serializa distintas compras.
        $c=$this->q('SELECT c.*,b.ruc FROM compras c JOIN bodegueros b ON b.bodeguero_id=c.bodeguero_id WHERE c.compra_id=? FOR UPDATE',[$purchase])->fetch();
        if (!$c || $c['estado_pedido']==='CANCELADO') throw new InvalidArgumentException('Pedido no válido');
        $existing=$this->q("SELECT comprobante_id,serie,correlativo FROM comprobantes_pago WHERE compra_id=? AND tipo_comprobante='FACTURA_ELECTRONICA' AND metodo_pago IN ('YAPE','EFECTIVO','TARJETA') ORDER BY comprobante_id DESC LIMIT 1",[$purchase])->fetch();
        if ($existing) return $existing+['ya_emitida'=>true];
        $dispatch=$this->q('SELECT r.ruta_id FROM guias_remision g JOIN rutas_despacho r ON r.guia_id=g.guia_id JOIN usuarios_internos u ON u.usuario_interno_id=r.transportista_id WHERE g.compra_id=? AND u.rol=\'TRANSPORTISTA\' LIMIT 1',[$purchase])->fetch();
        if (!$dispatch) throw new InvalidArgumentException('Asigna un despacho a un transportista antes de emitir la factura.');
        $payment=$this->q('SELECT metodo_pago,codigo_operacion FROM pagos_compra WHERE compra_id=?',[$purchase])->fetch();
        $known=$payment && in_array($payment['metodo_pago'],['YAPE','EFECTIVO','TARJETA'],true);
        $method=$known?$payment['metodo_pago']:null;
        $operation=$known?trim($payment['codigo_operacion']??''):'';
        if (!in_array($method,['YAPE','EFECTIVO','TARJETA'],true) || !$operation) throw new InvalidArgumentException('La compra no tiene un pago registrado válido. No se puede emitir la factura.');
        $this->q("INSERT INTO documento_secuencias (serie,ultimo) VALUES ('F001',0) ON DUPLICATE KEY UPDATE serie=VALUES(serie)");
        $last=(int)$this->q("SELECT ultimo FROM documento_secuencias WHERE serie='F001' FOR UPDATE")->fetchColumn();
        $next=max($last,(int)$this->q("SELECT COALESCE(MAX(correlativo),0) FROM comprobantes_pago WHERE serie='F001'")->fetchColumn())+1;
        $this->q("UPDATE documento_secuencias SET ultimo=? WHERE serie='F001'",[$next]);
        $this->q("INSERT INTO comprobantes_pago (compra_id,tipo_comprobante,serie,correlativo,ruc_emisor,ruc_receptor,subtotal,igv,total,metodo_pago,codigo_operacion) VALUES (?,'FACTURA_ELECTRONICA','F001',?,'00000000999',?,?,?,?,?,?)",[$purchase,$next,$c['ruc'],$c['subtotal'],$c['igv'],$c['total'],$method,$operation]);
        return ['comprobante_id'=>(int)$this->db->lastInsertId(),'serie'=>'F001','correlativo'=>$next,'ya_emitida'=>false];
    }
}
