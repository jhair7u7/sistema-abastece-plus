<?php

require_once __DIR__ . "/../utils/Response.php";

class BotController
{
    private $conexion;

    public function __construct($conexion)
    {
        $this->conexion = $conexion;
    }

    /**
     * Procesa una consulta al bot de soporte Abastece+
     * Recibe: { "mensaje": string, "historial": array (opcional) }
     */
    public function consultar($datos)
    {
        $mensaje = isset($datos["mensaje"]) ? trim($datos["mensaje"]) : "";
        if ($mensaje === "") {
            Response::json([
                "exito" => false,
                "mensaje" => "El campo 'mensaje' es obligatorio."
            ], 400);
            return;
        }

        $historial = isset($datos["historial"]) && is_array($datos["historial"]) 
            ? array_slice($datos["historial"], -6) // Conservar últimos 6 mensajes para contexto
            : [];

        // 1. Obtener usuario autenticado si existe token (opcional, no bloqueante)
        $usuario = $this->obtenerUsuarioOpcional();

        // 2. Consultar datos en TIEMPO REAL desde la base de datos MySQL
        $contextoBD = $this->recopilarContextoBD($mensaje, $usuario);

        // 3. Consultar API de Google Gemini con grounding estricto
        $respuestaIA = $this->llamarGemini($mensaje, $historial, $contextoBD, $usuario);

        // 4. Generar sugerencias rápidas contextuales para el frontend
        $sugerencias = $this->generarSugerencias($mensaje);

        Response::json([
            "exito" => true,
            "respuesta" => $respuestaIA,
            "sugerencias" => $sugerencias
        ], 200);
    }

