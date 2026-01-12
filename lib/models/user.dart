import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User {
  @HiveField(0)
  final String id; // Firebase auth UID

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool isAnonymous; // For existing anonymous users

  @HiveField(8)
  final String? anonymousName; // Preserve anonymous identity if desired

  @HiveField(9)
  final List<String> goals; // User's selected health goals

  @HiveField(10)
  final int streakCount; // Consecutive days logged in

  @HiveField(11)
  final DateTime? lastLoginDate; // Last date user opened the app

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.isAnonymous = false,
    this.anonymousName,
    this.goals = const [],
    this.streakCount = 0,
    this.lastLoginDate,
  });

  // Computed properties
  String get firstName {
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : displayName;
  }

  String get initials {
    final parts = displayName.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // CopyWith method
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    String? anonymousName,
    List<String>? goals,
    int? streakCount,
    DateTime? lastLoginDate,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousName: anonymousName ?? this.anonymousName,
      goals: goals ?? this.goals,
      streakCount: streakCount ?? this.streakCount,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'anonymousName': anonymousName,
      'goals': goals,
      'streakCount': streakCount,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      bio: map['bio'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      anonymousName: map['anonymousName'] as String?,
      goals: List<String>.from(map['goals'] ?? []),
      streakCount: map['streakCount'] as int? ?? 0,
      lastLoginDate: map['lastLoginDate'] != null
          ? DateTime.parse(map['lastLoginDate'] as String)
          : null,
    );
  }

  // Serialization for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isAnonymous': isAnonymous,
      'anonymousName': anonymousName,
      'goals': goals,
      'streakCount': streakCount,
      'lastLoginDate':
          lastLoginDate != null ? Timestamp.fromDate(lastLoginDate!) : null,
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      anonymousName: data['anonymousName'] as String?,
      goals: List<String>.from(data['goals'] ?? []),
      streakCount: data['streakCount'] as int? ?? 0,
      lastLoginDate: data['lastLoginDate'] != null
          ? (data['lastLoginDate'] as Timestamp).toDate()
          : null,
    );
  }

  factory User.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      anonymousName: data['anonymousName'] as String?,
      goals: List<String>.from(data['goals'] ?? []),
      streakCount: data['streakCount'] as int? ?? 0,
      lastLoginDate: data['lastLoginDate'] != null
          ? (data['lastLoginDate'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, displayName: $displayName, email: $email, isAnonymous: $isAnonymous)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
