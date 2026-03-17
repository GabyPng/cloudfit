# CloudFit Flutter — Setup y cambios implementados

## Dependencias agregadas

En `pubspec.yaml`:

```yaml
firebase_core: ^3.13.0
firebase_auth: ^5.5.2
http: ^1.3.0
```

Instalar con:
```bash
flutter pub get
```

---

## Configuración de Firebase

Se generó automáticamente el archivo `lib/firebase_options.dart` con:
```bash
dart pub global run flutterfire_cli:flutterfire configure --project=cloudfit-3c00a
```

Este archivo contiene las credenciales de Firebase para cada plataforma (Android, iOS, Web, Windows, macOS). **No modificar manualmente.**

---

## Archivos creados / modificados

### `lib/main.dart`
- Inicializa Firebase antes de arrancar la app con `Firebase.initializeApp()`

### `lib/firebase_options.dart`
- Generado por FlutterFire CLI
- Configuración de conexión con el proyecto Firebase `cloudfit-3c00a`

### `lib/core/auth_service.dart` ← nuevo
Servicio que encapsula Firebase Auth:
- `AuthService.login(email, password)` — inicia sesión
- `AuthService.register(email, password)` — crea cuenta
- `AuthService.logout()` — cierra sesión
- `AuthService.getIdToken()` — obtiene el token para mandarlo al backend
- `AuthService.currentUser` — usuario actualmente autenticado

### `lib/core/api_client.dart` ← nuevo
Cliente HTTP que agrega automáticamente el token Firebase en cada request al backend Laravel:
- `ApiClient.get('/endpoint')`
- `ApiClient.post('/endpoint', body)`
- `ApiClient.put('/endpoint', body)`
- `ApiClient.delete('/endpoint')`

La URL base está en `lib/core/constants.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
}
```

### `lib/core/constants.dart`
- Se agregó `ApiConfig.baseUrl` apuntando al backend Laravel local

### `lib/sections/auth/login_screen.dart`
- Conectado a Firebase Auth real
- Muestra errores en español según el código de error de Firebase
- Indicador de carga mientras espera respuesta

### `lib/sections/auth/register_screen.dart`
- Conectado a Firebase Auth real
- Valida que las contraseñas coincidan antes de llamar a Firebase
- Muestra errores en español
- Indicador de carga mientras espera respuesta

### `lib/sections/auth/splash_screen.dart`
- Verifica si hay sesión activa al arrancar
- Si hay sesión → redirige a `/` (dashboard)
- Si no hay sesión → redirige a `/login`

---

## Cómo correr el proyecto

### Requisitos previos
- Flutter SDK instalado
- Developer Mode activado en Windows (`start ms-settings:developers`)
- Backend Laravel corriendo en `http://127.0.0.1:8000`

### Backend
```bash
cd api-backend
php -S 127.0.0.1:8000 -t public
```

### Flutter
```bash
cd Flutter/flutter_application_cloudfit
flutter pub get
flutter run -d windows   # app de escritorio
flutter run -d chrome    # navegador
```

---

## Flujo de autenticación

```
1. Usuario abre la app → SplashScreen verifica sesión
2. Sin sesión → LoginScreen / RegisterScreen
3. Firebase Auth valida credenciales y devuelve un ID Token
4. Flutter usa ApiClient para llamar al backend con el token en el header:
   Authorization: Bearer {token}
5. Laravel verifica el token con Firebase y responde con datos
```
