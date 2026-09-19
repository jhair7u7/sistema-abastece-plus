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

    // -- VERIFICAR ACCESO PARA CONSULTAR CATEGORÍAS | ADMINISTRADOR / LOGISTICA / BODEGUERO
    private function verificarAccesoConsulta()
    {
        $payload = AuthMiddleware::verificarToken();

        // BODEGUERO
        if (
            isset($payload["tipo_usuario"]) &&
            $payload["tipo_usuario"] === "BODEGUERO"
        ) {
            return $payload;
        }

        // USUARIOS INTERNOS
        if (
            isset($payload["rol"]) &&
            in_array($payload["rol"], [
                "ADMINISTRADOR",
                "LOGISTICA"
            ])
        ) {
            return $payload;
        }

        Response::json([
            "mensaje" => "No tiene permisos para consultar categorías"
        ], 403);

        exit;
    }

    // -- REGISTRAR CATEGORÍA | ADMINISTRADOR / LOGISTICA
    public function registrar()
    {
        AuthMiddleware::verificarToken();
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $datos = json_decode(
            file_get_contents("php://input"),
            true
        );

        if (
            !isset($datos["nombre"]) ||
            trim($datos["nombre"]) === ""
        ) {
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

            $resultado = $this->categoria->registrar($nombre);

            if ($resultado) {
                Response::json([
                    "mensaje" => "Categoría registrada correctamente"
                ], 201);

                return;
            }

            Response::json([
                "mensaje" => "No se pudo registrar la categoría"
            ], 500);

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al registrar la categoría"
            ], 500);
        }
    }

    // -- LISTAR CATEGORÍAS | ADMINISTRADOR / LOGISTICA / BODEGUERO
    public function listar()
    {
        $this->verificarAccesoConsulta();

        $categorias = $this->categoria->listar();

        Response::json([
            "mensaje" => "Categorías obtenidas correctamente",
            "datos" => $categorias
        ]);
    }

    // -- BUSCAR CATEGORÍA POR ID | ADMINISTRADOR / LOGISTICA / BODEGUERO
    public function buscar($id)
    {
        $this->verificarAccesoConsulta();

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

    // -- BUSCAR CATEGORÍA POR NOMBRE | ADMINISTRADOR / LOGISTICA / BODEGUERO
    public function buscarPorNombre()
    {
        $this->verificarAccesoConsulta();

        $nombre = isset($_GET["nombre"])
            ? trim($_GET["nombre"])
            : "";

        if ($nombre === "") {
            Response::json([
                "mensaje" => "Debe indicar el nombre de la categoría"
            ], 400);

            return;
        }

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

    // -- ACTUALIZAR CATEGORÍA | ADMINISTRADOR / LOGISTICA
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

        $datos = json_decode(
            file_get_contents("php://input"),
            true
        );

        if (
            !isset($datos["nombre"]) ||
            trim($datos["nombre"]) === ""
        ) {
            Response::json([
                "mensaje" => "El nombre de la categoría es obligatorio"
            ], 400);

            return;
        }

        $nombre = trim($datos["nombre"]);

        // Mantener estado actual si no se envía
        $activo = isset($datos["activo"])
            ? (bool)$datos["activo"]
            : (bool)$categoria["activo"];

        // Verificar duplicado
        $existente = $this->categoria->buscarPorNombre($nombre);

        if (
            $existente &&
            $existente["categoria_id"] != $id
        ) {
            Response::json([
                "mensaje" => "Ya existe otra categoría con ese nombre"
            ], 409);

            return;
        }

        try {

            $resultado = $this->categoria->actualizar(
                $id,
                $nombre,
                $activo
            );

            if ($resultado) {
                Response::json([
                    "mensaje" => "Categoría actualizada correctamente"
                ]);

                return;
            }

            Response::json([
                "mensaje" => "No se pudo actualizar la categoría"
            ], 500);

        } catch (PDOException $e) {

            Response::json([
                "mensaje" => "Error al actualizar la categoría"
            ], 500);
        }
    }

    // -- CAMBIAR ESTADO | ADMINISTRADOR / LOGISTICA
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

        $datos = json_decode(
            file_get_contents("php://input"),
            true
        );

        if (!isset($datos["activo"])) {
            Response::json([
                "mensaje" => "Debe indicar el estado activo"
            ], 400);

            return;
        }

        $activo = (bool)$datos["activo"];

        $resultado = $this->categoria->cambiarEstado(
            $id,
            $activo
        );

        if ($resultado) {
            Response::json([
                "mensaje" => $activo
                    ? "Categoría activada correctamente"
                    : "Categoría desactivada correctamente"
            ]);

            return;
        }

        Response::json([
            "mensaje" => "No se pudo cambiar el estado de la categoría"
        ], 500);
    }

    // -- ELIMINAR CATEGORÍA | SOLO ADMINISTRADOR
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

        // No eliminar si tiene productos asociados
        if ($this->categoria->tieneProductos($id)) {
            Response::json([
                "mensaje" => "No se puede eliminar la categoría porque tiene productos asociados"
            ], 409);

            return;
        }

        $resultado = $this->categoria->eliminar($id);

        if ($resultado) {
            Response::json([
                "mensaje" => "Categoría eliminada correctamente"
            ]);

            return;
        }

        Response::json([
            "mensaje" => "No se pudo eliminar la categoría"
        ], 500);
    }
}