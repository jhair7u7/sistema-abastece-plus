# Abastece+

Sistema de abastecimiento para bodegas: React/Vite, API PHP y MySQL. La web pública incluye catálogo, registro y Mi panel; `/admin` contiene los módulos internos de Usuarios, Logística, Transporte y Atención.

## Instalación

Requisitos: Node.js 20.19+ o 22.12+, PHP 8.2+ con PDO MySQL, mbstring y fileinfo, y MySQL 8+. El usuario de MySQL debe poder crear tablas y vistas. Para ejecutar la prueba de instalación también necesita crear y eliminar una base temporal.

1. En una instalación nueva, importa **primero** `bd/Abastece_nuevo.sql` y **después** `bd/Inserts_abastece.sql` mediante MySQL Workbench o phpMyAdmin. El primero contiene toda la estructura y vistas; el segundo contiene los registros iniciales. No necesitas otros SQL. La estructura no elimina una base existente. No importes los inserts sobre datos existentes.
2. Copia `backend/.env.example` a `backend/.env` y configura DB_HOST, DB_PORT, DB_NAME, DB_USER y DB_PASSWORD para tu servidor. Define un AUTH_SECRET propio. Conserva tu archivo `.env` si ya tienes una instalación configurada.
3. Desde la raíz inicia la API:

   ```powershell
   php -S localhost:8000 -t backend/public
   ```

4. En otra terminal:

   ```powershell
   cd frontend
   npm ci
   npm run dev
   ```

Abre `http://localhost:5173`. Vite redirige `/api` a `http://localhost:8000`; las imágenes de productos están en `backend/public/uploads/products`, que debe conservarse. Las evidencias privadas se almacenan en `backend/storage` y necesitan permisos de escritura para PHP. Ajusta `upload_max_filesize` y `post_max_size` para admitir cinco fotos de hasta 5 MB cada una.

## Cuentas incluidas en los inserts

Son cuentas ficticias de desarrollo. Todas usan la contraseña inicial **Abastece2026!**, almacenada con bcrypt. Cambia las contraseñas antes de usar datos propios.

| Rol | Correo |
|---|---|
| Administrador | administrador@abastece.com |
| Logística | logistica@abastece.com |
| Atención | atencion@abastece.com |
| Transportista Luis | transporte@abastece.com |
| Transportista Jorge | transporte.jorge@abastece.com |
| Transportista Miguel | transporte.miguel@abastece.com |

Comerciantes: `rosa.huaman@example.com`, `jose.salazar@example.com`, `elena.paredes@example.com`, `pedro.castillo@example.com`, `lucia.rojas@example.com`, `carmen.flores@example.com`, `ricardo.gutierrez@example.com`, `patricia.mendoza@example.com`, `daniel.vargas@example.com` y `ana.torres@example.com`.

Los nombres de personas, DNI, RUC de comerciantes, contactos y placas tienen formatos de desarrollo: no se atribuyen a personas reales ni están validados ante RENIEC, SUNAT o registros vehiculares. Los correos `example.com` no son contactos operativos. Los contactos asociados a los proveedores también son ficticios; las razones sociales y RUC de Alicorp y Leche Gloria son públicos.

## Datos incluidos

El catálogo conserva sus 60 productos, imágenes, empaques y precios almacenados en el sistema al 12/10/2026. No se cambiaron los precios por cotizaciones externas. Incluye inventario por lote, dos proveedores, diez comercios, pagos, diez compras y despachos distribuidos entre tres conductores, cuatro facturas, favoritos, conformidades y cinco incidencias con seguimiento. Los importes de compra incluyen IGV.

Las diez direcciones están distribuidas en Los Olivos, San Martín de Porres, Independencia y Rímac. Son ubicaciones públicas verificables usadas como destinos de prueba; **no representan bodegas existentes ni vínculos con sus ocupantes**. No hay coordenadas GPS inventadas. Caché de mapas, posiciones GPS y fotos de evidencias comienzan vacíos y se generan al usar el sistema.

