<?php

require_once __DIR__ . "/../models/Producto.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

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
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $productos = $this->producto->listar();

        Response::json([
            "mensaje" => "Productos obtenidos correctamente",
            "datos" => $productos
        ]);
    }

    public function buscar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
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

    public function registrar()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
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

            if ($this->producto->registrar($datos)) {

                Response::json([
                    "mensaje" => "Producto registrado correctamente"
                ], 201);

            } else {

                Response::json([
                    "mensaje" => "No se pudo registrar el producto"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al registrar el producto",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    public function actualizar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
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
                "error" => $e->getMessage()
            ], 500);
        }
    }

    public function eliminar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
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
                "error" => $e->getMessage()
            ], 500);
        }
    }
}

