<?php

// PHP no carga archivos .env por sí solo. Se leen aquí sin sobrescribir
// variables que ya hayan sido definidas por Apache, Docker o el sistema.
$envPath = __DIR__ . "/../.env";
if (is_file($envPath) && is_readable($envPath)) {
    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === "" || str_starts_with($line, "#") || !str_contains($line, "=")) {
            continue;
        }

        [$key, $value] = array_map("trim", explode("=", $line, 2));
        if ($key === "" || getenv($key) !== false) {
            continue;
        }

        if (strlen($value) >= 2) {
            $first = $value[0];
            $last = $value[strlen($value) - 1];
            if (($first === '"' && $last === '"') || ($first === "'" && $last === "'")) {
                $value = substr($value, 1, -1);
            }
        }

        putenv($key . "=" . $value);
        $_ENV[$key] = $value;
        $_SERVER[$key] = $value;
    }
}

$host = getenv("DB_HOST") ?: "localhost";
$port = getenv("DB_PORT") ?: "3306";
$dbname = getenv("DB_NAME") ?: "abastece_plus_db";
$username = getenv("DB_USER") ?: "root";
$password = getenv("DB_PASSWORD") ?: "luz123";

try {
    $conexion = new PDO(
        "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
        $username,
        $password
    );

    $conexion->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conexion->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

} catch (PDOException $e) {

    http_response_code(500);
    header("Content-Type: application/json; charset=UTF-8");
    echo json_encode(["mensaje" => "No se pudo conectar con la base de datos"]);
    exit;

}
