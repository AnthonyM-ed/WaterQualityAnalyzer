# Arquitectura Técnica - Sistema de Monitoreo de Calidad del Agua

## 1. Flutter: Definición de Interfaz y Funcionalidades Clave

### 1.1 Descripción General
El sistema utiliza Flutter como framework multiplataforma para desarrollar una aplicación móvil/desktop que permite el monitoreo en tiempo real de la calidad del agua mediante la integración con dispositivos IoT.

### 1.2 Funcionalidades Clave Implementadas

#### Dashboard en Tiempo Real
- **Monitoreo Multi-Estación**: Visualización simultánea de 3 estaciones de monitoreo (CA-08, CA-09, CA-10)
- **Métricas Principales**:
  - pH (6.5-8.5): Nivel de acidez/alcalinidad del agua
  - TDS (0-1000 mg/L): Sólidos disueltos totales
  - Turbidez (0-5 UNT): Claridad del agua
  - Cloro Residual (0.5-5 mg/L): Nivel de desinfección del agua
- **Actualizaciones Automáticas**: Lecturas cada 30 segundos simulando sensores IoT reales
- **Indicadores de Estado**: Sistema de colores (verde/amarillo/rojo) según umbrales de calidad

#### Análisis Histórico con Gráficos Interactivos
- **Múltiples Períodos**: 24 horas, 7 días, 30 días, 90 días
- **Visualización**: Gráficos de línea con fl_chart mostrando tendencias
- **Optimización de Rendimiento**: Muestreo inteligente (máximo 50 puntos para 24h)
- **Formato de Tiempo**: Etiquetas adaptativas (horas para 24h, fechas para períodos largos)

#### Sistema de Autenticación Firebase
- **Registro de Usuarios**: Creación de cuentas con nombre, email, DNI y contraseña
- **Login Seguro**: Autenticación mediante Firebase Auth
- **Gestión de Sesión**: Persistencia de login, logout, recuperación de contraseña
- **Base de Datos de Usuarios**: Almacenamiento de datos adicionales en Firebase Realtime Database

#### Gestión de Datos Cloud-First
- **Sincronización Automática**: Lecturas guardadas automáticamente en Firebase
- **Modo Offline**: Caché de 10MB con sincronización diferida
- **Fallback CSV**: Datos históricos de respaldo cuando no hay conexión
- **Optimización**: Consultas eficientes con filtrado en memoria

### 1.3 Interfaz de Usuario (UI/UX)

#### Pantalla de Dashboard
```
┌─────────────────────────────────────┐
│  Calidad del Agua - Dashboard       │
├─────────────────────────────────────┤
│  [Tiempo Real] [Histórico]          │
│                                     │
│  Estación CA-08                     │
│  ┌──────┬──────┬──────┬──────┐      │
│  │ pH   │ TDS  │ Turb │ Cloro│      │
│  │ 7.2  │ 180  │ 12.5 │ 0.7  │      │
│  └──────┴──────┴──────┴──────┘      │
│                                     │
│  Estación CA-09                     │
│  [...similar layout...]             │
│                                     │
│  Estación CA-10                     │
│  [...similar layout...]             │
└─────────────────────────────────────┘
```

#### Pantalla de Gráficos
```
┌─────────────────────────────────────┐
│  Análisis Histórico                 │
├─────────────────────────────────────┤
│  Estación: [CA-08 ▼]                │
│  Período: [24h] [7d] [30d] [90d]    │
│                                     │
│  [Gráfico de Línea - pH]            │
│  8.0 ┤     ╭─╮                      │
│  7.5 ┤   ╭─╯ ╰─╮                    │
│  7.0 ┤ ╭─╯     ╰─╮                  │
│  6.5 ┴─────────────                 │
│      0h  6h  12h  18h  24h          │
│                                     │
│  [Gráfico de Línea - TDS]           │
│  [Gráfico de Línea - Turbidez]      │
│  [Gráfico de Línea - Cloro Residual]│
└─────────────────────────────────────┘
```

