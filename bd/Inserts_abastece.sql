-- Abastece+ | Inserts organizados por tabla
-- Personas, contactos, DNI, RUC de comerciantes y placas son ficticios.
-- Razones sociales y RUC de proveedores son públicos; contactos ficticios.
-- Direcciones públicas usadas como destinos de desarrollo, no tiendas reales.
-- Catálogo y precios conservados del sistema al 12/10/2026.
--
-- USO SELECTIVO
-- 1. Importa primero Abastece_nuevo.sql y selecciona la base abastece_nuevo.
-- 2. Puedes ejecutar un bloque individual o eliminar/comentar bloques que no necesites.
-- 3. Carga primero las tablas indicadas en "Requiere" y conserva los IDs referenciados.
--    Si omites una fila padre, omite o adapta también sus filas dependientes.
-- 4. Los IDs son explícitos: no ejecutes dos veces el mismo bloque sobre los mismos datos.
--    No se desactivan las claves foráneas ni se reemplazan registros existentes.
-- 5. Las plantillas comentadas de tablas vacías requieren datos reales del sistema;
--    no se ejecutan durante una importación completa.
-- 6. Al importar todo el archivo, se carga dentro de una transacción.
--
-- ÍNDICE (orden válido por dependencias)
-- 01. bodegueros — Usuarios bodegueros
-- 02. categorias — Categorías del catálogo
-- 03. documento_secuencias — Correlativos de documentos
-- 04. mapa_busquedas — Caché de geocodificación
-- 05. tarjetas_prueba — Tarjetas del entorno de pago simulado
-- 06. usuarios_internos — Usuarios internos y transportistas
-- 07. direcciones — Direcciones de bodegas
-- 08. productos — Productos y precios
-- 09. proveedores — Proveedores
-- 10. compras — Compras de bodegueros
-- 11. inventario_lotes — Stock por lote
-- 12. producto_imagenes — Imágenes de productos
-- 13. productos_favoritos — Favoritos de bodegueros
-- 14. atencion_incidencias — Incidencias reportadas
-- 15. comprobantes_pago — Facturas emitidas
-- 16. detalle_compras — Productos de cada compra
-- 17. guias_remision — Despachos: guías de remisión
-- 18. movimientos_stock — Movimientos de inventario
-- 19. pagos_compra — Pagos registrados
-- 20. atencion_seguimiento — Seguimiento y solución de incidencias
-- 21. conformidades_producto — Conformidad de productos
-- 22. incidencia_detalles — Productos afectados y prioridad
-- 23. incidencia_evidencias — Fotografías de incidencias
-- 24. rutas_despacho — Despachos: asignación de transportistas
-- 25. rutas_gps — Posiciones GPS
-- 26. rutas_mapa — Recorridos calculados

USE abastece_nuevo;
SET NAMES utf8mb4;
START TRANSACTION;

