# CloudFit — API Backend

API REST construida con Laravel 12. Se conecta a Firebase Data Connect (PostgreSQL) y usa Firebase Auth para autenticación.

---

## Requisitos

- PHP 8.2+
- Composer
- Node.js + npm (para el emulador de Firebase)
- Firebase CLI: `npm install -g firebase-tools`

---

## Instalación

```bash
# 1. Instalar dependencias de PHP
composer install

# 2. Crear tu archivo de configuración local
cp .env.example .env

# 3. Generar la clave de la aplicación
php artisan key:generate
```

No necesitas correr migraciones — la base de datos la maneja Firebase Data Connect.

---

## Correr el proyecto localmente

Necesitas dos terminales abiertas al mismo tiempo:

**Terminal 1 — Emulador de Firebase (base de datos)**
```bash
# Desde la raíz del proyecto (cloudfit/)
npx firebase emulators:start --only dataconnect
```

**Terminal 2 — Servidor Laravel (API)**
```bash
# Desde api-backend/
php artisan serve
```

La API queda disponible en `http://localhost:8000`

---

## Autenticación

Toda la autenticación es via **Firebase Auth**. El login y registro lo maneja el frontend directamente con Firebase.

Cada request protegido debe incluir el Firebase ID Token en el header:
```
Authorization: Bearer {firebase_id_token}
```

El token debe tener un custom claim `role` con uno de estos valores:
- `ADMINISTRADOR`
- `COACH`
- `NUTRIOLOGO`
- `CLIENTE`

---

## Endpoints

| Método | Ruta | Rol requerido | Descripción |
|--------|------|---------------|-------------|
| GET | `/api/me` | cualquiera | Info del usuario autenticado |
| GET | `/api/admin/dashboard` | ADMINISTRADOR | Panel de admin |
| GET | `/api/admin/users` | ADMINISTRADOR | Lista de usuarios |
| GET | `/api/coach/dashboard` | COACH | Panel del coach |
| GET | `/api/coach/clientes` | COACH | Clientes del coach |
| GET | `/api/coach/planes` | COACH | Planes de entrenamiento |
| GET | `/api/nutriologo/dashboard` | NUTRIOLOGO | Panel del nutriólogo |
| GET | `/api/nutriologo/clientes` | NUTRIOLOGO | Clientes del nutriólogo |
| GET | `/api/nutriologo/planes` | NUTRIOLOGO | Planes nutricionales |
| GET | `/api/cliente/dashboard` | CLIENTE, ADMINISTRADOR | Panel del cliente |
| GET | `/api/cliente/plan-entrenamiento` | CLIENTE, ADMINISTRADOR | Plan de entrenamiento |
| GET | `/api/cliente/plan-nutricional` | CLIENTE, ADMINISTRADOR | Plan nutricional |
| GET | `/api/cliente/progreso` | CLIENTE, ADMINISTRADOR | Historial de progreso |

---

## Variables de entorno

Copia `.env.example` a `.env`. Para desarrollo local no necesitas cambiar nada — los valores por defecto apuntan al emulador.

Para producción cambia:
```
FIREBASE_AUTH_EMULATOR=false
FIREBASE_PROJECT_ID=tu-proyecto-real
FIREBASE_CREDENTIALS=/ruta/al/service-account.json
DATACONNECT_EMULATOR=false
```

---

## Estructura del proyecto

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Auth/AuthController.php         # Endpoint /me
│   │   ├── Admin/AdminController.php
│   │   ├── Coach/CoachController.php
│   │   ├── Cliente/ClienteController.php
│   │   └── Nutriologo/NutriologoController.php
│   └── Middleware/
│       ├── VerifyFirebaseToken.php          # Valida Firebase ID Token
│       └── CheckRole.php                   # Verifica el rol del usuario
├── Services/
│   └── DataConnectService.php              # Cliente HTTP para Data Connect
config/
├── firebase.php                            # Config de Firebase Auth
└── dataconnect.php                         # Config de Data Connect
routes/
├── api.php                                 # Hub de rutas
└── api/
    ├── admin.php
    ├── coach.php
    ├── nutriologo.php
    └── cliente.php
```