## 2. Desarrollo e Implementación

### 2.1 Stack Tecnológico

#### Frontend (Flutter)
- **Framework**: Flutter 3.5.4 / Dart 3.5.4
- **Arquitectura**: Clean Architecture con separación por features
- **Gestión de Estado**: setState para simplicidad (escalable a Riverpod/Bloc)
- **UI Components**: Material Design 3
- **Gráficos**: fl_chart ^0.69.0

#### Backend (Firebase)
- **Autenticación**: Firebase Auth 4.19.6
- **Base de Datos**: Firebase Realtime Database 10.5.6
- **Persistencia Offline**: 10MB cache, sincronización automática
- **Proyecto**: water-quality-db-630a8

#### Almacenamiento Local
- **CSV Histórico**: Datos de respaldo en assets/data/
- **Estructura**: station_id, timestamp, ph, tds, turbidity, chlorine_residual
- **Propósito**: Fallback cuando Firebase no disponible

### 2.2 Estructura del Proyecto

```
lib/
├── core/                          # Configuración global
│   ├── constants/
│   │   ├── app_constants.dart     # Umbrales de calidad LMP (DIGESA)
│   │   └── api_constants.dart     # Configuración de APIs
│   ├── providers/
│   │   └── theme_provider.dart    # Gestión de tema claro/oscuro
│   ├── themes/
│   │   └── app_theme.dart         # Tema Material Design
│   ├── errors/                    # Manejo de errores
│   ├── utils/                     # Utilidades compartidas
│   └── widgets/                   # Widgets reutilizables
│
├── features/                      # Módulos por funcionalidad
│   ├── auth/                      # Autenticación
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   │
│   ├── dashboard/                 # Pantalla principal
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── dashboard_page.dart
│   │           └── station_detail_page.dart
│   │
│   ├── charts/                    # Análisis histórico
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── charts_page.dart
│   │
│   ├── maps/                      # Visualización geográfica
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── map_page.dart
│   │
│   └── settings/                  # Configuración de la app
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── settings_page.dart
│
├── shared/                        # Código compartido
│   ├── domain/                    # Entidades del negocio
│   │   ├── entities/
│   │   │   ├── measurement.dart   # Mediciones de sensores
│   │   │   ├── measurement.g.dart # JSON serialization
│   │   │   ├── station.dart       # Estaciones de monitoreo
│   │   │   ├── station.g.dart
│   │   │   ├── sensor.dart        # Tipos de sensores
│   │   │   ├── sensor.g.dart
│   │   │   ├── alert.dart         # Alertas de calidad
│   │   │   ├── alert.g.dart
│   │   │   ├── user.dart          # Usuarios del sistema
│   │   │   └── user.g.dart
│   │   └── domain.dart            # Barrel file
│   │
│   ├── data/                      # Servicios de datos
│   │   └── services/
│   │       ├── firebase_data_service.dart    # CRUD Firebase Realtime DB
│   │       ├── csv_data_service.dart         # Lectura de datos CSV
│   │       ├── sensor_simulator_service.dart # Simulación IoT en tiempo real
│   │       └── simulated_data_service.dart   # Generación de datos simulados
│   │
│   └── presentation/              # Widgets compartidos
│
├── scripts/                       # Herramientas de desarrollo
│   ├── migrate_csv_to_firebase.dart    # Migración CSV → Firebase
│   └── check_firebase_data.dart        # Verificación de datos
│
├── firebase_options.dart          # Configuración Firebase autogenerada
└── main.dart                      # Entry point de la aplicación
```

### 2.3 Flujo de Datos

#### Lectura de Datos (Cloud-First)
```
Usuario Abre App
    ↓
Firebase.getLatestReading()
    ↓
¿Datos disponibles?
    ├─ SÍ → Mostrar datos Firebase
    │         ↓
    │     Iniciar SensorSimulator
    │         ↓
    │     Recibir actualizaciones cada 30s
    │
    └─ NO → Cargar datos CSV
              ↓
          Mostrar datos históricos
```

