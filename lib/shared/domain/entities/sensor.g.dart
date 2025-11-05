// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sensor _$SensorFromJson(Map<String, dynamic> json) => Sensor(
  id: json['id'] as String,
  stationId: json['stationId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$SensorTypeEnumMap, json['type']),
  parameter: json['parameter'] as String,
  unit: json['unit'] as String,
  minValue: (json['minValue'] as num).toDouble(),
  maxValue: (json['maxValue'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  status: $enumDecode(_$SensorStatusEnumMap, json['status']),
  installedAt: DateTime.parse(json['installedAt'] as String),
  lastCalibration: json['lastCalibration'] == null
      ? null
      : DateTime.parse(json['lastCalibration'] as String),
  nextCalibration: json['nextCalibration'] == null
      ? null
      : DateTime.parse(json['nextCalibration'] as String),
  config: SensorConfig.fromJson(json['config'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SensorToJson(Sensor instance) => <String, dynamic>{
  'id': instance.id,
  'stationId': instance.stationId,
  'name': instance.name,
  'type': _$SensorTypeEnumMap[instance.type]!,
  'parameter': instance.parameter,
  'unit': instance.unit,
  'minValue': instance.minValue,
  'maxValue': instance.maxValue,
  'accuracy': instance.accuracy,
  'status': _$SensorStatusEnumMap[instance.status]!,
  'installedAt': instance.installedAt.toIso8601String(),
  'lastCalibration': instance.lastCalibration?.toIso8601String(),
  'nextCalibration': instance.nextCalibration?.toIso8601String(),
  'config': instance.config,
};

const _$SensorTypeEnumMap = {
  SensorType.ph: 'ph',
  SensorType.dissolvedOxygen: 'dissolved_oxygen',
  SensorType.temperature: 'temperature',
  SensorType.turbidity: 'turbidity',
  SensorType.conductivity: 'conductivity',
  SensorType.ammonia: 'ammonia',
  SensorType.nitrites: 'nitrites',
  SensorType.nitrates: 'nitrates',
  SensorType.chlorine: 'chlorine',
  SensorType.pressure: 'pressure',
};

const _$SensorStatusEnumMap = {
  SensorStatus.active: 'active',
  SensorStatus.inactive: 'inactive',
  SensorStatus.maintenance: 'maintenance',
  SensorStatus.error: 'error',
  SensorStatus.calibrationNeeded: 'calibration_needed',
};

SensorConfig _$SensorConfigFromJson(Map<String, dynamic> json) => SensorConfig(
  readingInterval: (json['readingInterval'] as num).toInt(),
  transmissionInterval: (json['transmissionInterval'] as num).toInt(),
  calibrationOffset: (json['calibrationOffset'] as num?)?.toDouble() ?? 0.0,
  calibrationSlope: (json['calibrationSlope'] as num?)?.toDouble() ?? 1.0,
  vendorSpecificSettings:
      json['vendorSpecificSettings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SensorConfigToJson(SensorConfig instance) =>
    <String, dynamic>{
      'readingInterval': instance.readingInterval,
      'transmissionInterval': instance.transmissionInterval,
      'calibrationOffset': instance.calibrationOffset,
      'calibrationSlope': instance.calibrationSlope,
      'vendorSpecificSettings': instance.vendorSpecificSettings,
    };
