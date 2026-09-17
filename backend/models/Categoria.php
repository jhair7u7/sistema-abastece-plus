<?php

class Categoria
{
    private $conn;
    private $table = "categorias";

    public function __construct($db)
    {
        $this->conn = $db;
    }

    // LISTAR CATEGORÍAS
    public function listar()
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM {$this->table}
                ORDER BY categoria_id ASC";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // BUSCAR POR ID
    public function buscarPorId($id)
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM {$this->table}
                WHERE categoria_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // BUSCAR POR NOMBRE
    public function buscarPorNombre($nombre)
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM {$this->table}
                WHERE nombre = :nombre";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":nombre", $nombre);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // REGISTRAR
    public function registrar($nombre)
    {
        $sql = "INSERT INTO {$this->table} (nombre, activo)
                VALUES (:nombre, TRUE)";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":nombre", $nombre);

        return $stmt->execute();
    }

    // ACTUALIZAR
    public function actualizar($id, $nombre, $activo)
    {
        $sql = "UPDATE {$this->table}
                SET nombre = :nombre,
                    activo = :activo
                WHERE categoria_id = :id";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindParam(":nombre", $nombre);
        $stmt->bindParam(":activo", $activo, PDO::PARAM_BOOL);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    // ACTIVAR / DESACTIVAR
    public function cambiarEstado($id, $activo)
    {
        $sql = "UPDATE {$this->table}
                SET activo = :activo
                WHERE categoria_id = :id";

        $stmt = $this->conn->prepare($sql);

        $stmt->bindParam(":activo", $activo, PDO::PARAM_BOOL);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    // ELIMINAR LÓGICAMENTE
    public function eliminar($id)
    {
        $sql = "UPDATE {$this->table}
                SET activo = FALSE
                WHERE categoria_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    // VERIFICAR SI TIENE PRODUCTOS
    public function tieneProductos($id)
    {
        $sql = "SELECT COUNT(*) 
                FROM productos
                WHERE categoria_id = :id";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchColumn() > 0;
    }
}