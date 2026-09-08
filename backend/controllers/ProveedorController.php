<?php

class ProveedorController
{
    private $proveedor;

    public function __construct($conexion)
    {
        require_once "../models/Proveedor.php";
        $this->proveedor = new Proveedor($conexion);
    }

    // -- REGISTRAR PROVEEDOR

    public function registrar($datos)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        if (
            !isset($datos["ruc"]) ||
            !isset($datos["razon_social"]) ||
            !isset($datos["nombre_comercial"]) ||
            !isset($datos["contacto_nombre"]) ||
            !isset($datos["correo"]) ||
            !isset($datos["telefono"])
        ) {
            Response::json([
                "mensaje" => "Todos los campos son obligatorios"
            ], 400);
            return;
        }

        $ruc = trim($datos["ruc"]);
        $razonSocial = trim($datos["razon_social"]);
        $nombreComercial = trim($datos["nombre_comercial"]);
        $contactoNombre = trim($datos["contacto_nombre"]);
        $correo = trim($datos["correo"]);
        $telefono = trim($datos["telefono"]);

        // Verificar RUC
        $rucExistente = $this->proveedor->buscarPorRuc($ruc);

        if ($rucExistente) {
            Response::json([
                "mensaje" => "El RUC ya está registrado"
            ], 409);
            return;
        }

        // Verificar correo
        $correoExistente = $this->proveedor->buscarPorCorreo($correo);

        if ($correoExistente) {
            Response::json([
                "mensaje" => "El correo ya está registrado"
            ], 409);
            return;
        }

        $resultado = $this->proveedor->registrar(
            $ruc,
            $razonSocial,
            $nombreComercial,
            $contactoNombre,
            $correo,
            $telefono
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Proveedor registrado correctamente"
            ], 201);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo registrar el proveedor"
        ], 500);
    }

    // -- LISTAR PROVEEDORES

    public function listar()
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        $proveedores = $this->proveedor->listar();

        Response::json([
            "mensaje" => "Proveedores obtenidos correctamente",
            "proveedores" => $proveedores
        ], 200);
    }

    // -- BUSCAR PROVEEDOR

    public function buscar($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de proveedor no válido"
            ], 400);
            return;
        }

        $proveedor = $this->proveedor->buscarPorId($id);

        if (!$proveedor) {
            Response::json([
                "mensaje" => "Proveedor no encontrado"
            ], 404);
            return;
        }

        Response::json([
            "mensaje" => "Proveedor encontrado",
            "proveedor" => $proveedor
        ], 200);
    }

    // -- ACTUALIZAR PROVEEDOR

    public function actualizar($id, $datos)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR",
            "LOGISTICA"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de proveedor no válido"
            ], 400);
            return;
        }

        if (
            !isset($datos["ruc"]) ||
            !isset($datos["razon_social"]) ||
            !isset($datos["nombre_comercial"]) ||
            !isset($datos["contacto_nombre"]) ||
            !isset($datos["correo"]) ||
            !isset($datos["telefono"])
        ) {
            Response::json([
                "mensaje" => "Todos los campos son obligatorios"
            ], 400);
            return;
        }

        $proveedorExistente = $this->proveedor->buscarPorId($id);

        if (!$proveedorExistente) {
            Response::json([
                "mensaje" => "Proveedor no encontrado"
            ], 404);
            return;
        }

        $ruc = trim($datos["ruc"]);
        $razonSocial = trim($datos["razon_social"]);
        $nombreComercial = trim($datos["nombre_comercial"]);
        $contactoNombre = trim($datos["contacto_nombre"]);
        $correo = trim($datos["correo"]);
        $telefono = trim($datos["telefono"]);

        // Verificar que el RUC no pertenezca a otro proveedor
        $rucExistente = $this->proveedor->buscarPorRuc($ruc);

        if (
            $rucExistente &&
            $rucExistente["proveedor_id"] != $id
        ) {
            Response::json([
                "mensaje" => "El RUC ya está registrado por otro proveedor"
            ], 409);
            return;
        }

        // Verificar que el correo no pertenezca a otro proveedor
        $correoExistente = $this->proveedor->buscarPorCorreo($correo);

        if (
            $correoExistente &&
            $correoExistente["proveedor_id"] != $id
        ) {
            Response::json([
                "mensaje" => "El correo ya está registrado por otro proveedor"
            ], 409);
            return;
        }

        $resultado = $this->proveedor->actualizar(
            $id,
            $ruc,
            $razonSocial,
            $nombreComercial,
            $contactoNombre,
            $correo,
            $telefono
        );

        if ($resultado) {
            Response::json([
                "mensaje" => "Proveedor actualizado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo actualizar el proveedor"
        ], 500);
    }

    // -- DESACTIVAR PROVEEDOR

    public function desactivar($id)
    {
        AuthMiddleware::permitirRoles([
            "ADMINISTRADOR"
        ]);

        if (!$id || !is_numeric($id)) {
            Response::json([
                "mensaje" => "ID de proveedor no válido"
            ], 400);
            return;
        }

        $proveedor = $this->proveedor->buscarPorId($id);

        if (!$proveedor) {
            Response::json([
                "mensaje" => "Proveedor no encontrado"
            ], 404);
            return;
        }

        $resultado = $this->proveedor->desactivar($id);

        if ($resultado) {
            Response::json([
                "mensaje" => "Proveedor desactivado correctamente"
            ], 200);
            return;
        }

        Response::json([
            "mensaje" => "No se pudo desactivar el proveedor"
        ], 500);
    }
}