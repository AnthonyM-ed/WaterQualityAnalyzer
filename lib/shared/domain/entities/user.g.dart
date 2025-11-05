// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  preferences: UserPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'role': _$UserRoleEnumMap[instance.role]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'isActive': instance.isActive,
  'preferences': instance.preferences,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.operator: 'operator',
  UserRole.viewer: 'viewer',
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableEmailAlerts: json['enableEmailAlerts'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'es',
      favoriteStations:
          (json['favoriteStations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      alertPreferences:
          (json['alertPreferences'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'enableNotifications': instance.enableNotifications,
      'enableEmailAlerts': instance.enableEmailAlerts,
      'darkMode': instance.darkMode,
      'language': instance.language,
      'favoriteStations': instance.favoriteStations,
      'alertPreferences': instance.alertPreferences,
    };
