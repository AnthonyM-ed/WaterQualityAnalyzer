// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterStation _$WaterStationFromJson(Map<String, dynamic> json) => WaterStation(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String,
  region: json['region'] as String,
  waterBody: json['waterBody'] as String,
  status: $enumDecode(_$StationStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastDataUpdate: json['lastDataUpdate'] == null
      ? null
      : DateTime.parse(json['lastDataUpdate'] as String),
  sensorIds: (json['sensorIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: StationMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WaterStationToJson(WaterStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'region': instance.region,
      'waterBody': instance.waterBody,
      'status': _$StationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastDataUpdate': instance.lastDataUpdate?.toIso8601String(),
      'sensorIds': instance.sensorIds,
      'metadata': instance.metadata,
    };

const _$StationStatusEnumMap = {
  StationStatus.active: 'active',
  StationStatus.inactive: 'inactive',
  StationStatus.maintenance: 'maintenance',
  StationStatus.error: 'error',
};

StationMetadata _$StationMetadataFromJson(Map<String, dynamic> json) =>
    StationMetadata(
      elevation: (json['elevation'] as num).toDouble(),
      department: json['department'] as String,
      municipality: json['municipality'] as String,
      waterBodyType: json['waterBodyType'] as String,
      depth: (json['depth'] as num?)?.toDouble(),
      additionalInfo:
          json['additionalInfo'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$StationMetadataToJson(StationMetadata instance) =>
    <String, dynamic>{
      'elevation': instance.elevation,
      'department': instance.department,
      'municipality': instance.municipality,
      'waterBodyType': instance.waterBodyType,
      'depth': instance.depth,
      'additionalInfo': instance.additionalInfo,
    };