    /**
     * Recopila el catálogo y stock actualizados en vivo, además de pedidos si aplica.
     */
    private function recopilarContextoBD($mensaje, $usuario)
    {
        $contexto = [];

        // A. Catálogo y stock en vivo desde la vista oficial
        try {
            $stmt = $this->conexion->query("
                SELECT nombre, marca, categoria, unidad_medida, unidades_por_empaque, 
                       precio_unitario, stock_total, estado_stock 
                FROM vista_catalogo_disponible 
                ORDER BY categoria ASC, nombre ASC
            ");
            $productos = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $contexto["catalogo_en_vivo"] = $productos;
        } catch (Exception $e) {
            $contexto["catalogo_en_vivo"] = [];
        }

        // B. Información si el usuario autenticado es un Bodeguero
        if ($usuario && ($usuario["rol"] ?? "") === "BODEGUERO") {
            try {
                $stmt = $this->conexion->prepare("
                    SELECT c.codigo_compra, c.total, c.estado_pedido, c.fecha_compra,
                           COALESCE(r.estado_entrega, 'EN PREPARACIÓN') AS estado_entrega
                    FROM compras c
                    LEFT JOIN guias_remision g ON g.compra_id = c.compra_id
                    LEFT JOIN rutas_despacho r ON r.guia_id = g.guia_id
                    WHERE c.bodeguero_id = ?
                    ORDER BY c.fecha_compra DESC 
                    LIMIT 3
                ");
                $stmt->execute([$usuario["id"]]);
                $contexto["ultimos_pedidos_usuario"] = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } catch (Exception $e) {
                $contexto["ultimos_pedidos_usuario"] = [];
            }
        }

        // C. Búsqueda de pedido por código específico si se menciona en el mensaje (ej: COM-2026-0001)
        if (preg_match('/COM-[\w\-]+/i', $mensaje, $coincidencias)) {
            $codigoBuscado = strtoupper($coincidencias[0]);
            try {
                $stmt = $this->conexion->prepare("
                    SELECT c.codigo_compra, c.total, c.estado_pedido, c.fecha_compra,
                           COALESCE(r.estado_entrega, 'EN PREPARACIÓN') AS estado_entrega
                    FROM compras c
                    LEFT JOIN guias_remision g ON g.compra_id = c.compra_id
                    LEFT JOIN rutas_despacho r ON r.guia_id = g.guia_id
                    WHERE UPPER(c.codigo_compra) = ?
                    LIMIT 1
                ");
                $stmt->execute([$codigoBuscado]);
                $pedidoEncontrado = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($pedidoEncontrado) {
                    $contexto["pedido_consultado_por_codigo"] = $pedidoEncontrado;
                }
            } catch (Exception $e) {
                // Silencioso
            }
        }

        return $contexto;
    }

    /**
     * Realiza la llamada a la API de Google Gemini (modelos flash recomendados)
     */
    private function llamarGemini($mensaje, $historial, $contextoBD, $usuario)
    {
        $apiKey = getenv("GEMINI_API_KEY") ?: ($_ENV["GEMINI_API_KEY"] ?? "");
        if (!$apiKey) {
            return "El servicio del asistente no tiene configurada la clave de API (GEMINI_API_KEY). Por favor contacta al administrador.";
        }

        $systemPrompt = $this->construirSystemPrompt($contextoBD, $usuario);

        // Construir contenido para Gemini
        $contents = [];

        // Historial previo
        foreach ($historial as $h) {
            $rol = (isset($h["rol"]) && $h["rol"] === "bot") ? "model" : "user";
            $texto = isset($h["texto"]) ? trim($h["texto"]) : "";
            if ($texto !== "") {
                $contents[] = [
                    "role" => $rol,
                    "parts" => [["text" => $texto]]
                ];
            }
        }

        // Mensaje actual del usuario
        $contents[] = [
            "role" => "user",
            "parts" => [["text" => $mensaje]]
        ];

        $payload = [
            "systemInstruction" => [
                "parts" => [
                    ["text" => $systemPrompt]
                ]
            ],
            "contents" => $contents,
            "generationConfig" => [
                "temperature" => 0.2, // Baja temperatura para evitar inventos
                "maxOutputTokens" => 800
            ]
        ];

        // Intentar con gemini-3.5-flash-lite, fallback a gemini-3.8-flash
        $modelos = ["gemini-3.5-flash-lite", "gemini-3.8-flash"];
        $ultimoError = "";

        foreach ($modelos as $modelo) {
            $url = "https://generativelanguage.googleapis.com/v1beta/models/{$modelo}:generateContent?key=" . urlencode($apiKey);

            $jsonBody = json_encode($payload, JSON_UNESCAPED_UNICODE);

            $resultado = $this->ejecutarHttp($url, $jsonBody);

            if ($resultado["status"] === 200 && !empty($resultado["body"])) {
                $respuestaDecodificada = json_decode($resultado["body"], true);
                $texto = $respuestaDecodificada["candidates"][0]["content"]["parts"][0]["text"] ?? null;
                if ($texto !== null && trim($texto) !== "") {
                    return trim($texto);
                }
            } else {
                $ultimoError = "HTTP {$resultado['status']}: " . substr($resultado["body"], 0, 200);
            }
        }

        return "Lo siento, en este momento el servicio del asistente está experimentando alta demanda. Por favor intenta de nuevo en unos instantes. (" . htmlspecialchars($ultimoError) . ")";
    }

    /**
     * Construye el prompt con las políticas de Abastece+ y la inyección de datos de la BD en tiempo real.
     */
    private function construirSystemPrompt($contextoBD, $usuario)
    {
        $nombreUsuario = $usuario ? ($usuario["correo"] ?? "Cliente registrado") : "Visitante";
        $rolUsuario = $usuario ? ($usuario["rol"] ?? "PÚBLICO") : "INVITADO";

        $catalogoTexto = "";
        if (!empty($contextoBD["catalogo_en_vivo"])) {
            $lineas = [];
            foreach ($contextoBD["catalogo_en_vivo"] as $p) {
                $lineas[] = "- {$p['nombre']} ({$p['marca']}) | Cat: {$p['categoria']} | Empaque: {$p['unidad_medida']} | Precio: S/ {$p['precio_unitario']} | Stock: {$p['stock_total']} ({$p['estado_stock']})";
            }
            $catalogoTexto = implode("\n", $lineas);
        } else {
            $catalogoTexto = "No hay productos disponibles actualmente en el catálogo.";
        }

        $pedidosTexto = "";
        if (!empty($contextoBD["ultimos_pedidos_usuario"])) {
            $pedidosTexto .= "\nÚLTIMOS PEDIDOS DEL USUARIO AUTENTICADO:\n";
            foreach ($contextoBD["ultimos_pedidos_usuario"] as $ped) {
                $pedidosTexto .= "- Código: {$ped['codigo_compra']} | Total: S/ {$ped['total']} | Estado: {$ped['estado_pedido']} | Entrega: {$ped['estado_entrega']} | Fecha: {$ped['fecha_compra']}\n";
            }
        }

        if (!empty($contextoBD["pedido_consultado_por_codigo"])) {
            $ped = $contextoBD["pedido_consultado_por_codigo"];
            $pedidosTexto .= "\nINFORMACIÓN DEL PEDIDO CONSULTADO ESPECÍFICAMENTE:\n";
            $pedidosTexto .= "- Código: {$ped['codigo_compra']} | Total: S/ {$ped['total']} | Estado: {$ped['estado_pedido']} | Despacho: {$ped['estado_entrega']} | Fecha: {$ped['fecha_compra']}\n";
        }

        return <<<PROMPT
Eres "Abas el capibara", el asistente virtual oficial de la plataforma mayorista "Abastece+".
Tu objetivo es ayudar a bodegueros, comerciantes y visitantes con información precisa sobre compras, productos, precios, entregas y pedidos.

POLÍTICAS Y REGLAS DE RESPUESTA:
1. CERO EMOJIS: Prohibido usar emojis o emoticonos en cualquier respuesta. Mantén un estilo sobrio, limpio y minimalista.
2. VERACIDAD ABSOLUTA: Basa tus respuestas ÚNICAMENTE en la información y catálogo en tiempo real que se te proporciona a continuación. NUNCA inventes productos, marcas, precios ni estados de stock que no figuren en los datos.
3. PRECIOS Y MONEDA: Todos los precios están expresados en Soles peruanos (S/).
4. DISPONIBILIDAD: Si un producto tiene stock 0 o no aparece en la lista, indica de forma directa que no se encuentra disponible o está agotado.
5. MÉTODOS DE PAGO: En Abastece+ se aceptan tarjetas de crédito/débito (Visa, Mastercard), transferencia bancaria y pagos autorizados del sistema.
6. DESPACHO Y ENTREGAS: Los pedidos son preparados por Logística y despachados mediante transportistas oficiales con Guía de Remisión.
7. INCIDENCIAS: Si un cliente tiene una queja o inconformidad con su pedido, indícale registrar una incidencia desde su panel de usuario.
8. TONO: Directo, claro, conciso y profesional. Usa viñetas con guiones y negritas simples.
9. LÍMITES: Si preguntan sobre temas ajenos a Abastece+, indica brevemente que solo puedes atender dudas sobre Abastece+.

INFORMACIÓN DEL USUARIO ACTUAL:
- Tipo: {$rolUsuario}
- Identificador: {$nombreUsuario}

DATOS EN TIEMPO REAL DESDE LA BASE DE DATOS DE ABASTECE+:
=== CATÁLOGO Y STOCK ACTUALIZADO AL INSTANTE ===
{$catalogoTexto}
{$pedidosTexto}
PROMPT;
    }

    /**
     * Genera botones de sugerencias rápidas para enriquecer la experiencia en frontend
     */
    private function generarSugerencias($mensaje)
    {
        $mensajeLower = function_exists("mb_strtolower") ? mb_strtolower($mensaje, "UTF-8") : strtolower($mensaje);

        if (str_contains($mensajeLower, "hola") || str_contains($mensajeLower, "buenas") || str_contains($mensajeLower, "inicio")) {
            return [
                "¿Qué productos tienen en oferta o catálogo?",
                "¿Cómo hago un pedido?",
                "¿Cuáles son los métodos de pago?"
            ];
        }

        if (str_contains($mensajeLower, "precio") || str_contains($mensajeLower, "producto") || str_contains($mensajeLower, "stock")) {
            return [
                "¿Tienen Aceite Primor o Abarrotes?",
                "¿Cuánto es el pedido mínimo?",
                "¿Cuánto demora la entrega?"
            ];
        }

        if (str_contains($mensajeLower, "pedido") || str_contains($mensajeLower, "com-") || str_contains($mensajeLower, "entrega")) {
            return [
                "¿Cómo consultar el estado de mi pedido?",
                "¿Qué hago si mi pedido llegó incompleto?",
                "Volver al catálogo"
            ];
        }

        return [
            "Ver catálogo disponible",
            "¿Cuáles son las formas de entrega?",
            "Consultar mi pedido"
        ];
    }

    /**
     * Valida de manera segura y no bloqueante si hay un token válido en la solicitud
     */
    private function obtenerUsuarioOpcional()
    {
        $authHeader = null;
        if (function_exists("getallheaders")) {
            foreach (getallheaders() as $nombre => $valor) {
                if (strcasecmp($nombre, "Authorization") === 0) {
                    $authHeader = trim($valor);
                    break;
                }
            }
        }

        if (!$authHeader) {
            foreach (["HTTP_AUTHORIZATION", "REDIRECT_HTTP_AUTHORIZATION"] as $k) {
                if (!empty($_SERVER[$k])) {
                    $authHeader = trim($_SERVER[$k]);
                    break;
                }
            }
        }

        if (!$authHeader || strpos($authHeader, "Bearer ") !== 0) {
            return null;
        }

        $token = substr($authHeader, 7);
        $partes = explode(".", $token);
        if (count($partes) !== 2) {
            return null;
        }

        $payloadBase64 = $partes[0];
        $firmaRecibida = $partes[1];
        $secret = getenv("AUTH_SECRET") ?: "ABASTECEPLUS_SECRET_2026";

        $firmaEsperada = hash_hmac("sha256", $payloadBase64, $secret);
        if (!hash_equals($firmaEsperada, $firmaRecibida)) {
            return null;
        }

        $payloadJson = base64_decode(strtr($payloadBase64, "-_", "+/"));
        $payload = json_decode($payloadJson, true);

        if (!$payload || !isset($payload["exp"]) || time() > $payload["exp"]) {
            return null;
        }

        return $payload;
    }

    /**
     * Realiza petición HTTP POST compatible con cURL o fallback a stream context
     */
    private function ejecutarHttp($url, $jsonBody)
    {
        if (extension_loaded("curl")) {
            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_POST => true,
                CURLOPT_HTTPHEADER => [
                    "Content-Type: application/json"
                ],
                CURLOPT_POSTFIELDS => $jsonBody,
                CURLOPT_TIMEOUT => 15,
                CURLOPT_SSL_VERIFYPEER => false // Evitar problemas de certificados CA en entornos locales Windows
            ]);

            $body = curl_exec($ch);
            $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);

            return ["status" => $status, "body" => $body];
        }

        // Fallback a stream context si cURL no está disponible
        $context = stream_context_create([
            "http" => [
                "method" => "POST",
                "header" => "Content-Type: application/json\r\n",
                "content" => $jsonBody,
                "ignore_errors" => true,
                "timeout" => 15
            ],
            "ssl" => [
                "verify_peer" => false,
                "verify_peer_name" => false
            ]
        ]);

        $body = @file_get_contents($url, false, $context);
        $status = 200;
        $headers = function_exists("http_get_last_response_headers") 
            ? http_get_last_response_headers() 
            : null;
        if (!empty($headers) && !empty($headers[0])) {
            preg_match('{HTTP\/\S*\s(\d{3})}', $headers[0], $match);
            $status = isset($match[1]) ? (int)$match[1] : 200;
        }

        return ["status" => $status, "body" => $body];
    }
}
