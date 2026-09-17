<?php

require_once __DIR__ . "/../models/Usuario.php";
require_once __DIR__ . "/../models/Bodeguero.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

class AuthController
{
    private $usuario;
    private $bodeguero;

    public function __construct($conexion)
    {
        $this->usuario = new Usuario($conexion);
        $this->bodeguero = new Bodeguero($conexion);
    }

    public function loginAdmin($datos)
    {
        if (!isset($datos["usuario"]) || !isset($datos["password"])) {
            Response::json([
                "mensaje" => "Usuario y contraseña son obligatorios"
            ], 400);
            return;
        }

        $usuarioLogin = trim($datos["usuario"]);
        $password = $datos["password"];

        $usuario = $this->usuario->buscarPorCorreo($usuarioLogin);

        if (!$usuario) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

        $passwordHash = hash("sha256", $password);

        if (!hash_equals($usuario["password_hash"], $passwordHash)) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

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

    public function loginCliente($datos)
    {
        if (!isset($datos["usuario"]) || !isset($datos["password"])) {
            Response::json([
                "mensaje" => "Usuario y contraseña son obligatorios"
            ], 400);
            return;
        }

        $correo = trim($datos["usuario"]);
        $password = $datos["password"];

        $bodeguero = $this->bodeguero->buscarPorCorreo($correo);

        if (!$bodeguero) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

        $passwordHash = hash("sha256", $password);

        if (!hash_equals($bodeguero["password_hash"], $passwordHash)) {
            Response::json([
                "mensaje" => "Usuario o contraseña incorrectos"
            ], 401);
            return;
        }

        if ($bodeguero["estado_cuenta"] === "BLOQUEADO") {
            Response::json([
                "mensaje" => "La cuenta del bodeguero está bloqueada"
            ], 403);
            return;
        }

        $token = AuthMiddleware::crearTokenBodeguero($bodeguero);

        Response::json([
            "mensaje" => "Inicio de sesión exitoso",
            "token" => $token,
            "bodeguero" => [
                "id" => $bodeguero["bodeguero_id"],
                "nombre" => $bodeguero["nombre"],
                "apellidos" => $bodeguero["apellidos"],
                "correo" => $bodeguero["correo"],
                "telefono" => $bodeguero["telefono"],
                "ruc" => $bodeguero["ruc"],
                "tipo_establecimiento" => $bodeguero["tipo_establecimiento"],
                "nombre_comercial" => $bodeguero["nombre_comercial"],
                "razon_social" => $bodeguero["razon_social"],
                "estado_cuenta" => $bodeguero["estado_cuenta"],
                "linea_credito_max" => $bodeguero["linea_credito_max"],
                "credito_utilizado" => $bodeguero["credito_utilizado"]
            ]
        ], 200);
    }

    public function login($datos)
    {
        $this->loginAdmin($datos);
    }

    public function registrar($datos)
    {
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