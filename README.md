# Monitor de Calidad del Agua - Río Acarí, Arequipa

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Sistema de monitoreo en tiempo real de la calidad del agua en la cuenca del Río Acarí, Caravelí - Arequipa, Perú**

[Características](#-características) • [Arquitectura](#-arquitectura) • [Instalación](#-instalación) • [Documentación](#-documentación) • [Estaciones](#-estaciones-de-monitoreo)

</div>

---

## Descripción

Aplicación multiplataforma desarrollada en **Flutter** para el monitoreo continuo de la calidad del agua en la **cuenca del Río Acarí** (Caravelí, Arequipa). El sistema integra sensores IoT simulados que replican condiciones reales basadas en datos históricos de la zona, proporcionando análisis en tiempo real, alertas automáticas según LMP DIGESA, visualización de datos históricos y mapas de estaciones de monitoreo.

### Contexto del Proyecto

Basado en el estudio "Parámetros fisicoquímicos de la cuenca del río Acarí" (2008), esta aplicación monitorea **3 estaciones críticas** (CA-08, CA-09, CA-10) que representan puntos estratégicos desde la zona alta hasta el impacto urbano del pueblo de Acarí.

## Características

### Implementadas
- ✅ **Autenticación Firebase**: Login/Registro con Firebase Auth + Realtime Database
- ✅ **Dashboard en Tiempo Real**: Monitoreo simultáneo de 3 estaciones (CA-08, CA-09, CA-10)
- ✅ **Sincronización Cloud**: Firebase Realtime Database con persistencia offline (10MB)
- ✅ **Gráficos Históricos**: Análisis de 24h, 7d, 30d, 90d con muestreo inteligente (fl_chart)
- ✅ **Simulación IoT**: Generación de datos realistas cada 30s basados en CSV históricos
- ✅ **Mapas Interactivos**: Visualización geográfica de estaciones (flutter_map)
- ✅ **Modo Offline**: Fallback a datos CSV cuando no hay conexión
- ✅ **Temas**: Modo claro/oscuro con Material Design 3
- ✅ **Alertas de Calidad**: Sistema de colores según LMP DIGESA

### Pantallas Principales
- **Login/Registro**: Autenticación + modo demo
- **Dashboard**: Vista en tiempo real con métricas clave (pH, TDS, Turbidez, Cloro)
- **Gráficos**: Análisis histórico con múltiples períodos
- **Mapa**: Ubicación de estaciones en cuenca del Río Acarí
- **Detalle de Estación**: Vista expandida de estación individual
- **Configuración**: Ajustes de tema y preferencias

## Arquitectura

### Clean Architecture + Repository Pattern

```
lib/
├── core/                          # Configuración global
│   ├── constants/
│   │   ├── app_constants.dart     # LMP DIGESA, umbrales de calidad
│   │   └── api_constants.dart     # Configuración de APIs
│   ├── providers/
│   │   └── theme_provider.dart    # Gestión de temas
│   └── themes/
│       └── app_theme.dart         # Material Design 3
│
├── features/                      # Módulos por funcionalidad
│   ├── auth/                      # Autenticación
│   │   ├── data/repositories/
│   │   └── presentation/pages/
│   ├── dashboard/                 # Dashboard principal
│   │   └── presentation/pages/
│   ├── charts/                    # Análisis histórico
│   │   └── presentation/
│   ├── maps/                      # Visualización geográfica
│   │   └── presentation/
│   └── settings/                  # Configuración
│       └── presentation/
│
├── shared/                        # Código compartido
│   ├── domain/entities/           # Entidades del negocio
│   │   ├── measurement.dart       # Mediciones de sensores
│   │   ├── station.dart           # Estaciones de monitoreo
│   │   ├── sensor.dart            # Tipos de sensores
│   │   ├── alert.dart             # Alertas de calidad
│   │   └── user.dart              # Usuarios
│   └── data/services/
│       ├── firebase_data_service.dart    # CRUD Firebase
│       ├── csv_data_service.dart         # Lectura CSV
│       ├── sensor_simulator_service.dart # Simulación IoT
│       └── simulated_data_service.dart   # Generación de datos
│
├── scripts/                       # Herramientas de desarrollo
│   ├── migrate_csv_to_firebase.dart
│   └── check_firebase_data.dart
│
└── firebase_options.dart          # Configuración Firebase
```

### Flujo de Datos (Cloud-First)

```
Usuario Abre App → Firebase Auth → Dashboard
                                       ↓
                      Firebase Realtime DB (Online)
                                       ↓
                    Sensor Simulator (cada 30s)
                                       ↓
                    Guardar en Firebase + UI Update
                                       ↓
                    Si Offline → CSV Fallback
```

## Parámetros de Calidad Monitoreados

Según **LMP DIGESA** (Límites Máximos Permisibles) y estándares OMS:

| Parámetro | Rango Óptimo | Rango Aceptable | Unidad | Sensor |
|-----------|--------------|-----------------|--------|--------|
| **pH** | 7.0 - 7.5 | 6.5 - 8.5 | pH | Electrodo de vidrio (±0.1) |
| **TDS** | 0 - 500 | 0 - 1000 | mg/L | Conductividad (±1%) |
| **Turbidez** | 0 - 1.0 | 0 - 5.0 | UNT | Sensor óptico (±0.1) |
| **Cloro Residual** | 0.5 - 1.5 | 0.5 - 5.0 | mg/L | Electroquímico DPD (±0.05) |

### Sistema de Alertas por Color

- 🟢 **Verde**: Óptimo - Agua segura para consumo
- 🟡 **Amarillo**: Advertencia - Requiere atención
- 🔴 **Rojo**: Crítico - Fuera de LMP DIGESA

## Stack Tecnológico

### Frontend
- **Flutter** 3.5.4 - Framework multiplataforma
- **Dart** 3.5.4 - Lenguaje de programación
- **Provider** - Gestión de estado
- **Go Router** - Navegación declarativa

### Backend & Cloud
- **Firebase Auth** 4.19.6 - Autenticación de usuarios
- **Firebase Realtime Database** 10.5.6 - Base de datos NoSQL en tiempo real
- **Firebase Cloud** - Persistencia offline (10MB)

### UI & Visualización
- **Material Design 3** - Sistema de diseño moderno
- **fl_chart** 0.69.0 - Gráficos interactivos
- **flutter_map** 8.2.2 - Mapas con OpenStreetMap

### Data & Storage
- **SQLite** 2.3.3 - Base de datos local
- **CSV** 6.0.0 - Datos históricos de respaldo
- **Shared Preferences** 2.2.2 - Preferencias del usuario
- **JSON Serialization** - Conversión automática de datos

### Servicios
- **Geolocator** 12.0.0 - Servicios de ubicación GPS
- **Geocoding** 3.0.0 - Conversión coordenadas/direcciones
- **HTTP** 1.2.2 - Cliente HTTP
- **Web Socket Channel** 2.4.5 - Comunicación en tiempo real

### Notificaciones
- **Flutter Local Notifications** 17.2.2 - Alertas push locales

## Instalación

### Prerrequisitos
- **Flutter SDK** ≥ 3.9.2
- **Dart SDK** ≥ 3.9.2
- **Android Studio** / **VS Code** con extensiones Flutter
- **Git**
- Cuenta de **Firebase** (para funcionalidades cloud)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/AnthonyM-ed/WaterQualityAnalyzer.git
cd WaterQualityAnalyzer
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar archivos de serialización**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar Firebase** (Opcional para funcionalidades cloud)
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

5. **Ejecutar la aplicación**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# Web
flutter run -d chrome
```

### Modo Demo

El **botón "Acceso Demo"** permite:
- Acceso directo al dashboard sin registro
- Explorar todas las funcionalidades de la app
- **Requiere Firebase configurado** (la app intenta cargar datos cloud)
- Si no hay conexión, automáticamente usa datos CSV históricos como fallback

**Nota**: El modo demo salta la autenticación pero la app sigue intentando conectarse a Firebase para datos en tiempo real. Para funcionar completamente offline, la app tiene un sistema de fallback automático a CSV.

## Estaciones de Monitoreo

### Cuenca del Río Acarí, Caravelí - Arequipa

| Estación | Nombre | Ubicación | Elevación | Descripción |
|----------|--------|-----------|-----------|-------------|
| **CA-08** | Zona Media Alta | -15.4265°, -74.6139° | 1200 m | Aguas arriba - Control de calidad zona alta |
| **CA-09** | Pueblo Acarí | -15.4324°, -74.6169° | 430 m | Estación principal cercana al pueblo |
| **CA-10** | Zona Baja | -15.4395°, -74.6139° | 420 m | Aguas abajo - Monitoreo impacto urbano |

> **Base histórica**: Datos basados en "Parámetros fisicoquímicos cuenca río Acarí" (2008)

### Simulación de Sensores IoT

El sistema genera datos realistas cada **30 segundos** con las siguientes características:

- **Baseline CSV**: Datos históricos reales de la cuenca (2008)
- **Variaciones**: Drift de sensores (±5%) simulando condiciones naturales
- **Patrones**: Ciclos diurnos, estacionalidad, eventos de contaminación
- **Anomalías**: 10% probabilidad de valores fuera de LMP (genera alertas)

#### Características de Simulación por Estación:
- **CA-08** (Zona Alta): Agua más limpia, bajo TDS, cloro 0.7 mg/L
- **CA-09** (Pueblo): Impacto moderado, TDS medio, cloro 0.4 mg/L
- **CA-10** (Zona Baja): Mayor turbidez, impacto urbano, cloro 0.15 mg/L

## Descarga

**Puedes descargar la aplicación directamente desde el siguiente enlace:** [app-debug.apk](https://drive.google.com/file/d/18e3XVBhAxmkQ9uAAZYAroZwkrFG40QKm/view?usp=drive_link)

## Autor

- **Desarrollo** - [AnthonyM-ed](https://github.com/AnthonyM-ed)

## Agradecimientos

- Datos históricos basados en "Parámetros fisicoquímicos cuenca río Acarí" (2008)
- Normativas DIGESA (Perú) y OMS para estándares de calidad del agua
- Comunidad de Acarí, Caravelí - Arequipa