#### Escritura de Datos (Automática)
```
SensorSimulator.generate()
    ↓
Crear WaterQualityReading
    ↓
FirebaseDataService.saveReading()
    ├─ Online → Guardar inmediatamente
    │             ↓
    │         Actualizar UI
    │
    └─ Offline → Guardar en caché
                    ↓
                Sincronizar cuando reconecte
```

## 3. Arquitectura de Integración IoT

### 3.1 Arquitectura General del Sistema

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         CAPA DE PRESENTACIÓN                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐ ┌──────────────┐       │
│  │  Dashboard  │  │   Gráficos  │  │ Autenticación│  │     Mapa     │ │ Cofiguración │       │
│  │    Page     │  │    Page     │  │     Page     │  │     Page     │ │     Page     │       │
│  └─────────────┘  └─────────────┘  └──────────────┘  └──────────────┘ └──────────────┘       │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
                            ↕
┌──────────────────────────────────────────────────────────────┐
│                      CAPA DE DOMINIO                         │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │   Entidades      │  │   Repositorios   │                  │
│  │  (Reading, User) │  │   (Interfaces)   │                  │
│  └──────────────────┘  └──────────────────┘                  │
└──────────────────────────────────────────────────────────────┘
                            ↕
┌──────────────────────────────────────────────────────────────┐
│                       CAPA DE DATOS                          │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐      │
│  │  Firebase   │  │  CSV Service │  │ Sensor Simulator│      │
│  │   Service   │  │              │  │                 │      │
│  └─────────────┘  └──────────────┘  └─────────────────┘      │
└──────────────────────────────────────────────────────────────┘
                            ↕
┌──────────────────────────────────────────────────────────────┐
│                    INFRAESTRUCTURA CLOUD                     │
│  ┌────────────────────────────────────────────────────────┐  │
│  │         Firebase Realtime Database (NoSQL)             │  │
│  │  ┌────────────────────────────────────────────────┐    │  │
│  │  │ readings/                                      │    │  │
│  │  │   ├─ CA-08/                                    │    │  │
│  │  │   │   ├─ 1732653092165: {ph, tds, ...}         │    │  │
│  │  │   │   ├─ 1732653122165: {ph, tds, ...}         │    │  │
│  │  │   │   └─ latest: {referencia a última}         │    │  │
│  │  │   ├─ CA-09/ [...]                              │    │  │
│  │  │   └─ CA-10/ [...]                              │    │  │
│  │  │                                                │    │  │
│  │  │ users/                                         │    │  │
│  │  │   └─ {uid}: {name, email, dni, createdAt}      │    │  │
│  │  └────────────────────────────────────────────────┘    │  │
│  │                                                        │  │
│  │         Firebase Auth (Autenticación)                  │  │
│  │  ┌────────────────────────────────────────────────┐    │  │
│  │  │ Email/Password Authentication                  │    │  │
│  │  │ Session Management                             │    │  │
│  │  └────────────────────────────────────────────────┘    │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
                            ↕
┌──────────────────────────────────────────────────────────────┐
│              DISPOSITIVOS IoT (Simulados)                    │
│  ┌───────────┐      ┌───────────┐      ┌────────────┐        │
│  │ Sensor    │      │ Sensor    │      │ Sensor     │        │
│  │ CA-08     │      │ CA-09     │      │ CA-10      │        │
│  │           │      │           │      │            │        │
│  │ pH: 7.2   │      │ pH: 7.5   │      │ pH: 6.8    │        │
│  │ TDS: 180  │      │ TDS: 220  │      │ TDS: 150   │        │
│  │ Turb: 12  │      │ Turb: 18  │      │ Turb: 8    │        │
│  │ Cloro: 0.7│      │ Cloro: 0.4│      │ Cloro: 0.15│        │
│  └───────────┘      └───────────┘      └────────────┘        │
│       ↓                  ↓                   ↓               │
│  [Transmisión cada 30 segundos via MQTT/HTTP simulado]       │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Protocolo de Comunicación IoT

