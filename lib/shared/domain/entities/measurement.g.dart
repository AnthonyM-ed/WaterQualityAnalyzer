// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Measurement _$MeasurementFromJson(Map<String, dynamic> json) => Measurement(
  id: json['id'] as String,
  sensorId: json['sensorId'] as String,
  stationId: json['stationId'] as String,
  parameter: json['parameter'] as String,
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  quality: $enumDecode(_$MeasurementQualityEnumMap, json['quality']),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MeasurementToJson(Measurement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sensorId': instance.sensorId,
      'stationId': instance.stationId,
      'parameter': instance.parameter,
      'value': instance.value,
      'unit': instance.unit,
      'timestamp': instance.timestamp.toIso8601String(),
      'quality': _$MeasurementQualityEnumMap[instance.quality]!,
      'metadata': instance.metadata,
    };

const _$MeasurementQualityEnumMap = {
  MeasurementQuality.excellent: 'excellent',
  MeasurementQuality.good: 'good',
  MeasurementQuality.fair: 'fair',
  MeasurementQuality.poor: 'poor',
  MeasurementQuality.invalid: 'invalid',
};

WaterQualityReading _$WaterQualityReadingFromJson(Map<String, dynamic> json) =>
    WaterQualityReading(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      parameters: (json['parameters'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      overallStatus: $enumDecode(
        _$WaterQualityStatusEnumMap,
        json['overallStatus'],
      ),
      qualityIndex: (json['qualityIndex'] as num).toDouble(),
      alerts:
          (json['alerts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WaterQualityReadingToJson(
  WaterQualityReading instance,
) => <String, dynamic>{
  'id': instance.id,
  'stationId': instance.stationId,
  'timestamp': instance.timestamp.toIso8601String(),
  'parameters': instance.parameters,
  'overallStatus': _$WaterQualityStatusEnumMap[instance.overallStatus]!,
  'qualityIndex': instance.qualityIndex,
  'alerts': instance.alerts,
};

const _$WaterQualityStatusEnumMap = {
  WaterQualityStatus.excellent: 'excellent',
  WaterQualityStatus.good: 'good',
  WaterQualityStatus.moderate: 'moderate',
  WaterQualityStatus.poor: 'poor',
  WaterQualityStatus.veryPoor: 'very_poor',
};
