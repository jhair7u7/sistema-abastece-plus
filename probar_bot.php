<?php

require_once __DIR__ . '/backend/config/database.php';
require_once __DIR__ . '/backend/controllers/BotController.php';

echo "Abastece+ | Asistente: Abas el capibara\n";
echo "Escribe tu consulta y presiona Enter ('salir' para terminar).\n\n";

$bot = new BotController($conexion);

$reflection = new ReflectionClass($bot);
$methodGemini = $reflection->getMethod('llamarGemini');
$methodContexto = $reflection->getMethod('recopilarContextoBD');

$historial = [];

while (true) {
    echo "> ";
    $linea = trim(fgets(STDIN));

    if (strtolower($linea) === 'salir' || $linea === '') {
        if ($linea === '') continue;
        break;
    }

    $inicio = microtime(true);
    $contexto = $methodContexto->invoke($bot, $linea, null);
    $respuesta = $methodGemini->invoke($bot, $linea, $historial, $contexto, null);
    $segundos = round(microtime(true) - $inicio, 2);

    echo "\nAbas ({$segundos}s):\n";
    echo $respuesta . "\n\n";

    $historial[] = ['rol' => 'user', 'texto' => $linea];
    $historial[] = ['rol' => 'bot', 'texto' => $respuesta];
}
