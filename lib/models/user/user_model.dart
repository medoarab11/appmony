import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  final String id;
  final String? name;
  final String? email;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final String languageCode;
  final String currencyCode;
  final ThemeMode themeMode;

  UserModel({
    String? id,
    this.name,
    this.email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isPremium = false,
    this.premiumExpiryDate,
    required this.languageCode,
    required this.currencyCode,
    this.themeMode = ThemeMode.system,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();

  UserModel copyWith({
    String? name,
    String? email,
    DateTime? lastLoginAt,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? languageCode,
    String? currencyCode,
    ThemeMode? themeMode,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? DateTime.now(),
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'isPremium': isPremium ? 1 : 0,
      'premiumExpiryDate': premiumExpiryDate?.millisecondsSinceEpoch,
      'languageCode': languageCode,
      'currencyCode': currencyCode,
      'themeMode': themeMode.toString(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt']),
      isPremium: map['isPremium'] == 1,
      premiumExpiryDate: map['premiumExpiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['premiumExpiryDate'])
          : null,
      languageCode: map['languageCode'],
      currencyCode: map['currencyCode'],
      themeMode: _parseThemeMode(map['themeMode']),
    );
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}