<?php

$allowedOrigin = getenv("FRONTEND_URL") ?: "http://localhost:5173";
header("Access-Control-Allow-Origin: " . $allowedOrigin);
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Vary: Origin");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit;
}

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../utils/Response.php";

require_once __DIR__ . "/../routes/api.php";
