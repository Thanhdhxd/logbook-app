// lib/data/models/user_dto.dart

import '../../domain/entities/user_entity.dart';

/// Data Transfer Object for User
/// Handles JSON serialization/deserialization
class UserDTO {
  final String id;
  final String name;
  final String username;

  UserDTO({
    required this.id,
    required this.name,
    required this.username,
  });

  /// Create DTO from JSON
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
    );
  }

  /// Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
    };
  }

  /// Map DTO to Domain Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      username: username,
    );
  }

  /// Create DTO from Domain Entity
  factory UserDTO.fromEntity(UserEntity entity) {
    return UserDTO(
      id: entity.id,
      name: entity.name,
      username: entity.username,
    );
  }
}
