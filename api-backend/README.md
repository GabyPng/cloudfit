# CloudFit — API Backend

API REST construida con Laravel 12. Usa JWT de Supabase para autenticación/autorización por roles y Gemini (opcional) para el chatbot.

---

## Requisitos

- PHP 8.2+
- Composer
- Una URL de proyecto Supabase válida (para validar JWT vía JWKS)

---

## Instalación

```bash
# 1. Instalar dependencias de PHP
composer install

# 2. Crear tu archivo de configuración local
cp .env.example .env

# 3. Generar la clave de la aplicación
php artisan key:generate

# 4. Crear tablas locales necesarias
php artisan migrate

# 5. (Opcional, recomendado) verificar rutas activas
php artisan route:list --path=api --except-vendor
```

Nota: el backend actual usa base local de Laravel para datos internos del usuario sincronizado (tabla `users`) y validación de rol por token.

---

## Correr el proyecto localmente

**Terminal — Servidor Laravel (API)**
```bash
# Desde api-backend/
php artisan serve
```

La API queda disponible en `http://localhost:8000`

---

## Autenticación

Toda la autenticación protegida es vía **Supabase JWT**.

Cada request protegido debe incluir el token en el header:
```
Authorization: Bearer {supabase_access_token}
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
| GET | `/api/me` | cualquiera autenticado | Info del usuario autenticado |
| PUT | `/api/me` | cualquiera autenticado | Actualiza perfil local (name/objective/avatar_url) |
| POST | `/api/sync` | cualquiera autenticado | Sincroniza usuario Supabase en DB local |
| POST | `/api/chatbot/message` | cualquiera autenticado | Mensaje al asistente (Gemini o fallback rule-based) |
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

Copia `.env.example` a `.env`.

Mínimo para funcionamiento:
```
SUPABASE_URL=https://<tu-proyecto>.supabase.co
```

Recomendado para integración completa:
```
SUPABASE_ANON_KEY=<tu-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<tu-service-role-key>
```

Opcional (chatbot con IA):
```
GEMINI_API_KEY=<tu-api-key>
GEMINI_MODEL=gemini-2.0-flash
GEMINI_ENABLED=true
```

También existen variables legadas de Firebase/Data Connect en `.env.example`, pero no son requeridas por las rutas API actuales.

---

## Estructura del proyecto

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Auth/AuthController.php
│   │   ├── Admin/AdminController.php
│   │   ├── Chatbot/ChatbotController.php
│   │   ├── Coach/CoachController.php
│   │   ├── Cliente/ClienteController.php
│   │   └── Nutriologo/NutriologoController.php
│   └── Middleware/
│       ├── VerifySupabaseToken.php         # Valida JWT de Supabase
│       └── CheckRole.php                   # Verifica roles permitidos por ruta
config/
├── supabase.php                            # Config de Supabase
└── gemini.php                              # Config del chatbot IA
routes/
├── api.php                                 # Hub de rutas
└── api/
    ├── admin.php
    ├── chatbot.php
    ├── coach.php
    ├── nutriologo.php
    └── cliente.php
```
