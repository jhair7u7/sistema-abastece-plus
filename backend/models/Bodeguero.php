<?php

class Bodeguero
{
    private $conexion;

    public function __construct($conexion)
    {
        $this->conexion = $conexion;
    }

    public function buscarPorCorreo($correo)
    {
        $sql = "SELECT
                    bodeguero_id,
                    nombre,
                    apellidos,
                    correo,
                    password_hash,
                    telefono,
                    ruc,
                    tipo_establecimiento,
                    nombre_comercial,
                    razon_social,
                    email_verificado,
                    token_verificacion_correo,
                    email_verificado_en,
                    linea_credito_max,
                    credito_utilizado,
                    estado_cuenta,
                    creado_en,
                    actualizado_en
                FROM bodegueros
                WHERE correo = :correo
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":correo", $correo);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function buscarPorRuc($ruc)
    {
        $sql = "SELECT
                    bodeguero_id,
                    nombre,
                    apellidos,
                    correo,
                    telefono,
                    ruc,
                    tipo_establecimiento,
                    nombre_comercial,
                    razon_social,
                    email_verificado,
                    linea_credito_max,
                    credito_utilizado,
                    estado_cuenta,
                    creado_en,
                    actualizado_en
                FROM bodegueros
                WHERE ruc = :ruc
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":ruc", $ruc);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function listar()
    {
        $sql = "SELECT
                    bodeguero_id,
                    nombre,
                    apellidos,
                    correo,
                    telefono,
                    ruc,
                    tipo_establecimiento,
                    nombre_comercial,
                    razon_social,
                    email_verificado,
                    email_verificado_en,
                    linea_credito_max,
                    credito_utilizado,
                    estado_cuenta,
                    creado_en,
                    actualizado_en
                FROM bodegueros
                ORDER BY bodeguero_id ASC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function buscarPorId($id)
    {
        $sql = "SELECT
                    bodeguero_id,
                    nombre,
                    apellidos,
                    correo,
                    telefono,
                    ruc,
                    tipo_establecimiento,
                    nombre_comercial,
                    razon_social,
                    email_verificado,
                    email_verificado_en,
                    linea_credito_max,
                    credito_utilizado,
                    estado_cuenta,
                    creado_en,
                    actualizado_en
                FROM bodegueros
                WHERE bodeguero_id = :id
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function registrar(
        $nombre,
        $apellidos,
        $correo,
        $passwordHash,
        $telefono,
        $ruc,
        $tipoEstablecimiento,
        $nombreComercial,
        $razonSocial
    ) {
        $sql = "INSERT INTO bodegueros
                (
                    nombre,
                    apellidos,
                    correo,
                    password_hash,
                    telefono,
                    ruc,
                    tipo_establecimiento,
                    nombre_comercial,
                    razon_social
                )
                VALUES
                (
                    :nombre,
                    :apellidos,
                    :correo,
                    :password_hash,
                    :telefono,
                    :ruc,
                    :tipo_establecimiento,
                    :nombre_comercial,
                    :razon_social
                )";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":nombre", $nombre);
        $stmt->bindParam(":apellidos", $apellidos);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":password_hash", $passwordHash);
        $stmt->bindParam(":telefono", $telefono);
        $stmt->bindParam(":ruc", $ruc);
        $stmt->bindParam(":tipo_establecimiento", $tipoEstablecimiento);
        $stmt->bindParam(":nombre_comercial", $nombreComercial);
        $stmt->bindParam(":razon_social", $razonSocial);

        return $stmt->execute();
    }

    public function actualizar(
        $id,
        $nombre,
        $apellidos,
        $correo,
        $telefono,
        $ruc,
        $tipoEstablecimiento,
        $nombreComercial,
        $razonSocial
    ) {
        $sql = "UPDATE bodegueros
                SET
                    nombre = :nombre,
                    apellidos = :apellidos,
                    correo = :correo,
                    telefono = :telefono,
                    ruc = :ruc,
                    tipo_establecimiento = :tipo_establecimiento,
                    nombre_comercial = :nombre_comercial,
                    razon_social = :razon_social
                WHERE bodeguero_id = :id";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->bindParam(":nombre", $nombre);
        $stmt->bindParam(":apellidos", $apellidos);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":telefono", $telefono);
        $stmt->bindParam(":ruc", $ruc);
        $stmt->bindParam(":tipo_establecimiento", $tipoEstablecimiento);
        $stmt->bindParam(":nombre_comercial", $nombreComercial);
        $stmt->bindParam(":razon_social", $razonSocial);

        return $stmt->execute();
    }

    public function bloquear($id)
    {
        $sql = "UPDATE bodegueros
                SET estado_cuenta = 'BLOQUEADO'
                WHERE bodeguero_id = :id";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}