enum ChallengeType { raw, sugarDetox, fasting, oilFree, noSugar }

enum ChallengeDuration { sevenDays, fourteenDays, twentyOneDays, thirtyDays }

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ChallengeType type;
  final ChallengeDuration duration;
  final String iconEmoji;
  final int currentStreak;
  final bool isActive;
  final DateTime? startDate;

  const Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.duration,
    required this.iconEmoji,
    this.currentStreak = 0,
    this.isActive = false,
    this.startDate,
  });

  int get totalDays {
    switch (duration) {
      case ChallengeDuration.sevenDays:
        return 7;
      case ChallengeDuration.fourteenDays:
        return 14;
      case ChallengeDuration.twentyOneDays:
        return 21;
      case ChallengeDuration.thirtyDays:
        return 30;
    }
  }

  double get progress => totalDays > 0 ? currentStreak / totalDays : 0;

  Challenge copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    ChallengeType? type,
    ChallengeDuration? duration,
    String? iconEmoji,
    int? currentStreak,
    bool? isActive,
    DateTime? startDate,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      currentStreak: currentStreak ?? this.currentStreak,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
    );
  }
}

// Sample data
final List<Challenge> sampleChallenges = [
  const Challenge(
    id: '1',
    title: '7-Day Sugar Free',
    subtitle: 'Reset your taste buds',
    description: 'Go 7 days without added sugars, artificial sweeteners, or refined carbs. Notice how your cravings change and energy stabilizes!',
    type: ChallengeType.sugarDetox,
    duration: ChallengeDuration.sevenDays,
    iconEmoji: '🍬',
  ),
  const Challenge(
    id: '2',
    title: '7-Day Celery Juice',
    subtitle: 'Morning celery ritual',
    description: 'Start each morning with 16oz of fresh celery juice on an empty stomach. Wait 20-30 minutes before eating. Great for gut health and energy!',
    type: ChallengeType.raw,
    duration: ChallengeDuration.sevenDays,
    iconEmoji: '🥬',
  ),
  const Challenge(
    id: '3',
    title: '7-Day Lemon Detox',
    subtitle: 'Warm lemon water daily',
    description: 'Begin every morning with warm lemon water before anything else. Supports digestion, hydration, and gentle detoxification.',
    type: ChallengeType.raw,
    duration: ChallengeDuration.sevenDays,
    iconEmoji: '🍋',
  ),
  const Challenge(
    id: '4',
    title: '14-Day Raw Challenge',
    subtitle: 'Eat only living foods',
    description: 'Transform your energy by eating only raw fruits, vegetables, nuts, and seeds for 14 days. Feel the power of living foods!',
    type: ChallengeType.raw,
    duration: ChallengeDuration.fourteenDays,
    iconEmoji: '🥗',
  ),
  const Challenge(
    id: '5',
    title: '21-Day Sugar Detox',
    subtitle: 'Break the sugar habit',
    description: 'A deeper reset - 21 days to fully break sugar addiction and rewire your taste buds. The cravings will fade, we promise!',
    type: ChallengeType.sugarDetox,
    duration: ChallengeDuration.twentyOneDays,
    iconEmoji: '🍯',
  ),
  const Challenge(
    id: '6',
    title: 'Intermittent Fasting',
    subtitle: '16:8 fasting window',
    description: 'Give your digestive system a break with a 16-hour fasting window. Eat between noon and 8pm only.',
    type: ChallengeType.fasting,
    duration: ChallengeDuration.fourteenDays,
    iconEmoji: '⏰',
  ),
  const Challenge(
    id: '7',
    title: '7-Day No Oil',
    subtitle: 'Cook without added oils',
    description: 'Eliminate all added oils from your cooking for 7 days. Use water, broth, or steam to cook. Great for heart health and reducing inflammation!',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.sevenDays,
    iconEmoji: '🫒',
  ),
  const Challenge(
    id: '8',
    title: '7-Day No Fat',
    subtitle: 'Ultra low-fat eating',
    description: 'Avoid added fats including oils, nuts, seeds, and avocados for 7 days. Focus on fruits, vegetables, and whole grains. A powerful reset!',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.sevenDays,
    iconEmoji: '🥦',
  ),
  const Challenge(
    id: '9',
    title: '14-Day No Oil',
    subtitle: 'Deeper oil-free reset',
    description: 'Two weeks without added oils. Your arteries will thank you! Learn to cook with water, vegetable broth, and citrus juices instead.',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.fourteenDays,
    iconEmoji: '🫒',
  ),
  const Challenge(
    id: '10',
    title: '21-Day No Oil',
    subtitle: 'Build lasting habits',
    description: 'Three weeks is what it takes to form a new habit. Go oil-free and discover how delicious whole food flavors can be without the grease.',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.twentyOneDays,
    iconEmoji: '💚',
  ),
  const Challenge(
    id: '11',
    title: '30-Day No Oil',
    subtitle: 'Full month transformation',
    description: 'The ultimate oil-free challenge. One month of clean eating focused on whole plant foods. Many people never go back after experiencing the benefits!',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.thirtyDays,
    iconEmoji: '🏆',
  ),
  const Challenge(
    id: '12',
    title: '14-Day No Fat',
    subtitle: 'Extended low-fat cleanse',
    description: 'Two weeks avoiding all added fats - oils, nuts, seeds, and avocados. Let your body heal with simple, clean plant foods.',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.fourteenDays,
    iconEmoji: '🌿',
  ),
  const Challenge(
    id: '13',
    title: '30-Day No Fat',
    subtitle: 'Maximum healing protocol',
    description: 'A full month of ultra low-fat eating. This intensive reset is inspired by Dr. Esselstyn and other whole food plant-based pioneers.',
    type: ChallengeType.oilFree,
    duration: ChallengeDuration.thirtyDays,
    iconEmoji: '❤️',
  ),
];
