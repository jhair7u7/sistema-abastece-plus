<?php
require_once __DIR__ . "/../models/Producto.php";

class ProductoController
{
    private $producto;
    public function __construct($conexion) { $this->producto = new Producto($conexion); }
    public function listar()
    {
        Response::json([
            "mensaje" => "Productos obtenidos correctamente",
            "productos" => $this->producto->listar()
        ]);
    }
}
