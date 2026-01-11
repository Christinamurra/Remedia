import 'package:hive/hive.dart';

part 'login_streak.g.dart';

@HiveType(typeId: 7)
class LoginStreak {
  @HiveField(0)
  final int currentStreak;

  @HiveField(1)
  final int longestStreak;

  @HiveField(2)
  final DateTime lastLoginDate;

  @HiveField(3)
  final DateTime streakStartDate;

  @HiveField(4)
  final int totalDaysLoggedIn;

  LoginStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLoginDate,
    required this.streakStartDate,
    required this.totalDaysLoggedIn,
  });

  factory LoginStreak.initial() {
    final now = DateTime.now();
    return LoginStreak(
      currentStreak: 1,
      longestStreak: 1,
      lastLoginDate: now,
      streakStartDate: now,
      totalDaysLoggedIn: 1,
    );
  }

  LoginStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLoginDate,
    DateTime? streakStartDate,
    int? totalDaysLoggedIn,
  }) {
    return LoginStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      totalDaysLoggedIn: totalDaysLoggedIn ?? this.totalDaysLoggedIn,
    );
  }

  /// Check if the streak is still active (logged in yesterday or today)
  bool get isStreakActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    final difference = today.difference(lastLogin).inDays;
    return difference <= 1;
  }

  /// Check if already logged in today
  bool get hasLoggedInToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    return today.isAtSameMomentAs(lastLogin);
  }

  /// Record a new login and return updated streak
  LoginStreak recordLogin() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    final daysSinceLastLogin = today.difference(lastLogin).inDays;

    if (daysSinceLastLogin == 0) {
      // Already logged in today, no change
      return this;
    } else if (daysSinceLastLogin == 1) {
      // Consecutive day - extend streak
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastLoginDate: now,
        totalDaysLoggedIn: totalDaysLoggedIn + 1,
      );
    } else {
      // Streak broken - start fresh
      return copyWith(
        currentStreak: 1,
        streakStartDate: now,
        lastLoginDate: now,
        totalDaysLoggedIn: totalDaysLoggedIn + 1,
      );
    }
  }

  @override
  String toString() {
    return 'LoginStreak(current: $currentStreak, longest: $longestStreak, lastLogin: $lastLoginDate)';
  }
}
