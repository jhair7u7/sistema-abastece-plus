-- =============================================================================
-- BASE DE DATOS: ABASTECE+ (ARQUITECTURA TRANSACCIONAL Y ROLES SEPARADOS)
-- MOTOR: MySQL 8.0+ | INNODB | UTF8MB4
-- =============================================================================

DROP DATABASE IF EXISTS abastece_plus_db;
CREATE DATABASE abastece_plus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE abastece_plus_db;

-- -----------------------------------------------------------------------------
-- 1. USUARIOS INTERNOS DEL SISTEMA
-- Roles: Administrador, Transportista, Gestor de Atención, Logística
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
-- 2. USUARIOS EXTERNOS (BODEGUEROS / COMERCIOS AFILIADOS)
-- -----------------------------------------------------------------------------
CREATE TABLE bodegueros (
    bodeguero_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    ruc CHAR(11) UNIQUE NOT NULL,
    tipo_establecimiento ENUM('BODEGA', 'MINIMARKET', 'MARKET_LOCAL', 'OTROS') NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    email_verificado BOOLEAN DEFAULT FALSE,
    token_verificacion_correo VARCHAR(100) NULL,
    email_verificado_en TIMESTAMP NULL,
    linea_credito_max DECIMAL(10,2) DEFAULT 0.00,
    credito_utilizado DECIMAL(10,2) DEFAULT 0.00,
    estado_cuenta ENUM('PENDIENTE_VERIFICACION', 'ACTIVO', 'BLOQUEADO') DEFAULT 'PENDIENTE_VERIFICACION',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. PROVEEDORES MAYORISTAS (SRM)
-- -----------------------------------------------------------------------------
CREATE TABLE proveedores (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    ruc CHAR(11) UNIQUE NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    contacto_nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    reputacion_srm DECIMAL(3,2) DEFAULT 5.00,
    tiempo_promedio_entrega_hrs INT DEFAULT 24,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. DIRECCIONES DE ENTREGA Y ALMACENES
-- -----------------------------------------------------------------------------
CREATE TABLE direcciones (
    direccion_id INT AUTO_INCREMENT PRIMARY KEY,
    bodeguero_id INT NULL,
    proveedor_id INT NULL,
    departamento VARCHAR(50) DEFAULT 'Lima',
    provincia VARCHAR(50) DEFAULT 'Lima',
    distrito VARCHAR(60) NOT NULL,
    direccion_exacta VARCHAR(200) NOT NULL,
    referencia VARCHAR(200),
    zona_reparto ENUM('LIMA_CENTRO', 'LIMA_NORTE', 'LIMA_SUR', 'LIMA_ESTE', 'CALLAO') NOT NULL,
    codigo_postal VARCHAR(10),
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id) ON DELETE CASCADE,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id) ON DELETE CASCADE,
    -- Validación: la dirección pertenece a una bodega o a un proveedor, jamás a ambos o a ninguno
    CONSTRAINT chk_entidad_direccion CHECK (
        (bodeguero_id IS NOT NULL AND proveedor_id IS NULL) OR 
        (bodeguero_id IS NULL AND proveedor_id IS NOT NULL)
    )
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. CATÁLOGO Y GESTIÓN DE STOCK FIFO
-- -----------------------------------------------------------------------------
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    codigo_sku VARCHAR(50) UNIQUE NOT NULL,
    codigo_barras VARCHAR(30) UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    marca VARCHAR(80) NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL,
    peso_kg DECIMAL(8,2) NOT NULL,
    precio_base_sugerido DECIMAL(10,2) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
) ENGINE=InnoDB;

CREATE TABLE productos_proveedor_escalas (
    escala_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    cantidad_minima INT NOT NULL,
    cantidad_maxima INT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id) ON DELETE CASCADE,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE inventario_lotes (
    lote_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    numero_lote VARCHAR(50) NOT NULL,
    fecha_elaboracion DATE NULL,
    fecha_vencimiento DATE NOT NULL,
    stock_ingresado INT NOT NULL,
    stock_disponible INT NOT NULL,
    ubicacion_almacen VARCHAR(60) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id),
    CONSTRAINT chk_stock_lote CHECK (stock_disponible >= 0)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. TRANSACCIONES: SOLICITUDES Y PEDIDOS FIRMES
