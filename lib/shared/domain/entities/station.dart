import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'station.g.dart';

@JsonSerializable()
class WaterStation extends Equatable {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String region;
  final String waterBody; // Río, lago, etc.
  final StationStatus status;
  final DateTime createdAt;
  final DateTime? lastDataUpdate;
  final List<String> sensorIds;
  final StationMetadata metadata;

  const WaterStation({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.region,
    required this.waterBody,
    required this.status,
    required this.createdAt,
    this.lastDataUpdate,
    required this.sensorIds,
    required this.metadata,
  });

  factory WaterStation.fromJson(Map<String, dynamic> json) => 
      _$WaterStationFromJson(json);
  Map<String, dynamic> toJson() => _$WaterStationToJson(this);

  WaterStation copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? region,
    String? waterBody,
    StationStatus? status,
    DateTime? createdAt,
    DateTime? lastDataUpdate,
    List<String>? sensorIds,
    StationMetadata? metadata,
  }) {
    return WaterStation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      region: region ?? this.region,
      waterBody: waterBody ?? this.waterBody,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastDataUpdate: lastDataUpdate ?? this.lastDataUpdate,
      sensorIds: sensorIds ?? this.sensorIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        latitude,
        longitude,
        address,
        region,
        waterBody,
        status,
        createdAt,
        lastDataUpdate,
        sensorIds,
        metadata,
      ];
}

enum StationStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('error')
  error,
}

@JsonSerializable()
class StationMetadata extends Equatable {
  final double elevation; // metros sobre el nivel del mar
  final String department; // Departamento de Colombia
  final String municipality; // Municipio
  final String waterBodyType; // río, lago, embalse, etc.
  final double? depth; // profundidad del agua en metros
  final Map<String, dynamic> additionalInfo;

  const StationMetadata({
    required this.elevation,
    required this.department,
    required this.municipality,
    required this.waterBodyType,
    this.depth,
    this.additionalInfo = const {},
  });

  factory StationMetadata.fromJson(Map<String, dynamic> json) => 
      _$StationMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$StationMetadataToJson(this);

  StationMetadata copyWith({
    double? elevation,
    String? department,
    String? municipality,
    String? waterBodyType,
    double? depth,
    Map<String, dynamic>? additionalInfo,
  }) {
    return StationMetadata(
      elevation: elevation ?? this.elevation,
      department: department ?? this.department,
      municipality: municipality ?? this.municipality,
      waterBodyType: waterBodyType ?? this.waterBodyType,
      depth: depth ?? this.depth,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props => [
        elevation,
        department,
        municipality,
        waterBodyType,
        depth,
        additionalInfo,
      ];
}