<?php

class Proveedor
{
    private $conexion;

    public function __construct($conexion)
    {
        $this->conexion = $conexion;
    }

    // -- BUSCAR POR RUC

    public function buscarPorRuc($ruc)
    {
        $sql = "SELECT
                    proveedor_id,
                    ruc,
                    razon_social,
                    nombre_comercial,
                    contacto_nombre,
                    correo,
                    telefono,
                    reputacion_srm,
                    tiempo_promedio_entrega_hrs,
                    activo,
                    creado_en
                FROM proveedores
                WHERE ruc = :ruc
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":ruc", $ruc);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // -- BUSCAR POR CORREO

    public function buscarPorCorreo($correo)
    {
        $sql = "SELECT
                    proveedor_id,
                    ruc,
                    razon_social,
                    nombre_comercial,
                    contacto_nombre,
                    correo,
                    telefono,
                    reputacion_srm,
                    tiempo_promedio_entrega_hrs,
                    activo,
                    creado_en
                FROM proveedores
                WHERE correo = :correo
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":correo", $correo);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // -- LISTAR PROVEEDORES

    public function listar()
    {
        $sql = "SELECT
                    proveedor_id,
                    ruc,
                    razon_social,
                    nombre_comercial,
                    contacto_nombre,
                    correo,
                    telefono,
                    reputacion_srm,
                    tiempo_promedio_entrega_hrs,
                    activo,
                    creado_en
                FROM proveedores
                ORDER BY proveedor_id ASC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // -- BUSCAR POR ID

    public function buscarPorId($id)
    {
        $sql = "SELECT
                    proveedor_id,
                    ruc,
                    razon_social,
                    nombre_comercial,
                    contacto_nombre,
                    correo,
                    telefono,
                    reputacion_srm,
                    tiempo_promedio_entrega_hrs,
                    activo,
                    creado_en
                FROM proveedores
                WHERE proveedor_id = :id
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // -- REGISTRAR PROVEEDOR

    public function registrar(
        $ruc,
        $razonSocial,
        $nombreComercial,
        $contactoNombre,
        $correo,
        $telefono
    ) {
        $sql = "INSERT INTO proveedores
                (
                    ruc,
                    razon_social,
                    nombre_comercial,
                    contacto_nombre,
                    correo,
                    telefono
                )
                VALUES
                (
                    :ruc,
                    :razon_social,
                    :nombre_comercial,
                    :contacto_nombre,
                    :correo,
                    :telefono
                )";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":ruc", $ruc);
        $stmt->bindParam(":razon_social", $razonSocial);
        $stmt->bindParam(":nombre_comercial", $nombreComercial);
        $stmt->bindParam(":contacto_nombre", $contactoNombre);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":telefono", $telefono);

        return $stmt->execute();
    }

    // -- ACTUALIZAR PROVEEDOR

    public function actualizar(
        $id,
        $ruc,
        $razonSocial,
        $nombreComercial,
        $contactoNombre,
        $correo,
        $telefono
    ) {
        $sql = "UPDATE proveedores
                SET
                    ruc = :ruc,
                    razon_social = :razon_social,
                    nombre_comercial = :nombre_comercial,
                    contacto_nombre = :contacto_nombre,
                    correo = :correo,
                    telefono = :telefono
                WHERE proveedor_id = :id";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->bindParam(":ruc", $ruc);
        $stmt->bindParam(":razon_social", $razonSocial);
        $stmt->bindParam(":nombre_comercial", $nombreComercial);
        $stmt->bindParam(":contacto_nombre", $contactoNombre);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":telefono", $telefono);

        return $stmt->execute();
    }

    // -- DESACTIVAR PROVEEDOR

    public function desactivar($id)
    {
        $sql = "UPDATE proveedores
                SET activo = FALSE
                WHERE proveedor_id = :id";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}