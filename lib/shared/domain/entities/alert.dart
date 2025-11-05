import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alert.g.dart';

@JsonSerializable()
class Alert extends Equatable {
  final String id;
  final String stationId;
  final String? sensorId;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertStatus status;
  final Map<String, dynamic> data; // Datos específicos del alert
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const Alert({
    required this.id,
    required this.stationId,
    this.sensorId,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    this.data = const {},
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
  Map<String, dynamic> toJson() => _$AlertToJson(this);

  Alert copyWith({
    String? id,
    String? stationId,
    String? sensorId,
    AlertType? type,
    AlertSeverity? severity,
    String? title,
    String? description,
    DateTime? timestamp,
    AlertStatus? status,
    Map<String, dynamic>? data,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return Alert(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      sensorId: sensorId ?? this.sensorId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      data: data ?? this.data,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stationId,
        sensorId,
        type,
        severity,
        title,
        description,
        timestamp,
        status,
        data,
        acknowledgedAt,
        acknowledgedBy,
        resolvedAt,
        resolvedBy,
      ];
}

enum AlertType {
  @JsonValue('parameter_out_of_range')
  parameterOutOfRange,
  @JsonValue('sensor_malfunction')
  sensorMalfunction,
  @JsonValue('station_offline')
  stationOffline,
  @JsonValue('calibration_needed')
  calibrationNeeded,
  @JsonValue('maintenance_required')
  maintenanceRequired,
  @JsonValue('data_quality_issue')
  dataQualityIssue,
  @JsonValue('environmental_concern')
  environmentalConcern,
}

enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum AlertStatus {
  @JsonValue('new')
  new_,
  @JsonValue('acknowledged')
  acknowledged,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('dismissed')
  dismissed,
}

@JsonSerializable()
class AlertRule extends Equatable {
  final String id;
  final String name;
  final String description;
  final String parameter;
  final AlertCondition condition;
  final double threshold;
  final AlertSeverity severity;
  final bool enabled;
  final List<String> applicableStations;
  final int delayMinutes; // Delay before triggering alert
  final Map<String, dynamic> settings;

  const AlertRule({
    required this.id,
    required this.name,
    required this.description,
    required this.parameter,
    required this.condition,
    required this.threshold,
    required this.severity,
    this.enabled = true,
    this.applicableStations = const [],
    this.delayMinutes = 0,
    this.settings = const {},
  });

  factory AlertRule.fromJson(Map<String, dynamic> json) => 
      _$AlertRuleFromJson(json);
  Map<String, dynamic> toJson() => _$AlertRuleToJson(this);

  AlertRule copyWith({
    String? id,
    String? name,
    String? description,
    String? parameter,
    AlertCondition? condition,
    double? threshold,
    AlertSeverity? severity,
    bool? enabled,
    List<String>? applicableStations,
    int? delayMinutes,
    Map<String, dynamic>? settings,
  }) {
    return AlertRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parameter: parameter ?? this.parameter,
      condition: condition ?? this.condition,
      threshold: threshold ?? this.threshold,
      severity: severity ?? this.severity,
      enabled: enabled ?? this.enabled,
      applicableStations: applicableStations ?? this.applicableStations,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parameter,
        condition,
        threshold,
        severity,
        enabled,
        applicableStations,
        delayMinutes,
        settings,
      ];
}

enum AlertCondition {
  @JsonValue('greater_than')
  greaterThan,
  @JsonValue('less_than')
  lessThan,
  @JsonValue('equal_to')
  equalTo,
  @JsonValue('between')
  between,
  @JsonValue('outside_range')
  outsideRange,
}