<?php

require_once "../controllers/AuthController.php";
require_once "../controllers/UsuarioController.php";
require_once "../controllers/BodegueroController.php";
require_once "../middleware/AuthMiddleware.php";
require_once "../controllers/ProveedorController.php";
require_once "../controllers/CategoriaController.php";
require_once "../controllers/ProductoController.php";

$metodo = $_SERVER["REQUEST_METHOD"];

$datos = json_decode(file_get_contents("php://input"), true);

$authController = new AuthController($conexion);
$usuarioController = new UsuarioController($conexion);
$bodegueroController = new BodegueroController($conexion);

$accion = isset($_GET["accion"]) ? $_GET["accion"] : "";


// -- LOGIN USUARIO INTERNO (DEDICADO)

if ($metodo === "POST" && $accion === "login_admin") {
    $authController->loginAdmin($datos);
    exit;
}


// -- LOGIN CLIENTE / BODEGUERO (DEDICADO)

if ($metodo === "POST" && $accion === "login_cliente") {
    $authController->loginCliente($datos);
    exit;
}


// -- ALIAS RETROCOMPATIBLES

if ($metodo === "POST" && $accion === "login") {
    $authController->loginAdmin($datos);
    exit;
}

if ($metodo === "POST" && $accion === "login_bodeguero") {
    $authController->loginCliente($datos);
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

// REGISTRAR CATEGORÍA
if ($accion === "registrar_categoria" && $_SERVER["REQUEST_METHOD"] === "POST") {

    $controller = new CategoriaController($conexion);
    $controller->registrar();

    exit;
}


// LISTAR CATEGORÍAS
if ($accion === "listar_categorias" && $_SERVER["REQUEST_METHOD"] === "GET") {

    $controller = new CategoriaController($conexion);
    $controller->listar();

    exit;
}


// BUSCAR CATEGORÍA POR ID
if ($accion === "buscar_categoria" && $_SERVER["REQUEST_METHOD"] === "GET") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID de la categoría"
        ], 400);
        exit;
    }

    $controller = new CategoriaController($conexion);
    $controller->buscar($_GET["id"]);

    exit;
}


// BUSCAR CATEGORÍA POR NOMBRE
if ($accion === "buscar_categoria_nombre" && $_SERVER["REQUEST_METHOD"] === "GET") {

    $controller = new CategoriaController($conexion);
    $controller->buscarPorNombre();

    exit;
}


// ACTUALIZAR CATEGORÍA
if ($accion === "actualizar_categoria" && $_SERVER["REQUEST_METHOD"] === "PUT") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID de la categoría"
        ], 400);
        exit;
    }

    $controller = new CategoriaController($conexion);
    $controller->actualizar($_GET["id"]);

    exit;
}


// ELIMINAR CATEGORÍA
if ($accion === "eliminar_categoria" && $_SERVER["REQUEST_METHOD"] === "DELETE") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID de la categoría"
        ], 400);
        exit;
    }

    $controller = new CategoriaController($conexion);
    $controller->eliminar($_GET["id"]);

    exit;
}


// ACTIVAR / DESACTIVAR CATEGORÍA
if ($accion === "cambiar_estado_categoria" && $_SERVER["REQUEST_METHOD"] === "PUT") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID de la categoría"
        ], 400);
        exit;
    }

    $controller = new CategoriaController($conexion);
    $controller->cambiarEstado($_GET["id"]);

    exit;
}

if ($accion === "listar_productos" && $_SERVER["REQUEST_METHOD"] === "GET") {

    $controller = new ProductoController($conexion);
    $controller->listar();

    exit;
}


if ($accion === "buscar_producto" && $_SERVER["REQUEST_METHOD"] === "GET") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID del producto"
        ], 400);
        exit;
    }

    $controller = new ProductoController($conexion);
    $controller->buscar($_GET["id"]);

    exit;
}


if ($accion === "registrar_producto" && $_SERVER["REQUEST_METHOD"] === "POST") {

    $controller = new ProductoController($conexion);
    $controller->registrar();

    exit;
}


if ($accion === "actualizar_producto" && $_SERVER["REQUEST_METHOD"] === "PUT") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID del producto"
        ], 400);
        exit;
    }

    $controller = new ProductoController($conexion);
    $controller->actualizar($_GET["id"]);

    exit;
}


if ($accion === "eliminar_producto" && $_SERVER["REQUEST_METHOD"] === "DELETE") {

    if (!isset($_GET["id"])) {
        Response::json([
            "mensaje" => "Debe indicar el ID del producto"
        ], 400);
        exit;
    }

    $controller = new ProductoController($conexion);
    $controller->eliminar($_GET["id"]);

    exit;
}

Response::json([
    "mensaje" => "Método o acción no permitido"
], 405);