<?php

class Direccion
{
    private $conn;

    public function __construct($conexion)
    {
        $this->conn = $conexion;
    }

    // LISTAR TODAS LAS DIRECCIONES
    public function listar()
    {
        $sql = "SELECT
                    d.direccion_id,
                    d.bodeguero_id,
                    d.proveedor_id,
                    d.departamento,
                    d.provincia,
                    d.distrito,
                    d.direccion_exacta,
                    d.referencia,
                    d.zona_reparto,
                    d.codigo_postal,
                    b.nombre_comercial AS nombre_bodeguero,
                    p.nombre_comercial AS nombre_proveedor
                FROM direcciones d
                LEFT JOIN bodegueros b
                    ON d.bodeguero_id = b.bodeguero_id
                LEFT JOIN proveedores p
                    ON d.proveedor_id = p.proveedor_id
                ORDER BY d.direccion_id DESC";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // OBTENER UNA DIRECCIÓN
    public function obtenerPorId($id)
    {
        $sql = "SELECT
                    d.direccion_id,
                    d.bodeguero_id,
                    d.proveedor_id,
                    d.departamento,
                    d.provincia,
                    d.distrito,
                    d.direccion_exacta,
                    d.referencia,
                    d.zona_reparto,
                    d.codigo_postal,
                    b.nombre_comercial AS nombre_bodeguero,
                    p.nombre_comercial AS nombre_proveedor
                FROM direcciones d
                LEFT JOIN bodegueros b
                    ON d.bodeguero_id = b.bodeguero_id
                LEFT JOIN proveedores p
                    ON d.proveedor_id = p.proveedor_id
                WHERE d.direccion_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindValue(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // LISTAR DIRECCIONES DE UN BODEGUERO
    public function listarPorBodeguero($bodegueroId)
    {
        $sql = "SELECT
                    direccion_id,
                    bodeguero_id,
                    proveedor_id,
                    departamento,
                    provincia,
                    distrito,
                    direccion_exacta,
                    referencia,
                    zona_reparto,
                    codigo_postal
                FROM direcciones
                WHERE bodeguero_id = :bodeguero_id
                ORDER BY direccion_id DESC";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindValue(":bodeguero_id", $bodegueroId, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // LISTAR DIRECCIONES DE UN PROVEEDOR
    public function listarPorProveedor($proveedorId)
    {
        $sql = "SELECT
                    direccion_id,
                    bodeguero_id,
                    proveedor_id,
                    departamento,
                    provincia,
                    distrito,
                    direccion_exacta,
                    referencia,
                    zona_reparto,
                    codigo_postal
                FROM direcciones
                WHERE proveedor_id = :proveedor_id
                ORDER BY direccion_id DESC";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindValue(":proveedor_id", $proveedorId, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // CREAR DIRECCIÓN
    public function crear($datos)
    {
        $sql = "INSERT INTO direcciones (
                    bodeguero_id,
                    proveedor_id,
                    departamento,
                    provincia,
                    distrito,
                    direccion_exacta,
                    referencia,
                    zona_reparto,
                    codigo_postal
                ) VALUES (
                    :bodeguero_id,
                    :proveedor_id,
                    :departamento,
                    :provincia,
                    :distrito,
                    :direccion_exacta,
                    :referencia,
                    :zona_reparto,
                    :codigo_postal
                )";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindValue(
            ":bodeguero_id",
            $datos["bodeguero_id"] ?? null,
            isset($datos["bodeguero_id"]) ? PDO::PARAM_INT : PDO::PARAM_NULL
        );

        $stmt->bindValue(
            ":proveedor_id",
            $datos["proveedor_id"] ?? null,
            isset($datos["proveedor_id"]) ? PDO::PARAM_INT : PDO::PARAM_NULL
        );

        $stmt->bindValue(":departamento", $datos["departamento"] ?? "Lima");
        $stmt->bindValue(":provincia", $datos["provincia"] ?? "Lima");
        $stmt->bindValue(":distrito", $datos["distrito"]);
        $stmt->bindValue(":direccion_exacta", $datos["direccion_exacta"]);
        $stmt->bindValue(":referencia", $datos["referencia"] ?? null);
        $stmt->bindValue(":zona_reparto", $datos["zona_reparto"]);
        $stmt->bindValue(":codigo_postal", $datos["codigo_postal"] ?? null);

        return $stmt->execute();
    }

    // ACTUALIZAR DIRECCIÓN
    public function actualizar($id, $datos)
    {
        $sql = "UPDATE direcciones SET
                    departamento = :departamento,
                    provincia = :provincia,
                    distrito = :distrito,
                    direccion_exacta = :direccion_exacta,
                    referencia = :referencia,
                    zona_reparto = :zona_reparto,
                    codigo_postal = :codigo_postal
                WHERE direccion_id = :id";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindValue(":departamento", $datos["departamento"] ?? "Lima");
        $stmt->bindValue(":provincia", $datos["provincia"] ?? "Lima");
        $stmt->bindValue(":distrito", $datos["distrito"]);
        $stmt->bindValue(":direccion_exacta", $datos["direccion_exacta"]);
        $stmt->bindValue(":referencia", $datos["referencia"] ?? null);
        $stmt->bindValue(":zona_reparto", $datos["zona_reparto"]);
        $stmt->bindValue(":codigo_postal", $datos["codigo_postal"] ?? null);
        $stmt->bindValue(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    // ELIMINAR DIRECCIÓN
    public function eliminar($id)
    {
        $sql = "DELETE FROM direcciones
                WHERE direccion_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindValue(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}