-- -----------------------------------------------------------------------------
CREATE TABLE solicitudes_abastecimiento (
    solicitud_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_solicitud VARCHAR(30) UNIQUE NOT NULL,
    bodeguero_id INT NOT NULL,
    direccion_id INT NOT NULL,
    estado ENUM('PENDIENTE', 'COTIZADA', 'APROBADA', 'RECHAZADA') DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id),
    FOREIGN KEY (direccion_id) REFERENCES direcciones(direccion_id)
) ENGINE=InnoDB;

CREATE TABLE detalle_solicitudes (
    detalle_solicitud_id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad_requerida INT NOT NULL,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes_abastecimiento(solicitud_id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

CREATE TABLE pedidos_ordenes (
    orden_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_orden VARCHAR(35) UNIQUE NOT NULL,
    solicitud_id INT NOT NULL,
    bodeguero_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    direccion_id INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    igv DECIMAL(10,2) NOT NULL,
    costo_envio DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    logistica_usuario_id INT NULL, 
    estado_pedido ENUM('EN_PREPARACION', 'LISTO_PARA_RUTA', 'EN_RUTA', 'ENTREGADO', 'CANCELADO') DEFAULT 'EN_PREPARACION',
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes_abastecimiento(solicitud_id),
    FOREIGN KEY (bodeguero_id) REFERENCES bodegueros(bodeguero_id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(proveedor_id),
    FOREIGN KEY (direccion_id) REFERENCES direcciones(direccion_id),
    FOREIGN KEY (logistica_usuario_id) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

CREATE TABLE detalle_ordenes (
    detalle_orden_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    producto_id INT NOT NULL,
    lote_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_linea DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (orden_id) REFERENCES pedidos_ordenes(orden_id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    FOREIGN KEY (lote_id) REFERENCES inventario_lotes(lote_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. MÓDULO TRANSPORTISTA
-- -----------------------------------------------------------------------------
CREATE TABLE rutas_despacho (
    ruta_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL UNIQUE,
    transportista_id INT NOT NULL,
    vehiculo_placa VARCHAR(10) NOT NULL,
    estado_entrega ENUM('ASIGNADO', 'EN_TRAYECTO', 'ENTREGADO', 'FALLIDO') DEFAULT 'ASIGNADO',
    hora_salida DATETIME NULL,
    hora_entrega DATETIME NULL,
    notas_entrega TEXT,
    FOREIGN KEY (orden_id) REFERENCES pedidos_ordenes(orden_id),
    FOREIGN KEY (transportista_id) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. MÓDULO ATENCIÓN: INCIDENCIAS (GESTOR DE ATENCIÓN)
-- -----------------------------------------------------------------------------
CREATE TABLE atencion_incidencias (
    incidencia_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL,
    gestor_usuario_id INT NULL, 
    tipo_incidencia ENUM('PRODUCTO_DANADO', 'PEDIDO_INCOMPLETO', 'PRODUCTO_PROXIMO_VENCER', 'DEMORA_ENTREGA', 'OTRO') NOT NULL,
    descripcion TEXT NOT NULL,
    estado_atencion ENUM('ABIERTO', 'EN_REVISION', 'SOLUCIONADO', 'RECHAZADO') DEFAULT 'ABIERTO',
    conformidad_final BOOLEAN DEFAULT FALSE,
    resolucion TEXT NULL,
    fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_solucion DATETIME NULL,
    FOREIGN KEY (orden_id) REFERENCES pedidos_ordenes(orden_id),
    FOREIGN KEY (gestor_usuario_id) REFERENCES usuarios_internos(usuario_interno_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. FACTURACIÓN ELECTRÓNICA
-- -----------------------------------------------------------------------------
CREATE TABLE comprobantes_pago (
    comprobante_id INT AUTO_INCREMENT PRIMARY KEY,
    orden_id INT NOT NULL UNIQUE,
    tipo_comprobante ENUM('FACTURA_ELECTRONICA', 'BOLETA_ELECTRONICA') NOT NULL,
    serie VARCHAR(4) NOT NULL,
    numero VARCHAR(8) NOT NULL,
    ruc_emisor CHAR(11) NOT NULL,
    ruc_receptor CHAR(11) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    igv DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('YAPE', 'PLIN', 'TRANSFERENCIA_BANCARIA', 'LINEA_CREDITO') NOT NULL,
    codigo_operacion VARCHAR(100) NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orden_id) REFERENCES pedidos_ordenes(orden_id)
) ENGINE=InnoDB;

-- =============================================================================
-- PROCEDIMIENTO ALMACENADO: DESPACHO CON LÓGICA FIFO
-- =============================================================================
DELIMITER $$

CREATE PROCEDURE sp_despachar_orden_fifo(
    IN p_orden_id INT,
    IN p_producto_id INT,
    IN p_cantidad_solicitada INT,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE v_lote_id INT;
    DECLARE v_stock_disponible INT;
    DECLARE v_cantidad_a_descontar INT;
    DECLARE v_cantidad_restante INT DEFAULT p_cantidad_solicitada;
    DECLARE done INT DEFAULT FALSE;

    -- Cursor que prioriza lotes próximos a vencer (FIFO)
    DECLARE cur_lotes CURSOR FOR 
        SELECT lote_id, stock_disponible 
        FROM inventario_lotes 
        WHERE producto_id = p_producto_id AND stock_disponible > 0
        ORDER BY lote_id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    OPEN cur_lotes;

    read_loop: LOOP
        FETCH cur_lotes INTO v_lote_id, v_stock_disponible;
        IF done OR v_cantidad_restante <= 0 THEN
            LEAVE read_loop;
        END IF;

        IF v_stock_disponible >= v_cantidad_restante THEN
            SET v_cantidad_a_descontar = v_cantidad_restante;
        ELSE
            SET v_cantidad_a_descontar = v_stock_disponible;
        END IF;

        -- 1. Descontar inventario del lote seleccionado
        UPDATE inventario_lotes 
        SET stock_disponible = stock_disponible - v_cantidad_a_descontar 
        WHERE lote_id = v_lote_id;

        -- 2. Registrar el desglose exacto en detalle_ordenes
        INSERT INTO detalle_ordenes (orden_id, producto_id, lote_id, cantidad, precio_unitario, total_linea)
        VALUES (p_orden_id, p_producto_id, v_lote_id, v_cantidad_a_descontar, p_precio_unitario, (v_cantidad_a_descontar * p_precio_unitario));

        SET v_cantidad_restante = v_cantidad_restante - v_cantidad_a_descontar;
    END LOOP;

    CLOSE cur_lotes;

    -- Validar si se cubrió el total solicitado
    IF v_cantidad_restante > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error FIFO: Stock insuficiente en almacén para completar el despacho del ítem.';
    ELSE
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- INSERTS DE PRUEBA
-- =============================================================================

-- 1. Usuarios Internos
INSERT INTO usuarios_internos (usuario_interno_id, nombre, apellidos, correo, password_hash, telefono, rol) VALUES
(1, 'Manuel', 'Alcantara', 'admin@abasteceplus.pe', '$2y$10$e8T7Q6EwG4nQ0t6U5Xz1euKkI/E6hJ2/O0gQ3jQ1yP.c.Z5iQn6pG', '999111222', 'ADMINISTRADOR'),
(2, 'Jorge', 'Perez Cisneros', 'transporte1@abasteceplus.pe', '$2y$10$1Y8hE7nE8xI8sO9qP3u7e.m8B6kP4aT1vR2sD3fG4hJ5kL6zX7cV.', '999333444', 'TRANSPORTISTA'),
(3, 'Sofia', 'Mendoza Vivas', 'atencion.soporte@abasteceplus.pe', '$2y$10$w8T9Q0EwG4nQ0t6U5Xz1euKkI/E6hJ2/O0gQ3jQ1yP.c.Z5iQn6pG', '999555666', 'GESTOR_ATENCION'),
(4, 'Ricardo', 'Lozano Paredes', 'logistica@abasteceplus.pe', '$2y$10$v8T9Q0EwG4nQ0t6U5Xz1euKkI/E6hJ2/O0gQ3jQ1yP.c.Z5iQn6pG', '999777888', 'LOGISTICA');

UPDATE usuarios_internos
SET password_hash = SHA2('admin123', 256)
WHERE usuario_interno_id = 1;

UPDATE usuarios_internos
SET password_hash = SHA2('transporte123', 256)
WHERE usuario_interno_id = 2;

UPDATE usuarios_internos
SET password_hash = SHA2('atencion123', 256)
WHERE usuario_interno_id = 3;

UPDATE usuarios_internos
SET password_hash = SHA2('logistica123', 256)
WHERE usuario_interno_id = 4;

-- 2. Usuarios Externos (Bodegueros)
INSERT INTO bodegueros (
    bodeguero_id, nombre, apellidos, correo, password_hash, telefono, ruc, 
    tipo_establecimiento, nombre_comercial, razon_social, 
    email_verificado, token_verificacion_correo, email_verificado_en, 
    linea_credito_max, credito_utilizado, estado_cuenta
) VALUES 
(
    1, 'Rosa Elena', 'Quispe Mendoza', 'dona.rosa@gmail.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '987654321', '10456892317', 'MINIMARKET', 'Minimarket Doña Rosa', 'Rosa Elena Quispe Mendoza',
    TRUE, 'tok_auth_987f65a43b21c', '2026-08-25 10:00:00',
    4500.00, 0.00, 'ACTIVO'
),
(
    2, 'Carlos Alberto', 'Flores Ruiz', 'bodega.charly@gmail.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '976543210', '10328765431', 'BODEGA', 'Bodega San Carlos', 'Carlos Alberto Flores Ruiz',
    TRUE, 'tok_auth_123a45b67c89d', '2026-08-26 14:30:00',
    2000.00, 0.00, 'ACTIVO'
);

-- 3. Proveedores Mayoristas
INSERT INTO proveedores (proveedor_id, ruc, razon_social, nombre_comercial, contacto_nombre, correo, telefono, reputacion_srm) VALUES
(1, '20601487523', 'Distribuidora Mayorista San Jacinto S.A.C.', 'Distribuidora San Jacinto', 'Carlos San Jacinto', 'ventas@sanjacinto.pe', '912345678', 4.95),
(2, '20509876124', 'Comercializadora Alimentos del Norte E.I.R.L.', 'Alimentos del Norte', 'Marita Gonzales', 'contacto@alimentosnorte.pe', '923456789', 4.80);

-- 4. Direcciones (Validadas por Check)
INSERT INTO direcciones (direccion_id, bodeguero_id, proveedor_id, departamento, provincia, distrito, direccion_exacta, referencia, zona_reparto, codigo_postal) VALUES
(1, 1, NULL, 'Lima', 'Lima', 'Rimac', 'Jr. Chiclayo 450', 'Frente a la Alameda de los Descalzos', 'LIMA_CENTRO', '15093'),
(2, 2, NULL, 'Lima', 'Lima', 'Los Olivos', 'Av. Las Palmeras 3820', 'A dos cuadras de Antúnez de Mayolo', 'LIMA_NORTE', '15301'),
(3, NULL, 1, 'Lima', 'Lima', 'Santa Anita', 'Av. De la Cultura 1200, Complejo B4', 'Mercado Mayorista', 'LIMA_ESTE', '15011');

-- 5. Catálogo
INSERT INTO categorias (categoria_id, nombre, descripcion) VALUES
(1, 'Abarrotes Basicos', 'Arroz, azucar, fideos, aceites y granos'),
(2, 'Lacteos y Derivados', 'Leche evaporada, quesos y mantequillas');

INSERT INTO productos (producto_id, categoria_id, codigo_sku, codigo_barras, nombre, descripcion, marca, unidad_medida, peso_kg, precio_base_sugerido) VALUES
(1, 1, 'ARR-COS-50KG', '775123456701', 'Arroz Costeño Extra 50 kg', 'Saco de arroz grano largo', 'Costeño', 'Saco x 50kg', 50.00, 185.00),
(2, 1, 'ACE-PRI-12L', '775123456702', 'Aceite Primor Clasico 1L (Caja x 12)', 'Caja de 12 botellas de 1L', 'Primor', 'Caja x 12', 12.00, 118.00),
(3, 2, 'LEC-GLO-AZUL', '775123456703', 'Leche Gloria Azul 400g (Plancha x 24)', 'Plancha de 24 latas de leche', 'Gloria', 'Plancha x 24', 9.60, 92.00);

-- Precios por Escalas
INSERT INTO productos_proveedor_escalas (producto_id, proveedor_id, cantidad_minima, cantidad_maxima, precio_unitario) VALUES
(1, 1, 1, 4, 185.00),
(1, 1, 5, 14, 178.00),
(1, 1, 15, NULL, 172.00),
(2, 1, 1, 5, 118.00),
(2, 1, 6, NULL, 112.00),
(3, 2, 1, 10, 92.00),
(3, 2, 11, NULL, 88.50);

-- Inventario Lotes (Stock inicial real)
INSERT INTO inventario_lotes (lote_id, producto_id, proveedor_id, numero_lote, fecha_elaboracion, fecha_vencimiento, stock_ingresado, stock_disponible, ubicacion_almacen) VALUES
(1, 1, 1, 'LOTE-ARR-2026-A1', '2026-06-01', '2027-01-15', 100, 100, 'Rack A-01'),
(2, 2, 1, 'LOTE-ACE-2026-01', '2026-05-15', '2027-09-20', 120, 120, 'Rack B-03'),
(3, 3, 2, 'LOTE-GLO-2026-05', '2026-07-01', '2027-06-30', 80, 80, 'Rack C-02');

-- 6. Transacciones: Solicitudes de Abastecimiento
-- Solicitud 1: Aprobada y despachada a Orden
INSERT INTO solicitudes_abastecimiento (solicitud_id, codigo_solicitud, bodeguero_id, direccion_id, estado, fecha_creacion) VALUES
(1, 'SOL-2026-001', 1, 1, 'APROBADA', '2026-09-01 09:15:00');

INSERT INTO detalle_solicitudes (solicitud_id, producto_id, cantidad_requerida) VALUES
(1, 1, 10),
(1, 2, 6);

-- Solicitud 2: Pendiente de cotización y revisión por Logística
INSERT INTO solicitudes_abastecimiento (solicitud_id, codigo_solicitud, bodeguero_id, direccion_id, estado, fecha_creacion) VALUES
(2, 'SOL-2026-002', 2, 2, 'PENDIENTE', '2026-09-03 16:40:00');

INSERT INTO detalle_solicitudes (solicitud_id, producto_id, cantidad_requerida) VALUES
(2, 3, 15);

-- Orden Generada a partir de Solicitud 1
INSERT INTO pedidos_ordenes (
    orden_id, codigo_orden, solicitud_id, bodeguero_id, proveedor_id, direccion_id,
    subtotal, igv, costo_envio, total, logistica_usuario_id, estado_pedido, fecha_orden
) VALUES (
    1, 'ORD-2026-00045', 1, 1, 1, 1,
    2077.97, 374.03, 30.00, 2482.00, 4, 'EN_RUTA', '2026-09-02 08:00:00'
);

-- Se ejecuta la lógica FIFO para descontar lotes y poblar detalle_ordenes:
CALL sp_despachar_orden_fifo(1, 1, 10, 178.00); -- Consume 10 sacos de Arroz
CALL sp_despachar_orden_fifo(1, 2, 6, 112.00);  -- Consume 6 cajas de Aceite

-- 7. Despacho en Ruta
INSERT INTO rutas_despacho (ruta_id, orden_id, transportista_id, vehiculo_placa, estado_entrega, hora_salida, notas_entrega) VALUES
(1, 1, 2, 'B3X-892', 'EN_TRAYECTO', '2026-09-02 08:30:00', 'Entregar en Minimarket Doña Rosa (Rímac)');

-- 8. Incidencia y Solución (Gestor de Atención)
INSERT INTO atencion_incidencias (incidencia_id, orden_id, gestor_usuario_id, tipo_incidencia, descripcion, estado_atencion, conformidad_final, resolucion) VALUES
(1, 1, 3, 'PRODUCTO_DANADO', '1 saco de arroz con raspadura en empaque externo', 'SOLUCIONADO', TRUE, 'Se verificó precinto interior intacto en presencia de la titular doña Rosa');

-- 9. Facturación Electrónica Emitida
INSERT INTO comprobantes_pago (comprobante_id, orden_id, tipo_comprobante, serie, numero, ruc_emisor, ruc_receptor, subtotal, igv, total, metodo_pago, codigo_operacion) VALUES
(1, 1, 'FACTURA_ELECTRONICA', 'F001', '00008412', '20601487523', '10456892317', 2077.97, 374.03, 2482.00, 'YAPE', 'YAPE-OP-98341209');


-- =============================================================================
-- BANCO EXHAUSTIVO DE CONSULTAS SQL (CON TODOS LOS INNER JOIN)
-- =============================================================================

-- =============================================================================
-- SECCIÓN 1: SOLICITUDES DE ABASTECIMIENTO Y PROCESO DE COTIZACIÓN
-- =============================================================================

-- 1.1. Bandeja de solicitudes de bodegas con datos del titular y dirección
SELECT 
    s.solicitud_id,
    s.codigo_solicitud,
    s.fecha_creacion,
    s.estado,
    b.nombre_comercial AS bodega,
    b.ruc AS ruc_bodega,
    CONCAT(b.nombre, ' ', b.apellidos) AS titular,
    b.telefono AS contacto_bodega,
    d.distrito,
    d.direccion_exacta,
    d.zona_reparto
FROM solicitudes_abastecimiento s
INNER JOIN bodegueros b ON s.bodeguero_id = b.bodeguero_id
INNER JOIN direcciones d ON s.direccion_id = d.direccion_id
ORDER BY s.fecha_creacion DESC;

-- 1.2. Detalle completo de productos requeridos en cada solicitud
SELECT 
    s.codigo_solicitud,
    s.estado AS estado_solicitud,
    b.nombre_comercial AS bodega,
    c.nombre AS categoria,
    p.codigo_sku,
    p.nombre AS producto,
    p.marca,
    p.unidad_medida,
    ds.cantidad_requerida,
    (ds.cantidad_requerida * p.peso_kg) AS peso_estimado_kg
FROM detalle_solicitudes ds
INNER JOIN solicitudes_abastecimiento s ON ds.solicitud_id = s.solicitud_id
INNER JOIN bodegueros b ON s.bodeguero_id = b.bodeguero_id
INNER JOIN productos p ON ds.producto_id = p.producto_id
INNER JOIN categorias c ON p.categoria_id = c.categoria_id
ORDER BY s.codigo_solicitud, p.nombre;

-- 1.3. Matriz de Cotización automática de solicitudes según escalas de proveedores
SELECT 
    s.codigo_solicitud,
    b.nombre_comercial AS bodega,
    p.nombre AS producto,
    ds.cantidad_requerida,
    pr.nombre_comercial AS proveedor_asignado,
    e.precio_unitario AS precio_escala,
    (ds.cantidad_requerida * e.precio_unitario) AS subtotal_linea_estimado
FROM detalle_solicitudes ds
INNER JOIN solicitudes_abastecimiento s ON ds.solicitud_id = s.solicitud_id
INNER JOIN bodegueros b ON s.bodeguero_id = b.bodeguero_id
INNER JOIN productos p ON ds.producto_id = p.producto_id
INNER JOIN productos_proveedor_escalas e ON p.producto_id = e.producto_id
INNER JOIN proveedores pr ON e.proveedor_id = pr.proveedor_id
WHERE (ds.cantidad_requerida >= e.cantidad_minima)
  AND (e.cantidad_maxima IS NULL OR ds.cantidad_requerida <= e.cantidad_maxima);

-- 1.4. Trazabilidad completa: Solicitud -> Orden generada -> Estado de entrega
SELECT 
    s.codigo_solicitud,
    s.fecha_creacion AS fecha_solicitud,
    s.estado AS estado_solicitud,
    o.codigo_orden,
    o.fecha_orden,
    o.estado_pedido,
    b.nombre_comercial AS bodega,
    pr.nombre_comercial AS proveedor,
    o.total AS total_orden
FROM solicitudes_abastecimiento s
INNER JOIN pedidos_ordenes o ON s.solicitud_id = o.solicitud_id
INNER JOIN bodegueros b ON o.bodeguero_id = b.bodeguero_id
INNER JOIN proveedores pr ON o.proveedor_id = pr.proveedor_id;


-- =============================================================================
-- SECCIÓN 2: AUDITORÍA DE INVENTARIO FIFO Y CATÁLOGO (ROL LOGÍSTICA)
-- =============================================================================

-- 2.1. Auditoría de lotes FIFO ordenada por vencimiento con cálculo de despacho
SELECT 
    p.codigo_sku,
    p.nombre AS producto,
    p.unidad_medida,
    pr.nombre_comercial AS proveedor,
    l.numero_lote,
    l.fecha_vencimiento,
    l.stock_ingresado,
    l.stock_disponible,
    (l.stock_ingresado - l.stock_disponible) AS stock_consumido,
    l.ubicacion_almacen
FROM inventario_lotes l
INNER JOIN productos p ON l.producto_id = p.producto_id
INNER JOIN proveedores pr ON l.proveedor_id = pr.proveedor_id
ORDER BY p.nombre, l.fecha_vencimiento ASC;

-- 2.2. Órdenes despachadas bajo control del personal de Logística
SELECT 
    o.codigo_orden,
    o.fecha_orden,
    b.nombre_comercial AS bodega_cliente,
    pr.nombre_comercial AS proveedor_origen,
    CONCAT(u.nombre, ' ', u.apellidos) AS responsable_logistica,
    o.estado_pedido,
    o.total
FROM pedidos_ordenes o
INNER JOIN bodegueros b ON o.bodeguero_id = b.bodeguero_id
INNER JOIN proveedores pr ON o.proveedor_id = pr.proveedor_id
INNER JOIN usuarios_internos u ON o.logistica_usuario_id = u.usuario_interno_id;


-- =============================================================================
-- SECCIÓN 3: RUTAS, DESPACHO Y CONTROL FÍSICO (ROL TRANSPORTISTA)
-- =============================================================================

-- 3.1. Hoja de ruta para el transportista con orden, cliente y dirección exacta
SELECT 
    r.ruta_id,
    r.vehiculo_placa,
    r.estado_entrega,
    r.hora_salida,
    o.codigo_orden,
    b.nombre_comercial AS bodega_destino,
    CONCAT(b.nombre, ' ', b.apellidos) AS receptor,
    b.telefono AS telefono_contacto,
    d.direccion_exacta,
    d.distrito,
    d.referencia,
    d.zona_reparto
FROM rutas_despacho r
INNER JOIN pedidos_ordenes o ON r.orden_id = o.orden_id
INNER JOIN bodegueros b ON o.bodeguero_id = b.bodeguero_id
INNER JOIN direcciones d ON o.direccion_id = d.direccion_id
INNER JOIN usuarios_internos u ON r.transportista_id = u.usuario_interno_id
WHERE r.transportista_id = 2;

-- 3.2. Manifiesto de carga: desglose físico de bultos y lotes para el transportista
SELECT 
    r.ruta_id,
    o.codigo_orden,
    p.nombre AS producto,
    p.unidad_medida,
    l.numero_lote,
    l.ubicacion_almacen,
    do_det.cantidad,
    p.peso_kg AS peso_unit_kg,
    (p.peso_kg * do_det.cantidad) AS peso_total_kg
FROM rutas_despacho r
INNER JOIN pedidos_ordenes o ON r.orden_id = o.orden_id
INNER JOIN detalle_ordenes do_det ON o.orden_id = do_det.orden_id
INNER JOIN productos p ON do_det.producto_id = p.producto_id
INNER JOIN inventario_lotes l ON do_det.lote_id = l.lote_id
WHERE r.transportista_id = 2;


-- =============================================================================
-- SECCIÓN 4: GESTIÓN DE INCIDENCIAS Y CONFORMIDAD (GESTOR DE ATENCIÓN)
-- =============================================================================

-- 4.1. Seguimiento de incidencias atendidas por el Gestor de Atención
SELECT 
    i.incidencia_id,
    o.codigo_orden,
    b.nombre_comercial AS bodega,
    b.telefono AS contacto_bodega,
    i.tipo_incidencia,
    i.descripcion AS reclamo_bodeguero,
    i.estado_atencion,
    i.conformidad_final,
    i.resolucion,
    CONCAT(u.nombre, ' ', u.apellidos) AS gestor_a_cargo,
    i.fecha_reporte,
    i.fecha_solucion
FROM atencion_incidencias i
INNER JOIN pedidos_ordenes o ON i.orden_id = o.orden_id
INNER JOIN bodegueros b ON o.bodeguero_id = b.bodeguero_id
INNER JOIN usuarios_internos u ON i.gestor_usuario_id = u.usuario_interno_id;


-- =============================================================================
-- SECCIÓN 5: FACTURACIÓN Y CUADRE CONTABLE SUNAT
-- =============================================================================

-- 5.1. Comprobante electrónico asociado a la orden, emisor (mayorista) y receptor (bodega)
SELECT 
    CONCAT(cp.serie, '-', cp.numero) AS comprobante_fiscal,
    cp.tipo_comprobante,
    o.codigo_orden,
    pr.razon_social AS mayorista_emisor,
    cp.ruc_emisor,
    b.razon_social AS bodega_receptora,
    cp.ruc_receptor,
    cp.subtotal AS valor_venta,
    cp.igv AS igv_18,
    o.costo_envio,
    cp.total AS importe_total,
    cp.metodo_pago,
    cp.codigo_operacion,
    cp.fecha_emision
FROM comprobantes_pago cp
INNER JOIN pedidos_ordenes o ON cp.orden_id = o.orden_id
INNER JOIN proveedores pr ON o.proveedor_id = pr.proveedor_id
INNER JOIN bodegueros b ON o.bodeguero_id = b.bodeguero_id;

-- 5.2. Verificación matemática entre las líneas del detalle y la factura
SELECT 
    o.codigo_orden,
    CONCAT(cp.serie, '-', cp.numero) AS comprobante,
    SUM(dod.total_linea) AS suma_productos_detalle,
    o.subtotal AS base_imponible_orden,
    o.igv AS igv_orden,
    o.costo_envio,
    o.total AS total_orden,
    cp.total AS total_comprobante,
    (SUM(dod.total_linea) + o.costo_envio) AS total_calculado
FROM pedidos_ordenes o
INNER JOIN comprobantes_pago cp ON o.orden_id = cp.orden_id
INNER JOIN detalle_ordenes dod ON o.orden_id = dod.orden_id
GROUP BY o.orden_id, cp.comprobante_id;