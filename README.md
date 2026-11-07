# PayID — Aplicación Móvil Flutter

Ecosistema digital que centraliza la identidad, los documentos personales, la billetera digital y los pagos de estudiantes de educación superior y padres de familia en el Perú. Desarrollada con **Flutter**, **Dart** y **Clean Architecture**, siguiendo fielmente el sistema de diseño oficial de **Figma (PayID 1.0)** y conectada al backend real **ASP.NET Core 9**.

---

## 🌟 Características Principales

- **Identidad Visual Oficial (PayID 1.0)**:
  - Paleta institucional: Verde Institucional (`#00763E`), Verde Profundo (`#005D32`), Petróleo (`#12646B`), Tinta (`#182B24`), Lienzo (`#F3F6F3`).
  - Tipografía exclusiva **Inter** (Google Fonts).
  - Iconografía **Lucide Outline** con trazo uniforme de 2px y target táctil accesible (mínimo 48×48 px).
  - Componentes UI reutilizables: `PayIdButton`, `PayIdTextField`, `PayIdCard` (Information, Action, Security), `PayIdBadge`, `PayIdDialog`, `PayIdBottomNav`.
- **Historias de Usuario (Documento Académico E1–E9)**:
  - **E1 Gestión de Usuarios**: Registro con DNI y celular peruano (US1), creación y gestión de perfiles familiares (US2).
  - **E2 Documentos Digitales**: Registro de DNI, Carné Universitario, Pasaporte y C.E. (US3), seguimiento de vencimiento y renovación (US4).
  - **E3 Pagos y Recargas**: Recarga de tarjetas de transporte Metropolitano/Metro (US5), amortización y pago de deudas (US6), historial completo de transacciones (US7), billetera digital y saldos en PEN (US19).
  - **E5 Notificaciones y Alertas**: Alerta de vencimiento (US9), notificaciones de trámites (US10), centro de notificaciones con filtros y badge dinámico (US21).
  - **E6 Acceso Sin Conexión**: Consulta de documentos en caché local vía Hive con fallback automático (US11).
  - **E7 Información y Confianza**: Onboarding interactivo (US12), políticas de privacidad y términos legales peruanos (US13), testimonios (US14), splash y acceso seguro (US15).
  - **E8 APIs REST**: Integración con API de autenticación JWT (US16) y API de documentos (US17).
  - **E9 Infraestructura y Seguridad**: Clean Architecture con Riverpod y GoRouter (US18), control de intentos fallidos con bloqueo 423 y temporizador activo de 15 minutos (US22).

---

## 🏗️ Arquitectura del Software (Clean Architecture)

El proyecto está estructurado con estricta separación de capas y responsabilidades:

```text
lib/
├── core/
│   ├── config/          # ApiConfig: URL del backend en Render y endpoints
│   ├── constants/       # AppColors, AppTypography, AppDimensions
│   ├── di/              # Inyección de dependencias (Riverpod)
│   ├── errors/          # Failures y Exceptions tipadas
│   ├── network/         # ApiClient (Dio) con interceptor Bearer JWT
│   ├── router/          # AppRouter (StatefulShellRoute con 5 tabs)
│   ├── storage/         # SecureStorageService (JWT) y HiveStorageService (offline)
│   ├── theme/           # AppTheme (Material 3 + Tokens Figma)
│   ├── utils/           # CurrencyFormatter (PEN S/), DateFormatter, Validators
│   └── widgets/         # Componentes atómicos reutilizables
│
├── features/
│   ├── authentication/  # Login, Registro, Recuperación, Onboarding, Splash
│   ├── dashboard/       # Dashboard principal, resumen de saldo, accesos rápidos
│   ├── documents/       # Listado, Registro, Detalle, Renovación, Caché offline
│   ├── wallet/          # Tarjetas de crédito/débito, transporte, recargas, deudas
│   ├── payments/        # Historial de transacciones, nuevos pagos
│   ├── profiles/        # Perfil personal y gestión de dependientes familiares
│   ├── notifications/   # Centro de notificaciones, filtros y lecturas
│   └── settings/        # Información personal, seguridad, políticas, soporte
│
└── main.dart            # Punto de entrada e inicialización de servicios
```

---

## 🔒 Seguridad y Privacidad

1. **Tokens JWT**: Almacenados de forma cifrada mediante `FlutterSecureStorage` (Keystore en Android / Keychain en iOS).
2. **Datos Sensibles**: El código CVV nunca se almacena en memoria persistente; se destruye inmediatamente tras el procesamiento.
3. **Enmascaramiento de Tarjetas**: Se muestran únicamente los últimos 4 dígitos (`•••• •••• •••• 1234`).
4. **Protección de Rutas**: `GoRouter` redirige automáticamente a `/login` ante sesiones inexistentes o tokens expirados.
5. **Mitigación de Ataques de Fuerza Bruta (US22)**: Recepción del código HTTP `423 Locked` tras 5 intentos fallidos, activando un temporizador en pantalla que bloquea el reintento durante 15 minutos.

---

## 🚀 Requisitos y Configuración

### Prerrequisitos
- **Flutter SDK**: 3.47.9 (stable) / Dart ^3.13.7, la misma versión usada en CI.
- **Backend**: ASP.NET Core 9 desplegado en Render. No hace falta correrlo localmente.

### Backend
| | URL |
|---|---|
| Servidor | `https://payid-backend-n573.onrender.com` |
| API (URL base de la app) | `https://payid-backend-n573.onrender.com/api` |
| Documentación (Swagger) | `https://payid-backend-n573.onrender.com/swagger/index.html` |
| Health check | `https://payid-backend-n573.onrender.com/health` |

La URL se define en `lib/core/config/api_config.dart`. Swagger es solo documentación, no la URL base. La app añade `/api` a la raíz del servidor y envía el JWT del login en `Authorization: Bearer <token>`. No se necesita ninguna clave ni secreto en la app.

Para apuntar a otro servidor sin tocar el código, pasa su raíz (sin `/api`) al compilar:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://otro-servidor.com
```

> El backend está en el plan gratuito de Render: si estuvo inactivo, la primera petición puede tardar ~30 s mientras el servidor arranca.

### Instalación de dependencias
```bash
flutter pub get
```

### Análisis estático de código
```bash
flutter analyze
```

### Ejecución de pruebas
```bash
flutter test
```

### Ejecutar la aplicación
```bash
# En emulador Android o dispositivo físico:
flutter run

# En Windows Desktop:
flutter run -d windows

# En Google Chrome (Web):
flutter run -d chrome
```

### Generar el APK
**Localmente:**
```bash
flutter build apk --release
# Resultado: build/app/outputs/flutter-apk/app-release.apk
```

**Con GitHub Actions** (`.github/workflows/build-apk.yml`): el workflow se ejecuta en cada push a `main` y también manualmente. Corre `flutter analyze`, `flutter test` y `flutter build apk --release`.

1. En GitHub abre **Actions → Build APK**.
2. Pulsa **Run workflow**, elige la rama `main` y confirma (o simplemente haz push a `main`).
3. Cuando termine en verde, abre la ejecución y en la sección **Artifacts** descarga `payid-app-release-<n>`.
4. Descomprime el `.zip` y copia `app-release.apk` al teléfono. Para instalarlo, Android pedirá permitir apps de origen desconocido.

Los artefactos se conservan 30 días. El APK está firmado con la clave de depuración, sirve para pruebas e instalación directa pero no para publicarlo en Google Play.

---

## 📄 Licencia

Este proyecto forma parte del ecosistema PayID para fines académicos y profesionales. Todos los derechos reservados.
