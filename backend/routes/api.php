<?php

require_once "../controllers/AuthController.php";
require_once "../controllers/UsuarioController.php";
require_once "../controllers/BodegueroController.php";
require_once "../middleware/AuthMiddleware.php";
require_once "../controllers/ProveedorController.php";

$metodo = $_SERVER["REQUEST_METHOD"];

$datos = json_decode(file_get_contents("php://input"), true);

$authController = new AuthController($conexion);
$usuarioController = new UsuarioController($conexion);
$bodegueroController = new BodegueroController($conexion);

$accion = isset($_GET["accion"]) ? $_GET["accion"] : "";


// -- LOGIN USUARIO INTERNO

if ($metodo === "POST" && $accion === "login") {
    $authController->login($datos);
    exit;
}


// -- REGISTRAR USUARIO INTERNO

if ($metodo === "POST" && $accion === "registrar") {
    AuthMiddleware::permitirRoles([
        "ADMINISTRADOR"
    ]);

    $authController->registrar($datos);
    exit;
}


// -- CRUD USUARIOS INTERNOS

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


// -- REGISTRAR BODEGUERO

if ($metodo === "POST" && $accion === "registrar_bodeguero") {
    $bodegueroController->registrar($datos);
    exit;
}


// -- LOGIN BODEGUERO

if ($metodo === "POST" && $accion === "login_bodeguero") {
    $bodegueroController->login($datos);
    exit;
}


// -- CRUD BODEGUEROS

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

// -- PROVEEDORES

if ($accion === "registrar_proveedor" && $_SERVER["REQUEST_METHOD"] === "POST") {

    $datos = json_decode(file_get_contents("php://input"), true);

    $controller = new ProveedorController($conexion);
    $controller->registrar($datos);

    exit;
}

if ($accion === "listar_proveedores" && $_SERVER["REQUEST_METHOD"] === "GET") {

    $controller = new ProveedorController($conexion);
    $controller->listar();

    exit;
}

if ($accion === "buscar_proveedor" && $_SERVER["REQUEST_METHOD"] === "GET") {

    $id = $_GET["id"] ?? null;

    $controller = new ProveedorController($conexion);
    $controller->buscar($id);

    exit;
}

if ($accion === "actualizar_proveedor" && $_SERVER["REQUEST_METHOD"] === "PUT") {

    $id = $_GET["id"] ?? null;
    $datos = json_decode(file_get_contents("php://input"), true);

    $controller = new ProveedorController($conexion);
    $controller->actualizar($id, $datos);

    exit;
}

if ($accion === "desactivar_proveedor" && $_SERVER["REQUEST_METHOD"] === "DELETE") {

    $id = $_GET["id"] ?? null;

    $controller = new ProveedorController($conexion);
    $controller->desactivar($id);

    exit;
}

Response::json([
    "mensaje" => "Método o acción no permitido"
], 405);