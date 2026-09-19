<?php

class Producto
{
    private $conexion;
    public function __construct($conexion) { $this->conexion = $conexion; }

    public function listar()
    {
        $sql = "SELECT p.producto_id, p.codigo_sku, p.nombre, p.descripcion, p.marca,
                       p.unidad_medida, p.peso_kg, p.precio_base_sugerido,
                       c.categoria_id, c.nombre AS categoria,
                       COALESCE(i.stock_disponible, 0) AS stock_disponible,
                       e.precio_desde, e.compra_minima
                FROM productos p
                INNER JOIN categorias c ON c.categoria_id = p.categoria_id
                LEFT JOIN (SELECT producto_id, SUM(stock_disponible) AS stock_disponible FROM inventario_lotes GROUP BY producto_id) i ON i.producto_id = p.producto_id
                LEFT JOIN (SELECT producto_id, MIN(precio_unitario) AS precio_desde, MIN(cantidad_minima) AS compra_minima FROM productos_proveedor_escalas GROUP BY producto_id) e ON e.producto_id = p.producto_id
                WHERE p.activo = TRUE
                ORDER BY c.nombre, p.nombre";
        $stmt = $this->conexion->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
