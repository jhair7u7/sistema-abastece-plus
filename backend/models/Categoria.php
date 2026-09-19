<?php

class Categoria
{
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    // -- LISTAR CATEGORÍAS
    public function listar()
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM categorias
                ORDER BY categoria_id ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // -- BUSCAR CATEGORÍA POR ID
    public function buscarPorId($id)
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM categorias
                WHERE categoria_id = :categoria_id
                LIMIT 1";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":categoria_id",
            $id,
            PDO::PARAM_INT
        );

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // -- BUSCAR POR NOMBRE
    public function buscarPorNombre($nombre)
    {
        $sql = "SELECT 
                    categoria_id,
                    nombre,
                    activo
                FROM categorias
                WHERE nombre = :nombre
                LIMIT 1";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":nombre",
            $nombre,
            PDO::PARAM_STR
        );

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // -- REGISTRAR CATEGORÍA
    public function registrar($nombre)
    {
        $sql = "INSERT INTO categorias (
                    nombre,
                    activo
                )
                VALUES (
                    :nombre,
                    TRUE
                )";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":nombre",
            $nombre,
            PDO::PARAM_STR
        );

        return $stmt->execute();
    }

    // -- ACTUALIZAR CATEGORÍA
    public function actualizar($id, $nombre, $activo)
    {
        $sql = "UPDATE categorias
                SET nombre = :nombre,
                    activo = :activo
                WHERE categoria_id = :categoria_id";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":nombre",
            $nombre,
            PDO::PARAM_STR
        );

        $stmt->bindParam(
            ":activo",
            $activo,
            PDO::PARAM_BOOL
        );

        $stmt->bindParam(
            ":categoria_id",
            $id,
            PDO::PARAM_INT
        );

        return $stmt->execute();
    }

    // -- CAMBIAR ESTADO
    public function cambiarEstado($id, $activo)
    {
        $sql = "UPDATE categorias
                SET activo = :activo
                WHERE categoria_id = :categoria_id";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":activo",
            $activo,
            PDO::PARAM_BOOL
        );

        $stmt->bindParam(
            ":categoria_id",
            $id,
            PDO::PARAM_INT
        );

        return $stmt->execute();
    }

    // -- VERIFICAR SI TIENE PRODUCTOS
    public function tieneProductos($id)
    {
        $sql = "SELECT COUNT(*) AS cantidad
                FROM productos
                WHERE categoria_id = :categoria_id";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":categoria_id",
            $id,
            PDO::PARAM_INT
        );

        $stmt->execute();

        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);

        return $resultado["cantidad"] > 0;
    }

    // -- ELIMINAR CATEGORÍA
    public function eliminar($id)
    {
        $sql = "DELETE FROM categorias
                WHERE categoria_id = :categoria_id";

        $stmt = $this->db->prepare($sql);

        $stmt->bindParam(
            ":categoria_id",
            $id,
            PDO::PARAM_INT
        );

        return $stmt->execute();
    }
}