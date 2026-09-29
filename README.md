# Abastece+

Aplicación B2B para mayoristas y bodegas con frontend React/Vite y API PHP/MySQL.

## Requisitos

- Node.js 20+
- PHP 8.1+
- MySQL 8.0+

## Puesta en marcha

1. Importa `bd/Abastece_nuevo.sql` en tu servidor MySQL.
2. Si tus credenciales de MySQL difieren de las por defecto (`root` / `1234`), crea un archivo `.env` en la carpeta `backend/` basado en `backend/.env.example`.
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

5. Abre en tu navegador `http://localhost:5173`. Vite redirige automáticamente las peticiones `/api` al backend PHP en `http://localhost:8000`.

## Accesos de Usuarios Internos (`@abastece.com`)

| Rol | Correo | Contraseña |
|-----|--------|------------|
| **ADMINISTRADOR** | `carlos.ramirez@abastece.com` | `carlos123` |
| **LOGISTICA** | `maria.torres@abastece.com` | `maria123` |
| **TRANSPORTISTA** | `luis.mendoza@abastece.com` | `luis123` |
| **GESTOR_ATENCION** | `andrea.flores@abastece.com` | `andrea123` |

*(Hay 5 usuarios disponibles por cada rol en la base de datos).*

## Accesos de Bodegueros / Clientes (`@gmail.com`)

| Negocio | Correo | Contraseña |
|---------|--------|------------|
| Minimarket Don Jorge | `jorge.huaman@gmail.com` | `jorge123` |
| Bodega Doña Rosa | `rosa.condori@gmail.com` | `rosa123` |
| Market El Vecino | `miguel.paredes@gmail.com` | `miguel123` |
| Comercial Doña Carmen | `carmen.rojas@gmail.com` | `carmen123` |
| Bodega Patricia | `patricia.soto@gmail.com` | `patricia123` |

*(Hay 14 bodegueros registrados en la base de datos, todos con contraseñas en formato `nombre123` y direcciones de entrega ya asignadas).*
