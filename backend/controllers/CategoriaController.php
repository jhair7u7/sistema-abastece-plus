<?php

require_once __DIR__ . "/../models/Categoria.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

class CategoriaController
{
    private $db;
    private $categoria;

    public function __construct($db)
    {
        $this->db = $db;
        $this->categoria = new Categoria($db);
    }

    // REGISTRAR CATEGORÍA
    public function registrar()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $datos = json_decode(file_get_contents("php://input"), true);

        if (!isset($datos["nombre"]) || trim($datos["nombre"]) === "") {
            Response::json([
                "mensaje" => "El nombre de la categoría es obligatorio"
            ], 400);
            return;
        }

        $nombre = trim($datos["nombre"]);

        // Verificar duplicado
        $existente = $this->categoria->buscarPorNombre($nombre);

        if ($existente) {
            Response::json([
                "mensaje" => "La categoría ya existe"
            ], 409);
            return;
        }

        try {

            if ($this->categoria->registrar($nombre)) {

                Response::json([
                    "mensaje" => "Categoría registrada correctamente"
                ], 201);

            } else {

                Response::json([
                    "mensaje" => "No se pudo registrar la categoría"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al registrar la categoría",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    // LISTAR CATEGORÍAS
    public function listar()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $categorias = $this->categoria->listar();

        Response::json([
            "mensaje" => "Categorías obtenidas correctamente",
            "datos" => $categorias
        ]);
    }

    // BUSCAR POR ID
    public function buscar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $categoria = $this->categoria->buscarPorId($id);

        if (!$categoria) {
            Response::json([
                "mensaje" => "Categoría no encontrada"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Categoría encontrada",
            "datos" => $categoria
        ]);
    }

    // BUSCAR POR NOMBRE
    public function buscarPorNombre()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        if (!isset($_GET["nombre"]) || trim($_GET["nombre"]) === "") {
            Response::json([
                "mensaje" => "Debe indicar el nombre de la categoría"
            ], 400);
            return;
        }

        $nombre = trim($_GET["nombre"]);

        $categoria = $this->categoria->buscarPorNombre($nombre);

        if (!$categoria) {
            Response::json([
                "mensaje" => "Categoría no encontrada"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Categoría encontrada",
            "datos" => $categoria
        ]);
    }

    // ACTUALIZAR CATEGORÍA
    public function actualizar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $categoria = $this->categoria->buscarPorId($id);

        if (!$categoria) {
            Response::json([
                "mensaje" => "Categoría no encontrada"
            ], 404);
            return;
        }

        $datos = json_decode(file_get_contents("php://input"), true);

        if (!isset($datos["nombre"]) || trim($datos["nombre"]) === "") {
            Response::json([
                "mensaje" => "El nombre de la categoría es obligatorio"
            ], 400);
            return;
        }

        $nombre = trim($datos["nombre"]);

        // Mantener activo actual si no se envía
        $activo = isset($datos["activo"])
            ? (bool)$datos["activo"]
            : (bool)$categoria["activo"];

        // Verificar que el nuevo nombre no pertenezca a otra categoría
        $existente = $this->categoria->buscarPorNombre($nombre);

        if ($existente && $existente["categoria_id"] != $id) {
            Response::json([
                "mensaje" => "Ya existe otra categoría con ese nombre"
            ], 409);
            return;
        }

        try {

            if ($this->categoria->actualizar($id, $nombre, $activo)) {

                Response::json([
                    "mensaje" => "Categoría actualizada correctamente"
                ]);

            } else {

                Response::json([
                    "mensaje" => "No se pudo actualizar la categoría"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al actualizar la categoría",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    // ELIMINAR CATEGORÍA (BAJA LÓGICA)
    public function eliminar($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        $categoria = $this->categoria->buscarPorId($id);

        if (!$categoria) {
            Response::json([
                "mensaje" => "Categoría no encontrada"
            ], 404);
            return;
        }

        if ((int)$categoria["activo"] === 0) {
            Response::json([
                "mensaje" => "La categoría ya está desactivada"
            ], 409);
            return;
        }

        try {

            if ($this->categoria->eliminar($id)) {

                Response::json([
                    "mensaje" => "Categoría desactivada correctamente"
                ]);

            } else {

                Response::json([
                    "mensaje" => "No se pudo desactivar la categoría"
                ], 500);
            }

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al desactivar la categoría",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    // ACTIVAR / DESACTIVAR
    public function cambiarEstado($id)
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $categoria = $this->categoria->buscarPorId($id);

        if (!$categoria) {
            Response::json([
                "mensaje" => "Categoría no encontrada"
            ], 404);
            return;
        }

        $datos = json_decode(file_get_contents("php://input"), true);

        if (!isset($datos["activo"])) {
            Response::json([
                "mensaje" => "Debe indicar el estado activo"
            ], 400);
            return;
        }

        $activo = (bool)$datos["activo"];

        if ($this->categoria->cambiarEstado($id, $activo)) {

            Response::json([
                "mensaje" => $activo
                    ? "Categoría activada correctamente"
                    : "Categoría desactivada correctamente"
            ]);

        } else {

            Response::json([
                "mensaje" => "No se pudo cambiar el estado"
            ], 500);
        }
    }
}