#### Configuración Actual (Simulación)
```dart
// lib/shared/data/services/sensor_simulator_service.dart
class SensorSimulatorService {
  // Intervalo de lectura (simula sensores reales de la cuenca del Río Acarí)
  Duration interval = const Duration(seconds: 30);
  
  // Generación de datos basada en CSV históricos + variaciones
  Map<String, dynamic> _generateReading(String stationId) {
    // 1. Obtener baseline de datos CSV históricos de Acarí
    final baseline = CsvDataService.getStationBaseline(stationId);
    
    // 2. Aplicar variaciones realistas (drift de sensores reales)
    final parameters = {
      'ph': baseline['ph'] + _random.nextDouble() * 0.4 - 0.2,
      'tds': baseline['tds'] + _random.nextInt(20) - 10,
      'turbidity': baseline['turbidity'] + _random.nextDouble() * 2 - 1,
      'chlorine_residual': baseline['chlorine_residual'] + _random.nextDouble() * 0.1 - 0.05,
    };
    
    // 3. Crear Measurement y guardar en Firebase
    final measurement = Measurement(
      id: '${stationId}_${DateTime.now().millisecondsSinceEpoch}',
      stationId: stationId,
      parameters: parameters,
      timestamp: DateTime.now(),
    );
    
    return measurement;
  }
  
  // Publicación a Firebase (simula MQTT publish)
  Future<void> _saveToFirebase(Measurement reading) async {
    await FirebaseDataService().saveMeasurement(reading);
  }
}
```

#### Arquitectura de Producción (Futura)
```
Sensores Físicos IoT
    ↓
[Arduino/ESP32 con sensores pH/TDS/Turbidez]
    ↓
MQTT Broker (AWS IoT Core / HiveMQ)
    ↓
Firebase Cloud Functions (procesar datos)
    ↓
Firebase Realtime Database
    ↓
Flutter App (sin cambios)
```

### 3.3 Estructura de Datos Firebase

```json
{
  "readings": {
    "CA-08": {
      "1732653092165": {
        "stationId": "CA-08",
        "timestamp": 1732653092165,
        "ph": 7.2,
        "tds": 180,
        "turbidity": 12.5,
        "chlorine_residual": 0.7
      },
      "1732653122165": { "..." },
      "latest": {
        "timestamp": 1732653122165
      }
    },
    "CA-09": { "..." },
    "CA-10": { "..." }
  },
  "users": {
    "uid_abc123": {
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "dni": "12345678",
      "createdAt": "2025-11-26T10:30:00.000Z",
      "lastLogin": "2025-11-26T14:25:00.000Z"
    }
  }
}
```

## 4. Especificaciones Técnicas

### 4.1 Requisitos del Sistema

#### Plataformas Soportadas
- **Android**: API 21+ (Android 5.0 Lollipop)
- **iOS**: iOS 12.0+
- **Windows**: Windows 10/11
- **Linux**: Ubuntu 20.04+
- **macOS**: macOS 10.14+
- **Web**: Chrome, Firefox, Safari (últimas 2 versiones)

#### Requisitos de Hardware
- **Memoria RAM**: Mínimo 2GB, recomendado 4GB
- **Almacenamiento**: 100MB para la app + 10MB cache
- **Conectividad**: WiFi o datos móviles para sincronización cloud
- **Sensores IoT**: 
  - pH: Sensor de electrodo de vidrio (precisión ±0.1)
  - TDS: Sensor conductividad (rango 0-1000 ppm)
  - Turbidez: Sensor óptico (rango 0-100 NTU)
  - Cloro Residual: Sensor electroquímico DPD (rango 0-5 mg/L)

### 4.2 Configuración Firebase

