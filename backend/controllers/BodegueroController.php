<?php

require_once "../models/Bodeguero.php";
require_once "../middleware/AuthMiddleware.php";

class BodegueroController
{
    private $bodeguero;

    public function __construct($conexion)
    {
        $this->bodeguero = new Bodeguero($conexion);
    }

    // -- REGISTRAR BODEGUERO

    public function registrar($datos)
    {
        if (
            !isset($datos["nombre"]) ||
            !isset($datos["apellidos"]) ||
            !isset($datos["usuario"]) ||
            !isset($datos["password"]) ||
            !isset($datos["telefono"]) ||
            !isset($datos["ruc"]) ||
            !isset($datos["tipo_establecimiento"]) ||
            !isset($datos["nombre_comercial"]) ||
            !isset($datos["razon_social"])
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
        $ruc = trim($datos["ruc"]);
        $tipoEstablecimiento = trim($datos["tipo_establecimiento"]);
        $nombreComercial = trim($datos["nombre_comercial"]);
        $razonSocial = trim($datos["razon_social"]);

        $correoExistente = $this->bodeguero->buscarPorCorreo($correo);

        if ($correoExistente) {
            Response::json([
                "mensaje" => "El correo ya está registrado"
            ], 409);
            return;
        }

        $rucExistente = $this->bodeguero->buscarPorRuc($ruc);

        if ($rucExistente) {
            Response::json([
                "mensaje" => "El RUC ya está registrado"
            ], 409);
            return;
        }

        $tiposPermitidos = [
            "BODEGA",
            "MINIMARKET",
            "MARKET_LOCAL",
            "OTROS"
        ];

        if (!in_array($tipoEstablecimiento, $tiposPermitidos)) {
            Response::json([
                "mensaje" => "Tipo de establecimiento no válido"
            ], 400);
            return;
        }

        $passwordHash = hash("sha256", $password);

        $resultado = $this->bodeguero->registrar(
            $nombre,
            $apellidos,
            $correo,
            $passwordHash,
            $telefono,
            $ruc,
            $tipoEstablecimiento,
            $nombreComercial,
            $razonSocial
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Bodeguero registrado correctamente",
                "bodeguero" => [
                    "nombre" => $nombre,
                    "apellidos" => $apellidos,
                    "usuario" => $correo,
                    "telefono" => $telefono,
                    "ruc" => $ruc,
                    "tipo_establecimiento" => $tipoEstablecimiento,
                    "nombre_comercial" => $nombreComercial,
                    "razon_social" => $razonSocial,
                    "estado_cuenta" => "PENDIENTE_VERIFICACION"
                ]
            ], 201);

            return;
        }

        Response::json([
            "mensaje" => "No se pudo registrar el bodeguero"
        ], 500);
    }

    // -- LOGIN BODEGUERO

    public function login($datos)
    {
        if (
            !isset($datos["usuario"]) ||
            !isset($datos["password"])
        ) {
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

    // -- LISTAR BODEGUEROS

    public function listar()
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "GESTOR_ATENCION"
        ]);

        $bodegueros = $this->bodeguero->listar();

        Response::json([
            "mensaje" => "Bodegueros obtenidos correctamente",
            "bodegueros" => $bodegueros
        ], 200);
    }

    // -- BUSCAR BODEGUERO

    public function buscar($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "GESTOR_ATENCION"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de bodeguero no válido"
            ], 400);
            return;
        }

        $bodeguero = $this->bodeguero->buscarPorId($id);

        if (!$bodeguero) {
            Response::json([
                "mensaje" => "Bodeguero no encontrado"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Bodeguero encontrado",
            "bodeguero" => $bodeguero
        ], 200);
    }

    // -- ACTUALIZAR BODEGUERO

    public function actualizar($id, $datos)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de bodeguero no válido"
            ], 400);
            return;
        }

        if (
            !isset($datos["nombre"]) ||
            !isset($datos["apellidos"]) ||
            !isset($datos["usuario"]) ||
            !isset($datos["telefono"]) ||
            !isset($datos["ruc"]) ||
            !isset($datos["tipo_establecimiento"]) ||
            !isset($datos["nombre_comercial"]) ||
            !isset($datos["razon_social"])
        ) {
            Response::json([
                "mensaje" => "Todos los campos son obligatorios"
            ], 400);
            return;
        }

        $bodegueroExistente = $this->bodeguero->buscarPorId($id);

        if (!$bodegueroExistente) {
            Response::json([
                "mensaje" => "Bodeguero no encontrado"
            ], 404);
            return;
        }

        $nombre = trim($datos["nombre"]);
        $apellidos = trim($datos["apellidos"]);
        $correo = trim($datos["usuario"]);
        $telefono = trim($datos["telefono"]);
        $ruc = trim($datos["ruc"]);
        $tipoEstablecimiento = trim($datos["tipo_establecimiento"]);
        $nombreComercial = trim($datos["nombre_comercial"]);
        $razonSocial = trim($datos["razon_social"]);

        $correoExistente = $this->bodeguero->buscarPorCorreo($correo);

        if (
            $correoExistente &&
            $correoExistente["bodeguero_id"] != $id
        ) {
            Response::json([
                "mensaje" => "El correo ya está registrado por otro bodeguero"
            ], 409);
            return;
        }

        $rucExistente = $this->bodeguero->buscarPorRuc($ruc);

        if (
            $rucExistente &&
            $rucExistente["bodeguero_id"] != $id
        ) {
            Response::json([
                "mensaje" => "El RUC ya está registrado por otro bodeguero"
            ], 409);
            return;
        }

        $tiposPermitidos = [
            "BODEGA",
            "MINIMARKET",
            "MARKET_LOCAL",
            "OTROS"
        ];

        if (!in_array($tipoEstablecimiento, $tiposPermitidos)) {
            Response::json([
                "mensaje" => "Tipo de establecimiento no válido"
            ], 400);
            return;
        }

        $resultado = $this->bodeguero->actualizar(
            $id,
            $nombre,
            $apellidos,
            $correo,
            $telefono,
            $ruc,
            $tipoEstablecimiento,
            $nombreComercial,
            $razonSocial
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Bodeguero actualizado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo actualizar el bodeguero"
        ], 500);
    }

    // -- BLOQUEAR BODEGUERO

    public function bloquear($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de bodeguero no válido"
            ], 400);
            return;
        }

        $bodeguero = $this->bodeguero->buscarPorId($id);

        if (!$bodeguero) {
            Response::json([
                "mensaje" => "Bodeguero no encontrado"
            ], 404);
            return;
        }

        $resultado = $this->bodeguero->bloquear($id);

        if ($resultado) {
            Response::json([
                "mensaje" => "Bodeguero bloqueado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo bloquear el bodeguero"
        ], 500);
    }
}