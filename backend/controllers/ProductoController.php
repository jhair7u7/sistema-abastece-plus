<?php

require_once __DIR__ . "/../models/Producto.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";
require_once __DIR__ . "/../utils/Response.php";

class ProductoController
{
    private $db;
    private $producto;

    public function __construct($db)
    {
        $this->db = $db;
        $this->producto = new Producto($db);
    }

    public function listar()
    {
        $usuario = AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR",
            "BODEGUERO"
        ]);

        $productos = $this->producto->listar($usuario["rol"] === "BODEGUERO");

        Response::json([
            "mensaje" => "Productos obtenidos correctamente",
            "datos" => $productos
        ]);
    }

    public function buscar($id)
    {
        AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR"
        ]);

        $producto = $this->producto->buscarPorId($id);

        if (!$producto) {
            Response::json([
                "mensaje" => "Producto no encontrado"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Producto encontrado",
            "datos" => $producto
        ]);
    }

    public function buscarPorNombre()
    {
        $usuario = AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR",
            "BODEGUERO"
        ]);

        $nombre = isset($_GET["nombre"])
            ? trim($_GET["nombre"])
            : "";

        if ($nombre === "") {
            Response::json([
                "mensaje" => "Debe indicar el nombre del producto"
            ], 400);
            return;
        }

        $productos = $this->producto->buscarPorNombre(
            $nombre,
            $usuario["rol"] === "BODEGUERO"
        );

        Response::json([
            "mensaje" => "Productos encontrados",
            "datos" => $productos
        ]);
    }

    public function registrar()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR"
        ]);

        $datos = json_decode(file_get_contents("php://input"), true);

        $camposObligatorios = [
            "categoria_id",
            "codigo_sku",
            "nombre",
            "marca",
            "unidad_medida",
            "peso_kg",
            "precio_base_sugerido"
        ];

        foreach ($camposObligatorios as $campo) {
            if (!isset($datos[$campo]) || trim((string)$datos[$campo]) === "") {
                Response::json([
                    "mensaje" => "El campo '$campo' es obligatorio"
                ], 400);
                return;
            }
        }

        $datos["codigo_sku"] = trim($datos["codigo_sku"]);
        $datos["nombre"] = trim($datos["nombre"]);
        $datos["marca"] = trim($datos["marca"]);
        $datos["unidad_medida"] = trim($datos["unidad_medida"]);
        $datos["descripcion"] = isset($datos["descripcion"]) ? trim($datos["descripcion"]) : null;
        $datos["imagen_url"] = isset($datos["imagen_url"]) ? trim($datos["imagen_url"]) : null;

        $existente = $this->producto->buscarPorSku($datos["codigo_sku"]);

        if ($existente) {
            Response::json([
                "mensaje" => "Ya existe un producto con ese codigo SKU"
            ], 409);
            return;
        }

        try {

            $productoId = $this->producto->registrar($datos);
            if ($productoId) {

                Response::json([
                    "mensaje" => "Producto registrado correctamente",
                    "producto_id" => $productoId
                ], 201);

            } else {

                Response::json([
                    "mensaje" => "No se pudo registrar el producto"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al registrar el producto",
                "error" => "Error interno del servidor"
            ], 500);
        }
    }

    public function subirImagen($id)
    {
        $usuario = AuthMiddleware::permitirRoles(["LOGISTICA", "ADMINISTRADOR"]);
        $producto = $this->producto->buscarPorId($id);
        if (!$producto) {
            Response::json(["mensaje" => "Producto no encontrado"], 404);
            return;
        }
        if (!isset($_FILES["imagen"]) || $_FILES["imagen"]["error"] !== UPLOAD_ERR_OK) {
            Response::json(["mensaje" => "Selecciona una imagen válida"], 400);
            return;
        }

        $archivo = $_FILES["imagen"];
        if ($archivo["size"] > 5 * 1024 * 1024) {
            Response::json(["mensaje" => "La imagen no puede superar 5 MB"], 422);
            return;
        }
        $mime = (new finfo(FILEINFO_MIME_TYPE))->file($archivo["tmp_name"]);
        $extensiones = ["image/jpeg" => "jpg", "image/png" => "png", "image/webp" => "webp"];
        if (!isset($extensiones[$mime])) {
            Response::json(["mensaje" => "Formato no permitido. Usa JPG, PNG o WEBP"], 422);
            return;
        }

        $directorio = __DIR__ . "/../public/uploads/products";
        if (!is_dir($directorio) && !mkdir($directorio, 0755, true)) {
            Response::json(["mensaje" => "No se pudo preparar el directorio de imágenes"], 500);
            return;
        }
        $nombre = "product-" . (int)$id . "-" . bin2hex(random_bytes(8)) . "." . $extensiones[$mime];
        $destino = $directorio . "/" . $nombre;
        if (!move_uploaded_file($archivo["tmp_name"], $destino)) {
            Response::json(["mensaje" => "No se pudo guardar la imagen"], 500);
            return;
        }

        $ruta = "/api/uploads/products/" . $nombre;
        try {
            $this->producto->guardarImagenPrincipal($id, $ruta, $usuario["id"]);
            Response::json(["mensaje" => "Imagen cargada correctamente", "imagen_url" => $ruta]);
        } catch (Throwable $e) {
            @unlink($destino);
            Response::json(["mensaje" => "No se pudo asociar la imagen al producto"], 500);
        }
    }

    public function actualizar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR"
        ]);

        $producto = $this->producto->buscarPorId($id);

        if (!$producto) {
            Response::json([
                "mensaje" => "Producto no encontrado"
            ], 404);
            return;
        }

        $datos = json_decode(file_get_contents("php://input"), true);

        $camposObligatorios = [
            "categoria_id",
            "codigo_sku",
            "nombre",
            "marca",
            "unidad_medida",
            "peso_kg",
            "precio_base_sugerido"
        ];

        foreach ($camposObligatorios as $campo) {
            if (!isset($datos[$campo]) || trim((string)$datos[$campo]) === "") {
                Response::json([
                    "mensaje" => "El campo '$campo' es obligatorio"
                ], 400);
                return;
            }
        }

        $datos["codigo_sku"] = trim($datos["codigo_sku"]);
        $datos["nombre"] = trim($datos["nombre"]);
        $datos["marca"] = trim($datos["marca"]);
        $datos["unidad_medida"] = trim($datos["unidad_medida"]);
        $datos["descripcion"] = isset($datos["descripcion"]) ? trim($datos["descripcion"]) : null;
        $datos["imagen_url"] = isset($datos["imagen_url"]) ? trim($datos["imagen_url"]) : null;

        $existente = $this->producto->buscarPorSku($datos["codigo_sku"]);

        if ($existente && $existente["producto_id"] != $id) {
            Response::json([
                "mensaje" => "Ya existe otro producto con ese codigo SKU"
            ], 409);
            return;
        }

        try {

            if ($this->producto->actualizar($id, $datos)) {

                Response::json([
                    "mensaje" => "Producto actualizado correctamente"
                ]);

            } else {

                Response::json([
                    "mensaje" => "No se pudo actualizar el producto"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al actualizar el producto",
                "error" => "Error interno del servidor"
            ], 500);
        }
    }

    public function eliminar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "LOGISTICA",
            "ADMINISTRADOR"
        ]);

        $producto = $this->producto->buscarPorId($id);

        if (!$producto) {
            Response::json([
                "mensaje" => "Producto no encontrado"
            ], 404);
            return;
        }

        if ((int)$producto["activo"] === 0) {
            Response::json([
                "mensaje" => "El producto ya esta desactivado"
            ], 409);
            return;
        }

        try {

            if ($this->producto->cambiarEstado($id, false)) {

                Response::json([
                    "mensaje" => "Producto desactivado correctamente"
                ]);

            } else {

                Response::json([
                    "mensaje" => "No se pudo desactivar el producto"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al desactivar el producto",
                "error" => "Error interno del servidor"
            ], 500);
        }
    }
}
