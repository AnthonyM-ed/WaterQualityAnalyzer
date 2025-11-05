import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final UserPreferences preferences;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        role,
        createdAt,
        lastLoginAt,
        isActive,
        preferences,
      ];
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('operator')
  operator,
  @JsonValue('viewer')
  viewer,
}

@JsonSerializable()
class UserPreferences extends Equatable {
  final bool enableNotifications;
  final bool enableEmailAlerts;
  final bool darkMode;
  final String language;
  final List<String> favoriteStations;
  final Map<String, bool> alertPreferences;

  const UserPreferences({
    this.enableNotifications = true,
    this.enableEmailAlerts = false,
    this.darkMode = false,
    this.language = 'es',
    this.favoriteStations = const [],
    this.alertPreferences = const {},
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    bool? enableNotifications,
    bool? enableEmailAlerts,
    bool? darkMode,
    String? language,
    List<String>? favoriteStations,
    Map<String, bool>? alertPreferences,
  }) {
    return UserPreferences(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailAlerts: enableEmailAlerts ?? this.enableEmailAlerts,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      alertPreferences: alertPreferences ?? this.alertPreferences,
    );
  }

  @override
  List<Object?> get props => [
        enableNotifications,
        enableEmailAlerts,
        darkMode,
        language,
        favoriteStations,
        alertPreferences,
      ];
}