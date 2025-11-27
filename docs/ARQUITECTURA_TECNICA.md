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
│   │   └── app_constants.dart     # Umbrales de calidad, configuración
│   └── themes/
│       └── app_theme.dart         # Tema Material Design
│
├── features/                      # Módulos por funcionalidad
│   ├── auth/                      # Autenticación
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │
│   ├── dashboard/                 # Pantalla principal
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── dashboard_page.dart
│   │       └── widgets/
│   │           ├── station_card.dart
│   │           └── metric_tile.dart
│   │
│   └── charts/                    # Análisis histórico
│       └── presentation/
│           ├── pages/
│           │   └── charts_page.dart
│           └── widgets/
│               └── metric_chart.dart
│
├── shared/                        # Código compartido
│   ├── domain/                    # Entidades del negocio
│   │   ├── entities/
│   │   │   ├── water_quality_reading.dart
│   │   │   ├── monitoring_station.dart
│   │   │   └── user.dart
│   │   └── domain.dart
│   │
│   └── data/                      # Servicios de datos
│       └── services/
│           ├── firebase_data_service.dart    # CRUD Firebase
│           ├── csv_data_service.dart         # Lectura CSV
│           └── sensor_simulator_service.dart # Simulación IoT
│
├── scripts/                       # Herramientas
│   └── migrate_csv_to_firebase.dart
│
└── main.dart                      # Entry point
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
┌──────────────────────────────────────────────────────────────┐
│                     CAPA DE PRESENTACIÓN                     │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐          │
│  │  Dashboard  │  │   Gráficos  │  │ Autenticación│          │
│  │    Page     │  │    Page     │  │     Page     │          │
│  └─────────────┘  └─────────────┘  └──────────────┘          │
└──────────────────────────────────────────────────────────────┘
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
// SensorSimulatorService
class SensorSimulatorService {
  // Intervalo de lectura (simula sensores reales)
  Duration interval = Duration(seconds: 30);
  
  // Generación de datos basada en CSV + variaciones
  WaterQualityReading _generateReading(String stationId) {
    // 1. Obtener baseline de datos históricos CSV
    final baseline = _getBaselineReading(stationId);
    
    // 2. Aplicar variaciones realistas (±5% drift)
    final ph = baseline.ph + _random.nextDouble() * 0.4 - 0.2;
    final tds = baseline.tds + _random.nextInt(20) - 10;
    // ...
    
    // 3. Retornar lectura simulada
    return WaterQualityReading(...);
  }
  
  // Publicación a Firebase (simula MQTT publish)
  Future<void> _saveToFirebase(WaterQualityReading reading) async {
    await FirebaseDataService().saveReading(reading);
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
// Habilitar caché offline (10MB)
FirebaseDatabase.instance.setPersistenceEnabled(true);
FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
```

### 4.3 Umbrales de Calidad del Agua

```dart
class WaterQualityThresholds {
  // pH (nivel de acidez/alcalinidad)
  static const double phMin = 6.5;      // Mínimo aceptable
  static const double phMax = 8.5;      // Máximo aceptable
  static const double phIdeal = 7.0;    // Neutro ideal
  
  // TDS - Total Dissolved Solids (ppm)
  static const double tdsMax = 300;     // Límite seguro OMS
  static const double tdsWarning = 200; // Advertencia
  
  // Turbidez (NTU - Nephelometric Turbidity Units)
  static const double turbidityMax = 5.0;    // Límite OMS
  static const double turbidityWarning = 3.0; // Advertencia
  
  // Cloro Residual (mg/L)
  static const double chlorineMin = 0.5;     // Mínimo para desinfección
  static const double chlorineMax = 5.0;     // Máximo seguro OMS
}
```

### 4.4 Optimizaciones de Rendimiento

#### Muestreo de Datos
```dart
// Límites de puntos para gráficos
const int maxPoints24h = 50;  // 24h: máximo 50 puntos
// 7d, 30d, 90d: usar estimatedReadings del servicio

// Algoritmo de muestreo uniforme
List<WaterQualityReading> _sampleReadings(
  List<WaterQualityReading> readings, 
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
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.31.1
  firebase_auth: ^4.19.6
  firebase_database: ^10.5.6
  
  # Gráficos
  fl_chart: ^0.69.0
  
  # Utilidades
  csv: ^6.0.0
  intl: ^0.19.0
  
  # UI
  cupertino_icons: ^1.0.6
```

### 4.7 Métricas de Calidad del Código

```
Archivos Dart: 25
Líneas de código: ~3,500
Cobertura de errores: Try-catch en todos los servicios
Logs de producción: Mínimos (solo errores críticos)
Arquitectura: Clean Architecture (3 capas)
Separación de concerns: Features independientes
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
// Validación en cliente (Flutter)
if (ph < 0 || ph > 14) throw Exception('pH fuera de rango');
if (tds < 0 || tds > 1000) throw Exception('TDS fuera de rango');

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

**Versión del Documento**: 1.2  
**Última Actualización**: 26 de Noviembre, 2025  
**Autores**: Equipo de Desarrollo Water Quality Analyzer
