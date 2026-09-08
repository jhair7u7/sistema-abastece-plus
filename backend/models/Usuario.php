<?php

class Usuario
{
    private $conexion;

    public function __construct($conexion)
    {
        $this->conexion = $conexion;
    }

    // BUSCAR USUARIO POR CORREO
    public function buscarPorCorreo($correo)
    {
        $sql = "SELECT
                    usuario_interno_id,
                    nombre,
                    apellidos,
                    correo,
                    password_hash,
                    telefono,
                    rol,
                    activo,
                    creado_en,
                    actualizado_en
                FROM usuarios_internos
                WHERE correo = :correo
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":correo", $correo);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // LISTAR TODOS LOS USUARIOS
    public function listar()
    {
        $sql = "SELECT
                    usuario_interno_id,
                    nombre,
                    apellidos,
                    correo,
                    telefono,
                    rol,
                    activo,
                    creado_en,
                    actualizado_en
                FROM usuarios_internos
                ORDER BY usuario_interno_id ASC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // BUSCAR USUARIO POR ID
    public function buscarPorId($id)
    {
        $sql = "SELECT
                    usuario_interno_id,
                    nombre,
                    apellidos,
                    correo,
                    telefono,
                    rol,
                    activo,
                    creado_en,
                    actualizado_en
                FROM usuarios_internos
                WHERE usuario_interno_id = :id
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // REGISTRAR USUARIO
    public function registrar($nombre, $apellidos, $correo, $passwordHash, $telefono, $rol)
    {
        $sql = "INSERT INTO usuarios_internos
                (nombre, apellidos, correo, password_hash, telefono, rol)
                VALUES
                (:nombre, :apellidos, :correo, :password_hash, :telefono, :rol)";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":nombre", $nombre);
        $stmt->bindParam(":apellidos", $apellidos);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":password_hash", $passwordHash);
        $stmt->bindParam(":telefono", $telefono);
        $stmt->bindParam(":rol", $rol);

        return $stmt->execute();
    }

    // ACTUALIZAR USUARIO
    public function actualizar($id, $nombre, $apellidos, $correo, $telefono, $rol)
    {
        $sql = "UPDATE usuarios_internos
                SET
                    nombre = :nombre,
                    apellidos = :apellidos,
                    correo = :correo,
                    telefono = :telefono,
                    rol = :rol
                WHERE usuario_interno_id = :id";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->bindParam(":nombre", $nombre);
        $stmt->bindParam(":apellidos", $apellidos);
        $stmt->bindParam(":correo", $correo);
        $stmt->bindParam(":telefono", $telefono);
        $stmt->bindParam(":rol", $rol);

        return $stmt->execute();
    }

    // ACTUALIZAR CONTRASEÑA
    public function actualizarPassword($id, $passwordHash)
    {
        $sql = "UPDATE usuarios_internos
                SET password_hash = :password_hash
                WHERE usuario_interno_id = :id";

        $stmt = $this->conexion->prepare($sql);

        $stmt->bindParam(":id", $id, PDO::PARAM_INT);
        $stmt->bindParam(":password_hash", $passwordHash);

        return $stmt->execute();
    }

    // DESACTIVAR USUARIO
    public function eliminar($id)
    {
        $sql = "UPDATE usuarios_internos
                SET activo = FALSE
                WHERE usuario_interno_id = :id";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bindParam(":id", $id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}