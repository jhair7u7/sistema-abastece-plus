-- =============================================================================
-- BASE DE DATOS: ABASTECE+ (MAYORISTA B2B - VENTA A BODEGAS)
-- MOTOR: MySQL 8.0+ | INNODB | UTF8MB4 | SIN PROCEDIMIENTOS ALMACENADOS
-- =============================================================================

-- Instalacion inicial: se detiene si la base ya existe; no borra datos.
DROP DATABASE IF EXISTS abastece_nuevo;
CREATE DATABASE abastece_nuevo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE abastece_nuevo;

-- -----------------------------------------------------------------------------
-- 1. USUARIOS INTERNOS
-- -----------------------------------------------------------------------------
CREATE TABLE usuarios_internos (
    usuario_interno_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    rol ENUM('ADMINISTRADOR', 'TRANSPORTISTA', 'GESTOR_ATENCION', 'LOGISTICA') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. BODEGUEROS (CLIENTES)
-- -----------------------------------------------------------------------------
CREATE TABLE bodegueros (
    bodeguero_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    ruc CHAR(11) UNIQUE NOT NULL,
    tipo_establecimiento ENUM('BODEGA', 'MINIMARKET', 'MARKET_LOCAL', 'OTRO') NOT NULL,
    tipo_establecimiento_otro VARCHAR(120) NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    linea_credito_max DECIMAL(10,2) NOT NULL DEFAULT 0,
    credito_utilizado DECIMAL(10,2) NOT NULL DEFAULT 0,
    email_verificado BOOLEAN DEFAULT FALSE,
    token_verificacion_correo VARCHAR(100) NULL,
    email_verificado_en TIMESTAMP NULL,
    estado_cuenta ENUM('PENDIENTE_VERIFICACION', 'ACTIVO', 'BLOQUEADO') DEFAULT 'PENDIENTE_VERIFICACION',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_establecimiento_otro CHECK (
        (tipo_establecimiento = 'OTRO' AND tipo_establecimiento_otro IS NOT NULL)
        OR (tipo_establecimiento <> 'OTRO' AND tipo_establecimiento_otro IS NULL)
    )
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. PROVEEDORES MAYORISTAS
-- -----------------------------------------------------------------------------
CREATE TABLE proveedores (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    ruc CHAR(11) UNIQUE NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    contacto_nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion_fiscal VARCHAR(200) NULL,
    distrito VARCHAR(60) NULL,
    puntaje DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    puntaje_actualizado_por INT NULL,
    puntaje_actualizado_en TIMESTAMP NULL,
    tiempo_promedio_entrega_hrs INT DEFAULT 24,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (puntaje_actualizado_por) REFERENCES usuarios_internos(usuario_interno_id),
    CONSTRAINT chk_puntaje CHECK (puntaje >= 0.00 AND puntaje <= 5.00)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. DIRECCIONES (SOLO DE BODEGUEROS)
-- -----------------------------------------------------------------------------
CREATE TABLE direcciones (
    direccion_id INT AUTO_INCREMENT PRIMARY KEY,
    bodeguero_id INT NOT NULL,
    departamento VARCHAR(50) NOT NULL DEFAULT 'Lima',
    provincia VARCHAR(50) NOT NULL DEFAULT 'Lima',
    distrito VARCHAR(60) NOT NULL,
    direccion_exacta VARCHAR(200) NOT NULL,
    referencia VARCHAR(200) NULL,
    zona_reparto ENUM('LIMA_CENTRO', 'LIMA_NORTE', 'LIMA_SUR', 'LIMA_ESTE', 'CALLAO') NOT NULL,
    codigo_postal VARCHAR(10) NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY uk_direccion_bodeguero (direccion_id, bodeguero_id),
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. CATALOGO (ADMINISTRADO POR LOGISTICA / ADMINISTRACION)
-- -----------------------------------------------------------------------------
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    codigo_interno VARCHAR(50) UNIQUE NOT NULL COMMENT 'Uso interno de logistica: no se expone en el catalogo publico',
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    peso_kg DECIMAL(10,3) NOT NULL DEFAULT 0,
    marca VARCHAR(80) NOT NULL,
    unidad_medida VARCHAR(40) NOT NULL,
    unidades_por_empaque INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    stock_minimo INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    actualizado_por INT NULL,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    FOREIGN KEY (actualizado_por) REFERENCES usuarios_internos(usuario_interno_id),
    CONSTRAINT chk_precio_unitario CHECK (precio_unitario > 0),
    CONSTRAINT chk_unidades_empaque CHECK (unidades_por_empaque > 0)
) ENGINE=InnoDB;

CREATE TABLE producto_imagenes (
    imagen_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    ruta_imagen VARCHAR(255) NOT NULL,
    texto_alternativo VARCHAR(150) NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    principal_unica TINYINT GENERATED ALWAYS AS (IF(es_principal, 1, NULL)) STORED,
    subido_por INT NULL,
    subido_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_imagen_principal (producto_id, principal_unica),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id) ON DELETE CASCADE,
    FOREIGN KEY (subido_por) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

CREATE TABLE inventario_lotes (
    lote_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    numero_lote VARCHAR(50) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_vencimiento DATE NULL,
    stock_ingresado INT NOT NULL,
    stock_disponible INT NOT NULL,
    ubicacion_almacen VARCHAR(60) NOT NULL,
    registrado_por INT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id),
    FOREIGN KEY (registrado_por) REFERENCES usuarios_internos(usuario_interno_id),
    UNIQUE KEY uk_lote_producto (lote_id, producto_id),
    CONSTRAINT chk_stock_ingresado CHECK (stock_ingresado >= 0),
    CONSTRAINT chk_stock_lote CHECK (stock_disponible >= 0 AND stock_disponible <= stock_ingresado)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. COMPRAS DEL BODEGUERO
-- -----------------------------------------------------------------------------
CREATE TABLE compras (
    compra_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_compra VARCHAR(30) UNIQUE NOT NULL,
    bodeguero_id INT NOT NULL,
    direccion_id INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    igv DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado_pedido ENUM('PENDIENTE', 'PREPARANDO', 'DESPACHADO', 'ENTREGADO', 'CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
    UNIQUE KEY uk_compra_bodeguero (compra_id, bodeguero_id),
    CONSTRAINT chk_total_compra CHECK (subtotal >= 0 AND igv >= 0 AND total = subtotal + igv),
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id),
    FOREIGN KEY (direccion_id, bodeguero_id) REFERENCES direcciones(direccion_id, bodeguero_id)
) ENGINE=InnoDB;

CREATE TABLE detalle_compras (
    detalle_compra_id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL,
    producto_id INT NOT NULL,
    lote_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_linea DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (compra_id) REFERENCES compras(compra_id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    FOREIGN KEY (lote_id, producto_id) REFERENCES inventario_lotes(lote_id, producto_id),
    CONSTRAINT chk_cantidad_compra CHECK (cantidad > 0)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. GUIA DE REMISION (DOCUMENTO COMPLETO DEL TRANSPORTISTA)
-- -----------------------------------------------------------------------------
CREATE TABLE guias_remision (
    guia_id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL UNIQUE,
    codigo_guia VARCHAR(30) UNIQUE NOT NULL,
    total_bultos INT NOT NULL,
    peso_total_kg DECIMAL(8,2) NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL,
    detalle_carga TEXT NOT NULL,
    observaciones TEXT NULL,
    emitida_por INT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (compra_id) REFERENCES compras(compra_id) ON DELETE CASCADE,
    FOREIGN KEY (emitida_por) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. RUTAS DE DESPACHO
-- -----------------------------------------------------------------------------
CREATE TABLE rutas_despacho (
    ruta_id INT AUTO_INCREMENT PRIMARY KEY,
    guia_id INT NOT NULL UNIQUE,
    transportista_id INT NOT NULL,
    vehiculo_placa VARCHAR(10) NOT NULL,
    punto_partida VARCHAR(150) NOT NULL,
    direccion_destino_id INT NOT NULL,
    descripcion_ruta VARCHAR(200) NOT NULL,
    estado_entrega ENUM('ASIGNADO', 'EN_TRAYECTO', 'ENTREGADO', 'FALLIDO') NOT NULL DEFAULT 'ASIGNADO',
    hora_salida DATETIME NULL,
    hora_entrega DATETIME NULL,
    notas_entrega TEXT NULL,
    FOREIGN KEY (guia_id) REFERENCES guias_remision(guia_id) ON DELETE CASCADE,
    FOREIGN KEY (transportista_id) REFERENCES usuarios_internos(usuario_interno_id),
    FOREIGN KEY (direccion_destino_id) REFERENCES direcciones(direccion_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. ATENCION DE INCIDENCIAS
-- -----------------------------------------------------------------------------
CREATE TABLE atencion_incidencias (
    incidencia_id INT AUTO_INCREMENT PRIMARY KEY,
    bodeguero_id INT NOT NULL,
    compra_id INT NULL,
    gestor_usuario_id INT NULL,
    tipo_incidencia ENUM('PRODUCTO_DANADO', 'PEDIDO_INCOMPLETO', 'PRODUCTO_PROXIMO_VENCER', 'DEMORA_ENTREGA', 'OTRO') NOT NULL,
    descripcion TEXT NOT NULL,
    estado_atencion ENUM('ABIERTO', 'EN_REVISION', 'SOLUCIONADO', 'RECHAZADO') NOT NULL DEFAULT 'ABIERTO',
    conformidad_final TEXT NULL,
    fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_solucion DATETIME NULL,
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id),
    FOREIGN KEY (compra_id, bodeguero_id) REFERENCES compras(compra_id, bodeguero_id),
    FOREIGN KEY (gestor_usuario_id) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 10. COMPROBANTES DE PAGO
-- -----------------------------------------------------------------------------
CREATE TABLE tarjetas_prueba (
    tarjeta_id INT AUTO_INCREMENT PRIMARY KEY,
    banco VARCHAR(80) NOT NULL,
    marca VARCHAR(30) NOT NULL,
    numero VARCHAR(19) UNIQUE NOT NULL,
    ultimos_digitos CHAR(4) NOT NULL,
    titular VARCHAR(120) NOT NULL,
    vencimiento CHAR(5) NOT NULL,
    cvv CHAR(3) NOT NULL,
    color_inicio CHAR(7) NOT NULL,
    color_fin CHAR(7) NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    es_simulada BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE comprobantes_pago (
    comprobante_id INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL UNIQUE,
    tipo_comprobante ENUM('FACTURA_ELECTRONICA', 'BOLETA_ELECTRONICA') NOT NULL,
    serie VARCHAR(4) NOT NULL,
    correlativo INT NOT NULL,
    es_simulado BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uk_comprobante_numero (tipo_comprobante, serie, correlativo),
    ruc_emisor CHAR(11) NOT NULL,
    ruc_receptor CHAR(11) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    igv DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('TARJETA', 'YAPE', 'PLIN', 'TRANSFERENCIA_BANCARIA', 'EFECTIVO') NOT NULL,
    codigo_operacion VARCHAR(100) NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (compra_id) REFERENCES compras(compra_id)
) ENGINE=InnoDB;

-- =============================================================================
-- VISTAS: AUTOMATIZACION DE STOCK Y ACCESOS POR ROL
-- =============================================================================

-- Estado de stock calculado en tiempo real: al llegar a 0 el producto queda AGOTADO
CREATE VIEW vista_stock_productos AS
SELECT
    p.producto_id,
    p.nombre,
    p.marca,
    c.nombre AS categoria,
    p.unidad_medida,
    p.unidades_por_empaque,
    p.precio_unitario,
    p.stock_minimo,
    p.activo,
    COALESCE(s.stock_total, 0) AS stock_total,
    CASE
        WHEN COALESCE(s.stock_total, 0) = 0 THEN 'AGOTADO'
        WHEN COALESCE(s.stock_total, 0) <= p.stock_minimo THEN 'POR_AGOTARSE'
        ELSE 'DISPONIBLE'
    END AS estado_stock,
    (p.activo = TRUE AND COALESCE(s.stock_total, 0) > 0) AS seleccionable,
    i.ruta_imagen AS imagen_principal
FROM productos p
JOIN categorias c ON c.categoria_id = p.categoria_id
LEFT JOIN (
    SELECT producto_id, SUM(stock_disponible) AS stock_total
    FROM inventario_lotes
    WHERE fecha_vencimiento IS NULL OR fecha_vencimiento >= CURRENT_DATE
    GROUP BY producto_id
) s ON s.producto_id = p.producto_id
LEFT JOIN producto_imagenes i ON i.producto_id = p.producto_id AND i.es_principal = TRUE;

-- Catálogo público: conserva también los agotados para mostrarlos deshabilitados.
CREATE VIEW vista_catalogo_disponible AS
SELECT producto_id, nombre, marca, categoria, unidad_medida, unidades_por_empaque,
       precio_unitario, stock_total, estado_stock, imagen_principal
FROM vista_stock_productos
WHERE activo = TRUE;

-- Logistica: resumen de lo comprado por el bodeguero, sin peso ni detalle de carga
CREATE VIEW vista_compras_logistica AS
SELECT
    c.compra_id,
    c.codigo_compra,
    g.codigo_guia,
    b.nombre_comercial AS cliente,
    d.distrito,
    d.zona_reparto,
    r.total_items,
    r.total_unidades,
    c.total,
    c.fecha_compra,
    ru.estado_entrega
FROM compras c
JOIN bodegueros b ON b.bodeguero_id = c.bodeguero_id
JOIN direcciones d ON d.direccion_id = c.direccion_id
LEFT JOIN guias_remision g ON g.compra_id = c.compra_id
LEFT JOIN rutas_despacho ru ON ru.guia_id = g.guia_id
LEFT JOIN (
    SELECT compra_id, COUNT(*) AS total_items, SUM(cantidad) AS total_unidades
    FROM detalle_compras
    GROUP BY compra_id
) r ON r.compra_id = c.compra_id;

-- Transportista: guia completa con costo, peso, bultos y ruta
CREATE VIEW vista_guia_transportista AS
SELECT
    g.guia_id,
    ru.ruta_id,
    ru.transportista_id,
    g.codigo_guia,
    c.codigo_compra,
    b.nombre_comercial AS cliente,
    b.telefono AS telefono_cliente,
    CONCAT(d.direccion_exacta, ', ', d.distrito) AS direccion_entrega,
    d.referencia,
    d.zona_reparto,
    ru.descripcion_ruta,
    ru.punto_partida,
    ru.vehiculo_placa,
    CONCAT(u.nombre, ' ', u.apellidos) AS transportista,
    g.total_bultos,
    g.peso_total_kg,
    g.costo_total,
    g.detalle_carga,
    g.observaciones,
    ru.estado_entrega,
    ru.hora_salida,
    ru.hora_entrega
FROM guias_remision g
JOIN compras c ON c.compra_id = g.compra_id
JOIN bodegueros b ON b.bodeguero_id = c.bodeguero_id
JOIN direcciones d ON d.direccion_id = c.direccion_id
LEFT JOIN rutas_despacho ru ON ru.guia_id = g.guia_id
LEFT JOIN usuarios_internos u ON u.usuario_interno_id = ru.transportista_id;

-- Transportista: detalle linea por linea de la carga
CREATE VIEW vista_detalle_guia_transportista AS
SELECT
    g.codigo_guia,
    p.nombre AS producto,
    p.marca,
    p.unidad_medida,
    dc.cantidad,
    (dc.cantidad * p.unidades_por_empaque) AS unidades_totales,
    dc.precio_unitario,
    dc.total_linea,
    l.numero_lote,
    l.ubicacion_almacen
FROM guias_remision g
JOIN detalle_compras dc ON dc.compra_id = g.compra_id
JOIN productos p ON p.producto_id = dc.producto_id
JOIN inventario_lotes l ON l.lote_id = dc.lote_id;

-- Logistica y administracion: seguimiento del estado de entrega
CREATE VIEW vista_entregas_administracion AS
SELECT
    ru.ruta_id,
    g.codigo_guia,
    c.codigo_compra,
    b.nombre_comercial AS cliente,
    ru.descripcion_ruta,
    d.zona_reparto,
    CONCAT(u.nombre, ' ', u.apellidos) AS transportista,
    ru.vehiculo_placa,
    ru.estado_entrega,
    ru.hora_salida,
    ru.hora_entrega,
    c.total
FROM rutas_despacho ru
JOIN guias_remision g ON g.guia_id = ru.guia_id
JOIN compras c ON c.compra_id = g.compra_id
JOIN bodegueros b ON b.bodeguero_id = c.bodeguero_id
JOIN direcciones d ON d.direccion_id = ru.direccion_destino_id
JOIN usuarios_internos u ON u.usuario_interno_id = ru.transportista_id;

-- Bodeguero: estado de sus propias compras
CREATE VIEW vista_seguimiento_bodeguero AS
SELECT
    c.bodeguero_id,
    c.codigo_compra,
    c.fecha_compra,
    c.total,
    COALESCE(ru.estado_entrega, 'ASIGNADO') AS estado_entrega,
    ru.hora_entrega
FROM compras c
LEFT JOIN guias_remision g ON g.compra_id = c.compra_id
LEFT JOIN rutas_despacho ru ON ru.guia_id = g.guia_id;

-- =============================================================================
-- DATOS INICIALES
-- =============================================================================

-- Usuarios internos (5 por cada rol: ADMINISTRADOR, LOGISTICA, TRANSPORTISTA, GESTOR_ATENCION)
-- Contraseñas: primer nombre en minúsculas + 123
INSERT INTO usuarios_internos (usuario_interno_id, nombre, apellidos, correo, password_hash, telefono, rol) VALUES
(1, 'Carlos', 'Ramírez López', 'carlos.ramirez@abastece.com', '$2y$12$nSPIx.DYlPbsx8KiPp3ZDeWFQCrlo.Fu.tdQ3E.LcEm7bUXZNe.HG', '951284730', 'ADMINISTRADOR'),
(2, 'María', 'Torres Sánchez', 'maria.torres@abastece.com', '$2y$12$rS0u/qoBgN6UhilBed7Sv.sX1qa8uCCMGw3XUdTgERI7HljTpR.Vy', '962395841', 'LOGISTICA'),
(3, 'Luis', 'Mendoza Pérez', 'luis.mendoza@abastece.com', '$2y$12$/p4q3N1KFrloh65KXshwe.n.XCFN4LdLAPeVkoDPYzXM/eZHUwyEa', '973506952', 'TRANSPORTISTA'),
(4, 'Andrea', 'Flores García', 'andrea.flores@abastece.com', '$2y$12$ltSHKD6qTpnxhWcjEGOzCuEWWrcnNmGPYmgxplZHsJ.dqQZkTa1C.', '984617063', 'GESTOR_ATENCION'),
(5, 'Juan', 'Navarro Prado', 'juan.navarro@abastece.com', '$2y$12$O6vI4estvhEt9b5aSVD41ul0E.pd8oIsKOSdTOcywWXHDXRVDXqX2', '952395801', 'ADMINISTRADOR'),
(6, 'Ana', 'Salazar Benítez', 'ana.salazar@abastece.com', '$2y$12$DRVgrNrnVCB9NL3b6DLPo.iaYA72PFrinwJelP78SE2jE3aZCZVzm', '953406912', 'ADMINISTRADOR'),
(7, 'Roberto', 'Morales Vega', 'roberto.morales@abastece.com', '$2y$12$/w5TaPwt9pmOS3icj38e5..lnnN1WlKXOoV4bsrJavOjpmv69UNje', '954517023', 'ADMINISTRADOR'),
(8, 'Diana', 'Castro Medina', 'diana.castro@abastece.com', '$2y$12$GxetEqkcrdFw8.Msg2A94ugAaudcCrN03fuMIEVhN6gyxIaX41xgm', '955628134', 'ADMINISTRADOR'),
(9, 'Javier', 'Villanueva Peña', 'javier.villanueva@abastece.com', '$2y$12$PuAb1C/hbNYoUt4ukvAYpemswxeDryurqH5PWbbJNSRRL1mrjwg6y', '963406951', 'LOGISTICA'),
(10, 'Lucía', 'Romero Alva', 'lucia.romero@abastece.com', '$2y$12$ag5LReK98zEXfzkEurkMneyB6jJUsKNPNcgx.iqWokqsLkqrSmXmW', '964517062', 'LOGISTICA'),
(11, 'Gonzalo', 'Rivas Delgado', 'gonzalo.rivas@abastece.com', '$2y$12$xa7SgEtJDvEPfZmhLsjKvOoXliwDhSTcF2xkRCYJUYnY8N7pWprXa', '965628173', 'LOGISTICA'),
(12, 'Valeria', 'Ortiz Campos', 'valeria.ortiz@abastece.com', '$2y$12$t7/xgo8.oB8o0usgcBulF..qkp2R8rfPjCErEsHmtTkP/k6zU6HWu', '966739284', 'LOGISTICA'),
(13, 'Manuel', 'Quispe Córdova', 'manuel.quispe@abastece.com', '$2y$12$0rivMu40M69ryeDTMra5y.oQT53i2Jp4zhGocc7ZlCTE4XN3C.3dO', '974617061', 'TRANSPORTISTA'),
(14, 'Pedro', 'Tello Aguilar', 'pedro.tello@abastece.com', '$2y$12$nijWfYFaoEfS3IJHx2H44OexUnyEZX/P2w9pr1X/7TBvs6DLv8bFO', '975728172', 'TRANSPORTISTA'),
(15, 'César', 'Palacios Miranda', 'cesar.palacios@abastece.com', '$2y$12$1J97RgeWIk3odH7SPGzhTO4owd.gPO4QECIZjZMA.tdRsYOg55J1G', '976839283', 'TRANSPORTISTA'),
(16, 'Jorge', 'Barreto Núñez', 'jorge.barreto@abastece.com', '$2y$12$IrldlG2EPpadLsVi1KJwA.yuOhUwmeBUMNTjcTSogXZRgLw8SrSoC', '977940394', 'TRANSPORTISTA'),
(17, 'Claudia', 'Meza Guzmán', 'claudia.meza@abastece.com', '$2y$12$3Ieu6rIPnLM.n7vINSpzx.EGhj7VdQhFvBuBGk0q6mFGRa8Yu92pa', '985728171', 'GESTOR_ATENCION'),
(18, 'Gabriel', 'Huamán Solís', 'gabriel.huaman@abastece.com', '$2y$12$cmQC7n4L7EWstSZYQRCz9.YlSuFqS1uWFVu914YiUzKDgvkkC6WX6', '986839282', 'GESTOR_ATENCION'),
(19, 'Mónica', 'Cáceres Vargas', 'monica.caceres@abastece.com', '$2y$12$2sBXARI0v4MvEcnOKghE7.3Vc.N9VYQ0K.sGtaGegT/rZpfoOsPt6', '987940393', 'GESTOR_ATENCION'),
(20, 'Daniel', 'Vidal Pinedo', 'daniel.vidal@abastece.com', '$2y$12$TXAe0Ue/kq0vfF.f/adJieO.3VmjPiw/kJbPfCxJFijAato2V5GFW', '988051404', 'GESTOR_ATENCION');

-- Bodegueros / Clientes (contraseña = nombre_en_minusculas + 123)
-- jorge123, rosa123, miguel123, carmen123
INSERT INTO bodegueros (bodeguero_id, nombre, apellidos, correo, password_hash, telefono, ruc, tipo_establecimiento, tipo_establecimiento_otro, nombre_comercial, razon_social, email_verificado, token_verificacion_correo, email_verificado_en, estado_cuenta) VALUES
(1, 'Jorge', 'Huamán Quispe', 'jorge.huaman@gmail.com', '$2y$12$eS46bUGTIemDctQtKMJwJui7xyEpGfvmcw.isJCp2ptOr/qP2LcHO', '912345678', '20601234501', 'MINIMARKET', NULL, 'Minimarket Don Jorge', 'Jorge Huamán Quispe E.I.R.L.', TRUE, NULL, '2026-08-25 10:00:00', 'ACTIVO'),
(2, 'Rosa', 'Condori Mamani', 'rosa.condori@gmail.com', '$2y$12$0/PR8PUghQVKazde4uB0xee/dFUNR.ONqaReI7ElhQc0by/8ukUXC', '923456789', '20601234502', 'BODEGA', NULL, 'Bodega Doña Rosa', 'Rosa Condori Mamani E.I.R.L.', TRUE, NULL, '2026-08-26 14:30:00', 'ACTIVO'),
(3, 'Miguel', 'Paredes Castillo', 'miguel.paredes@gmail.com', '$2y$12$hJVdTzE2eR6c0/25mDlUqupzAF7y/x3kkQqRpy8wPGUbeIOg47JlG', '934567890', '20601234503', 'MARKET_LOCAL', NULL, 'Market El Vecino', 'Miguel Paredes Castillo E.I.R.L.', TRUE, NULL, '2026-08-28 09:20:00', 'ACTIVO'),
(4, 'Carmen', 'Rojas Villaverde', 'carmen.rojas@gmail.com', '$2y$12$Ur5PA1qIuoUbveje9k1RPOLNIDCGIzZZWUy5NeCd.zXdzPCGC3EoW', '945678901', '20601234504', 'OTRO', 'Puesto de mercado mayorista con atención al público', 'Comercial Doña Carmen', 'Carmen Rojas Villaverde E.I.R.L.', TRUE, NULL, '2026-09-02 11:45:00', 'ACTIVO'),
(5, 'Patricia', 'Soto Medina', 'patricia.soto@gmail.com', '$2y$12$KQuUFd9PTKEMMZwxRSHM4OHw1GqxYY6YxmxsqS5KBR1At4u7IQXWi', '956789012', '20601234505', 'BODEGA', NULL, 'Bodega Patricia', 'Patricia Soto Medina E.I.R.L.', TRUE, NULL, '2026-09-03 08:30:00', 'ACTIVO'),
(6, 'Ricardo', 'Chávez Huanca', 'ricardo.chavez@gmail.com', '$2y$12$GyzTUILy5is9dFuDuti3vOYFcliFmmf0PH0auD8YLs8/HK7EerbNW', '967890123', '20601234506', 'MINIMARKET', NULL, 'Minimarket Chávez', 'Ricardo Chávez Huanca E.I.R.L.', TRUE, NULL, '2026-09-04 10:15:00', 'ACTIVO'),
(7, 'Elena', 'Quispe Torres', 'elena.quispe@gmail.com', '$2y$12$tknZvEwgDNpHcDFtbPkC7.qikn9q3QY8PhHOpRb0aMg9xzpfMAxKq', '978901234', '20601234507', 'MARKET_LOCAL', NULL, 'Market Doña Elena', 'Elena Quispe Torres E.I.R.L.', TRUE, NULL, '2026-09-05 14:00:00', 'ACTIVO'),
(8, 'Fernando', 'Gutiérrez Ramos', 'fernando.gutierrez@gmail.com', '$2y$12$6T4HSqEPsJumLQWYI8R5Ze/roS6YIHzwW.n9KTfi.J.pQXMgNUkAq', '989012345', '20601234508', 'BODEGA', NULL, 'Bodega Don Fernando', 'Fernando Gutiérrez Ramos E.I.R.L.', TRUE, NULL, '2026-09-06 09:45:00', 'ACTIVO'),
(9, 'Daniela', 'Espinoza Cruz', 'daniela.espinoza@gmail.com', '$2y$12$fRhvGSJiizitEtAAw1Uk1uezgbKqvB.6HvfgSAvJcM6vlWhgsCaJS', '990123456', '20601234509', 'MINIMARKET', NULL, 'Minimarket Dany', 'Daniela Espinoza Cruz E.I.R.L.', TRUE, NULL, '2026-09-07 11:30:00', 'ACTIVO'),
(10, 'Raúl', 'Vargas Mendoza', 'raul.vargas@gmail.com', '$2y$12$/46EzK1R5..RQmsNVqqe2O3wAFdKUjB5O0T52FplslUh/DsWZZika', '901234567', '20601234510', 'BODEGA', NULL, 'Bodega Vargas', 'Raúl Vargas Mendoza E.I.R.L.', TRUE, NULL, '2026-09-08 16:20:00', 'ACTIVO'),
(11, 'Sofía', 'Cárdenas Pinto', 'sofia.cardenas@gmail.com', '$2y$12$3SfWWEcw8I2Bob2Oe6QP8eW8cy9WHoD.47AOu6t8C1oJRIK/jfv/e', '912098765', '20601234511', 'MARKET_LOCAL', NULL, 'Market Sofía', 'Sofía Cárdenas Pinto E.I.R.L.', TRUE, NULL, '2026-09-09 13:10:00', 'ACTIVO'),
(12, 'Héctor', 'Zapata Flores', 'hector.zapata@gmail.com', '$2y$12$n6OUKP042hCLpVNifvJC7O995Hl0U/dmMAd3fyNJg6B/6hX9EvbBG', '923109876', '20601234512', 'MINIMARKET', NULL, 'Minimarket Zapata', 'Héctor Zapata Flores E.I.R.L.', TRUE, NULL, '2026-09-10 07:50:00', 'ACTIVO'),
(13, 'Valentina', 'Huanca Ríos', 'valentina.huanca@gmail.com', '$2y$12$DJWFDcbOrWDl/25l37UBf.zwKpTm8T/osxvCBVQCPKbJxIDlnRMOS', '934210987', '20601234513', 'BODEGA', NULL, 'Bodega Valentina', 'Valentina Huanca Ríos E.I.R.L.', TRUE, NULL, '2026-09-11 15:40:00', 'ACTIVO'),
(14, 'Óscar', 'Delgado Paredes', 'oscar.delgado@gmail.com', '$2y$12$muVDcjGB9yrSm9MkkRVZvOTiCPgDrJsI7gi/ElCb8h8K4AmPHWWHS', '945321098', '20601234514', 'OTRO', 'Distribuidora de abarrotes en mercado de barrio', 'Distribuidora Don Óscar', 'Óscar Delgado Paredes E.I.R.L.', TRUE, NULL, '2026-09-12 10:25:00', 'ACTIVO');

-- Direcciones (todas pertenecen a un bodeguero)
INSERT INTO direcciones (direccion_id, bodeguero_id, departamento, provincia, distrito, direccion_exacta, referencia, zona_reparto, codigo_postal, es_principal) VALUES
(1, 1, 'Lima', 'Lima', 'Rímac', 'Jr. Trujillo 482, Urbanización El Bosque', 'A media cuadra del mercado Limoncillo', 'LIMA_CENTRO', '15093', TRUE),
(2, 2, 'Lima', 'Lima', 'Los Olivos', 'Av. Palmeras 1236, Urb. Pro', 'Frente al parque Lloque Yupanqui', 'LIMA_NORTE', '15301', TRUE),
(3, 3, 'Lima', 'Lima', 'Villa El Salvador', 'Mz. K Lt. 12, Sector 3, Grupo 15', 'A dos cuadras del paradero del tren eléctrico', 'LIMA_SUR', '15842', TRUE),
(4, 4, 'Lima', 'Lima', 'Ate', 'Av. Nicolás Ayllón 3874, Zona Industrial', 'Al costado de la fábrica de plásticos', 'LIMA_ESTE', '15012', TRUE),
(5, 1, 'Lima', 'Lima', 'San Martin de Porres', 'Calle Los Jazmines 290, Urb. Fiori', 'A una cuadra del centro comercial Fiori', 'LIMA_NORTE', '15109', FALSE),
(6, 4, 'Callao', 'Callao', 'Bellavista', 'Av. Sáenz Peña 648, Bellavista', 'Frente a la municipalidad de Bellavista', 'CALLAO', '07011', FALSE),
(7, 5, 'Lima', 'Lima', 'Breña', 'Jr. Aguarico 350, Urb. Chacra Colorada', 'A una cuadra del hospital Loayza', 'LIMA_CENTRO', '15082', TRUE),
(8, 6, 'Lima', 'Lima', 'Comas', 'Av. Túpac Amaru 4520, Urb. El Retablo', 'Frente al mercado Unicachi de Comas', 'LIMA_NORTE', '15316', TRUE),
(9, 7, 'Lima', 'Lima', 'San Juan de Lurigancho', 'Av. Próceres de la Independencia 2890', 'Al lado de la estación Bayóvar del Metro', 'LIMA_ESTE', '15420', TRUE),
(10, 8, 'Lima', 'Lima', 'Chorrillos', 'Av. Defensores del Morro 1275', 'A dos cuadras de la playa Agua Dulce', 'LIMA_SUR', '15063', TRUE),
(11, 9, 'Lima', 'Lima', 'Independencia', 'Av. Izaguirre 876, Urb. Tahuantinsuyo', 'Cerca del centro comercial Plaza Norte', 'LIMA_NORTE', '15332', TRUE),
(12, 10, 'Lima', 'Lima', 'La Victoria', 'Jr. Gamarra 1480, Galería El Rey', 'Dentro de la galería, segundo piso puesto 210', 'LIMA_CENTRO', '15034', TRUE),
(13, 11, 'Lima', 'Lima', 'Surquillo', 'Calle Dante 185, Urb. San Felipe', 'A media cuadra del mercado N° 1 de Surquillo', 'LIMA_CENTRO', '15038', TRUE),
(14, 12, 'Lima', 'Lima', 'Puente Piedra', 'Av. Juan Lecaros 890, Urb. Las Vegas', 'Frente al grifo Repsol de Puente Piedra', 'LIMA_NORTE', '15118', TRUE),
(15, 13, 'Callao', 'Callao', 'Ventanilla', 'Mz. B Lt. 5, Urb. Mi Perú', 'A tres cuadras del mercado Mi Perú', 'CALLAO', '07061', TRUE),
(16, 14, 'Lima', 'Lima', 'San Juan de Miraflores', 'Av. San Juan 1560, Zona A Pamplona Alta', 'Al costado de la comisaría de Pamplona', 'LIMA_SUR', '15801', TRUE);

-- Proveedores mayoristas
INSERT INTO proveedores (proveedor_id, ruc, razon_social, nombre_comercial, contacto_nombre, correo, telefono, direccion_fiscal, distrito, puntaje, puntaje_actualizado_por, puntaje_actualizado_en, tiempo_promedio_entrega_hrs) VALUES
(1, '20512345101', 'Alicorp S.A.A.', 'Alicorp', 'Fernando Castañeda Ruiz', 'ventas.corporativas@alicorp.com', '016154200', 'Av. Argentina 4793, Carmen de la Legua', 'Santa Anita', 4.95, 2, '2026-09-05 10:00:00', 24),
(2, '20512345102', 'Gloria S.A.', 'Gloria', 'Patricia Valdivia Ochoa', 'pedidos.mayoristas@gloria.com', '014701130', 'Av. República de Panamá 2461, La Victoria', 'Independencia', 4.80, 2, '2026-09-05 10:05:00', 36),
(3, '20512345103', 'Arca Continental Lindley S.A.', 'Arca Continental', 'Roberto Espinoza Medina', 'distribuidora@arcacontinental.com', '012116100', 'Jr. Cajamarca 371, Rímac', 'Callao', 4.70, 2, '2026-09-05 10:10:00', 24),
(4, '20512345104', 'Intradevco Industrial S.A.', 'Intradevco', 'Gabriela Montoya Silva', 'comercial@intradevco.com', '016180200', 'Av. Producción Nacional 188, Chorrillos', 'Ate', 4.55, 2, '2026-09-05 10:15:00', 48),
(5, '20512345105', 'Colgate-Palmolive Perú S.A.', 'Colgate-Palmolive', 'Diego Ramos Vásquez', 'ventas.peru@colgate.com', '016289400', 'Av. Paseo de la República 3195, San Isidro', 'La Molina', 4.60, 2, '2026-09-05 10:20:00', 36),
(6, '20512345106', 'Ajinomoto del Perú S.A.', 'Ajinomoto', 'Keiko Tanaka Ríos', 'mayoristas@ajinomoto.com.pe', '016189200', 'Av. Néstor Gambetta 8580, Callao', 'Villa El Salvador', 4.40, 2, '2026-09-05 10:25:00', 48),
(7, '20512345107', 'Molitalia S.A.', 'Molitalia', 'Hernán Gutiérrez Campos', 'ventas.distribuidora@molitalia.com', '012196000', 'Av. Venezuela 2850, Cercado de Lima', 'Lima', 4.25, 2, '2026-09-05 10:30:00', 24),
(8, '20512345108', 'Procter & Gamble Perú S.R.L.', 'P&G Perú', 'Mariana Castro Delgado', 'canal.mayorista@pg.com', '016285700', 'Av. Del Derby 250, Santiago de Surco', 'Los Olivos', 4.85, 2, '2026-09-05 10:35:00', 24),
(9, '20512345109', 'Kimberly-Clark Perú S.R.L.', 'Kimberly-Clark', 'Álvaro Peña Salazar', 'pedidos@kimberly-clark.com', '016181700', 'Av. Paseo de la República 6280, Miraflores', 'Surquillo', 4.10, 2, '2026-09-05 10:40:00', 48),
(10, '20512345110', 'Backus y Johnston S.A.A.', 'Backus', 'Luciana Herrera Montoya', 'distribuidores@backus.com', '013111000', 'Av. Nicolás Ayllón 3986, Ate', 'Lurin', 4.35, 2, '2026-09-05 10:45:00', 72);

-- Categorias
INSERT INTO categorias (categoria_id, nombre, descripcion) VALUES
(1, 'Abarrotes', 'Aceites, arroz, azúcar, fideos, conservas, galletas y lácteos envasados'),
(2, 'Bebidas', 'Aguas, gaseosas, cervezas, néctares, yogures y bebidas energizantes'),
(3, 'Limpieza', 'Detergentes, lejías, ceras, papeles y artículos de limpieza del hogar'),
(4, 'Cuidado Personal', 'Higiene bucal, shampoo, jabones, desodorantes y cuidado personal');

-- Productos (catalogo mayorista)
INSERT INTO productos (producto_id, categoria_id, codigo_interno, nombre, descripcion, marca, unidad_medida, unidades_por_empaque, precio_unitario, stock_minimo, actualizado_por) VALUES
(1, 1, 'ABA-PRI-001', 'Aceite Primor Premium', 'Caja con 12 botellas de aceite vegetal premium para reventa mayorista.', 'Primor', 'Caja x 12 und', 12, 128.00, 8, 2),
(2, 1, 'ABA-AJI-001', 'Ajinomen Gallina', 'Caja con 24 sobres de sopa instantánea sabor gallina, 80 g c/u.', 'Ajinomen', 'Caja x 24 sobres', 24, 29.00, 5, 2),
(3, 1, 'ABA-COS-001', 'Arroz Costeño Extra', 'Saco de arroz extra de grano largo de 50 kg para reventa mayorista.', 'Costeño', 'Saco x 50 kg', 1, 185.00, 8, 2),
(4, 1, 'ABA-PRI-002', 'Atún Primor Trozos en Aceite', 'Caja con 48 latas de atún en trozos en aceite, 170 g c/u.', 'Primor', 'Caja x 48 und', 48, 154.00, 5, 2),
(5, 1, 'ABA-3OS-001', 'Avena 3 Ositos Tradicional', 'Caja con 24 bolsas de avena tradicional, 300 g c/u.', '3 Ositos', 'Caja x 24 bolsas', 24, 108.00, 5, 2),
(6, 1, 'ABA-PAR-001', 'Azúcar Rubia Paramonga', 'Saco de azúcar rubia de 50 kg para reventa mayorista.', 'Paramonga', 'Saco x 50 kg', 1, 145.00, 8, 2),
(7, 1, 'ABA-WIN-001', 'Chocolate Winter''s Taza', 'Display con 50 tabletas de chocolate para taza, 90 g c/u.', 'Winter''s', 'Display x 50 tabletas', 50, 115.00, 5, 2),
(8, 1, 'ABA-SUB-001', 'Chocolates Sublime Clásico', 'Display con 24 tabletas de chocolate Sublime, 30 g c/u.', 'Sublime', 'Display x 24 tabletas', 24, 39.00, 5, 2),
(9, 1, 'ABA-DON-001', 'Fideos Don Vittorio Spaghetti', 'Paquete con 20 bolsas de fideos spaghetti, 450 g c/u.', 'Don Vittorio', 'Paquete x 20 und', 20, 60.00, 5, 2),
(10, 1, 'ABA-CAS-001', 'Galletas Casino Menta', 'Display con 24 paquetes de galletas sabor menta.', 'Casino', 'Display x 24 paquetes', 24, 44.00, 5, 2),
(11, 1, 'ABA-SAN-001', 'Galletas Soda San Jorge', 'Display con 24 paquetes de galletas de soda.', 'San Jorge', 'Display x 24 paquetes', 24, 36.00, 5, 2),
(12, 1, 'ABA-GLO-001', 'Leche Gloria Azul', 'Caja con 24 tarros de leche evaporada, 400 g c/u.', 'Gloria', 'Caja x 24 und', 24, 115.00, 5, 2),
(13, 1, 'ABA-ALA-001', 'Mayonesa Alacena', 'Caja con 24 doy pack de mayonesa, 95 g c/u.', 'Alacena', 'Caja x 24 doy pack', 24, 53.00, 5, 2),
(14, 1, 'ABA-EMS-001', 'Sal de Mesa Emsal Yodada', 'Fardo con 20 bolsas de sal yodada, 1 kg c/u.', 'Emsal', 'Fardo x 20 bolsas', 20, 36.00, 5, 2),
(15, 1, 'ABA-MOL-001', 'Salsa Pomarola Molitalia', 'Caja con 24 doy pack de salsa pomarola, 145 g c/u.', 'Molitalia', 'Caja x 24 doy pack', 24, 60.00, 5, 2),
(16, 2, 'BEB-CIE-001', 'Agua Cielo Sin Gas', 'Plancha con 15 botellas de agua sin gas, 625 ml c/u.', 'Cielo', 'Plancha x 15 und', 15, 18.00, 8, 2),
(17, 2, 'BEB-SAN-001', 'Agua San Mateo Sin Gas', 'Plancha con 12 botellas de agua sin gas, 600 ml c/u.', 'San Mateo', 'Plancha x 12 und', 12, 16.00, 8, 2),
(18, 2, 'BEB-SPO-001', 'Bebida Hidratante Sporade Mandarina', 'Plancha con 12 botellas de bebida hidratante, 500 ml c/u.', 'Sporade', 'Plancha x 12 und', 12, 30.00, 8, 2),
(19, 2, 'BEB-CRI-001', 'Cerveza Cristal', 'Caja con 12 botellas de cerveza, 650 ml c/u.', 'Cristal', 'Caja x 12 botellas', 12, 66.00, 8, 2),
(20, 2, 'BEB-PIL-001', 'Cerveza Pilsen Callao', 'Plancha con 24 latas de cerveza, 355 ml c/u.', 'Pilsen Callao', 'Plancha x 24 latas', 24, 101.00, 5, 2),
(21, 2, 'BEB-COC-001', 'Coca Cola', 'Fardo con 12 botellas de gaseosa, 500 ml c/u.', 'Coca-Cola', 'Fardo x 12 und', 12, 34.00, 8, 2),
(22, 2, 'BEB-COC-002', 'Coca Cola Sabor Original', 'Fardo con 6 botellas de gaseosa, 3 L c/u.', 'Coca-Cola', 'Fardo x 6 und', 6, 57.00, 8, 2),
(23, 2, 'BEB-KOL-001', 'Gaseosa Kola Real Piña', 'Fardo con 6 botellas de gaseosa sabor piña, 3 L c/u.', 'Kola Real', 'Fardo x 6 und', 6, 39.00, 8, 2),
(24, 2, 'BEB-INC-001', 'Inca Kola', 'Fardo con 12 botellas de gaseosa, 500 ml c/u.', 'Inca Kola', 'Fardo x 12 und', 12, 34.00, 8, 2),
(25, 2, 'BEB-INC-002', 'Inca Kola Sin Azúcar', 'Fardo con 6 botellas de gaseosa sin azúcar, 3 L c/u.', 'Inca Kola', 'Fardo x 6 und', 6, 57.00, 8, 2),
(26, 2, 'BEB-FRU-001', 'Néctar Frugos del Valle Naranja', 'Fardo con 12 botellas de néctar de naranja, 300 ml c/u.', 'Frugos', 'Fardo x 12 botellas', 12, 26.00, 8, 2),
(27, 2, 'BEB-PUL-001', 'Néctar Pulp Durazno', 'Fardo con 24 cajitas de néctar de durazno, 235 ml c/u.', 'Pulp', 'Fardo x 24 cajitas', 24, 38.00, 5, 2),
(28, 2, 'BEB-FRE-001', 'Té Helado Free Tea Limón', 'Fardo con 12 botellas de té helado sabor limón, 475 ml c/u.', 'Free Tea', 'Fardo x 12 botellas', 12, 28.00, 8, 2),
(29, 2, 'BEB-VOL-001', 'Volt Blue Energy Maca', 'Plancha con 24 latas de bebida energizante, 300 ml c/u.', 'Volt', 'Plancha x 24 latas', 24, 84.00, 5, 2),
(30, 2, 'BEB-GLO-001', 'Yogurt Gloria Fresa', 'Galonera con 6 unidades de yogurt sabor fresa, 1 kg c/u.', 'Gloria', 'Galonera x 6 und', 6, 54.00, 8, 2),
(31, 3, 'LIM-CLA-001', 'Bolsas de Basura Clan 50L', 'Fardo con 20 paquetes de bolsas de basura de 50L, 10 und c/u.', 'Clan', 'Fardo x 20 paquetes', 20, 90.00, 5, 2),
(32, 3, 'LIM-TEK-001', 'Cera para Pisos Tekno Roja', 'Caja con 4 galoneras de cera roja para pisos, 1 galón c/u.', 'Tekno', 'Caja x 4 galoneras', 4, 112.00, 8, 2),
(33, 3, 'LIM-ACE-001', 'Detergente Ace Polvo', 'Bolsa multipack con 12 unidades de detergente en polvo, 750 g c/u.', 'Ace', 'Bolsa x 12 und', 12, 78.00, 8, 2),
(34, 3, 'LIM-BOL-001', 'Detergente Bolívar Floral', 'Bolsa de detergente en polvo floral de 5.8 kg.', 'Bolívar', 'Bolsa x 5.8 kg', 1, 38.00, 8, 2),
(35, 3, 'LIM-OPA-001', 'Detergente Opal Ultra Cristal', 'Bolsa de detergente en polvo Ultra Cristal de 5.8 kg.', 'Opal', 'Bolsa x 5.8 kg', 1, 36.00, 8, 2),
(36, 3, 'LIM-SCO-001', 'Esponja Scotch-Brite Verde', 'Caja con 24 esponjas verdes multiuso.', 'Scotch-Brite', 'Caja x 24 und', 24, 29.00, 5, 2),
(37, 3, 'LIM-AYU-001', 'Lavavajillas Líquido Ayudín Limón', 'Caja con 12 botellas de lavavajillas líquido, 900 ml c/u.', 'Ayudín', 'Caja x 12 und', 12, 58.00, 8, 2),
(38, 3, 'LIM-SAP-001', 'Lavavajillas Sapolio Pasta Limón', 'Caja con 24 unidades de lavavajillas en pasta, 800 g c/u.', 'Sapolio', 'Caja x 24 und', 24, 77.00, 5, 2),
(39, 3, 'LIM-CLO-001', 'Lejía Clorox Tradicional', 'Caja con 15 botellas de lejía tradicional, 1 kg c/u.', 'Clorox', 'Caja x 15 botellas', 15, 53.00, 8, 2),
(40, 3, 'LIM-SAP-002', 'Lejía Sapolio Tradicional', 'Fardo con 15 botellas de lejía tradicional, 1 kg c/u.', 'Sapolio', 'Fardo x 15 botellas', 15, 45.00, 8, 2),
(41, 3, 'LIM-POE-001', 'Limpiador Poett Lavanda', 'Caja con 12 botellas de limpiador multiusos, 900 ml c/u.', 'Poett', 'Caja x 12 botellas', 12, 66.00, 8, 2),
(42, 3, 'LIM-SAP-003', 'Limpiavidrios Sapolio Antiempañante', 'Caja con 12 gatillos limpiavidrios antiempañante, 650 ml c/u.', 'Sapolio', 'Caja x 12 und', 12, 50.00, 8, 2),
(43, 3, 'LIM-PAR-001', 'Papel Higiénico Paracas Black', 'Paquete con 10 planchas de papel higiénico, 4 rollos por plancha.', 'Paracas', 'Paquete x 10 planchas', 10, 130.00, 8, 2),
(44, 3, 'LIM-NOV-001', 'Papel Toalla Nova Clásico', 'Fardo con 12 paquetes de papel toalla, 2 rollos por paquete.', 'Nova', 'Fardo x 12 paquetes', 12, 78.00, 8, 2),
(45, 3, 'LIM-DOW-001', 'Suavizante Downy Floral', 'Caja con 12 doy pack de suavizante floral, 800 ml c/u.', 'Downy', 'Caja x 12 doy pack', 12, 60.00, 8, 2),
(46, 4, 'CUI-GIL-001', 'Afeitadora Gillette Prestobarba 3', 'Display con 24 afeitadoras desechables de 3 hojas.', 'Gillette', 'Display x 24 und', 24, 60.00, 5, 2),
(47, 4, 'CUI-COL-001', 'Cepillo Dental Colgate Extra Clean', 'Caja con 24 cepillos dentales Extra Clean.', 'Colgate', 'Caja x 24 und', 24, 43.00, 5, 2),
(48, 4, 'CUI-COL-002', 'Crema Dental Colgate Triple Acción', 'Caja con 36 tubos de crema dental, 100 ml c/u.', 'Colgate', 'Caja x 36 tubos', 36, 94.00, 5, 2),
(49, 4, 'CUI-KOL-001', 'Crema Dental Kolynos Triple Limpieza', 'Caja con 36 tubos de crema dental, 90 ml c/u.', 'Kolynos', 'Caja x 36 tubos', 36, 83.00, 5, 2),
(50, 4, 'CUI-NIV-001', 'Desodorante Nivea Roll-on Aclarado Natural', 'Caja con 12 desodorantes roll-on, 50 ml c/u.', 'Nivea', 'Caja x 12 und', 12, 78.00, 8, 2),
(51, 4, 'CUI-REX-001', 'Desodorante Rexona Clinical Aerosol Hombre', 'Caja con 12 desodorantes en aerosol, 150 ml c/u.', 'Rexona', 'Caja x 12 und', 12, 114.00, 8, 2),
(52, 4, 'CUI-BOL-001', 'Jabón Bolívar Blanco', 'Fardo con 24 barras de jabón blanco, 200 g c/u.', 'Bolívar', 'Fardo x 24 barras', 24, 38.00, 5, 2),
(53, 4, 'CUI-CAM-001', 'Jabón de Tocador Camay Clásico', 'Caja con 36 jabones de tocador, 125 g c/u.', 'Camay', 'Caja x 36 und', 36, 65.00, 5, 2),
(54, 4, 'CUI-AVA-001', 'Jabón Líquido Aval Antibacterial', 'Caja con 12 botellas de jabón líquido antibacterial.', 'Aval', 'Caja x 12 botellas', 12, 66.00, 8, 2),
(55, 4, 'CUI-BAB-001', 'Pañales Babysec Super Premium XXG', 'Fardo con 4 paquetes de pañales talla XXG, 44 und c/u.', 'Babysec', 'Fardo x 4 paquetes', 4, 112.00, 8, 2),
(56, 4, 'CUI-HEA-001', 'Shampoo Head & Shoulders Limpieza Renovadora', 'Caja con 12 shampoos anticaspa, 375 ml c/u.', 'Head & Shoulders', 'Caja x 12 und', 12, 126.00, 8, 2),
(57, 4, 'CUI-SED-001', 'Shampoo Sedal Ceramidas', 'Caja con 12 botellas de shampoo con ceramidas, 340 ml c/u.', 'Sedal', 'Caja x 12 botellas', 12, 90.00, 8, 2),
(58, 4, 'CUI-SED-002', 'Shampoo Sedal Tiras', 'Tira con 24 sachets individuales de shampoo.', 'Sedal', 'Tira x 24 sachets', 24, 22.00, 5, 2),
(59, 4, 'CUI-LAD-001', 'Toallas Higiénicas Ladysoft Normal con Alas', 'Fardo con 24 paquetes de toallas higiénicas con alas.', 'Ladysoft', 'Fardo x 24 paquetes', 24, 67.00, 5, 2),
(60, 4, 'CUI-NOS-001', 'Toallas Higiénicas Nosotras Buenas Noches', 'Fardo con 24 paquetes de toallas higiénicas nocturnas.', 'Nosotras', 'Fardo x 24 paquetes', 24, 72.00, 5, 2);

-- Imágenes principales del catálogo. Los archivos se sirven desde
-- backend/public/uploads/products y en la BD se conserva solamente la ruta.
INSERT INTO producto_imagenes (producto_id, ruta_imagen, texto_alternativo, es_principal)
SELECT p.producto_id,
       CONCAT('/api/uploads/products/product-', LPAD(p.producto_id, 3, '0'), '.png'),
       p.nombre,
       TRUE
FROM productos p
WHERE p.producto_id BETWEEN 1 AND 60;

-- Lotes de inventario (stock real por producto)
INSERT INTO inventario_lotes (lote_id, producto_id, proveedor_id, numero_lote, fecha_ingreso, fecha_vencimiento, stock_ingresado, stock_disponible, ubicacion_almacen, registrado_por) VALUES
(1, 1, 2, 'LOTE-ABA-PRI-001', '2026-04-04', '2028-06-15', 67, 63, 'Rack A-02', 2),
(2, 2, 6, 'LOTE-ABA-AJI-002', '2026-05-07', '2027-11-28', 74, 74, 'Rack A-03', 2),
(3, 3, 1, 'LOTE-ABA-COS-003', '2026-06-10', '2028-04-15', 81, 81, 'Rack A-04', 2),
(4, 4, 2, 'LOTE-ABA-PRI-004', '2026-07-13', '2027-09-28', 88, 88, 'Rack A-05', 2),
(5, 5, 6, 'LOTE-ABA-3OS-005', '2026-08-16', '2028-02-15', 95, 92, 'Rack A-06', 2),
(6, 6, 1, 'LOTE-ABA-PAR-006', '2026-03-19', '2027-07-28', 102, 99, 'Rack A-07', 2),
(7, 7, 2, 'LOTE-ABA-WIN-007', '2026-04-22', '2028-12-15', 109, 109, 'Rack A-08', 2),
(8, 8, 6, 'LOTE-ABA-SUB-008', '2026-05-25', '2027-05-28', 116, 116, 'Rack A-09', 2),
(9, 9, 1, 'LOTE-ABA-DON-009', '2026-06-01', '2028-10-15', 123, 117, 'Rack A-10', 2),
(10, 10, 2, 'LOTE-ABA-CAS-010', '2026-07-04', '2027-03-28', 130, 130, 'Rack A-11', 2),
(11, 11, 6, 'LOTE-ABA-SAN-011', '2026-08-07', '2028-08-15', 137, 137, 'Rack A-12', 2),
(12, 12, 1, 'LOTE-ABA-GLO-012', '2026-03-10', '2027-01-28', 144, 139, 'Rack A-01', 2),
(13, 13, 2, 'LOTE-ABA-ALA-013', '2026-04-13', '2028-06-15', 151, 151, 'Rack A-02', 2),
(14, 14, 6, 'LOTE-ABA-EMS-014', '2026-05-16', '2027-11-28', 40, 0, 'Rack A-03', 2),
(15, 15, 1, 'LOTE-ABA-MOL-015', '2026-06-19', '2028-04-15', 165, 165, 'Rack A-04', 2),
(16, 16, 3, 'LOTE-BEB-CIE-016', '2026-07-22', '2027-09-28', 172, 172, 'Rack B-05', 2),
(17, 17, 10, 'LOTE-BEB-SAN-017', '2026-08-25', '2028-02-15', 179, 179, 'Rack B-06', 2),
(18, 18, 3, 'LOTE-BEB-SPO-018', '2026-03-01', '2027-07-28', 66, 66, 'Rack B-07', 2),
(19, 19, 10, 'LOTE-BEB-CRI-019', '2026-04-04', '2028-12-15', 60, 6, 'Rack B-08', 2),
(20, 20, 3, 'LOTE-BEB-PIL-020', '2026-05-07', '2027-05-28', 80, 80, 'Rack B-09', 2),
(21, 21, 10, 'LOTE-BEB-COC-021', '2026-06-10', '2028-10-15', 87, 79, 'Rack B-10', 2),
(22, 22, 3, 'LOTE-BEB-COC-022', '2026-07-13', '2027-03-28', 94, 94, 'Rack B-11', 2),
(23, 23, 10, 'LOTE-BEB-KOL-023', '2026-08-16', '2028-08-15', 101, 101, 'Rack B-12', 2),
(24, 24, 3, 'LOTE-BEB-INC-024', '2026-03-19', '2027-01-28', 108, 102, 'Rack B-01', 2),
(25, 25, 10, 'LOTE-BEB-INC-025', '2026-04-22', '2028-06-15', 115, 115, 'Rack B-02', 2),
(26, 26, 3, 'LOTE-BEB-FRU-026', '2026-05-25', '2027-11-28', 122, 122, 'Rack B-03', 2),
(27, 27, 10, 'LOTE-BEB-PUL-027', '2026-06-01', '2028-04-15', 129, 125, 'Rack B-04', 2),
(28, 28, 3, 'LOTE-BEB-FRE-028', '2026-07-04', '2027-09-28', 136, 136, 'Rack B-05', 2),
(29, 29, 10, 'LOTE-BEB-VOL-029', '2026-08-07', '2028-02-15', 143, 143, 'Rack B-06', 2),
(30, 30, 3, 'LOTE-BEB-GLO-030', '2026-03-10', '2027-07-28', 150, 150, 'Rack B-07', 2),
(31, 31, 10, 'LOTE-LIM-CLA-031', '2026-04-13', NULL, 157, 157, 'Rack C-08', 2),
(32, 32, 4, 'LOTE-LIM-TEK-032', '2026-05-16', '2027-05-28', 164, 164, 'Rack C-09', 2),
(33, 33, 10, 'LOTE-LIM-ACE-033', '2026-06-19', '2028-10-15', 171, 171, 'Rack C-10', 2),
(34, 34, 4, 'LOTE-LIM-BOL-034', '2026-07-22', '2027-03-28', 178, 168, 'Rack C-11', 2),
(35, 35, 10, 'LOTE-LIM-OPA-035', '2026-08-25', '2028-08-15', 65, 65, 'Rack C-12', 2),
(36, 36, 4, 'LOTE-LIM-SCO-036', '2026-03-01', NULL, 72, 72, 'Rack C-01', 2),
(37, 37, 10, 'LOTE-LIM-AYU-037', '2026-04-04', '2028-06-15', 79, 77, 'Rack C-02', 2),
(38, 38, 4, 'LOTE-LIM-SAP-038', '2026-05-07', '2027-11-28', 86, 86, 'Rack C-03', 2),
(39, 39, 10, 'LOTE-LIM-CLO-039', '2026-06-10', '2028-04-15', 60, 6, 'Rack C-04', 2),
(40, 40, 4, 'LOTE-LIM-SAP-040', '2026-07-13', '2027-09-28', 100, 100, 'Rack C-05', 2),
(41, 41, 10, 'LOTE-LIM-POE-041', '2026-08-16', '2028-02-15', 107, 107, 'Rack C-06', 2),
(42, 42, 4, 'LOTE-LIM-SAP-042', '2026-03-19', '2027-07-28', 114, 114, 'Rack C-07', 2),
(43, 43, 10, 'LOTE-LIM-PAR-043', '2026-04-22', NULL, 121, 121, 'Rack C-08', 2),
(44, 44, 4, 'LOTE-LIM-NOV-044', '2026-05-25', NULL, 128, 128, 'Rack C-09', 2),
(45, 45, 10, 'LOTE-LIM-DOW-045', '2026-06-01', '2028-10-15', 135, 135, 'Rack C-10', 2),
(46, 46, 5, 'LOTE-CUI-GIL-046', '2026-07-04', NULL, 142, 142, 'Rack D-11', 2),
(47, 47, 9, 'LOTE-CUI-COL-047', '2026-08-07', NULL, 149, 149, 'Rack D-12', 2),
(48, 48, 5, 'LOTE-CUI-COL-048', '2026-03-10', '2027-01-28', 156, 154, 'Rack D-01', 2),
(49, 49, 9, 'LOTE-CUI-KOL-049', '2026-04-13', '2028-06-15', 163, 163, 'Rack D-02', 2),
(50, 50, 5, 'LOTE-CUI-NIV-050', '2026-05-16', '2027-11-28', 170, 170, 'Rack D-03', 2),
(51, 51, 9, 'LOTE-CUI-REX-051', '2026-06-19', '2028-04-15', 177, 177, 'Rack D-04', 2),
(52, 52, 5, 'LOTE-CUI-BOL-052', '2026-07-22', '2027-09-28', 64, 64, 'Rack D-05', 2),
(53, 53, 9, 'LOTE-CUI-CAM-053', '2026-08-25', '2028-02-15', 71, 71, 'Rack D-06', 2),
(54, 54, 5, 'LOTE-CUI-AVA-054', '2026-03-01', '2027-07-28', 78, 78, 'Rack D-07', 2),
(55, 55, 9, 'LOTE-CUI-BAB-055', '2026-04-04', '2028-12-15', 85, 83, 'Rack D-08', 2),
(56, 56, 5, 'LOTE-CUI-HEA-056', '2026-05-07', '2027-05-28', 92, 92, 'Rack D-09', 2),
(57, 57, 9, 'LOTE-CUI-SED-057', '2026-06-10', '2028-10-15', 99, 96, 'Rack D-10', 2),
(58, 58, 5, 'LOTE-CUI-SED-058', '2026-07-13', '2027-03-28', 40, 0, 'Rack D-11', 2),
(59, 59, 9, 'LOTE-CUI-LAD-059', '2026-08-16', '2028-08-15', 113, 113, 'Rack D-12', 2),
(60, 60, 5, 'LOTE-CUI-NOS-060', '2026-03-19', '2027-01-28', 120, 120, 'Rack D-01', 2);

-- Compras realizadas por los bodegueros
INSERT INTO compras (compra_id, codigo_compra, bodeguero_id, direccion_id, subtotal, igv, total, estado_pedido, fecha_compra) VALUES
(1, 'COM-2026-0001', 1, 1, 979.66, 176.34, 1156.00, 'ENTREGADO', '2026-09-02 09:15:00'),
(2, 'COM-2026-0002', 2, 2, 877.12, 157.88, 1035.00, 'ENTREGADO', '2026-09-08 16:40:00'),
(3, 'COM-2026-0003', 3, 3, 984.75, 177.25, 1162.00, 'DESPACHADO', '2026-09-14 11:05:00'),
(4, 'COM-2026-0004', 4, 4, 1107.63, 199.37, 1307.00, 'PREPARANDO', '2026-09-16 08:30:00');

-- Detalle de compras
INSERT INTO detalle_compras (compra_id, producto_id, lote_id, cantidad, precio_unitario, total_linea) VALUES
(1, 1, 1, 4, 128.00, 512.00),
(1, 5, 5, 3, 108.00, 324.00),
(1, 24, 24, 6, 34.00, 204.00),
(1, 37, 37, 2, 58.00, 116.00),
(2, 12, 12, 5, 115.00, 575.00),
(2, 21, 21, 8, 34.00, 272.00),
(2, 48, 48, 2, 94.00, 188.00),
(3, 9, 9, 6, 60.00, 360.00),
(3, 34, 34, 10, 38.00, 380.00),
(3, 57, 57, 3, 90.00, 270.00),
(3, 27, 27, 4, 38.00, 152.00),
(4, 6, 6, 3, 145.00, 435.00),
(4, 19, 19, 5, 66.00, 330.00),
(4, 39, 39, 6, 53.00, 318.00),
(4, 55, 55, 2, 112.00, 224.00);

-- Guias de remision (documento completo para el transportista)
INSERT INTO guias_remision (guia_id, compra_id, codigo_guia, total_bultos, peso_total_kg, costo_total, detalle_carga, observaciones, emitida_por, fecha_emision) VALUES
(1, 1, 'GR-2026-0001', 15, 182.50, 1156.00, '4 x Aceite Primor Premium (Caja x 12 und); 3 x Avena 3 Ositos Tradicional (Caja x 24 bolsas); 6 x Inca Kola (Fardo x 12 und); 2 x Lavavajillas Líquido Ayudín Limón (Caja x 12 und)', 'Cliente recibe solo hasta las 13:00 horas.', 2, '2026-09-02 12:00:00'),
(2, 2, 'GR-2026-0002', 15, 146.20, 1035.00, '5 x Leche Gloria Azul (Caja x 24 und); 8 x Coca Cola (Fardo x 12 und); 2 x Crema Dental Colgate Triple Acción (Caja x 36 tubos)', 'Descarga por la puerta lateral del local.', 2, '2026-09-08 18:00:00'),
(3, 3, 'GR-2026-0003', 23, 215.80, 1162.00, '6 x Fideos Don Vittorio Spaghetti (Paquete x 20 und); 10 x Detergente Bolívar Floral (Bolsa x 5.8 kg); 3 x Shampoo Sedal Ceramidas (Caja x 12 botellas); 4 x Néctar Pulp Durazno (Fardo x 24 cajitas)', 'Coordinar con el Sr. Miguel Paredes antes de llegar.', 2, '2026-09-15 08:00:00'),
(4, 4, 'GR-2026-0004', 16, 263.40, 1307.00, '3 x Azúcar Rubia Paramonga (Saco x 50 kg); 5 x Cerveza Cristal (Caja x 12 botellas); 6 x Lejía Clorox Tradicional (Caja x 15 botellas); 2 x Pañales Babysec Super Premium XXG (Fardo x 4 paquetes)', 'Ingreso vehicular restringido, usar carretilla desde la puerta 3.', 2, '2026-09-16 10:00:00');

-- Rutas de despacho
INSERT INTO rutas_despacho (ruta_id, guia_id, transportista_id, vehiculo_placa, punto_partida, direccion_destino_id, descripcion_ruta, estado_entrega, hora_salida, hora_entrega, notas_entrega) VALUES
(1, 1, 3, 'ABC-123', 'Almacén central Abastece+ - Av. Argentina 4200, Santa Anita', 1, 'Santa Anita → Rímac por Av. Abancay y Jr. Trujillo', 'ENTREGADO', '2026-09-02 13:30:00', '2026-09-02 15:10:00', 'Entregado conforme al Sr. Jorge Huamán en el Minimarket Don Jorge.'),
(2, 2, 3, 'ABC-123', 'Almacén central Abastece+ - Av. Argentina 4200, Santa Anita', 2, 'Santa Anita → Los Olivos por Panamericana Norte hasta Av. Palmeras', 'ENTREGADO', '2026-09-09 08:00:00', '2026-09-09 10:25:00', 'Recibido por la Sra. Rosa Condori, propietaria de Bodega Doña Rosa.'),
(3, 3, 3, 'ABC-123', 'Almacén central Abastece+ - Av. Argentina 4200, Santa Anita', 3, 'Santa Anita → Villa El Salvador por Panamericana Sur hasta Sector 3', 'EN_TRAYECTO', '2026-09-17 07:40:00', NULL, NULL),
(4, 4, 3, 'ABC-123', 'Almacén central Abastece+ - Av. Argentina 4200, Santa Anita', 4, 'Santa Anita → Ate por Av. Nicolás Ayllón', 'ASIGNADO', NULL, NULL, NULL);

-- Incidencias atendidas por gestion de atencion
INSERT INTO atencion_incidencias (incidencia_id, bodeguero_id, compra_id, gestor_usuario_id, tipo_incidencia, descripcion, estado_atencion, conformidad_final, fecha_reporte, fecha_solucion) VALUES
(1, 1, 1, 4, 'PRODUCTO_DANADO', 'Una caja de aceite Primor llegó con la esquina del empaque rota.', 'SOLUCIONADO', 'El Sr. Jorge Huamán aceptó la reposición de la caja en el siguiente despacho y quedó conforme con la atención.', '2026-09-02 16:00:00', '2026-09-03 09:30:00'),
(2, 2, 2, 4, 'PEDIDO_INCOMPLETO', 'Llegaron 7 fardos de Coca Cola en lugar de los 8 solicitados.', 'EN_REVISION', NULL, '2026-09-09 11:00:00', NULL),
(3, 4, NULL, 4, 'OTRO', 'La Sra. Carmen Rojas consulta si puede registrar una segunda dirección de entrega en el Callao.', 'SOLUCIONADO', 'Se registró la dirección adicional y la clienta confirmó que ya la visualiza en su cuenta.', '2026-09-12 09:15:00', '2026-09-12 10:00:00');

-- Comprobantes de pago emitidos
INSERT INTO tarjetas_prueba (tarjeta_id,banco,marca,numero,ultimos_digitos,titular,vencimiento,cvv,color_inicio,color_fin) VALUES
(1,'BCP','VISA','4111 1111 1111 1111','1111','MINIMARKET DON JORGE','12/29','123','#082d72','#0067b1'),
(2,'Interbank','MASTERCARD','5555 5555 5555 4444','4444','BODEGA DOÑA ROSA','10/30','456','#006b54','#00a88f'),
(3,'Scotiabank','VISA','4000 0566 5566 5556','5556','MARKET EL VECINO','08/31','789','#8b0015','#ec111a'),
(4,'BBVA','VISA','4000 0035 6000 0008','0008','CARMEN ROJAS VILLAVERDE','06/30','321','#061f5c','#1973b8'),
(5,'Banco Pichincha','MASTERCARD','5105 1051 0510 5100','5100','JORGE HUAMAN QUISPE','04/31','654','#f2b600','#765400');

INSERT INTO comprobantes_pago (comprobante_id, compra_id, tipo_comprobante, serie, correlativo, ruc_emisor, ruc_receptor, subtotal, igv, total, metodo_pago, codigo_operacion, fecha_emision) VALUES
(1, 1, 'FACTURA_ELECTRONICA', 'F001', 1, '20601234999', '20601234501', 979.66, 176.34, 1156.00, 'YAPE', 'YAPE-OP-98341209', '2026-09-02 12:05:00'),
(2, 2, 'FACTURA_ELECTRONICA', 'F001', 2, '20601234999', '20601234502', 877.12, 157.88, 1035.00, 'TRANSFERENCIA_BANCARIA', 'BCP-TRF-4471902', '2026-09-08 18:05:00'),
(3, 3, 'BOLETA_ELECTRONICA', 'B001', 3, '20601234999', '20601234503', 984.75, 177.25, 1162.00, 'PLIN', 'PLIN-OP-77120458', '2026-09-15 08:10:00'),
(4, 4, 'FACTURA_ELECTRONICA', 'F001', 4, '20601234999', '20601234504', 1107.63, 199.37, 1307.00, 'EFECTIVO', 'CAJA-2026-000318', '2026-09-16 10:05:00');
-- Conformidad de productos independiente de una incidencia.
CREATE TABLE conformidades_producto (
 conformidad_id INT AUTO_INCREMENT PRIMARY KEY,
 detalle_compra_id INT NOT NULL UNIQUE,
 estado ENUM('PENDIENTE','CONFORME','NO_CONFORME') NOT NULL DEFAULT 'PENDIENTE',
 observaciones TEXT NULL,
 revisado_por INT NULL,
 actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (detalle_compra_id) REFERENCES detalle_compras(detalle_compra_id),
 FOREIGN KEY (revisado_por) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;
INSERT INTO conformidades_producto (detalle_compra_id) SELECT detalle_compra_id FROM detalle_compras;

UPDATE compras c JOIN guias_remision g ON g.compra_id=c.compra_id JOIN rutas_despacho r ON r.guia_id=g.guia_id SET c.estado_pedido=CASE WHEN r.estado_entrega='ENTREGADO' THEN 'ENTREGADO' WHEN r.estado_entrega='EN_TRAYECTO' THEN 'DESPACHADO' ELSE 'PREPARANDO' END WHERE c.compra_id > 0;

CREATE TABLE movimientos_stock (
 movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
 lote_id INT NOT NULL,
 variacion INT NOT NULL,
 motivo VARCHAR(255) NOT NULL,
 registrado_por INT NOT NULL,
 creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (lote_id) REFERENCES inventario_lotes(lote_id),
 FOREIGN KEY (registrado_por) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

-- =============================================================================
-- CONSULTA DE REFERENCIA: CREDENCIALES DE ACCESO
-- Esta consulta SOLO MUESTRA las contraseñas, NO modifica la base de datos.
-- Ejecutar manualmente en el cliente SQL cuando se necesite recordar las claves.
-- =============================================================================
SELECT tipo_cuenta, nombre_completo, correo, contrasena, rol_o_negocio
FROM (
    SELECT 'INTERNO' AS tipo_cuenta,
           CONCAT(nombre, ' ', apellidos) AS nombre_completo,
           correo,
           CASE usuario_interno_id
               WHEN 1  THEN 'carlos123'
               WHEN 2  THEN 'maria123'
               WHEN 3  THEN 'luis123'
               WHEN 4  THEN 'andrea123'
               WHEN 5  THEN 'juan123'
               WHEN 6  THEN 'ana123'
               WHEN 7  THEN 'roberto123'
               WHEN 8  THEN 'diana123'
               WHEN 9  THEN 'javier123'
               WHEN 10 THEN 'lucia123'
               WHEN 11 THEN 'gonzalo123'
               WHEN 12 THEN 'valeria123'
               WHEN 13 THEN 'manuel123'
               WHEN 14 THEN 'pedro123'
               WHEN 15 THEN 'cesar123'
               WHEN 16 THEN 'jorge123'
               WHEN 17 THEN 'claudia123'
               WHEN 18 THEN 'gabriel123'
               WHEN 19 THEN 'monica123'
               WHEN 20 THEN 'daniel123'
           END AS contrasena,
           rol AS rol_o_negocio
    FROM usuarios_internos
    UNION ALL
    SELECT 'BODEGUERO' AS tipo_cuenta,
           CONCAT(nombre, ' ', apellidos) AS nombre_completo,
           correo,
           CASE bodeguero_id
               WHEN 1  THEN 'jorge123'
               WHEN 2  THEN 'rosa123'
               WHEN 3  THEN 'miguel123'
               WHEN 4  THEN 'carmen123'
               WHEN 5  THEN 'patricia123'
               WHEN 6  THEN 'ricardo123'
               WHEN 7  THEN 'elena123'
               WHEN 8  THEN 'fernando123'
               WHEN 9  THEN 'daniela123'
               WHEN 10 THEN 'raul123'
               WHEN 11 THEN 'sofia123'
               WHEN 12 THEN 'hector123'
               WHEN 13 THEN 'valentina123'
               WHEN 14 THEN 'oscar123'
           END AS contrasena,
           nombre_comercial AS rol_o_negocio
    FROM bodegueros
) credenciales
ORDER BY tipo_cuenta DESC, nombre_completo;
