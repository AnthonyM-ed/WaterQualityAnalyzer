# Simulación de Sensores IoT - Water Quality Analyzer

## Objetivo

Simular completamente el flujo de un sistema IoT de monitoreo de calidad de agua sin necesidad de hardware real, replicando el comportamiento de:
- Sensores ESP32/Arduino
- Protocolo MQTT
- Base de datos Firebase/Firestore
- Actualizaciones en tiempo real

## Arquitectura Simulada

```
┌─────────────────────────────────────────────────────────┐
│                 SensorSimulatorService                  │
│  (Simula sensores físicos enviando datos cada 30s)     │
└───────────────────────┬─────────────────────────────────┘
                        │
                        │ Stream de datos
                        │ (Simula MQTT publish)
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Dashboard/Map/Charts Pages                 │
│   (Suscritas a actualizaciones - Simula MQTT subscribe) │
└─────────────────────────────────────────────────────────┘
```

## Componentes

### 1. **SensorSimulatorService** 
Ubicación: `lib/shared/data/services/sensor_simulator_service.dart`

**Función:** Simula 3 sensores IoT (CA-08, CA-09, CA-10) que:
- Generan lecturas cada 30 segundos
- Tienen variaciones realistas (drift de sensores)
- Pueden fallar o desconectarse
- Generan anomalías aleatorias (10% de probabilidad)
- Calculan índice de calidad y alertas

**Eventos simulados:**
- pH spikes (descargas químicas)
- Turbidez alta (lluvia/sedimentos)
- Cloro bajo (falla en tratamiento)
- TDS alto (contaminación)
- Temperatura elevada

**Uso:**
```dart
final simulator = SensorSimulatorService();

// Suscribirse a updates (como MQTT subscribe)
simulator.subscribe((reading) {
  print('Nuevo dato: ${reading.stationId}');
});

// Iniciar simulación
simulator.startSimulation(interval: Duration(seconds: 30));

// Simular falla de sensor
simulator.setSensorStatus('CA-10', false);

// Detener
simulator.stopSimulation();
```

### 2. **Dashboard Integration**
Ubicación: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Características:**
- 🟢 **Modo Tiempo Real:** Actualiza automáticamente cada 30s
- 📊 **Modo Histórico:** Lee datos del CSV (sin actualizaciones)
- 🔔 **Notificaciones:** Alertas automáticas para valores críticos
- 🎚️ **Toggle:** Botón para cambiar entre modos

**Indicador visual:**
```
🟢 En vivo (actualiza cada 30s)  ← Modo tiempo real activo
```

## Flujo de Datos Simulado

### Modo Tiempo Real (Sensores IoT Simulados)

```
1. App inicia
   ↓
2. SensorSimulatorService.startSimulation()
   ↓
3. Cada 30 segundos:
   - Genera reading para CA-08
   - Genera reading para CA-09  
   - Genera reading para CA-10
   ↓
4. Publica a listeners (simula MQTT publish)
   ↓
5. Dashboard recibe update (simula MQTT onMessage)
   ↓
6. UI actualiza en tiempo real
   ↓
7. Si hay alertas críticas → Muestra SnackBar
```

### Modo Histórico (CSV Data)

```
1. App lee assets/data/arequipa_water_data.csv
   ↓
2. Muestra última lectura disponible
   ↓
3. No hay actualizaciones automáticas
   ↓
4. Usuario presiona "Refresh" para recargar
```

## Cómo Usar

### 1. Activar Simulación Tiempo Real

```dart
// En dashboard_page.dart
bool _useRealtimeSimulation = true; // ← true = tiempo real
```

O presiona el ícono de sensores en el AppBar para toggle entre modos.

### 2. Ajustar Intervalo de Actualización

```dart
_sensorSimulator.startSimulation(
  interval: const Duration(seconds: 15), // Cambia a 15s
);
```

### 3. Simular Eventos

```dart
// Falla de sensor
_sensorSimulator.setSensorStatus('CA-10', false);

// Recuperación
_sensorSimulator.setSensorStatus('CA-10', true);
```

## Datos Generados

### Parámetros Monitoreados:
- **pH:** 5.0 - 11.5 (LMP: 6.5 - 8.5)
- **TDS:** 50 - 3000 ppm (LMP: ≤1000)
- **Turbidez:** 0.1 - 10 NTU (LMP: ≤5.0)
- **Cloro residual:** 0.0 - 2.0 mg/L (LMP: 0.5 - 5.0)
- **Temperatura:** 15 - 35°C
- **Conductividad:** 100 - 5500 µS/cm

### Variaciones Realistas:
- **CA-08** (Zona Alta): Mejor calidad, TDS ~180 ppm
- **CA-09** (Pueblo): Calidad media, TDS ~170 ppm
- **CA-10** (Zona Baja): Peor calidad, TDS ~1650 ppm

## Sistema de Alertas

Cuando un parámetro excede el LMP:
1. Se genera alerta en el reading
2. Si es crítico (veryPoor o poor) → SnackBar rojo
3. Usuario puede presionar "Ver" para ir a detalle
4. Alerta se muestra en el card de la estación

## Ventajas de la Simulación

**No requiere hardware:** Funciona sin sensores físicos
**Testing realista:** Comportamiento similar a sensores reales
**Debugging fácil:** Logs detallados de cada evento
**Demo convincente:** Actualización en tiempo real visible
**Escalable:** Fácil agregar más estaciones
**Educativo:** Perfecto para tesis/presentaciones

## Migración a Hardware Real

Cuando se tenga sensores físicos, solo necesitas:

### 1. MQTT Real (HiveMQ/Mosquitto)

```dart
import 'package:mqtt_client/mqtt_client.dart';

final client = MqttServerClient('broker.hivemq.com', '1883');
await client.connect();

client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
  final payload = messages[0].payload as MqttPublishMessage;
  final reading = WaterQualityReading.fromJson(json.decode(payload));
  // ← Reemplaza SensorSimulatorService
});
```

### 2. Firebase Realtime Database

```dart
import 'package:firebase_database/firebase_database.dart';

final ref = FirebaseDatabase.instance.ref('stations/CA-08');
ref.onValue.listen((event) {
  final reading = WaterQualityReading.fromJson(event.snapshot.value);
  // ← Reemplaza SensorSimulatorService
});
```

## Logs de Ejemplo

```
🔌 Starting IoT sensor simulation...
📡 Sensors will send data every 30s
📻 New subscriber connected (1 total)
📊 CA-08: pH=7.65, TDS=185, Turbidez=1.2
📊 CA-09: pH=7.42, TDS=172, Turbidez=2.5
📊 CA-10: pH=7.08, TDS=1685, Turbidez=3.6
⚠️ [CA-10] ANOMALY: TDS spike!
📊 CA-10: pH=7.12, TDS=2527, Turbidez=3.5
```

**Nota:** El CSV (`arequipa_water_data.csv`) sigue disponible para análisis histórico y gráficos de tendencias. El modo tiempo real es para demostración del flujo IoT.