#### Proyecto Firebase
```yaml
Project ID: water-quality-db-630a8
Database URL: https://water-quality-db-630a8-default-rtdb.firebaseio.com
Region: us-central1
```

#### Reglas de Seguridad Realtime Database
```json
{
  "rules": {
    "readings": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$stationId": {
        "$timestamp": {
          ".validate": "newData.hasChildren(['stationId', 'timestamp', 'ph', 'tds', 'turbidity', 'chlorine_residual'])"
        }
      }
    },
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

#### Configuración de Persistencia Offline
```dart
// lib/main.dart - Inicialización de Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase con opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Habilitar persistencia offline (10MB)
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
  
  runApp(const WaterQualityApp());
}
```

### 4.3 Umbrales de Calidad del Agua (LMP DIGESA)

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // Estándares de calidad del agua para Cuenca Río Acarí - LMP DIGESA
  static const Map<String, Map<String, double>> waterQualityStandards = {
    'pH': {
      'min': 6.5,
      'max': 8.5,
      'optimal_min': 7.0,
      'optimal_max': 7.5,
    },
    'tds': { // Total Dissolved Solids (mg/L)
      'min': 0.0,
      'max': 1000.0,      // LMP DIGESA
      'optimal_min': 0.0,
      'optimal_max': 500.0,
    },
    'turbidity': { // UNT (Unidades Nefelométricas de Turbidez)
      'min': 0.0,
      'max': 5.0,         // LMP OMS
      'optimal_min': 0.0,
      'optimal_max': 1.0,
    },
    'chlorine_residual': { // Cloro residual (mg/L)
      'min': 0.5,         // LMP mínimo para desinfección
      'max': 5.0,         // LMP máximo seguro
      'optimal_min': 0.5,
      'optimal_max': 1.5,
    },
  };
  
  // Configuración de simulación - Cuenca Río Acarí
  static const int dataUpdateIntervalSeconds = 30;
  static const int maxStationsSimulated = 3; // CA-08, CA-09, CA-10
}
```

### 4.4 Optimizaciones de Rendimiento

#### Muestreo de Datos
```dart
// lib/features/charts/presentation/charts_page.dart

// Límites de puntos para optimización de rendimiento
const int maxPoints24h = 50;  // 24h: máximo 50 puntos
// Períodos más largos: estimatedReadings automático

// Algoritmo de muestreo uniforme para reducir puntos en gráficos
List<Measurement> _sampleReadings(
  List<Measurement> readings, 
  int maxPoints
) {
  if (readings.length <= maxPoints) return readings;
  
  final step = readings.length / maxPoints;
  final sampled = <WaterQualityReading>[];
  
  for (int i = 0; i < maxPoints; i++) {
    final index = (i * step).floor();
    sampled.add(readings[index]);
  }
  
  return sampled;
}
```

#### Caché y Persistencia
- **Firebase Offline**: 10MB caché local automático
- **CSV Fallback**: 122 lecturas históricas embebidas
- **Sincronización Diferida**: Escrituras en cola cuando offline

### 4.5 Formato de Datos CSV

```csv
station_id,timestamp,ph,tds,turbidity,chlorine_residual
CA-08,2025-08-20 09:00:00,7.2,180,12.5,0.7
CA-08,2025-08-21 09:00:00,7.3,185,13.0,0.75
CA-09,2025-08-20 09:00:00,7.5,220,18.0,0.4
...
```

### 4.6 Dependencias Principales

