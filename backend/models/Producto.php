<?php

class Producto
{
    private $conn;
    private $table = "productos";

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function listar()
    {
        $sql = "SELECT 
                    p.producto_id,
                    p.categoria_id,
                    c.nombre AS categoria_nombre,
                    p.codigo_sku,
                    p.nombre,
                    p.descripcion,
                    p.imagen_url,
                    p.marca,
                    p.unidad_medida,
                    p.peso_kg,
                    p.precio_base_sugerido,
                    p.activo
                FROM {$this->table} p
                LEFT JOIN categorias c ON p.categoria_id = c.categoria_id
                ORDER BY p.producto_id ASC";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function buscarPorId($id)
    {
        $sql = "SELECT 
                    p.producto_id,
                    p.categoria_id,
                    c.nombre AS categoria_nombre,
                    p.codigo_sku,
                    p.nombre,
                    p.descripcion,
                    p.imagen_url,
                    p.marca,
                    p.unidad_medida,
                    p.peso_kg,
                    p.precio_base_sugerido,
                    p.activo
                FROM {$this->table} p
                LEFT JOIN categorias c ON p.categoria_id = c.categoria_id
                WHERE p.producto_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function buscarPorSku($sku)
    {
        $sql = "SELECT 
                    producto_id,
                    codigo_sku
                FROM {$this->table}
                WHERE codigo_sku = :sku";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":sku", $sku);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function registrar($datos)
    {
        $sql = "INSERT INTO {$this->table} 
                    (categoria_id, codigo_sku, nombre, descripcion, imagen_url, marca, unidad_medida, peso_kg, precio_base_sugerido, activo)
                VALUES 
                    (:categoria_id, :codigo_sku, :nombre, :descripcion, :imagen_url, :marca, :unidad_medida, :peso_kg, :precio_base_sugerido, TRUE)";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindParam(":categoria_id", $datos["categoria_id"], PDO::PARAM_INT);
        $stmt->bindParam(":codigo_sku", $datos["codigo_sku"]);
        $stmt->bindParam(":nombre", $datos["nombre"]);
        $stmt->bindParam(":descripcion", $datos["descripcion"]);
        $stmt->bindParam(":imagen_url", $datos["imagen_url"]);
        $stmt->bindParam(":marca", $datos["marca"]);
        $stmt->bindParam(":unidad_medida", $datos["unidad_medida"]);
        $stmt->bindParam(":peso_kg", $datos["peso_kg"]);
        $stmt->bindParam(":precio_base_sugerido", $datos["precio_base_sugerido"]);

        return $stmt->execute();
    }

    public function actualizar($id, $datos)
    {
        $sql = "UPDATE {$this->table}
                SET categoria_id = :categoria_id,
                    codigo_sku = :codigo_sku,
                    nombre = :nombre,
                    descripcion = :descripcion,
                    imagen_url = :imagen_url,
                    marca = :marca,
                    unidad_medida = :unidad_medida,
                    peso_kg = :peso_kg,
                    precio_base_sugerido = :precio_base_sugerido
                WHERE producto_id = :id";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindParam(":categoria_id", $datos["categoria_id"], PDO::PARAM_INT);
        $stmt->bindParam(":codigo_sku", $datos["codigo_sku"]);
        $stmt->bindParam(":nombre", $datos["nombre"]);
        $stmt->bindParam(":descripcion", $datos["descripcion"]);
        $stmt->bindParam(":imagen_url", $datos["imagen_url"]);
        $stmt->bindParam(":marca", $datos["marca"]);
        $stmt->bindParam(":unidad_medida", $datos["unidad_medida"]);
        $stmt->bindParam(":peso_kg", $datos["peso_kg"]);
        $stmt->bindParam(":precio_base_sugerido", $datos["precio_base_sugerido"]);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    public function cambiarEstado($id, $activo)
    {
        $sql = "UPDATE {$this->table}
                SET activo = :activo
                WHERE producto_id = :id";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindParam(":activo", $activo, PDO::PARAM_BOOL);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}

