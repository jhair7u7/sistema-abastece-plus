<?php

require_once __DIR__ . "/../models/Direccion.php";
require_once __DIR__ . "/../middleware/AuthMiddleware.php";

class DireccionController
{
    private $direccion;

    public function __construct($conexion)
    {
        $this->direccion = new Direccion($conexion);
    }

    // -- LISTAR
    public function listar()
    {
        $usuario = AuthMiddleware::verificarToken();

        // BODEGUERO: solo ve sus propias direcciones
        if ($usuario["rol"] === "BODEGUERO") {

            $resultado = $this->direccion->listarPorBodeguero($usuario["id"]);

        } else {

            // Usuarios internos autorizados
            $resultado = $this->direccion->listar();
        }

        Response::json([
            "success" => true,
            "data" => $resultado
        ], 200);
    }

    // -- OBTENER POR ID
    public function obtener($id)
    {
        $usuario = AuthMiddleware::verificarToken();

        $direccion = $this->direccion->obtenerPorId($id);

        if (!$direccion) {
            Response::json([
                "success" => false,
                "mensaje" => "Dirección no encontrada"
            ], 404);
            return;
        }

        // BODEGUERO: solo puede consultar sus propias direcciones
        if (
            $usuario["rol"] === "BODEGUERO" &&
            (int)$direccion["bodeguero_id"] !== (int)$usuario["id"]
        ) {
            Response::json([
                "success" => false,
                "mensaje" => "No tienes permiso para consultar esta dirección"
            ], 403);
            return;
        }

        Response::json([
            "success" => true,
            "data" => $direccion
        ], 200);
    }

    // -- CREAR
    public function crear()
    {
        $usuario = AuthMiddleware::verificarToken();

        $datos = json_decode(file_get_contents("php://input"), true);

        if (!$datos) {
            Response::json([
                "success" => false,
                "mensaje" => "Datos JSON inválidos"
            ], 400);
            return;
        }

        // -- CAMPOS OBLIGATORIOS
        $campos = [
            "distrito",
            "direccion_exacta",
            "zona_reparto"
        ];

        foreach ($campos as $campo) {

            if (
                !isset($datos[$campo]) ||
                trim($datos[$campo]) === ""
            ) {
                Response::json([
                    "success" => false,
                    "mensaje" => "El campo $campo es obligatorio"
                ], 400);
                return;
            }
        }

        // -- BODEGUERO
        if ($usuario["rol"] === "BODEGUERO") {

            // El bodeguero NO puede enviar otro bodeguero_id
            $datos["bodeguero_id"] = (int)$usuario["id"];

            // Nunca puede crear dirección de proveedor
            $datos["proveedor_id"] = null;
        }

        // -- USUARIOS INTERNOS
        else {

            // Debe pertenecer a bodeguero O proveedor
            $bodeguero = !empty($datos["bodeguero_id"]);
            $proveedor = !empty($datos["proveedor_id"]);

            if ($bodeguero === $proveedor) {

                Response::json([
                    "success" => false,
                    "mensaje" => "La dirección debe pertenecer a un bodeguero o a un proveedor, pero no a ambos"
                ], 400);

                return;
            }
        }

        try {

            $resultado = $this->direccion->crear($datos);

            if ($resultado) {

                Response::json([
                    "success" => true,
                    "mensaje" => "Dirección registrada correctamente"
                ], 201);

            } else {

                Response::json([
                    "success" => false,
                    "mensaje" => "No se pudo registrar la dirección"
                ], 400);
            }

        } catch (PDOException $e) {

            Response::json([
                "success" => false,
                "mensaje" => "Error al registrar la dirección",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    // -- ACTUALIZAR
    public function actualizar($id)
    {
        $usuario = AuthMiddleware::verificarToken();

        $direccion = $this->direccion->obtenerPorId($id);

        if (!$direccion) {
            Response::json([
                "success" => false,
                "mensaje" => "Dirección no encontrada"
            ], 404);
            return;
        }

        // BODEGUERO solo puede modificar sus propias direcciones
        if (
            $usuario["rol"] === "BODEGUERO" &&
            (int)$direccion["bodeguero_id"] !== (int)$usuario["id"]
        ) {
            Response::json([
                "success" => false,
                "mensaje" => "No tienes permiso para modificar esta dirección"
            ], 403);
            return;
        }

        $datos = json_decode(file_get_contents("php://input"), true);

        if (!$datos) {
            Response::json([
                "success" => false,
                "mensaje" => "Datos JSON inválidos"
            ], 400);
            return;
        }

        foreach ([
            "distrito",
            "direccion_exacta",
            "zona_reparto"
        ] as $campo) {

            if (
                !isset($datos[$campo]) ||
                trim($datos[$campo]) === ""
            ) {
                Response::json([
                    "success" => false,
                    "mensaje" => "El campo $campo es obligatorio"
                ], 400);
                return;
            }
        }

        try {

            $resultado = $this->direccion->actualizar($id, $datos);

            Response::json([
                "success" => true,
                "mensaje" => "Dirección actualizada correctamente"
            ], 200);

        } catch (PDOException $e) {

            Response::json([
                "success" => false,
                "mensaje" => "Error al actualizar la dirección",
                "error" => $e->getMessage()
            ], 500);
        }
    }

    // -- ELIMINAR
    public function eliminar($id)
    {
        $usuario = AuthMiddleware::verificarToken();

        $direccion = $this->direccion->obtenerPorId($id);

        if (!$direccion) {
            Response::json([
                "success" => false,
                "mensaje" => "Dirección no encontrada"
            ], 404);
            return;
        }

        // BODEGUERO solo puede eliminar sus propias direcciones
        if (
            $usuario["rol"] === "BODEGUERO" &&
            (int)$direccion["bodeguero_id"] !== (int)$usuario["id"]
        ) {
            Response::json([
                "success" => false,
                "mensaje" => "No tienes permiso para eliminar esta dirección"
            ], 403);
            return;
        }

        try {

            $resultado = $this->direccion->eliminar($id);

            Response::json([
                "success" => true,
                "mensaje" => "Dirección eliminada correctamente"
            ], 200);

        } catch (PDOException $e) {

            Response::json([
                "success" => false,
                "mensaje" => "No se pudo eliminar la dirección",
                "error" => $e->getMessage()
            ], 500);
        }
    }
}