```yaml
# pubspec.yaml
name: water_quality_arequipa
description: "Aplicación para monitorear calidad del agua - Río Acarí, Arequipa"
version: 1.0.0+1

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.6
  provider: ^6.1.1
  equatable: ^2.0.5
  
  # Firebase
  firebase_core: ^2.31.1
  firebase_auth: ^4.19.6
  firebase_database: ^10.5.6
  google_sign_in: ^6.2.1
  
  # Data & Storage
  sqflite: ^2.3.3+1
  shared_preferences: ^2.2.2
  csv: ^6.0.0
  
  # Charts & Visualization
  fl_chart: ^0.69.0
  
  # Maps & Location
  flutter_map: ^8.2.2
  latlong2: ^0.9.1
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  
  # Networking
  http: ^1.2.2
  web_socket_channel: ^2.4.5
  
  # Notifications
  flutter_local_notifications: ^17.2.2
  
  # Utilities
  intl: ^0.19.0
  go_router: ^14.2.7
  json_annotation: ^4.9.0
  
  # UI
  cupertino_icons: ^1.0.6
```

### 4.7 Métricas de Calidad del Código

```
Arquitectura: Clean Architecture con separación por features
Patrón: Repository Pattern + Service Layer

Estructura:
├── 5 Features independientes (auth, dashboard, charts, maps, settings)
├── 6 Entidades de dominio (Measurement, Station, Sensor, Alert, User)
├── 4 Servicios de datos (Firebase, CSV, Simulator, Simulated)
├── 2 Scripts de utilidad (migrate, check_firebase)
└── Configuración centralizada (constants, themes, providers)

Calidad:
- Manejo de errores: Try-catch en todos los servicios críticos
- Logs: Mínimos en producción (solo errores)
- Serialización: JSON automática con json_annotation
- Tipado: Fuerte con Dart null-safety
- State Management: Provider + setState (escalable a Bloc)
- Offline-first: Persistencia automática Firebase + CSV fallback
```

## 5. Seguridad

### 5.1 Autenticación
- Email/Password con validación de Firebase
- Tokens JWT automáticos (manejados por Firebase Auth)
- Sesiones persistentes con logout manual

### 5.2 Autorización
- Reglas Firebase: Solo usuarios autenticados leen/escriben
- Usuarios solo acceden a sus propios datos en `/users/{uid}`
- Lecturas de sensores: acceso completo para usuarios autenticados

### 5.3 Validación de Datos
```dart
// lib/shared/data/services/firebase_data_service.dart
// Validación en cliente antes de guardar
void _validateMeasurement(Measurement measurement) {
  final ph = measurement.parameters['ph'];
  if (ph < 0 || ph > 14) {
    throw Exception('pH fuera de rango válido (0-14)');
  }
  
  final tds = measurement.parameters['tds'];
  if (tds < 0 || tds > 1000) {
    throw Exception('TDS fuera de rango LMP DIGESA (0-1000 mg/L)');
  }
  
  final turbidity = measurement.parameters['turbidity'];
  if (turbidity < 0 || turbidity > 100) {
    throw Exception('Turbidez fuera de rango (0-100 UNT)');
  }
  
  final chlorine = measurement.parameters['chlorine_residual'];
  if (chlorine < 0 || chlorine > 10) {
    throw Exception('Cloro residual fuera de rango (0-10 mg/L)');
  }
}

// Validación en Firebase Rules
".validate": "newData.child('ph').val() >= 0 && 
               newData.child('ph').val() <= 14"
```

## 6. Mantenimiento y Escalabilidad

### 6.1 Monitoreo
- Firebase Console: Lecturas en tiempo real
- Logs de errores: Try-catch en servicios críticos
- Performance: Métricas de frame rendering (target: <16ms)

### 6.2 Escalabilidad Horizontal
```
Lecturas por segundo actuales: 0.1 (3 estaciones × 30s)
Capacidad Firebase Spark (gratis): 100 conexiones simultáneas
Escalabilidad: Migrar a Firebase Blaze para +100 usuarios
```

### 6.3 Actualizaciones
- **App**: Over-the-air updates via Play Store/App Store
- **Base de datos**: Migraciones automáticas (versionado de esquema)
- **Reglas Firebase**: Actualización sin downtime

---

**Versión del Documento**: 1.3  
**Última Actualización**: 30 de Noviembre, 2025  
**Autores**: Equipo de Desarrollo Water Quality Analyzer
