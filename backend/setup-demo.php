<?php
// Solo CLI. Instalación no destructiva de la base de proyecto.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
putenv('DB_NAME=mysql');
require __DIR__ . '/config/database.php';
if ($conexion->query("SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='abastece_nuevo'")->fetchColumn()) {
    fwrite(STDERR, "abastece_nuevo ya existe. No se modificó.\n"); exit(1);
}
$conexion->exec(file_get_contents(__DIR__ . '/../bd/Abastece_nuevo.sql'));
echo "Base abastece_nuevo instalada.\n";
