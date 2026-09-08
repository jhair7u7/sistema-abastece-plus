<?php

require_once __DIR__ . "/../models/Usuario.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

class UsuarioController
{
    private $usuario;

    public function __construct($conexion)
    {
        $this->usuario = new Usuario($conexion);
    }

    // LISTAR USUARIOS
    public function listar()
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        $usuarios = $this->usuario->listar();

        Response::json([
            "mensaje" => "Usuarios obtenidos correctamente",
            "usuarios" => $usuarios
        ], 200);
    }

    // BUSCAR USUARIO POR ID
    public function buscar($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de usuario no válido"
            ], 400);
            return;
        }

        $usuario = $this->usuario->buscarPorId($id);

        if (!$usuario) {
            Response::json([
                "mensaje" => "Usuario no encontrado"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Usuario encontrado",
            "usuario" => $usuario
        ], 200);
    }

    // ACTUALIZAR USUARIO
    public function actualizar($id, $datos)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de usuario no válido"
            ], 400);
            return;
        }

        if (
            !isset($datos["nombre"]) ||
            !isset($datos["apellidos"]) ||
            !isset($datos["usuario"]) ||
            !isset($datos["telefono"]) ||
            !isset($datos["rol"])
        ) {
            Response::json([
                "mensaje" => "Todos los campos son obligatorios"
            ], 400);
            return;
        }

        $usuarioExistente = $this->usuario->buscarPorId($id);

        if (!$usuarioExistente) {
            Response::json([
                "mensaje" => "Usuario no encontrado"
            ], 404);
            return;
        }

        $nombre = trim($datos["nombre"]);
        $apellidos = trim($datos["apellidos"]);
        $correo = trim($datos["usuario"]);
        $telefono = trim($datos["telefono"]);
        $rol = trim($datos["rol"]);

        $rolesPermitidos = [
            "ADMINISTRADOR",
            "TRANSPORTISTA",
            "GESTOR_ATENCION",
            "LOGISTICA"
        ];

        if (!in_array($rol, $rolesPermitidos)) {
            Response::json([
                "mensaje" => "Rol no válido"
            ], 400);
            return;
        }

        $resultado = $this->usuario->actualizar(
            $id,
            $nombre,
            $apellidos,
            $correo,
            $telefono,
            $rol
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Usuario actualizado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo actualizar el usuario"
        ], 500);
    }

    // ELIMINAR / DESACTIVAR USUARIO
    public function eliminar($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);
        
        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de usuario no válido"
            ], 400);
            return;
        }

        $usuario = $this->usuario->buscarPorId($id);

        if (!$usuario) {
            Response::json([
                "mensaje" => "Usuario no encontrado"
            ], 404);
            return;
        }

        $resultado = $this->usuario->eliminar($id);

        if ($resultado) {
            Response::json([
                "mensaje" => "Usuario desactivado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo desactivar el usuario"
        ], 500);
    }
}