Fuentes de ubicaciones y proveedores:

- [Los Olivos: sedes municipales](https://www.gob.pe/institucion/munilosolivos/contacto-y-numeros-de-emergencias), [Palacio de la Juventud](https://munilosolivos.gob.pe/riesgos_desastres/PLAN_CONTINUIDAD_OPERATIVA.pdf) y [SUNAT: centros de atención](https://desa1.sunat.gob.pe/institucional/contactenos/presencial_Lima.html).
- [San Martín de Porres: sedes](https://www.gob.pe/institucion/munisanmartindeporres/sedes), [Independencia: sede judicial](https://portal.mpfn.gob.pe/descargas/transparencia/SEDES_SISTEMAWEB_3.pdf).
- [Rímac: sedes municipales](https://www.gob.pe/institucion/munirimac/sedes) y [Flor de Amancaes](https://www.gob.pe/institucion/sisol/sedes?sheet=6).
- [Alicorp: razón social y RUC](https://www.alicorp.com.pe/pe/es/promociones/concurso-interno-manos-a-las-cremas-junio-2026), [domicilio](https://www.alicorp.com.pe/pe/es/politicas-de-privacidad) y [Leche Gloria: razón social, RUC y domicilio](https://www.gloria.com.pe/images/politicasyprivacidad.pdf).

## Uso

Los comerciantes registran una dirección exacta, distrito, provincia y departamento; la referencia es opcional. Atención puede editarla. Mi panel muestra la dirección actual. Los cambios de dirección crean una versión nueva para que los pedidos anteriores conserven su destino.

El administrador accede a todos los módulos internos. Las cuentas desactivadas no pueden iniciar sesión ni usar sus sesiones anteriores. Atención administra incidencias, evidencias, respuestas, conformidades y cuentas de comercios. Logística administra catálogo, stock, proveedores y despachos.

Una compra guarda su método de pago y código de operación; no emite factura automáticamente. Logística asigna un despacho y después confirma **Emitir factura**. El transportista asignado puede descargarla únicamente tras su emisión. La emisión repetida conserva el mismo documento y correlativo. Los pagos de tarjeta y documentos PDF del entorno son simulados; no existe conexión con una pasarela bancaria ni emisión tributaria SUNAT.

Las placas de los tres conductores están registradas en los despachos iniciales; al asignar una entrega se obtiene la placa del historial. Para un conductor nuevo, registra previamente un despacho con su placa en la base mediante administración autorizada.

## Mapas y despliegue

Configura `PHOTON_URL` para geocodificación Photon o `GEOCODING_URL` para un servicio Nominatim compatible. `ROUTING_URL` define el proveedor OSRM de carreteras. Sin un geocodificador configurado, algunas direcciones nuevas no podrán localizarse. Una dirección pública válida no garantiza que cualquier proveedor reconozca el número exacto. El sistema avisa cuando no puede calcular el destino o recorrido.

El GPS necesita HTTPS o localhost y permiso del conductor. El administrador no reporta su propia posición como conductor. `VITE_MAP_TILES_URL` y `VITE_MAP_TILES_ATTRIBUTION` permiten configurar cartografía compatible en `frontend/.env.local`. Usa servicios autorizados para tu dominio y conserva sus créditos. Al usar túneles, publica también la API y configura `VITE_API_URL`; no incluyas secretos privados en variables VITE. Para compilar el frontend ejecuta `npm --prefix frontend run build` y publica `frontend/dist` con fallback de rutas a `index.html`.

## Verificación

```powershell
npm --prefix frontend run lint
npm --prefix frontend run build
php backend/tests/schema.php
php backend/tests/direcciones_flujo.php
php backend/tests/logistica_flujo.php
```

La prueba de esquema importa ambos SQL en una base temporal y la elimina al terminar. Las pruebas de direcciones y logística revierten sus cambios. Conserva copias de tu BD y de las evidencias antes de una actualización.
