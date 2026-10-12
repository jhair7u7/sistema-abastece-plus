<?php
class ComprobanteController
{
    private $conexion;
    public function __construct($conexion) { $this->conexion = $conexion; }
    public function consultar($id = null)
    {
        $user = AuthMiddleware::permitirRoles(['LOGISTICA', 'TRANSPORTISTA', 'BODEGUERO']);
        if ($user['rol'] === 'TRANSPORTISTA' && $id === null) { Response::json(['mensaje'=>'Acceso no permitido'],403); return; }
        if ($id !== null && (!ctype_digit((string) $id) || (int) $id < 1)) {
            Response::json(['mensaje' => 'ID de comprobante inválido'], 400);
            return;
        }
        try {
            $sql = "SELECT cp.*, cp.correlativo AS numero, c.codigo_compra AS compra,
                'Abastece+ S.A.C.' AS emisor_nombre, 'Lima, Perú' AS emisor_direccion,
                b.razon_social AS cliente_nombre,
                CONCAT_WS(', ', d.direccion_exacta, d.distrito, d.provincia) AS cliente_direccion
                FROM comprobantes_pago cp JOIN compras c ON c.compra_id = cp.compra_id
                JOIN bodegueros b ON b.bodeguero_id = c.bodeguero_id
                JOIN direcciones d ON d.direccion_id = c.direccion_id
                WHERE cp.metodo_pago IN ('YAPE', 'EFECTIVO', 'TARJETA')";
            if ($user['rol'] === 'TRANSPORTISTA') $sql .= ' AND EXISTS (SELECT 1 FROM guias_remision g JOIN rutas_despacho r ON r.guia_id=g.guia_id WHERE g.compra_id=cp.compra_id AND r.transportista_id=:transportista)';
            if ($user['rol'] === 'BODEGUERO') $sql .= ' AND c.bodeguero_id=:bodeguero';
            $params = $id !== null ? ['id'=>$id] : [];
            if ($user['rol'] === 'TRANSPORTISTA') $params['transportista'] = $user['id'];
            if ($user['rol'] === 'BODEGUERO') $params['bodeguero'] = $user['id'];
            $stmt = $this->conexion->prepare($sql . ($id !== null
                ? ' AND cp.comprobante_id = :id'
                : ' ORDER BY cp.fecha_emision DESC, cp.comprobante_id DESC'));
            $stmt->execute($params);
            if ($id === null) {
                Response::json(['comprobantes' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
                return;
            }
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$row) { Response::json(['mensaje' => 'Comprobante no encontrado'], 404); return; }
            $detail = $this->conexion->prepare('SELECT p.nombre AS descripcion, d.cantidad,
                d.precio_unitario, d.total_linea AS importe FROM detalle_compras d
                JOIN productos p ON p.producto_id = d.producto_id
                WHERE d.compra_id = :compra ORDER BY d.detalle_compra_id');
            $detail->execute(['compra' => $row['compra_id']]);
            $row['productos'] = $detail->fetchAll(PDO::FETCH_ASSOC);
            $row['moneda'] = 'PEN';
            Response::json(['comprobante' => $row]);
        } catch (PDOException $e) {
            Response::json(['mensaje' => 'No se pudieron consultar los comprobantes'], 500);
        }
    }
}