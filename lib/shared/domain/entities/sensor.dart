import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sensor.g.dart';

@JsonSerializable()
class Sensor extends Equatable {
  final String id;
  final String stationId;
  final String name;
  final SensorType type;
  final String parameter; // pH, dissolved_oxygen, temperature, etc.
  final String unit; // pH units, mg/L, °C, etc.
  final double minValue;
  final double maxValue;
  final double accuracy;
  final SensorStatus status;
  final DateTime installedAt;
  final DateTime? lastCalibration;
  final DateTime? nextCalibration;
  final SensorConfig config;

  const Sensor({
    required this.id,
    required this.stationId,
    required this.name,
    required this.type,
    required this.parameter,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.accuracy,
    required this.status,
    required this.installedAt,
    this.lastCalibration,
    this.nextCalibration,
    required this.config,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);
  Map<String, dynamic> toJson() => _$SensorToJson(this);

  Sensor copyWith({
    String? id,
    String? stationId,
    String? name,
    SensorType? type,
    String? parameter,
    String? unit,
    double? minValue,
    double? maxValue,
    double? accuracy,
    SensorStatus? status,
    DateTime? installedAt,
    DateTime? lastCalibration,
    DateTime? nextCalibration,
    SensorConfig? config,
  }) {
    return Sensor(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      name: name ?? this.name,
      type: type ?? this.type,
      parameter: parameter ?? this.parameter,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      accuracy: accuracy ?? this.accuracy,
      status: status ?? this.status,
      installedAt: installedAt ?? this.installedAt,
      lastCalibration: lastCalibration ?? this.lastCalibration,
      nextCalibration: nextCalibration ?? this.nextCalibration,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stationId,
        name,
        type,
        parameter,
        unit,
        minValue,
        maxValue,
        accuracy,
        status,
        installedAt,
        lastCalibration,
        nextCalibration,
        config,
      ];
}

enum SensorType {
  @JsonValue('ph')
  ph,
  @JsonValue('dissolved_oxygen')
  dissolvedOxygen,
  @JsonValue('temperature')
  temperature,
  @JsonValue('turbidity')
  turbidity,
  @JsonValue('conductivity')
  conductivity,
  @JsonValue('ammonia')
  ammonia,
  @JsonValue('nitrites')
  nitrites,
  @JsonValue('nitrates')
  nitrates,
  @JsonValue('chlorine')
  chlorine,
  @JsonValue('pressure')
  pressure,
}

enum SensorStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('error')
  error,
  @JsonValue('calibration_needed')
  calibrationNeeded,
}

@JsonSerializable()
class SensorConfig extends Equatable {
  final int readingInterval; // seconds between readings
  final int transmissionInterval; // seconds between data transmissions
  final double calibrationOffset;
  final double calibrationSlope;
  final Map<String, dynamic> vendorSpecificSettings;

  const SensorConfig({
    required this.readingInterval,
    required this.transmissionInterval,
    this.calibrationOffset = 0.0,
    this.calibrationSlope = 1.0,
    this.vendorSpecificSettings = const {},
  });

  factory SensorConfig.fromJson(Map<String, dynamic> json) => 
      _$SensorConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SensorConfigToJson(this);

  SensorConfig copyWith({
    int? readingInterval,
    int? transmissionInterval,
    double? calibrationOffset,
    double? calibrationSlope,
    Map<String, dynamic>? vendorSpecificSettings,
  }) {
    return SensorConfig(
      readingInterval: readingInterval ?? this.readingInterval,
      transmissionInterval: transmissionInterval ?? this.transmissionInterval,
      calibrationOffset: calibrationOffset ?? this.calibrationOffset,
      calibrationSlope: calibrationSlope ?? this.calibrationSlope,
      vendorSpecificSettings: vendorSpecificSettings ?? this.vendorSpecificSettings,
    );
  }

  @override
  List<Object?> get props => [
        readingInterval,
        transmissionInterval,
        calibrationOffset,
        calibrationSlope,
        vendorSpecificSettings,
      ];
}