<?php

require_once __DIR__ . '/../utils/Response.php';

class AuthMiddleware
{
    private static function secret()
    {
        return getenv("AUTH_SECRET") ?: "ABASTECEPLUS_SECRET_2026";
    }

    // Crear token
    public static function crearToken($usuario)
    {
        $payload = [
            "id" => $usuario["usuario_interno_id"],
            "correo" => $usuario["correo"],
            "rol" => $usuario["rol"],
            "exp" => time() + (60 * 60 * 8)
        ];

        $payloadBase64 = self::base64UrlEncode(
            json_encode($payload)
        );

        $firma = hash_hmac(
            "sha256",
            $payloadBase64,
            self::secret()
        );

        return $payloadBase64 . "." . $firma;
    }

    // Validar token
    public static function verificarToken()
    {
        $authorization = self::obtenerAuthorization();

        if ($authorization === null || $authorization === "") {
            Response::json([
                "mensaje" => "Token de acceso requerido"
            ], 401);
            exit;
        }

        if (strpos($authorization, "Bearer ") !== 0) {
            Response::json([
                "mensaje" => "Formato de token inválido"
            ], 401);
            exit;
        }

        $token = substr($authorization, 7);

        $partes = explode(".", $token);

        if (count($partes) !== 2) {
            Response::json([
                "mensaje" => "Token inválido"
            ], 401);
            exit;
        }

        $payloadBase64 = $partes[0];
        $firmaRecibida = $partes[1];

        $firmaEsperada = hash_hmac(
            "sha256",
            $payloadBase64,
            self::secret()
        );

        if (!hash_equals($firmaEsperada, $firmaRecibida)) {
            Response::json([
                "mensaje" => "Token inválido"
            ], 401);
            exit;
        }

        $payload = json_decode(
            self::base64UrlDecode($payloadBase64),
            true
        );

        if (!$payload) {
            Response::json([
                "mensaje" => "Token inválido"
            ], 401);
            exit;
        }

        if (time() > $payload["exp"]) {
            Response::json([
                "mensaje" => "Token expirado"
            ], 401);
            exit;
        }

        global $conexion;
        $interno = ($payload["rol"] ?? "") !== "BODEGUERO";
        $sql = $interno ? "SELECT rol FROM usuarios_internos WHERE usuario_interno_id=? AND activo=1" : "SELECT 'BODEGUERO' FROM bodegueros WHERE bodeguero_id=? AND estado_cuenta<>'BLOQUEADO'";
        $stmt = $conexion->prepare($sql);
        $stmt->execute([$payload["id"] ?? 0]);
        if ($stmt->fetchColumn() !== ($payload["rol"] ?? null)) {
            Response::json(["mensaje" => "La sesión ya no está autorizada"], 401); exit;
        }
        return $payload;
    }
    // CREAR TOKEN PARA BODEGUERO
    public static function crearTokenBodeguero($bodeguero)
    {
        $payload = [
            "id" => $bodeguero["bodeguero_id"],
            "correo" => $bodeguero["correo"],
            "rol" => "BODEGUERO",
            "exp" => time() + (60 * 60 * 8)
        ];

        $payloadBase64 = self::base64UrlEncode(
            json_encode($payload)
        );

        $firma = hash_hmac(
            "sha256",
            $payloadBase64,
            self::secret()
        );

        return $payloadBase64 . "." . $firma;
    }

    // Verificar si el usuario tiene uno de los roles permitidos
    public static function permitirRoles($rolesPermitidos)
    {
        $usuario = self::verificarToken();

        if (!isset($usuario["rol"]) || !in_array($usuario["rol"], $rolesPermitidos, true)) {
            Response::json([
                "mensaje" => "No tienes permisos para realizar esta acción"
            ], 403);
            exit;
        }

        return $usuario;
    }

    // PHP y los distintos servidores web no conservan siempre la misma
    // capitalización ni exponen Authorization en el mismo lugar.
    private static function obtenerAuthorization()
    {
        if (function_exists("getallheaders")) {
            foreach (getallheaders() as $nombre => $valor) {
                if (strcasecmp($nombre, "Authorization") === 0) {
                    return trim($valor);
                }
            }
        }

        foreach (["HTTP_AUTHORIZATION", "REDIRECT_HTTP_AUTHORIZATION"] as $clave) {
            if (!empty($_SERVER[$clave])) {
                return trim($_SERVER[$clave]);
            }
        }

        return null;
    }

    private static function base64UrlEncode($data)
    {
        return rtrim(
            strtr(base64_encode($data), "+/", "-_"),
            "="
        );
    }

    private static function base64UrlDecode($data)
    {
        return base64_decode(
            strtr($data, "-_", "+/")
        );
    }
}
