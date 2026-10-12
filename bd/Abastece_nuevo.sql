-- Abastece+ | Estructura completa | MySQL 8+
-- Instalación nueva: no reemplaza ni elimina una base existente.
CREATE DATABASE abastece_nuevo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE abastece_nuevo;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE `atencion_incidencias` (
  `incidencia_id` int NOT NULL AUTO_INCREMENT,
  `bodeguero_id` int NOT NULL,
  `compra_id` int DEFAULT NULL,
  `gestor_usuario_id` int DEFAULT NULL,
  `tipo_incidencia` enum('PRODUCTO_DANADO','PEDIDO_INCOMPLETO','PRODUCTO_PROXIMO_VENCER','DEMORA_ENTREGA','OTRO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_atencion` enum('ABIERTO','EN_REVISION','SOLUCIONADO','RECHAZADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ABIERTO',
  `conformidad_final` text COLLATE utf8mb4_unicode_ci,
  `fecha_reporte` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_solucion` datetime DEFAULT NULL,
  PRIMARY KEY (`incidencia_id`),
  KEY `bodeguero_id` (`bodeguero_id`),
  KEY `compra_id` (`compra_id`,`bodeguero_id`),
  KEY `gestor_usuario_id` (`gestor_usuario_id`),
  CONSTRAINT `atencion_incidencias_ibfk_1` FOREIGN KEY (`bodeguero_id`) REFERENCES `bodegueros` (`bodeguero_id`),
  CONSTRAINT `atencion_incidencias_ibfk_2` FOREIGN KEY (`compra_id`, `bodeguero_id`) REFERENCES `compras` (`compra_id`, `bodeguero_id`),
  CONSTRAINT `atencion_incidencias_ibfk_3` FOREIGN KEY (`gestor_usuario_id`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `atencion_seguimiento` (
  `incidencia_id` int NOT NULL,
  `requiere_reposicion` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_respuesta` date DEFAULT NULL,
  `cliente_conforme` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_conformidad` date DEFAULT NULL,
  PRIMARY KEY (`incidencia_id`),
  CONSTRAINT `atencion_seguimiento_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `atencion_incidencias` (`incidencia_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `bodegueros` (
  `documento_identidad` char(8) DEFAULT NULL,
  `bodeguero_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruc` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_establecimiento` enum('BODEGA','MINIMARKET','MARKET_LOCAL','OTRO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_establecimiento_otro` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_comercial` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `linea_credito_max` decimal(10,2) NOT NULL DEFAULT '0.00',
  `credito_utilizado` decimal(10,2) NOT NULL DEFAULT '0.00',
  `email_verificado` tinyint(1) DEFAULT '0',
  `token_verificacion_correo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verificado_en` timestamp NULL DEFAULT NULL,
  `estado_cuenta` enum('PENDIENTE_VERIFICACION','ACTIVO','BLOQUEADO') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDIENTE_VERIFICACION',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`bodeguero_id`),
  UNIQUE KEY `correo` (`correo`),
  UNIQUE KEY `ruc` (`ruc`),
  CONSTRAINT `chk_tipo_establecimiento_otro` CHECK ((((`tipo_establecimiento` = _utf8mb4'OTRO') and (`tipo_establecimiento_otro` is not null)) or ((`tipo_establecimiento` <> _utf8mb4'OTRO') and (`tipo_establecimiento_otro` is null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `categorias` (
  `categoria_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`categoria_id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `compras` (
  `compra_id` int NOT NULL AUTO_INCREMENT,
  `codigo_compra` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bodeguero_id` int NOT NULL,
  `direccion_id` int NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `estado_pedido` enum('PENDIENTE','PREPARANDO','DESPACHADO','ENTREGADO','CANCELADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `fecha_compra` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`compra_id`),
  UNIQUE KEY `codigo_compra` (`codigo_compra`),
  UNIQUE KEY `uk_compra_bodeguero` (`compra_id`,`bodeguero_id`),
  KEY `bodeguero_id` (`bodeguero_id`),
  KEY `direccion_id` (`direccion_id`,`bodeguero_id`),
  CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`bodeguero_id`) REFERENCES `bodegueros` (`bodeguero_id`),
  CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`direccion_id`, `bodeguero_id`) REFERENCES `direcciones` (`direccion_id`, `bodeguero_id`),
  CONSTRAINT `chk_total_compra` CHECK (((`subtotal` >= 0) and (`igv` >= 0) and (`total` = (`subtotal` + `igv`))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `comprobantes_pago` (
  `comprobante_id` int NOT NULL AUTO_INCREMENT,
  `compra_id` int NOT NULL,
  `tipo_comprobante` enum('FACTURA_ELECTRONICA','BOLETA_ELECTRONICA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `serie` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correlativo` int NOT NULL,
  `es_simulado` tinyint(1) NOT NULL DEFAULT '1',
  `ruc_emisor` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruc_receptor` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `metodo_pago` enum('TARJETA','YAPE','PLIN','TRANSFERENCIA_BANCARIA','EFECTIVO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo_operacion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comprobante_id`),
  UNIQUE KEY `compra_id` (`compra_id`),
  UNIQUE KEY `uk_comprobante_numero` (`tipo_comprobante`,`serie`,`correlativo`),
  CONSTRAINT `comprobantes_pago_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`compra_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `conformidades_producto` (
  `conformidad_id` int NOT NULL AUTO_INCREMENT,
  `detalle_compra_id` int NOT NULL,
  `estado` enum('PENDIENTE','CONFORME','NO_CONFORME') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `revisado_por` int DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conformidad_id`),
  UNIQUE KEY `detalle_compra_id` (`detalle_compra_id`),
  KEY `revisado_por` (`revisado_por`),
  CONSTRAINT `conformidades_producto_ibfk_1` FOREIGN KEY (`detalle_compra_id`) REFERENCES `detalle_compras` (`detalle_compra_id`),
  CONSTRAINT `conformidades_producto_ibfk_2` FOREIGN KEY (`revisado_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `detalle_compras` (
  `detalle_compra_id` int NOT NULL AUTO_INCREMENT,
  `compra_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `lote_id` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `total_linea` decimal(10,2) NOT NULL,
  PRIMARY KEY (`detalle_compra_id`),
  KEY `compra_id` (`compra_id`),
  KEY `producto_id` (`producto_id`),
  KEY `lote_id` (`lote_id`,`producto_id`),
  CONSTRAINT `detalle_compras_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`compra_id`) ON DELETE CASCADE,
  CONSTRAINT `detalle_compras_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`),
  CONSTRAINT `detalle_compras_ibfk_3` FOREIGN KEY (`lote_id`, `producto_id`) REFERENCES `inventario_lotes` (`lote_id`, `producto_id`),
  CONSTRAINT `chk_cantidad_compra` CHECK ((`cantidad` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `direcciones` (
  `direccion_id` int NOT NULL AUTO_INCREMENT,
  `bodeguero_id` int NOT NULL,
  `departamento` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Lima',
  `provincia` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Lima',
  `distrito` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion_exacta` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `referencia` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zona_reparto` enum('LIMA_CENTRO','LIMA_NORTE','LIMA_SUR','LIMA_ESTE','CALLAO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo_postal` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`direccion_id`),
  UNIQUE KEY `uk_direccion_bodeguero` (`direccion_id`,`bodeguero_id`),
  KEY `bodeguero_id` (`bodeguero_id`),
  CONSTRAINT `direcciones_ibfk_1` FOREIGN KEY (`bodeguero_id`) REFERENCES `bodegueros` (`bodeguero_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `documento_secuencias` (
  `serie` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ultimo` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`serie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `guias_remision` (
  `guia_id` int NOT NULL AUTO_INCREMENT,
  `compra_id` int NOT NULL,
  `codigo_guia` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_bultos` int NOT NULL,
  `peso_total_kg` decimal(8,2) NOT NULL,
  `costo_total` decimal(10,2) NOT NULL,
  `detalle_carga` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `emitida_por` int DEFAULT NULL,
  `fecha_emision` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`guia_id`),
  UNIQUE KEY `compra_id` (`compra_id`),
  UNIQUE KEY `codigo_guia` (`codigo_guia`),
  KEY `emitida_por` (`emitida_por`),
  CONSTRAINT `guias_remision_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`compra_id`) ON DELETE CASCADE,
  CONSTRAINT `guias_remision_ibfk_2` FOREIGN KEY (`emitida_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `incidencia_detalles` (
  `incidencia_id` int NOT NULL,
  `detalle_compra_id` int DEFAULT NULL,
  `prioridad` enum('BAJA','MEDIA','ALTA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MEDIA',
  `cantidad_afectada` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`incidencia_id`),
  KEY `detalle_compra_id` (`detalle_compra_id`),
  CONSTRAINT `incidencia_detalles_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `atencion_incidencias` (`incidencia_id`),
  CONSTRAINT `incidencia_detalles_ibfk_2` FOREIGN KEY (`detalle_compra_id`) REFERENCES `detalle_compras` (`detalle_compra_id`),
  CONSTRAINT `incidencia_detalles_chk_1` CHECK ((`cantidad_afectada` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `incidencia_evidencias` (
  `evidencia_id` int NOT NULL AUTO_INCREMENT,
  `incidencia_id` int NOT NULL,
  `archivo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_original` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`evidencia_id`),
  KEY `incidencia_id` (`incidencia_id`),
  CONSTRAINT `incidencia_evidencias_ibfk_1` FOREIGN KEY (`incidencia_id`) REFERENCES `atencion_incidencias` (`incidencia_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `inventario_lotes` (
  `lote_id` int NOT NULL AUTO_INCREMENT,
  `producto_id` int NOT NULL,
  `proveedor_id` int NOT NULL,
  `numero_lote` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_ingreso` date NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `stock_ingresado` int NOT NULL,
  `stock_disponible` int NOT NULL,
  `ubicacion_almacen` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registrado_por` int DEFAULT NULL,
  PRIMARY KEY (`lote_id`),
  UNIQUE KEY `uk_lote_producto` (`lote_id`,`producto_id`),
  KEY `producto_id` (`producto_id`),
  KEY `proveedor_id` (`proveedor_id`),
  KEY `registrado_por` (`registrado_por`),
  CONSTRAINT `inventario_lotes_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`),
  CONSTRAINT `inventario_lotes_ibfk_2` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`proveedor_id`),
  CONSTRAINT `inventario_lotes_ibfk_3` FOREIGN KEY (`registrado_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`),
  CONSTRAINT `chk_stock_ingresado` CHECK ((`stock_ingresado` >= 0)),
  CONSTRAINT `chk_stock_lote` CHECK (((`stock_disponible` >= 0) and (`stock_disponible` <= `stock_ingresado`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mapa_busquedas` (
  `consulta_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultados` json NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`consulta_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `movimientos_stock` (
  `movimiento_id` int NOT NULL AUTO_INCREMENT,
  `lote_id` int NOT NULL,
  `variacion` int NOT NULL,
  `motivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registrado_por` int NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`movimiento_id`),
  KEY `lote_id` (`lote_id`),
  KEY `registrado_por` (`registrado_por`),
  CONSTRAINT `movimientos_stock_ibfk_1` FOREIGN KEY (`lote_id`) REFERENCES `inventario_lotes` (`lote_id`),
  CONSTRAINT `movimientos_stock_ibfk_2` FOREIGN KEY (`registrado_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pagos_compra` (
  `compra_id` int NOT NULL,
  `metodo_pago` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo_operacion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registrado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`compra_id`),
  CONSTRAINT `pagos_compra_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`compra_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `producto_imagenes` (
  `imagen_id` int NOT NULL AUTO_INCREMENT,
  `producto_id` int NOT NULL,
  `ruta_imagen` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `texto_alternativo` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT '0',
  `principal_unica` tinyint GENERATED ALWAYS AS (if(`es_principal`,1,NULL)) STORED,
  `subido_por` int DEFAULT NULL,
  `subido_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`imagen_id`),
  UNIQUE KEY `uk_imagen_principal` (`producto_id`,`principal_unica`),
  KEY `subido_por` (`subido_por`),
  CONSTRAINT `producto_imagenes_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`) ON DELETE CASCADE,
  CONSTRAINT `producto_imagenes_ibfk_2` FOREIGN KEY (`subido_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `productos` (
  `producto_id` int NOT NULL AUTO_INCREMENT,
  `categoria_id` int NOT NULL,
  `codigo_interno` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Uso interno de logistica: no se expone en el catalogo publico',
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `peso_kg` decimal(10,3) NOT NULL DEFAULT '0.000',
  `marca` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unidad_medida` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unidades_por_empaque` int NOT NULL DEFAULT '1',
  `precio_unitario` decimal(10,2) NOT NULL,
  `stock_minimo` int NOT NULL DEFAULT '0',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `actualizado_por` int DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`producto_id`),
  UNIQUE KEY `codigo_interno` (`codigo_interno`),
  KEY `categoria_id` (`categoria_id`),
  KEY `actualizado_por` (`actualizado_por`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`categoria_id`),
  CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`actualizado_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`),
  CONSTRAINT `chk_precio_unitario` CHECK ((`precio_unitario` > 0)),
  CONSTRAINT `chk_unidades_empaque` CHECK ((`unidades_por_empaque` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `productos_favoritos` (
  `bodeguero_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bodeguero_id`,`producto_id`),
  KEY `fk_favorito_producto` (`producto_id`),
  CONSTRAINT `fk_favorito_bodeguero` FOREIGN KEY (`bodeguero_id`) REFERENCES `bodegueros` (`bodeguero_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorito_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `proveedores` (
  `contacto_dni` char(8) DEFAULT NULL,
  `proveedor_id` int NOT NULL AUTO_INCREMENT,
  `ruc` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre_comercial` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contacto_nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion_fiscal` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distrito` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `puntaje` decimal(3,2) NOT NULL DEFAULT '5.00',
  `puntaje_actualizado_por` int DEFAULT NULL,
  `puntaje_actualizado_en` timestamp NULL DEFAULT NULL,
  `tiempo_promedio_entrega_hrs` int DEFAULT '24',
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`proveedor_id`),
  UNIQUE KEY `ruc` (`ruc`),
  UNIQUE KEY `correo` (`correo`),
  KEY `puntaje_actualizado_por` (`puntaje_actualizado_por`),
  CONSTRAINT `proveedores_ibfk_1` FOREIGN KEY (`puntaje_actualizado_por`) REFERENCES `usuarios_internos` (`usuario_interno_id`),
  CONSTRAINT `chk_puntaje` CHECK (((`puntaje` >= 0.00) and (`puntaje` <= 5.00)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `rutas_despacho` (
  `ruta_id` int NOT NULL AUTO_INCREMENT,
  `guia_id` int NOT NULL,
  `transportista_id` int NOT NULL,
  `vehiculo_placa` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `punto_partida` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion_destino_id` int NOT NULL,
  `descripcion_ruta` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_entrega` enum('ASIGNADO','EN_TRAYECTO','ENTREGADO','FALLIDO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ASIGNADO',
  `hora_salida` datetime DEFAULT NULL,
  `hora_entrega` datetime DEFAULT NULL,
  `notas_entrega` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`ruta_id`),
  UNIQUE KEY `guia_id` (`guia_id`),
  KEY `transportista_id` (`transportista_id`),
  KEY `direccion_destino_id` (`direccion_destino_id`),
  CONSTRAINT `rutas_despacho_ibfk_1` FOREIGN KEY (`guia_id`) REFERENCES `guias_remision` (`guia_id`) ON DELETE CASCADE,
  CONSTRAINT `rutas_despacho_ibfk_2` FOREIGN KEY (`transportista_id`) REFERENCES `usuarios_internos` (`usuario_interno_id`),
  CONSTRAINT `rutas_despacho_ibfk_3` FOREIGN KEY (`direccion_destino_id`) REFERENCES `direcciones` (`direccion_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `rutas_gps` (
  `ruta_id` int NOT NULL,
  `transportista_id` int NOT NULL,
  `latitud` decimal(10,7) NOT NULL,
  `longitud` decimal(10,7) NOT NULL,
  `precision_m` double NOT NULL,
  `capturado_ms` bigint NOT NULL,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ruta_id`),
  KEY `transportista_id` (`transportista_id`),
  CONSTRAINT `rutas_gps_ibfk_1` FOREIGN KEY (`ruta_id`) REFERENCES `rutas_despacho` (`ruta_id`) ON DELETE CASCADE,
  CONSTRAINT `rutas_gps_ibfk_2` FOREIGN KEY (`transportista_id`) REFERENCES `usuarios_internos` (`usuario_interno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `rutas_mapa` (
  `ruta_id` int NOT NULL,
  `origen_direccion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destino_direccion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `origen_lat` decimal(10,7) NOT NULL,
  `origen_lng` decimal(10,7) NOT NULL,
  `destino_lat` decimal(10,7) NOT NULL,
  `destino_lng` decimal(10,7) NOT NULL,
  `entrega_hasta` datetime DEFAULT NULL,
  `llegada_en` datetime DEFAULT NULL,
  `geometria` json DEFAULT NULL,
  `distancia_m` double DEFAULT NULL,
  `duracion_s` double DEFAULT NULL,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ruta_id`),
  CONSTRAINT `rutas_mapa_ibfk_1` FOREIGN KEY (`ruta_id`) REFERENCES `rutas_despacho` (`ruta_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tarjetas_prueba` (
  `tarjeta_id` int NOT NULL AUTO_INCREMENT,
  `banco` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `marca` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero` varchar(19) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ultimos_digitos` char(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `titular` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vencimiento` char(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cvv` char(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color_inicio` char(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color_fin` char(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `es_simulada` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`tarjeta_id`),
  UNIQUE KEY `numero` (`numero`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuarios_internos` (
  `documento_identidad` char(8) DEFAULT NULL,
  `usuario_interno_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('ADMINISTRADOR','TRANSPORTISTA','GESTOR_ATENCION','LOGISTICA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ultimo_acceso` datetime DEFAULT NULL,
  PRIMARY KEY (`usuario_interno_id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_stock_productos` AS select `p`.`producto_id` AS `producto_id`,`p`.`nombre` AS `nombre`,`p`.`marca` AS `marca`,`c`.`nombre` AS `categoria`,`p`.`unidad_medida` AS `unidad_medida`,`p`.`unidades_por_empaque` AS `unidades_por_empaque`,`p`.`precio_unitario` AS `precio_unitario`,`p`.`stock_minimo` AS `stock_minimo`,`p`.`activo` AS `activo`,coalesce(`s`.`stock_total`,0) AS `stock_total`,(case when (coalesce(`s`.`stock_total`,0) = 0) then 'AGOTADO' when (coalesce(`s`.`stock_total`,0) <= `p`.`stock_minimo`) then 'POR_AGOTARSE' else 'DISPONIBLE' end) AS `estado_stock`,((`p`.`activo` = true) and (coalesce(`s`.`stock_total`,0) > 0)) AS `seleccionable`,`i`.`ruta_imagen` AS `imagen_principal` from (((`productos` `p` join `categorias` `c` on((`c`.`categoria_id` = `p`.`categoria_id`))) left join (select `inventario_lotes`.`producto_id` AS `producto_id`,sum(`inventario_lotes`.`stock_disponible`) AS `stock_total` from `inventario_lotes` where ((`inventario_lotes`.`fecha_vencimiento` is null) or (`inventario_lotes`.`fecha_vencimiento` >= curdate())) group by `inventario_lotes`.`producto_id`) `s` on((`s`.`producto_id` = `p`.`producto_id`))) left join `producto_imagenes` `i` on(((`i`.`producto_id` = `p`.`producto_id`) and (`i`.`es_principal` = true))));

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_catalogo_disponible` AS select `vista_stock_productos`.`producto_id` AS `producto_id`,`vista_stock_productos`.`nombre` AS `nombre`,`vista_stock_productos`.`marca` AS `marca`,`vista_stock_productos`.`categoria` AS `categoria`,`vista_stock_productos`.`unidad_medida` AS `unidad_medida`,`vista_stock_productos`.`unidades_por_empaque` AS `unidades_por_empaque`,`vista_stock_productos`.`precio_unitario` AS `precio_unitario`,`vista_stock_productos`.`stock_total` AS `stock_total`,`vista_stock_productos`.`estado_stock` AS `estado_stock`,`vista_stock_productos`.`imagen_principal` AS `imagen_principal` from `vista_stock_productos` where (`vista_stock_productos`.`activo` = true);

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_compras_logistica` AS select `c`.`compra_id` AS `compra_id`,`c`.`codigo_compra` AS `codigo_compra`,`g`.`codigo_guia` AS `codigo_guia`,`b`.`nombre_comercial` AS `cliente`,`d`.`distrito` AS `distrito`,`d`.`zona_reparto` AS `zona_reparto`,`r`.`total_items` AS `total_items`,`r`.`total_unidades` AS `total_unidades`,`c`.`total` AS `total`,`c`.`fecha_compra` AS `fecha_compra`,`ru`.`estado_entrega` AS `estado_entrega` from (((((`compras` `c` join `bodegueros` `b` on((`b`.`bodeguero_id` = `c`.`bodeguero_id`))) join `direcciones` `d` on((`d`.`direccion_id` = `c`.`direccion_id`))) left join `guias_remision` `g` on((`g`.`compra_id` = `c`.`compra_id`))) left join `rutas_despacho` `ru` on((`ru`.`guia_id` = `g`.`guia_id`))) left join (select `detalle_compras`.`compra_id` AS `compra_id`,count(0) AS `total_items`,sum(`detalle_compras`.`cantidad`) AS `total_unidades` from `detalle_compras` group by `detalle_compras`.`compra_id`) `r` on((`r`.`compra_id` = `c`.`compra_id`)));

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_guia_transportista` AS select `g`.`guia_id` AS `guia_id`,`ru`.`ruta_id` AS `ruta_id`,`ru`.`transportista_id` AS `transportista_id`,`g`.`codigo_guia` AS `codigo_guia`,`c`.`codigo_compra` AS `codigo_compra`,`b`.`nombre_comercial` AS `cliente`,`b`.`telefono` AS `telefono_cliente`,concat(`d`.`direccion_exacta`,', ',`d`.`distrito`) AS `direccion_entrega`,`d`.`referencia` AS `referencia`,`d`.`zona_reparto` AS `zona_reparto`,`ru`.`descripcion_ruta` AS `descripcion_ruta`,`ru`.`punto_partida` AS `punto_partida`,`ru`.`vehiculo_placa` AS `vehiculo_placa`,concat(`u`.`nombre`,' ',`u`.`apellidos`) AS `transportista`,`g`.`total_bultos` AS `total_bultos`,`g`.`peso_total_kg` AS `peso_total_kg`,`g`.`costo_total` AS `costo_total`,`g`.`detalle_carga` AS `detalle_carga`,`g`.`observaciones` AS `observaciones`,`ru`.`estado_entrega` AS `estado_entrega`,`ru`.`hora_salida` AS `hora_salida`,`ru`.`hora_entrega` AS `hora_entrega` from (((((`guias_remision` `g` join `compras` `c` on((`c`.`compra_id` = `g`.`compra_id`))) join `bodegueros` `b` on((`b`.`bodeguero_id` = `c`.`bodeguero_id`))) join `direcciones` `d` on((`d`.`direccion_id` = `c`.`direccion_id`))) left join `rutas_despacho` `ru` on((`ru`.`guia_id` = `g`.`guia_id`))) left join `usuarios_internos` `u` on((`u`.`usuario_interno_id` = `ru`.`transportista_id`)));

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_detalle_guia_transportista` AS select `g`.`codigo_guia` AS `codigo_guia`,`p`.`nombre` AS `producto`,`p`.`marca` AS `marca`,`p`.`unidad_medida` AS `unidad_medida`,`dc`.`cantidad` AS `cantidad`,(`dc`.`cantidad` * `p`.`unidades_por_empaque`) AS `unidades_totales`,`dc`.`precio_unitario` AS `precio_unitario`,`dc`.`total_linea` AS `total_linea`,`l`.`numero_lote` AS `numero_lote`,`l`.`ubicacion_almacen` AS `ubicacion_almacen` from (((`guias_remision` `g` join `detalle_compras` `dc` on((`dc`.`compra_id` = `g`.`compra_id`))) join `productos` `p` on((`p`.`producto_id` = `dc`.`producto_id`))) join `inventario_lotes` `l` on((`l`.`lote_id` = `dc`.`lote_id`)));

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_entregas_administracion` AS select `ru`.`ruta_id` AS `ruta_id`,`g`.`codigo_guia` AS `codigo_guia`,`c`.`codigo_compra` AS `codigo_compra`,`b`.`nombre_comercial` AS `cliente`,`ru`.`descripcion_ruta` AS `descripcion_ruta`,`d`.`zona_reparto` AS `zona_reparto`,concat(`u`.`nombre`,' ',`u`.`apellidos`) AS `transportista`,`ru`.`vehiculo_placa` AS `vehiculo_placa`,`ru`.`estado_entrega` AS `estado_entrega`,`ru`.`hora_salida` AS `hora_salida`,`ru`.`hora_entrega` AS `hora_entrega`,`c`.`total` AS `total` from (((((`rutas_despacho` `ru` join `guias_remision` `g` on((`g`.`guia_id` = `ru`.`guia_id`))) join `compras` `c` on((`c`.`compra_id` = `g`.`compra_id`))) join `bodegueros` `b` on((`b`.`bodeguero_id` = `c`.`bodeguero_id`))) join `direcciones` `d` on((`d`.`direccion_id` = `ru`.`direccion_destino_id`))) join `usuarios_internos` `u` on((`u`.`usuario_interno_id` = `ru`.`transportista_id`)));

CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `vista_seguimiento_bodeguero` AS select `c`.`bodeguero_id` AS `bodeguero_id`,`c`.`codigo_compra` AS `codigo_compra`,`c`.`fecha_compra` AS `fecha_compra`,`c`.`total` AS `total`,coalesce(`ru`.`estado_entrega`,'ASIGNADO') AS `estado_entrega`,`ru`.`hora_entrega` AS `hora_entrega` from ((`compras` `c` left join `guias_remision` `g` on((`g`.`compra_id` = `c`.`compra_id`))) left join `rutas_despacho` `ru` on((`ru`.`guia_id` = `g`.`guia_id`)));