-- ============================================================================
-- 01. Usuarios bodegueros | TABLA: bodegueros
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 10.
-- ============================================================================
-- Acceso: correo = rosa.huaman@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('1','Rosa','Huamán Quispe','rosa.huaman@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000101','00000101','10000001011','BODEGA','Bodega Las Palmeras','Rosa Huamán Quispe','1','ACTIVO');
-- Acceso: correo = jose.salazar@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('2','José','Salazar Díaz','jose.salazar@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000102','00000102','10000001029','MINIMARKET','Minimarket El Encuentro','José Salazar Díaz','1','ACTIVO');
-- Acceso: correo = elena.paredes@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('3','Elena','Paredes Ríos','elena.paredes@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000103','00000103','10000001037','BODEGA','Bodega Mercurio','Elena Paredes Ríos','1','ACTIVO');
-- Acceso: correo = pedro.castillo@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('4','Pedro','Castillo Vega','pedro.castillo@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000104','00000104','10000001045','BODEGA','Bodega Santa Luisa','Pedro Castillo Vega','1','ACTIVO');
-- Acceso: correo = lucia.rojas@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('5','Lucía','Rojas Medina','lucia.rojas@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000105','00000105','10000001053','MINIMARKET','Minimarket Las Tunas','Lucía Rojas Medina','1','ACTIVO');
-- Acceso: correo = carmen.flores@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('6','Carmen','Flores Soto','carmen.flores@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000106','00000106','10000001061','BODEGA','Bodega Los Próceres','Carmen Flores Soto','1','ACTIVO');
-- Acceso: correo = ricardo.gutierrez@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('7','Ricardo','Gutiérrez León','ricardo.gutierrez@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000107','00000107','10000001070','BODEGA','Market Plaza Norte','Ricardo Gutiérrez León','1','ACTIVO');
-- Acceso: correo = patricia.mendoza@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('8','Patricia','Mendoza Cruz','patricia.mendoza@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000108','00000108','10000001088','BODEGA','Bodega La Unión','Patricia Mendoza Cruz','1','ACTIVO');
-- Acceso: correo = daniel.vargas@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('9','Daniel','Vargas Peña','daniel.vargas@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000109','00000109','10000001096','BODEGA','Bodega Chiclayo','Daniel Vargas Peña','1','ACTIVO');
-- Acceso: correo = ana.torres@example.com | contraseña = Abastece2026!
INSERT INTO `bodegueros` (`bodeguero_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`ruc`,`tipo_establecimiento`,`nombre_comercial`,`razon_social`,`email_verificado`,`estado_cuenta`) VALUES ('10','Ana','Torres Campos','ana.torres@example.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000110','00000110','10000001100','MINIMARKET','Minimarket Amancaes','Ana Torres Campos','1','ACTIVO');

-- ============================================================================
-- 02. Categorías del catálogo | TABLA: categorias
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 4.
-- ============================================================================
INSERT INTO `categorias` (`categoria_id`,`nombre`,`descripcion`,`activo`) VALUES ('1','Abarrotes','Aceites, arroz, azúcar, fideos, conservas, galletas y lácteos envasados','1');
INSERT INTO `categorias` (`categoria_id`,`nombre`,`descripcion`,`activo`) VALUES ('2','Bebidas','Aguas, gaseosas, cervezas, néctares, yogures y bebidas energizantes','1');
INSERT INTO `categorias` (`categoria_id`,`nombre`,`descripcion`,`activo`) VALUES ('3','Limpieza','Detergentes, lejías, ceras, papeles y artículos de limpieza del hogar','1');
INSERT INTO `categorias` (`categoria_id`,`nombre`,`descripcion`,`activo`) VALUES ('4','Cuidado Personal','Higiene bucal, shampoo, jabones, desodorantes y cuidado personal','1');

-- ============================================================================
-- 03. Correlativos de documentos | TABLA: documento_secuencias
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 1.
-- ============================================================================
INSERT INTO `documento_secuencias` (`serie`,`ultimo`) VALUES ('F001','4');

-- ============================================================================
-- 04. Caché de geocodificación | TABLA: mapa_busquedas
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 0.
-- ============================================================================
-- Esta tabla inicia vacía y se alimenta durante el uso del sistema.
-- Habitualmente la completa el servicio de mapas; no necesita carga manual.
-- PLANTILLA OPCIONAL: sustituye todos los marcadores antes de ejecutarla.
-- INSERT INTO `mapa_busquedas` (`consulta_hash`, `resultados`)
-- VALUES ('<consulta_hash>', '<resultados>');

-- ============================================================================
-- 05. Tarjetas del entorno de pago simulado | TABLA: tarjetas_prueba
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 5.
-- ============================================================================
INSERT INTO `tarjetas_prueba` (`tarjeta_id`,`banco`,`marca`,`numero`,`ultimos_digitos`,`titular`,`vencimiento`,`cvv`,`color_inicio`,`color_fin`,`activa`,`es_simulada`) VALUES ('1','BCP','VISA','4111 1111 1111 1111','1111','Carlos Ramírez López','12/29','123','#082d72','#0067b1','1','1');
INSERT INTO `tarjetas_prueba` (`tarjeta_id`,`banco`,`marca`,`numero`,`ultimos_digitos`,`titular`,`vencimiento`,`cvv`,`color_inicio`,`color_fin`,`activa`,`es_simulada`) VALUES ('2','Interbank','MASTERCARD','5555 5555 5555 4444','4444','Carlos Ramírez López','10/30','456','#006b54','#00a88f','1','1');
INSERT INTO `tarjetas_prueba` (`tarjeta_id`,`banco`,`marca`,`numero`,`ultimos_digitos`,`titular`,`vencimiento`,`cvv`,`color_inicio`,`color_fin`,`activa`,`es_simulada`) VALUES ('3','Scotiabank','VISA','4000 0566 5566 5556','5556','Carlos Ramírez López','08/31','789','#8b0015','#ec111a','1','1');
INSERT INTO `tarjetas_prueba` (`tarjeta_id`,`banco`,`marca`,`numero`,`ultimos_digitos`,`titular`,`vencimiento`,`cvv`,`color_inicio`,`color_fin`,`activa`,`es_simulada`) VALUES ('4','BBVA','VISA','4000 0035 6000 0008','0008','Carlos Ramírez López','06/30','321','#061f5c','#1973b8','1','1');
INSERT INTO `tarjetas_prueba` (`tarjeta_id`,`banco`,`marca`,`numero`,`ultimos_digitos`,`titular`,`vencimiento`,`cvv`,`color_inicio`,`color_fin`,`activa`,`es_simulada`) VALUES ('5','Banco Pichincha','MASTERCARD','5105 1051 0510 5100','5100','Carlos Ramírez López','04/31','654','#f2b600','#765400','1','1');

-- ============================================================================
-- 06. Usuarios internos y transportistas | TABLA: usuarios_internos
-- Requiere: ninguna tabla previa.
-- Filas incluidas: 6.
-- ============================================================================
-- Administración, Logística y Atención (selecciona las filas que necesites).
-- Acceso: correo = administrador@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('1','Carlos','Ramírez López','administrador@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000001','00001001','ADMINISTRADOR','1');
-- Acceso: correo = logistica@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('2','María','Torres Sánchez','logistica@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000002','00001002','LOGISTICA','1');
-- Acceso: correo = atencion@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('4','Andrea','Flores García','atencion@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000004','00001004','GESTOR_ATENCION','1');

-- Transportistas: también pertenecen a usuarios_internos; no hay tabla separada.
-- Acceso: correo = transporte@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('3','Luis','Mendoza Pérez','transporte@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000003','00001003','TRANSPORTISTA','1');
-- Acceso: correo = transporte.jorge@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('5','Jorge','Castro Salazar','transporte.jorge@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000005','00001005','TRANSPORTISTA','1');
-- Acceso: correo = transporte.miguel@abastece.com | contraseña = Abastece2026!
INSERT INTO `usuarios_internos` (`usuario_interno_id`,`nombre`,`apellidos`,`correo`,`password_hash`,`telefono`,`documento_identidad`,`rol`,`activo`) VALUES ('6','Miguel','Vargas Rojas','transporte.miguel@abastece.com','$2y$10$6bzyfUHvewkYrHSz40Rvj.3MurN1uROmOtGSMbNi3z9hWGc8pBybm','900000006','00001006','TRANSPORTISTA','1');

-- ============================================================================
-- 07. Direcciones de bodegas | TABLA: direcciones
-- Requiere: bodegueros.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('1','1','Lima','Lima','Los Olivos','Av. Carlos Izaguirre 813','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('2','2','Lima','Lima','Los Olivos','Av. Universitaria 2086','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('3','3','Lima','Lima','Los Olivos','Av. Alfredo Mendiola 6163','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('4','4','Lima','Lima','San Martín de Porres','Av. San Bernardo 200','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('5','5','Lima','Lima','San Martín de Porres','Calle Las Tunas 308','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('6','6','Lima','Lima','San Martín de Porres','Av. Los Próceres 737','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('7','7','Lima','Lima','Independencia','Av. Alfredo Mendiola 1400','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('8','8','Lima','Lima','Independencia','Av. Carlos Izaguirre 176','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('9','9','Lima','Lima','Rímac','Jirón Chiclayo 570','LIMA_NORTE','1');
INSERT INTO `direcciones` (`direccion_id`,`bodeguero_id`,`departamento`,`provincia`,`distrito`,`direccion_exacta`,`zona_reparto`,`es_principal`) VALUES ('10','10','Lima','Lima','Rímac','Av. Prolongación Flor de Amancaes 1377','LIMA_NORTE','1');

-- ============================================================================
-- 08. Productos y precios | TABLA: productos
-- Requiere: categorias, usuarios_internos.
-- Filas incluidas: 60.
-- ============================================================================
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('1','1','ABA-PRI-001','Aceite Primor Premium','Caja con 12 botellas de aceite vegetal premium para reventa mayorista.','0.000','Primor','Caja x 12 und','12','130.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('2','1','ABA-AJI-001','Ajinomen Gallina','Caja con 24 sobres de sopa instantánea sabor gallina, 80 g c/u.','0.000','Ajinomen','Caja x 24 sobres','24','29.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('3','1','ABA-COS-001','Arroz Costeño Extra','Saco de arroz extra de grano largo de 50 kg para reventa mayorista.','0.000','Costeño','Saco x 50 kg','1','185.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('4','1','ABA-PRI-002','Atún Primor Trozos en Aceite','Caja con 48 latas de atún en trozos en aceite, 170 g c/u.','0.000','Primor','Caja x 48 und','48','154.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('5','1','ABA-3OS-001','Avena 3 Ositos Tradicional','Caja con 24 bolsas de avena tradicional, 300 g c/u.','0.000','3 Ositos','Caja x 24 bolsas','24','108.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('6','1','ABA-PAR-001','Azúcar Rubia Paramonga','Saco de azúcar rubia de 50 kg para reventa mayorista.','0.000','Paramonga','Saco x 50 kg','1','145.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('7','1','ABA-WIN-001','Chocolate Winter\'s Taza','Display con 50 tabletas de chocolate para taza, 90 g c/u.','0.000','Winter\'s','Display x 50 tabletas','50','115.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('8','1','ABA-SUB-001','Chocolates Sublime Clásico','Display con 24 tabletas de chocolate Sublime, 30 g c/u.','0.000','Sublime','Display x 24 tabletas','24','39.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('9','1','ABA-DON-001','Fideos Don Vittorio Spaghetti','Paquete con 20 bolsas de fideos spaghetti, 450 g c/u.','0.000','Don Vittorio','Paquete x 20 und','20','60.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('10','1','ABA-CAS-001','Galletas Casino Menta','Display con 24 paquetes de galletas sabor menta.','0.000','Casino','Display x 24 paquetes','24','44.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('11','1','ABA-SAN-001','Galletas Soda San Jorge','Display con 24 paquetes de galletas de soda.','0.000','San Jorge','Display x 24 paquetes','24','36.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('12','1','ABA-GLO-001','Leche Gloria Azul','Caja con 24 tarros de leche evaporada, 400 g c/u.','0.000','Gloria','Caja x 24 und','24','115.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('13','1','ABA-ALA-001','Mayonesa Alacena','Caja con 24 doy pack de mayonesa, 95 g c/u.','0.000','Alacena','Caja x 24 doy pack','24','53.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('14','1','ABA-EMS-001','Sal de Mesa Emsal Yodada','Fardo con 20 bolsas de sal yodada, 1 kg c/u.','0.000','Emsal','Fardo x 20 bolsas','20','36.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('15','1','ABA-MOL-001','Salsa Pomarola Molitalia','Caja con 24 doy pack de salsa pomarola, 145 g c/u.','0.000','Molitalia','Caja x 24 doy pack','24','60.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('16','2','BEB-CIE-001','Agua Cielo Sin Gas','Plancha con 15 botellas de agua sin gas, 625 ml c/u.','0.000','Cielo','Plancha x 15 und','15','18.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('17','2','BEB-SAN-001','Agua San Mateo Sin Gas','Plancha con 12 botellas de agua sin gas, 600 ml c/u.','0.000','San Mateo','Plancha x 12 und','12','16.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('18','2','BEB-SPO-001','Bebida Hidratante Sporade Mandarina','Plancha con 12 botellas de bebida hidratante, 500 ml c/u.','0.000','Sporade','Plancha x 12 und','12','30.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('19','2','BEB-CRI-001','Cerveza Cristal','Caja con 12 botellas de cerveza, 650 ml c/u.','0.000','Cristal','Caja x 12 botellas','12','66.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('20','2','BEB-PIL-001','Cerveza Pilsen Callao','Plancha con 24 latas de cerveza, 355 ml c/u.','0.000','Pilsen Callao','Plancha x 24 latas','24','101.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('21','2','BEB-COC-001','Coca Cola','Fardo con 12 botellas de gaseosa, 500 ml c/u.','0.000','Coca-Cola','Fardo x 12 und','12','34.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('22','2','BEB-COC-002','Coca Cola Sabor Original','Fardo con 6 botellas de gaseosa, 3 L c/u.','0.000','Coca-Cola','Fardo x 6 und','6','57.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('23','2','BEB-KOL-001','Gaseosa Kola Real Piña','Fardo con 6 botellas de gaseosa sabor piña, 3 L c/u.','0.000','Kola Real','Fardo x 6 und','6','39.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('24','2','BEB-INC-001','Inca Kola','Fardo con 12 botellas de gaseosa, 500 ml c/u.','0.000','Inca Kola','Fardo x 12 und','12','34.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('25','2','BEB-INC-002','Inca Kola Sin Azúcar','Fardo con 6 botellas de gaseosa sin azúcar, 3 L c/u.','0.000','Inca Kola','Fardo x 6 und','6','57.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('26','2','BEB-FRU-001','Néctar Frugos del Valle Naranja','Fardo con 12 botellas de néctar de naranja, 300 ml c/u.','0.000','Frugos','Fardo x 12 botellas','12','26.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('27','2','BEB-PUL-001','Néctar Pulp Durazno','Fardo con 24 cajitas de néctar de durazno, 235 ml c/u.','0.000','Pulp','Fardo x 24 cajitas','24','38.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('28','2','BEB-FRE-001','Té Helado Free Tea Limón','Fardo con 12 botellas de té helado sabor limón, 475 ml c/u.','0.000','Free Tea','Fardo x 12 botellas','12','28.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('29','2','BEB-VOL-001','Volt Blue Energy Maca','Plancha con 24 latas de bebida energizante, 300 ml c/u.','0.000','Volt','Plancha x 24 latas','24','84.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('30','2','BEB-GLO-001','Yogurt Gloria Fresa','Galonera con 6 unidades de yogurt sabor fresa, 1 kg c/u.','0.000','Gloria','Galonera x 6 und','6','54.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('31','3','LIM-CLA-001','Bolsas de Basura Clan 50L','Fardo con 20 paquetes de bolsas de basura de 50L, 10 und c/u.','0.000','Clan','Fardo x 20 paquetes','20','90.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('32','3','LIM-TEK-001','Cera para Pisos Tekno Roja','Caja con 4 galoneras de cera roja para pisos, 1 galón c/u.','0.000','Tekno','Caja x 4 galoneras','4','112.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('33','3','LIM-ACE-001','Detergente Ace Polvo','Bolsa multipack con 12 unidades de detergente en polvo, 750 g c/u.','0.000','Ace','Bolsa x 12 und','12','78.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('34','3','LIM-BOL-001','Detergente Bolívar Floral','Bolsa de detergente en polvo floral de 5.8 kg.','0.000','Bolívar','Bolsa x 5.8 kg','1','38.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('35','3','LIM-OPA-001','Detergente Opal Ultra Cristal','Bolsa de detergente en polvo Ultra Cristal de 5.8 kg.','0.000','Opal','Bolsa x 5.8 kg','1','36.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('36','3','LIM-SCO-001','Esponja Scotch-Brite Verde','Caja con 24 esponjas verdes multiuso.','0.000','Scotch-Brite','Caja x 24 und','24','29.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('37','3','LIM-AYU-001','Lavavajillas Líquido Ayudín Limón','Caja con 12 botellas de lavavajillas líquido, 900 ml c/u.','0.000','Ayudín','Caja x 12 und','12','58.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('38','3','LIM-SAP-001','Lavavajillas Sapolio Pasta Limón','Caja con 24 unidades de lavavajillas en pasta, 800 g c/u.','0.000','Sapolio','Caja x 24 und','24','77.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('39','3','LIM-CLO-001','Lejía Clorox Tradicional','Caja con 15 botellas de lejía tradicional, 1 kg c/u.','0.000','Clorox','Caja x 15 botellas','15','53.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('40','3','LIM-SAP-002','Lejía Sapolio Tradicional','Fardo con 15 botellas de lejía tradicional, 1 kg c/u.','0.000','Sapolio','Fardo x 15 botellas','15','45.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('41','3','LIM-POE-001','Limpiador Poett Lavanda','Caja con 12 botellas de limpiador multiusos, 900 ml c/u.','0.000','Poett','Caja x 12 botellas','12','66.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('42','3','LIM-SAP-003','Limpiavidrios Sapolio Antiempañante','Caja con 12 gatillos limpiavidrios antiempañante, 650 ml c/u.','0.000','Sapolio','Caja x 12 und','12','50.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('43','3','LIM-PAR-001','Papel Higiénico Paracas Black','Paquete con 10 planchas de papel higiénico, 4 rollos por plancha.','0.000','Paracas','Paquete x 10 planchas','10','130.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('44','3','LIM-NOV-001','Papel Toalla Nova Clásico','Fardo con 12 paquetes de papel toalla, 2 rollos por paquete.','0.000','Nova','Fardo x 12 paquetes','12','78.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('45','3','LIM-DOW-001','Suavizante Downy Floral','Caja con 12 doy pack de suavizante floral, 800 ml c/u.','0.000','Downy','Caja x 12 doy pack','12','60.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('46','4','CUI-GIL-001','Afeitadora Gillette Prestobarba 3','Display con 24 afeitadoras desechables de 3 hojas.','0.000','Gillette','Display x 24 und','24','60.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('47','4','CUI-COL-001','Cepillo Dental Colgate Extra Clean','Caja con 24 cepillos dentales Extra Clean.','0.000','Colgate','Caja x 24 und','24','43.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('48','4','CUI-COL-002','Crema Dental Colgate Triple Acción','Caja con 36 tubos de crema dental, 100 ml c/u.','0.000','Colgate','Caja x 36 tubos','36','94.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('49','4','CUI-KOL-001','Crema Dental Kolynos Triple Limpieza','Caja con 36 tubos de crema dental, 90 ml c/u.','0.000','Kolynos','Caja x 36 tubos','36','83.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('50','4','CUI-NIV-001','Desodorante Nivea Roll-on Aclarado Natural','Caja con 12 desodorantes roll-on, 50 ml c/u.','0.000','Nivea','Caja x 12 und','12','78.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('51','4','CUI-REX-001','Desodorante Rexona Clinical Aerosol Hombre','Caja con 12 desodorantes en aerosol, 150 ml c/u.','0.000','Rexona','Caja x 12 und','12','114.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('52','4','CUI-BOL-001','Jabón Bolívar Blanco','Fardo con 24 barras de jabón blanco, 200 g c/u.','0.000','Bolívar','Fardo x 24 barras','24','38.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('53','4','CUI-CAM-001','Jabón de Tocador Camay Clásico','Caja con 36 jabones de tocador, 125 g c/u.','0.000','Camay','Caja x 36 und','36','65.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('54','4','CUI-AVA-001','Jabón Líquido Aval Antibacterial','Caja con 12 botellas de jabón líquido antibacterial.','0.000','Aval','Caja x 12 botellas','12','66.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('55','4','CUI-BAB-001','Pañales Babysec Super Premium XXG','Fardo con 4 paquetes de pañales talla XXG, 44 und c/u.','0.000','Babysec','Fardo x 4 paquetes','4','112.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('56','4','CUI-HEA-001','Shampoo Head & Shoulders Limpieza Renovadora','Caja con 12 shampoos anticaspa, 375 ml c/u.','0.000','Head & Shoulders','Caja x 12 und','12','126.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('57','4','CUI-SED-001','Shampoo Sedal Ceramidas','Caja con 12 botellas de shampoo con ceramidas, 340 ml c/u.','0.000','Sedal','Caja x 12 botellas','12','90.00','8','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('58','4','CUI-SED-002','Shampoo Sedal Tiras','Tira con 24 sachets individuales de shampoo.','0.000','Sedal','Tira x 24 sachets','24','22.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('59','4','CUI-LAD-001','Toallas Higiénicas Ladysoft Normal con Alas','Fardo con 24 paquetes de toallas higiénicas con alas.','0.000','Ladysoft','Fardo x 24 paquetes','24','67.00','5','1','2');
INSERT INTO `productos` (`producto_id`,`categoria_id`,`codigo_interno`,`nombre`,`descripcion`,`peso_kg`,`marca`,`unidad_medida`,`unidades_por_empaque`,`precio_unitario`,`stock_minimo`,`activo`,`actualizado_por`) VALUES ('60','4','CUI-NOS-001','Toallas Higiénicas Nosotras Buenas Noches','Fardo con 24 paquetes de toallas higiénicas nocturnas.','0.000','Nosotras','Fardo x 24 paquetes','24','72.00','5','1','2');

-- ============================================================================
-- 09. Proveedores | TABLA: proveedores
-- Requiere: usuarios_internos.
-- Filas incluidas: 2.
-- ============================================================================
INSERT INTO `proveedores` (`proveedor_id`,`ruc`,`razon_social`,`nombre_comercial`,`contacto_nombre`,`contacto_dni`,`correo`,`telefono`,`direccion_fiscal`,`distrito`,`puntaje`,`puntaje_actualizado_por`,`tiempo_promedio_entrega_hrs`) VALUES ('1','20100055237','Alicorp S.A.A.','Alicorp','Paola Sánchez Ruiz','00002001','compras.alicorp@example.com','900000201','Av. Argentina 4793','Carmen de la Legua Reynoso','4.5','2','24');
INSERT INTO `proveedores` (`proveedor_id`,`ruc`,`razon_social`,`nombre_comercial`,`contacto_nombre`,`contacto_dni`,`correo`,`telefono`,`direccion_fiscal`,`distrito`,`puntaje`,`puntaje_actualizado_por`,`tiempo_promedio_entrega_hrs`) VALUES ('2','20100190797','Leche Gloria S.A.','Gloria','Álvaro Rivas Molina','00002002','compras.gloria@example.com','900000202','Av. República de Panamá 2461','La Victoria','4.5','2','24');

-- ============================================================================
-- 10. Compras de bodegueros | TABLA: compras
-- Requiere: bodegueros, direcciones.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('1','COM-202610-000001','1','1','220.34','39.66','260','ENTREGADO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('2','COM-202610-000002','2','2','49.15','8.85','58','ENTREGADO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('3','COM-202610-000003','3','3','313.56','56.44','370','ENTREGADO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('4','COM-202610-000004','4','4','261.02','46.98','308','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('5','COM-202610-000005','5','5','183.05','32.95','216','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('6','COM-202610-000006','6','6','245.76','44.24','290','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('7','COM-202610-000007','7','7','194.92','35.08','230','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('8','COM-202610-000008','8','8','66.1','11.9','78','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('9','COM-202610-000009','9','9','101.69','18.31','120','PREPARANDO');
INSERT INTO `compras` (`compra_id`,`codigo_compra`,`bodeguero_id`,`direccion_id`,`subtotal`,`igv`,`total`,`estado_pedido`) VALUES ('10','COM-202610-000010','10','10','74.58','13.42','88','PREPARANDO');

-- ============================================================================
-- 11. Stock por lote | TABLA: inventario_lotes
-- Requiere: productos, proveedores, usuarios_internos.
-- Filas incluidas: 60.
-- ============================================================================
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('1','1','1','LOTE-ABA-PRI-001','2026-04-04','2028-06-15','114','53','Rack A-02','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('2','2','1','LOTE-ABA-AJI-002','2026-05-07','2027-11-28','74','69','Rack A-03','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('3','3','2','LOTE-ABA-COS-003','2026-06-10','2028-04-15','81','80','Rack A-04','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('4','4','1','LOTE-ABA-PRI-004','2026-07-13','2027-09-28','88','82','Rack A-05','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('5','5','1','LOTE-ABA-3OS-005','2026-08-16','2028-02-15','95','84','Rack A-06','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('6','6','2','LOTE-ABA-PAR-006','2026-03-19','2027-07-28','102','96','Rack A-07','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('7','7','1','LOTE-ABA-WIN-007','2026-04-22','2028-12-15','109','104','Rack A-08','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('8','8','1','LOTE-ABA-SUB-008','2026-05-25','2027-05-28','116','103','Rack A-09','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('9','9','2','LOTE-ABA-DON-009','2026-06-01','2028-10-15','123','115','Rack A-10','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('10','10','1','LOTE-ABA-CAS-010','2026-07-04','2027-03-28','130','129','Rack A-11','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('11','11','1','LOTE-ABA-SAN-011','2026-08-07','2028-08-15','137','136','Rack A-12','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('12','12','2','LOTE-ABA-GLO-012','2026-03-10','2027-01-28','144','137','Rack A-01','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('13','13','1','LOTE-ABA-ALA-013','2026-04-13','2028-06-15','151','150','Rack A-02','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('14','14','1','LOTE-ABA-EMS-014','2026-05-16','2027-11-28','70','28','Rack A-03','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('15','15','2','LOTE-ABA-MOL-015','2026-06-19','2028-04-15','165','164','Rack A-04','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('16','16','2','LOTE-BEB-CIE-016','2026-07-22','2027-09-28','172','172','Rack B-05','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('17','17','1','LOTE-BEB-SAN-017','2026-08-25','2028-02-15','179','179','Rack B-06','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('18','18','2','LOTE-BEB-SPO-018','2026-03-01','2027-07-28','66','66','Rack B-07','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('19','19','1','LOTE-BEB-CRI-019','2026-04-04','2028-12-15','60','6','Rack B-08','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('20','20','2','LOTE-BEB-PIL-020','2026-05-07','2027-05-28','80','80','Rack B-09','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('21','21','1','LOTE-BEB-COC-021','2026-06-10','2028-10-15','87','77','Rack B-10','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('22','22','2','LOTE-BEB-COC-022','2026-07-13','2027-03-28','94','89','Rack B-11','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('23','23','1','LOTE-BEB-KOL-023','2026-08-16','2028-08-15','101','101','Rack B-12','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('24','24','2','LOTE-BEB-INC-024','2026-03-19','2027-01-28','108','100','Rack B-01','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('25','25','1','LOTE-BEB-INC-025','2026-04-22','2028-06-15','115','112','Rack B-02','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('26','26','2','LOTE-BEB-FRU-026','2026-05-25','2027-11-28','122','122','Rack B-03','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('27','27','1','LOTE-BEB-PUL-027','2026-06-01','2028-04-15','129','123','Rack B-04','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('28','28','2','LOTE-BEB-FRE-028','2026-07-04','2027-09-28','136','136','Rack B-05','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('29','29','1','LOTE-BEB-VOL-029','2026-08-07','2028-02-15','143','140','Rack B-06','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('30','30','2','LOTE-BEB-GLO-030','2026-03-10','2027-07-28','150','150','Rack B-07','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('31','31','1','LOTE-LIM-CLA-031','2026-04-13',NULL,'157','157','Rack C-08','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('32','32','1','LOTE-LIM-TEK-032','2026-05-16','2027-05-28','164','164','Rack C-09','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('33','33','1','LOTE-LIM-ACE-033','2026-06-19','2028-10-15','171','170','Rack C-10','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('34','34','1','LOTE-LIM-BOL-034','2026-07-22','2027-03-28','178','168','Rack C-11','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('35','35','1','LOTE-LIM-OPA-035','2026-08-25','2028-08-15','65','65','Rack C-12','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('36','36','1','LOTE-LIM-SCO-036','2026-03-01',NULL,'72','71','Rack C-01','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('37','37','1','LOTE-LIM-AYU-037','2026-04-04','2028-06-15','79','76','Rack C-02','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('38','38','1','LOTE-LIM-SAP-038','2026-05-07','2027-11-28','86','86','Rack C-03','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('39','39','1','LOTE-LIM-CLO-039','2026-06-10','2028-04-15','60','6','Rack C-04','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('40','40','1','LOTE-LIM-SAP-040','2026-07-13','2027-09-28','100','99','Rack C-05','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('41','41','1','LOTE-LIM-POE-041','2026-08-16','2028-02-15','107','106','Rack C-06','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('42','42','1','LOTE-LIM-SAP-042','2026-03-19','2027-07-28','114','114','Rack C-07','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('43','43','1','LOTE-LIM-PAR-043','2026-04-22',NULL,'121','121','Rack C-08','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('44','44','1','LOTE-LIM-NOV-044','2026-05-25',NULL,'128','128','Rack C-09','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('45','45','1','LOTE-LIM-DOW-045','2026-06-01','2028-10-15','135','134','Rack C-10','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('46','46','2','LOTE-CUI-GIL-046','2026-07-04',NULL,'142','142','Rack D-11','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('47','47','2','LOTE-CUI-COL-047','2026-08-07',NULL,'149','149','Rack D-12','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('48','48','2','LOTE-CUI-COL-048','2026-03-10','2027-01-28','156','154','Rack D-01','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('49','49','2','LOTE-CUI-KOL-049','2026-04-13','2028-06-15','163','163','Rack D-02','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('50','50','2','LOTE-CUI-NIV-050','2026-05-16','2027-11-28','170','170','Rack D-03','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('51','51','2','LOTE-CUI-REX-051','2026-06-19','2028-04-15','177','177','Rack D-04','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('52','52','2','LOTE-CUI-BOL-052','2026-07-22','2027-09-28','64','64','Rack D-05','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('53','53','2','LOTE-CUI-CAM-053','2026-08-25','2028-02-15','71','71','Rack D-06','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('54','54','2','LOTE-CUI-AVA-054','2026-03-01','2027-07-28','78','77','Rack D-07','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('55','55','2','LOTE-CUI-BAB-055','2026-04-04','2028-12-15','85','83','Rack D-08','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('56','56','2','LOTE-CUI-HEA-056','2026-05-07','2027-05-28','92','92','Rack D-09','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('57','57','2','LOTE-CUI-SED-057','2026-06-10','2028-10-15','99','96','Rack D-10','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('58','58','2','LOTE-CUI-SED-058','2026-07-13','2027-03-28','40','0','Rack D-11','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('59','59','2','LOTE-CUI-LAD-059','2026-08-16','2028-08-15','113','113','Rack D-12','2');
INSERT INTO `inventario_lotes` (`lote_id`,`producto_id`,`proveedor_id`,`numero_lote`,`fecha_ingreso`,`fecha_vencimiento`,`stock_ingresado`,`stock_disponible`,`ubicacion_almacen`,`registrado_por`) VALUES ('60','60','2','LOTE-CUI-NOS-060','2026-03-19','2027-01-28','120','120','Rack D-01','2');

-- ============================================================================
-- 12. Imágenes de productos | TABLA: producto_imagenes
-- Requiere: productos, usuarios_internos.
-- Filas incluidas: 60.
-- ============================================================================
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('2','2','/api/uploads/products/product-002.png','Ajinomen Gallina','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('3','3','/api/uploads/products/product-003.png','Arroz Costeño Extra','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('4','4','/api/uploads/products/product-004.png','Atún Primor Trozos en Aceite','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('5','5','/api/uploads/products/product-005.png','Avena 3 Ositos Tradicional','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('6','6','/api/uploads/products/product-006.png','Azúcar Rubia Paramonga','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('7','7','/api/uploads/products/product-007.png','Chocolate Winter\'s Taza','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('8','8','/api/uploads/products/product-008.png','Chocolates Sublime Clásico','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('9','9','/api/uploads/products/product-009.png','Fideos Don Vittorio Spaghetti','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('10','10','/api/uploads/products/product-010.png','Galletas Casino Menta','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('11','11','/api/uploads/products/product-011.png','Galletas Soda San Jorge','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('12','12','/api/uploads/products/product-012.png','Leche Gloria Azul','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('13','13','/api/uploads/products/product-013.png','Mayonesa Alacena','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('14','14','/api/uploads/products/product-014.png','Sal de Mesa Emsal Yodada','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('15','15','/api/uploads/products/product-015.png','Salsa Pomarola Molitalia','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('16','16','/api/uploads/products/product-016.png','Agua Cielo Sin Gas','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('17','17','/api/uploads/products/product-017.png','Agua San Mateo Sin Gas','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('18','18','/api/uploads/products/product-018.png','Bebida Hidratante Sporade Mandarina','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('19','19','/api/uploads/products/product-019.png','Cerveza Cristal','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('20','20','/api/uploads/products/product-020.png','Cerveza Pilsen Callao','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('21','21','/api/uploads/products/product-021.png','Coca Cola','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('22','22','/api/uploads/products/product-022.png','Coca Cola Sabor Original','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('23','23','/api/uploads/products/product-023.png','Gaseosa Kola Real Piña','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('24','24','/api/uploads/products/product-024.png','Inca Kola','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('25','25','/api/uploads/products/product-025.png','Inca Kola Sin Azúcar','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('26','26','/api/uploads/products/product-026.png','Néctar Frugos del Valle Naranja','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('27','27','/api/uploads/products/product-027.png','Néctar Pulp Durazno','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('28','28','/api/uploads/products/product-028.png','Té Helado Free Tea Limón','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('29','29','/api/uploads/products/product-029.png','Volt Blue Energy Maca','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('30','30','/api/uploads/products/product-030.png','Yogurt Gloria Fresa','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('31','31','/api/uploads/products/product-031.png','Bolsas de Basura Clan 50L','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('32','32','/api/uploads/products/product-032.png','Cera para Pisos Tekno Roja','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('33','33','/api/uploads/products/product-033.png','Detergente Ace Polvo','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('34','34','/api/uploads/products/product-034.png','Detergente Bolívar Floral','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('35','35','/api/uploads/products/product-035.png','Detergente Opal Ultra Cristal','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('36','36','/api/uploads/products/product-036.png','Esponja Scotch-Brite Verde','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('37','37','/api/uploads/products/product-037.png','Lavavajillas Líquido Ayudín Limón','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('38','38','/api/uploads/products/product-038.png','Lavavajillas Sapolio Pasta Limón','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('39','39','/api/uploads/products/product-039.png','Lejía Clorox Tradicional','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('40','40','/api/uploads/products/product-040.png','Lejía Sapolio Tradicional','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('41','41','/api/uploads/products/product-041.png','Limpiador Poett Lavanda','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('42','42','/api/uploads/products/product-042.png','Limpiavidrios Sapolio Antiempañante','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('43','43','/api/uploads/products/product-043.png','Papel Higiénico Paracas Black','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('44','44','/api/uploads/products/product-044.png','Papel Toalla Nova Clásico','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('45','45','/api/uploads/products/product-045.png','Suavizante Downy Floral','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('46','46','/api/uploads/products/product-046.png','Afeitadora Gillette Prestobarba 3','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('47','47','/api/uploads/products/product-047.png','Cepillo Dental Colgate Extra Clean','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('48','48','/api/uploads/products/product-048.png','Crema Dental Colgate Triple Acción','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('49','49','/api/uploads/products/product-049.png','Crema Dental Kolynos Triple Limpieza','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('50','50','/api/uploads/products/product-050.png','Desodorante Nivea Roll-on Aclarado Natural','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('51','51','/api/uploads/products/product-051.png','Desodorante Rexona Clinical Aerosol Hombre','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('52','52','/api/uploads/products/product-052.png','Jabón Bolívar Blanco','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('53','53','/api/uploads/products/product-053.png','Jabón de Tocador Camay Clásico','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('54','54','/api/uploads/products/product-054.png','Jabón Líquido Aval Antibacterial','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('55','55','/api/uploads/products/product-055.png','Pañales Babysec Super Premium XXG','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('56','56','/api/uploads/products/product-056.png','Shampoo Head & Shoulders Limpieza Renovadora','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('57','57','/api/uploads/products/product-057.png','Shampoo Sedal Ceramidas','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('58','58','/api/uploads/products/product-058.png','Shampoo Sedal Tiras','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('59','59','/api/uploads/products/product-059.png','Toallas Higiénicas Ladysoft Normal con Alas','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('60','60','/api/uploads/products/product-060.png','Toallas Higiénicas Nosotras Buenas Noches','1',NULL);
INSERT INTO `producto_imagenes` (`imagen_id`,`producto_id`,`ruta_imagen`,`texto_alternativo`,`es_principal`,`subido_por`) VALUES ('66','1','/api/uploads/products/product-1-f747420c249ece16.png',NULL,'1',NULL);

-- ============================================================================
-- 13. Favoritos de bodegueros | TABLA: productos_favoritos
-- Requiere: bodegueros, productos.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('1','1');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('2','2');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('3','3');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('4','4');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('5','5');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('6','6');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('7','7');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('8','8');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('9','9');
INSERT INTO `productos_favoritos` (`bodeguero_id`,`producto_id`) VALUES ('10','10');

-- ============================================================================
-- 14. Incidencias reportadas | TABLA: atencion_incidencias
-- Requiere: bodegueros, compras, usuarios_internos.
-- Filas incluidas: 5.
-- ============================================================================
INSERT INTO `atencion_incidencias` (`incidencia_id`,`bodeguero_id`,`compra_id`,`gestor_usuario_id`,`tipo_incidencia`,`descripcion`,`estado_atencion`,`conformidad_final`) VALUES ('1','1','1',NULL,'PRODUCTO_DANADO','El empaque del producto llegó abierto y requiere revisión.','ABIERTO',NULL);
INSERT INTO `atencion_incidencias` (`incidencia_id`,`bodeguero_id`,`compra_id`,`gestor_usuario_id`,`tipo_incidencia`,`descripcion`,`estado_atencion`,`conformidad_final`) VALUES ('2','2','2',NULL,'PEDIDO_INCOMPLETO','Se recibió una unidad menos de la cantidad solicitada.','ABIERTO',NULL);
INSERT INTO `atencion_incidencias` (`incidencia_id`,`bodeguero_id`,`compra_id`,`gestor_usuario_id`,`tipo_incidencia`,`descripcion`,`estado_atencion`,`conformidad_final`) VALUES ('3','3','3','4','PRODUCTO_PROXIMO_VENCER','El producto presenta una fecha de vencimiento muy cercana.','EN_REVISION',NULL);
INSERT INTO `atencion_incidencias` (`incidencia_id`,`bodeguero_id`,`compra_id`,`gestor_usuario_id`,`tipo_incidencia`,`descripcion`,`estado_atencion`,`conformidad_final`) VALUES ('4','4','4','4','DEMORA_ENTREGA','Solicito confirmar el horario de llegada de mi pedido.','EN_REVISION',NULL);
INSERT INTO `atencion_incidencias` (`incidencia_id`,`bodeguero_id`,`compra_id`,`gestor_usuario_id`,`tipo_incidencia`,`descripcion`,`estado_atencion`,`conformidad_final`) VALUES ('5','5','5','4','OTRO','Necesito coordinar la entrega en horario de la tarde.','SOLUCIONADO','Se coordinó la entrega y el cliente confirmó la solución.');

-- ============================================================================
-- 15. Facturas emitidas | TABLA: comprobantes_pago
-- Requiere: compras.
-- Filas incluidas: 4.
-- ============================================================================
INSERT INTO `comprobantes_pago` (`comprobante_id`,`compra_id`,`tipo_comprobante`,`serie`,`correlativo`,`es_simulado`,`ruc_emisor`,`ruc_receptor`,`subtotal`,`igv`,`total`,`metodo_pago`,`codigo_operacion`) VALUES ('1','1','FACTURA_ELECTRONICA','F001','1','1','20999999990','10000001011','220.34','39.66','260','TARJETA','OP-202610-000001');
INSERT INTO `comprobantes_pago` (`comprobante_id`,`compra_id`,`tipo_comprobante`,`serie`,`correlativo`,`es_simulado`,`ruc_emisor`,`ruc_receptor`,`subtotal`,`igv`,`total`,`metodo_pago`,`codigo_operacion`) VALUES ('2','2','FACTURA_ELECTRONICA','F001','2','1','20999999990','10000001029','49.15','8.85','58','YAPE','OP-202610-000002');
INSERT INTO `comprobantes_pago` (`comprobante_id`,`compra_id`,`tipo_comprobante`,`serie`,`correlativo`,`es_simulado`,`ruc_emisor`,`ruc_receptor`,`subtotal`,`igv`,`total`,`metodo_pago`,`codigo_operacion`) VALUES ('3','3','FACTURA_ELECTRONICA','F001','3','1','20999999990','10000001037','313.56','56.44','370','EFECTIVO','OP-202610-000003');
INSERT INTO `comprobantes_pago` (`comprobante_id`,`compra_id`,`tipo_comprobante`,`serie`,`correlativo`,`es_simulado`,`ruc_emisor`,`ruc_receptor`,`subtotal`,`igv`,`total`,`metodo_pago`,`codigo_operacion`) VALUES ('4','4','FACTURA_ELECTRONICA','F001','4','1','20999999990','10000001045','261.02','46.98','308','TARJETA','OP-202610-000004');

-- ============================================================================
-- 16. Productos de cada compra | TABLA: detalle_compras
-- Requiere: compras, productos, inventario_lotes.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('1','1','1','1','2','130.00','260');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('2','2','2','2','2','29.00','58');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('3','3','3','3','2','185.00','370');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('4','4','4','4','2','154.00','308');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('5','5','5','5','2','108.00','216');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('6','6','6','6','2','145.00','290');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('7','7','7','7','2','115.00','230');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('8','8','8','8','2','39.00','78');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('9','9','9','9','2','60.00','120');
INSERT INTO `detalle_compras` (`detalle_compra_id`,`compra_id`,`producto_id`,`lote_id`,`cantidad`,`precio_unitario`,`total_linea`) VALUES ('10','10','10','10','2','44.00','88');

-- ============================================================================
-- 17. Despachos: guías de remisión | TABLA: guias_remision
-- Requiere: compras, usuarios_internos.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('1','1','GR-2026-000001','2','8','260','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('2','2','GR-2026-000002','2','8','58','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('3','3','GR-2026-000003','2','8','370','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('4','4','GR-2026-000004','2','8','308','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('5','5','GR-2026-000005','2','8','216','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('6','6','GR-2026-000006','2','8','290','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('7','7','GR-2026-000007','2','8','230','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('8','8','GR-2026-000008','2','8','78','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('9','9','GR-2026-000009','2','8','120','Dos empaques mayoristas','2');
INSERT INTO `guias_remision` (`guia_id`,`compra_id`,`codigo_guia`,`total_bultos`,`peso_total_kg`,`costo_total`,`detalle_carga`,`emitida_por`) VALUES ('10','10','GR-2026-000010','2','8','88','Dos empaques mayoristas','2');

-- ============================================================================
-- 18. Movimientos de inventario | TABLA: movimientos_stock
-- Requiere: inventario_lotes, usuarios_internos.
-- Filas incluidas: 1.
-- ============================================================================
INSERT INTO `movimientos_stock` (`lote_id`,`variacion`,`motivo`,`registrado_por`) VALUES ('1','0','Conciliación de inventario sin diferencias','2');

-- ============================================================================
-- 19. Pagos registrados | TABLA: pagos_compra
-- Requiere: compras.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('1','TARJETA','OP-202610-000001');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('2','YAPE','OP-202610-000002');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('3','EFECTIVO','OP-202610-000003');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('4','TARJETA','OP-202610-000004');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('5','YAPE','OP-202610-000005');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('6','EFECTIVO','OP-202610-000006');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('7','TARJETA','OP-202610-000007');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('8','YAPE','OP-202610-000008');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('9','EFECTIVO','OP-202610-000009');
INSERT INTO `pagos_compra` (`compra_id`,`metodo_pago`,`codigo_operacion`) VALUES ('10','TARJETA','OP-202610-000010');

-- ============================================================================
-- 20. Seguimiento y solución de incidencias | TABLA: atencion_seguimiento
-- Requiere: atencion_incidencias.
-- Filas incluidas: 5.
-- ============================================================================
INSERT INTO `atencion_seguimiento` (`incidencia_id`,`requiere_reposicion`,`fecha_respuesta`,`cliente_conforme`,`fecha_conformidad`) VALUES ('1','1',NULL,'0',NULL);
INSERT INTO `atencion_seguimiento` (`incidencia_id`,`requiere_reposicion`,`fecha_respuesta`,`cliente_conforme`,`fecha_conformidad`) VALUES ('2','0',NULL,'0',NULL);
INSERT INTO `atencion_seguimiento` (`incidencia_id`,`requiere_reposicion`,`fecha_respuesta`,`cliente_conforme`,`fecha_conformidad`) VALUES ('3','0','2026-10-12','0',NULL);
INSERT INTO `atencion_seguimiento` (`incidencia_id`,`requiere_reposicion`,`fecha_respuesta`,`cliente_conforme`,`fecha_conformidad`) VALUES ('4','0','2026-10-12','0',NULL);
INSERT INTO `atencion_seguimiento` (`incidencia_id`,`requiere_reposicion`,`fecha_respuesta`,`cliente_conforme`,`fecha_conformidad`) VALUES ('5','0','2026-10-12','1','2026-10-12');

-- ============================================================================
-- 21. Conformidad de productos | TABLA: conformidades_producto
-- Requiere: detalle_compras, usuarios_internos.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('1','CONFORME','4');
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('2','CONFORME','4');
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('3','CONFORME','4');
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('4','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('5','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('6','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('7','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('8','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('9','PENDIENTE',NULL);
INSERT INTO `conformidades_producto` (`detalle_compra_id`,`estado`,`revisado_por`) VALUES ('10','PENDIENTE',NULL);

-- ============================================================================
-- 22. Productos afectados y prioridad | TABLA: incidencia_detalles
-- Requiere: atencion_incidencias, detalle_compras.
-- Filas incluidas: 5.
-- ============================================================================
INSERT INTO `incidencia_detalles` (`incidencia_id`,`detalle_compra_id`,`prioridad`,`cantidad_afectada`) VALUES ('1','1','ALTA','1');
INSERT INTO `incidencia_detalles` (`incidencia_id`,`detalle_compra_id`,`prioridad`,`cantidad_afectada`) VALUES ('2','2','MEDIA','1');
INSERT INTO `incidencia_detalles` (`incidencia_id`,`detalle_compra_id`,`prioridad`,`cantidad_afectada`) VALUES ('3','3','ALTA','1');
INSERT INTO `incidencia_detalles` (`incidencia_id`,`detalle_compra_id`,`prioridad`,`cantidad_afectada`) VALUES ('4','4','MEDIA','1');
INSERT INTO `incidencia_detalles` (`incidencia_id`,`detalle_compra_id`,`prioridad`,`cantidad_afectada`) VALUES ('5','5','ALTA','1');

-- ============================================================================
-- 23. Fotografías de incidencias | TABLA: incidencia_evidencias
-- Requiere: atencion_incidencias.
-- Filas incluidas: 0.
-- ============================================================================
-- Esta tabla inicia vacía y se alimenta durante el uso del sistema.
-- El archivo debe existir en el almacenamiento privado y pertenecer al caso.
-- PLANTILLA OPCIONAL: sustituye todos los marcadores antes de ejecutarla.
-- INSERT INTO `incidencia_evidencias` (`incidencia_id`, `archivo`, `mime`, `nombre_original`)
-- VALUES ('<incidencia_id>', '<archivo>', '<mime>', '<nombre_original>');

-- ============================================================================
-- 24. Despachos: asignación de transportistas | TABLA: rutas_despacho
-- Requiere: guias_remision, usuarios_internos, direcciones.
-- Filas incluidas: 10.
-- ============================================================================
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('1','1','3','B8K-731','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','1','Entrega en Los Olivos','ENTREGADO','2026-10-02 09:30:00','2026-10-02 13:30:00');
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('2','2','5','C4M-582','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','2','Entrega en Los Olivos','ENTREGADO','2026-10-03 09:30:00','2026-10-03 13:30:00');
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('3','3','6','D7R-946','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','3','Entrega en Los Olivos','ENTREGADO','2026-10-04 09:30:00','2026-10-04 13:30:00');
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('4','4','3','B8K-731','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','4','Entrega en San Martín de Porres','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('5','5','5','C4M-582','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','5','Entrega en San Martín de Porres','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('6','6','6','D7R-946','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','6','Entrega en San Martín de Porres','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('7','7','3','B8K-731','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','7','Entrega en Independencia','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('8','8','5','C4M-582','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','8','Entrega en Independencia','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('9','9','6','D7R-946','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','9','Entrega en Rímac','ASIGNADO',NULL,NULL);
INSERT INTO `rutas_despacho` (`ruta_id`,`guia_id`,`transportista_id`,`vehiculo_placa`,`punto_partida`,`direccion_destino_id`,`descripcion_ruta`,`estado_entrega`,`hora_salida`,`hora_entrega`) VALUES ('10','10','3','B8K-731','Av. Argentina 4793, Carmen de la Legua Reynoso, Callao','10','Entrega en Rímac','ASIGNADO',NULL,NULL);

-- ============================================================================
-- 25. Posiciones GPS | TABLA: rutas_gps
-- Requiere: rutas_despacho, usuarios_internos.
-- Filas incluidas: 0.
-- ============================================================================
-- Esta tabla inicia vacía y se alimenta durante el uso del sistema.
-- Usa coordenadas capturadas por el conductor asignado; no inventes posiciones.
-- PLANTILLA OPCIONAL: sustituye todos los marcadores antes de ejecutarla.
-- INSERT INTO `rutas_gps` (`ruta_id`, `transportista_id`, `latitud`, `longitud`, `precision_m`, `capturado_ms`)
-- VALUES ('<ruta_id>', '<transportista_id>', '<latitud>', '<longitud>', '<precision_m>', '<capturado_ms>');

-- ============================================================================
-- 26. Recorridos calculados | TABLA: rutas_mapa
-- Requiere: rutas_despacho.
-- Filas incluidas: 0.
-- ============================================================================
-- Esta tabla inicia vacía y se alimenta durante el uso del sistema.
-- Habitualmente la completa el servicio de mapas; no necesita carga manual.
-- PLANTILLA OPCIONAL: sustituye todos los marcadores antes de ejecutarla.
-- INSERT INTO `rutas_mapa` (`ruta_id`, `origen_direccion`, `destino_direccion`, `origen_lat`, `origen_lng`, `destino_lat`, `destino_lng`)
-- VALUES ('<ruta_id>', '<origen_direccion>', '<destino_direccion>', '<origen_lat>', '<origen_lng>', '<destino_lat>', '<destino_lng>');

COMMIT;
