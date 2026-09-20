# Abastece+

Aplicación B2B con frontend React/Vite y API PHP/MySQL.

## Requisitos

- Node.js 20+
- PHP 8+
- MySQL 8+

## Puesta en marcha

1. Importa `bd/Abastece+.sql` en MySQL.
2. Configura las variables descritas en `backend/.env.example` en tu servidor o ajusta sus valores locales.
3. Inicia la API desde la raíz del proyecto:

   ```powershell
   php -S localhost:8000 -t backend/public
   ```

4. En otra terminal inicia el frontend:

   ```powershell
   cd frontend
   npm install
   npm run dev
   ```

Vite publica el sitio en `http://localhost:5173` y redirige `/api` a la API local.

## Accesos de prueba "usuarios internos" incluidos en la base

- Administrador: `administrador@abastece.com` / `admin123`
- Transportista: `transporte1@abastece.com` / `transporte123`
- Atención: `atencion.soporte@abastece.com` / `atencion123`
- Logística: `logistica@abastece.com` / `logistica123`

## Accesos de prueba "bodeguero" incluido en la base

- bodeguero 1: `bodegueros1@example.test` / `rosa123`

Los comerciantes nuevos se registran desde `/registro`. La base de ejemplo contiene comerciantes históricos con hashes bcrypt incompatibles con el backend SHA-256 actual; para probar el acceso de comerciante debe crearse una cuenta desde el formulario.
