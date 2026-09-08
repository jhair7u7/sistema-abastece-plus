<?php

require_once __DIR__ . "/../models/Usuario.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

class AuthController
{
    private $usuario;

    public function __construct($conexion)
    {
        $this->usuario = new Usuario($conexion);
    }

    public function login($datos)
    {
        // Verificar que se hayan enviado usuario y contraseña
        if (!isset($datos["usuario"]) || !isset($datos["password"])) {
            Response::json([
                "mensaje" => "Usuario y contraseña son obligatorios"
            ], 400);
            return;
        }

        $usuarioLogin = trim($datos["usuario"]);
        $password = $datos["password"];

        // Buscar usuario por correo
        $usuario = $this->usuario->buscarPorCorreo($usuarioLogin);

        // Si no existe
        if (!$usuario) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

        // Convertir la contraseña ingresada a SHA-256
        $passwordHash = hash("sha256", $password);

        // Comparar con el hash almacenado en la BD
        if (!hash_equals($usuario["password_hash"], $passwordHash)) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

        // Login correcto
        $token = AuthMiddleware::crearToken($usuario);
        Response::json([
            "mensaje" => "Inicio de sesión exitoso",
            "token" => $token,
            "usuario" => [
                "id" => $usuario["usuario_interno_id"],
                "nombre" => $usuario["nombre"],
                "apellidos" => $usuario["apellidos"],
                "correo" => $usuario["correo"],
                "telefono" => $usuario["telefono"],
                "rol" => $usuario["rol"]
            ]
        ], 200);
    }

    public function registrar($datos)
    {
        // Verificar campos obligatorios
        if (
            !isset($datos["nombre"]) ||
            !isset($datos["apellidos"]) ||
            !isset($datos["usuario"]) ||
            !isset($datos["password"]) ||
            !isset($datos["telefono"]) ||
            !isset($datos["rol"])
        ) {
            Response::json([
                "mensaje" => "Todos los campos son obligatorios"
            ], 400);
            return;
        }

        $nombre = trim($datos["nombre"]);
        $apellidos = trim($datos["apellidos"]);
        $correo = trim($datos["usuario"]);
        $password = $datos["password"];
        $telefono = trim($datos["telefono"]);
        $rol = trim($datos["rol"]);

        // Verificar si el usuario ya existe
        $usuarioExistente = $this->usuario->buscarPorCorreo($correo);

        if ($usuarioExistente) {
            Response::json([
                "mensaje" => "El usuario ya está registrado"
            ], 409);
            return;
        }

        // Roles permitidos por la BD
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

        // Convertir contraseña a SHA-256
        $passwordHash = hash("sha256", $password);

        // Registrar usuario
        $resultado = $this->usuario->registrar(
            $nombre,
            $apellidos,
            $correo,
            $passwordHash,
            $telefono,
            $rol
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Usuario registrado correctamente",
                "usuario" => [
                    "nombre" => $nombre,
                    "apellidos" => $apellidos,
                    "usuario" => $correo,
                    "telefono" => $telefono,
                    "rol" => $rol
                ]
            ], 201);

            return;
        }

        Response::json([
            "mensaje" => "No se pudo registrar el usuario"
        ], 500);
    }
}