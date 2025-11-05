// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
  id: json['id'] as String,
  stationId: json['stationId'] as String,
  sensorId: json['sensorId'] as String?,
  type: $enumDecode(_$AlertTypeEnumMap, json['type']),
  severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
  title: json['title'] as String,
  description: json['description'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  status: $enumDecode(_$AlertStatusEnumMap, json['status']),
  data: json['data'] as Map<String, dynamic>? ?? const {},
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolvedBy: json['resolvedBy'] as String?,
);

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
  'id': instance.id,
  'stationId': instance.stationId,
  'sensorId': instance.sensorId,
  'type': _$AlertTypeEnumMap[instance.type]!,
  'severity': _$AlertSeverityEnumMap[instance.severity]!,
  'title': instance.title,
  'description': instance.description,
  'timestamp': instance.timestamp.toIso8601String(),
  'status': _$AlertStatusEnumMap[instance.status]!,
  'data': instance.data,
  'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
  'acknowledgedBy': instance.acknowledgedBy,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolvedBy': instance.resolvedBy,
};

const _$AlertTypeEnumMap = {
  AlertType.parameterOutOfRange: 'parameter_out_of_range',
  AlertType.sensorMalfunction: 'sensor_malfunction',
  AlertType.stationOffline: 'station_offline',
  AlertType.calibrationNeeded: 'calibration_needed',
  AlertType.maintenanceRequired: 'maintenance_required',
  AlertType.dataQualityIssue: 'data_quality_issue',
  AlertType.environmentalConcern: 'environmental_concern',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

const _$AlertStatusEnumMap = {
  AlertStatus.new_: 'new',
  AlertStatus.acknowledged: 'acknowledged',
  AlertStatus.inProgress: 'in_progress',
  AlertStatus.resolved: 'resolved',
  AlertStatus.dismissed: 'dismissed',
};

AlertRule _$AlertRuleFromJson(Map<String, dynamic> json) => AlertRule(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  parameter: json['parameter'] as String,
  condition: $enumDecode(_$AlertConditionEnumMap, json['condition']),
  threshold: (json['threshold'] as num).toDouble(),
  severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
  enabled: json['enabled'] as bool? ?? true,
  applicableStations:
      (json['applicableStations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  delayMinutes: (json['delayMinutes'] as num?)?.toInt() ?? 0,
  settings: json['settings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AlertRuleToJson(AlertRule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'parameter': instance.parameter,
  'condition': _$AlertConditionEnumMap[instance.condition]!,
  'threshold': instance.threshold,
  'severity': _$AlertSeverityEnumMap[instance.severity]!,
  'enabled': instance.enabled,
  'applicableStations': instance.applicableStations,
  'delayMinutes': instance.delayMinutes,
  'settings': instance.settings,
};

const _$AlertConditionEnumMap = {
  AlertCondition.greaterThan: 'greater_than',
  AlertCondition.lessThan: 'less_than',
  AlertCondition.equalTo: 'equal_to',
  AlertCondition.between: 'between',
  AlertCondition.outsideRange: 'outside_range',
};
