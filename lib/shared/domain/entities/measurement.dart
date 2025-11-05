import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'measurement.g.dart';

@JsonSerializable()
class Measurement extends Equatable {
  final String id;
  final String sensorId;
  final String stationId;
  final String parameter;
  final double value;
  final String unit;
  final DateTime timestamp;
  final MeasurementQuality quality;
  final Map<String, dynamic> metadata;

  const Measurement({
    required this.id,
    required this.sensorId,
    required this.stationId,
    required this.parameter,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.quality,
    this.metadata = const {},
  });

  factory Measurement.fromJson(Map<String, dynamic> json) => 
      _$MeasurementFromJson(json);
  Map<String, dynamic> toJson() => _$MeasurementToJson(this);

  Measurement copyWith({
    String? id,
    String? sensorId,
    String? stationId,
    String? parameter,
    double? value,
    String? unit,
    DateTime? timestamp,
    MeasurementQuality? quality,
    Map<String, dynamic>? metadata,
  }) {
    return Measurement(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      stationId: stationId ?? this.stationId,
      parameter: parameter ?? this.parameter,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      quality: quality ?? this.quality,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sensorId,
        stationId,
        parameter,
        value,
        unit,
        timestamp,
        quality,
        metadata,
      ];
}

enum MeasurementQuality {
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('fair')
  fair,
  @JsonValue('poor')
  poor,
  @JsonValue('invalid')
  invalid,
}

@JsonSerializable()
class WaterQualityReading extends Equatable {
  final String id;
  final String stationId;
  final DateTime timestamp;
  final Map<String, double> parameters; // parameter -> value
  final WaterQualityStatus overallStatus;
  final double qualityIndex; // 0-100 quality index
  final List<String> alerts;

  const WaterQualityReading({
    required this.id,
    required this.stationId,
    required this.timestamp,
    required this.parameters,
    required this.overallStatus,
    required this.qualityIndex,
    this.alerts = const [],
  });

  factory WaterQualityReading.fromJson(Map<String, dynamic> json) => 
      _$WaterQualityReadingFromJson(json);
  Map<String, dynamic> toJson() => _$WaterQualityReadingToJson(this);

  WaterQualityReading copyWith({
    String? id,
    String? stationId,
    DateTime? timestamp,
    Map<String, double>? parameters,
    WaterQualityStatus? overallStatus,
    double? qualityIndex,
    List<String>? alerts,
  }) {
    return WaterQualityReading(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      timestamp: timestamp ?? this.timestamp,
      parameters: parameters ?? this.parameters,
      overallStatus: overallStatus ?? this.overallStatus,
      qualityIndex: qualityIndex ?? this.qualityIndex,
      alerts: alerts ?? this.alerts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stationId,
        timestamp,
        parameters,
        overallStatus,
        qualityIndex,
        alerts,
      ];
}

enum WaterQualityStatus {
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('moderate')
  moderate,
  @JsonValue('poor')
  poor,
  @JsonValue('very_poor')
  veryPoor,
}