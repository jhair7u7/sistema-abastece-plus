<?php

require_once "../controllers/AuthController.php";
require_once "../controllers/UsuarioController.php";
require_once "../controllers/BodegueroController.php";
require_once "../middleware/AuthMiddleware.php";

$metodo = $_SERVER["REQUEST_METHOD"];

$datos = json_decode(file_get_contents("php://input"), true);

$authController = new AuthController($conexion);
$usuarioController = new UsuarioController($conexion);
$bodegueroController = new BodegueroController($conexion);

$accion = isset($_GET["accion"]) ? $_GET["accion"] : "";


// =====================================================
// LOGIN USUARIO INTERNO
// =====================================================

if ($metodo === "POST" && $accion === "login") {
    $authController->login($datos);
    exit;
}


// =====================================================
// REGISTRAR USUARIO INTERNO
// =====================================================

if ($metodo === "POST" && $accion === "registrar") {
    AuthMiddleware::permitirRoles([
        "ADMINISTRADOR"
    ]);

    $authController->registrar($datos);
    exit;
}


// =====================================================
// CRUD USUARIOS INTERNOS
// =====================================================

if ($metodo === "GET" && $accion === "listar") {
    $usuarioController->listar();
    exit;
}

if ($metodo === "GET" && $accion === "buscar") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $usuarioController->buscar($id);
    exit;
}

if ($metodo === "PUT" && $accion === "actualizar") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $usuarioController->actualizar($id, $datos);
    exit;
}

if ($metodo === "DELETE" && $accion === "eliminar") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $usuarioController->eliminar($id);
    exit;
}


// =====================================================
// REGISTRAR BODEGUERO
// =====================================================

if ($metodo === "POST" && $accion === "registrar_bodeguero") {
    $bodegueroController->registrar($datos);
    exit;
}


// =====================================================
// LOGIN BODEGUERO
// =====================================================

if ($metodo === "POST" && $accion === "login_bodeguero") {
    $bodegueroController->login($datos);
    exit;
}


// =====================================================
// CRUD BODEGUEROS
// =====================================================

// Listar
if ($metodo === "GET" && $accion === "listar_bodegueros") {
    $bodegueroController->listar();
    exit;
}

// Buscar por ID
if ($metodo === "GET" && $accion === "buscar_bodeguero") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $bodegueroController->buscar($id);
    exit;
}

// Actualizar
if ($metodo === "PUT" && $accion === "actualizar_bodeguero") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $bodegueroController->actualizar($id, $datos);
    exit;
}

// Bloquear
if ($metodo === "DELETE" && $accion === "bloquear_bodeguero") {
    $id = isset($_GET["id"]) ? $_GET["id"] : null;

    $bodegueroController->bloquear($id);
    exit;
}


// =====================================================
// ACCIÓN NO PERMITIDA
// =====================================================

Response::json([
    "mensaje" => "Método o acción no permitido"
], 405);