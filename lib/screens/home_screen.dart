import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/challenge.dart';
import 'challenges_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onAskRemedia;
  final VoidCallback? onCravingSOS;

  const HomeScreen({
    super.key,
    required this.onAskRemedia,
    this.onCravingSOS,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mantraExpanded = false;
  bool _quickActionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/garden_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Semi-transparent overlay for readability
              Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
              // Subtle decorative accents
              ..._buildDecorations(),
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - more compact
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    // Craving SOS Button - prominent
                    _buildCravingSOS(context),
                    const SizedBox(height: 24),

                    // Today's Mantra - collapsible
                    _buildCollapsibleMantra(context),
                    const SizedBox(height: 16),

                    // Today's Progress - always visible (priority)
                    _buildTodaysProgress(context),
                    const SizedBox(height: 16),

                    // Challenges Section - always visible (priority)
                    _buildChallengesSection(context),
                    const SizedBox(height: 16),

                    // Quick Actions - collapsible
                    _buildCollapsibleQuickActions(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return [
      // Subtle top accents
      Positioned(
        top: 20,
        right: 20,
        child: Opacity(
          opacity: 0.3,
          child: Text('✨', style: TextStyle(fontSize: 16)),
        ),
      ),
      Positioned(
        top: 100,
        left: 10,
        child: Opacity(
          opacity: 0.2,
          child: Text('🌿', style: TextStyle(fontSize: 20)),
        ),
      ),
      // Bottom accents
      Positioned(
        bottom: 120,
        right: 15,
        child: Opacity(
          opacity: 0.25,
          child: Text('🍃', style: TextStyle(fontSize: 18)),
        ),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remedia',
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleMantra(BuildContext context) {
    return _buildCollapsibleSection(
      title: "Today's Mantra",
      isExpanded: _mantraExpanded,
      onTap: () => setState(() => _mantraExpanded = !_mantraExpanded),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          '"Your body wants steadiness more than sugar."',
          style: TextStyle(
            color: RemediaColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: RemediaColors.mutedGreen,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildCravingSOS(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCravingSOS ?? widget.onAskRemedia,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
              ),
              child: const Text('⚡', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Craving SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Get instant support',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: RemediaColors.terraCotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '7',
                      style: TextStyle(
                        color: RemediaColors.terraCotta,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressCircle(
                icon: '💧',
                progress: 0.5,
                label: '4/8 cups',
                color: RemediaColors.waterBlue,
              ),
              _buildProgressCircle(
                icon: '🌙',
                progress: 0.875,
                label: '7h sleep',
                color: RemediaColors.sleepBrown,
              ),
              _buildProgressCircle(
                icon: '✓',
                progress: 1.0,
                label: 'Sugar free',
                color: RemediaColors.successGreen,
                isCheck: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required String icon,
    required double progress,
    required String label,
    required Color color,
    bool isCheck = false,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              if (isCheck)
                Icon(Icons.check, color: color, size: 28)
              else
                Text(icon, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesSection(BuildContext context) {
    // Show first 3 challenges
    final challenges = sampleChallenges.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Challenges',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChallengesScreen()),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: RemediaColors.mutedGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return _buildChallengeCard(context, challenge);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChallengesScreen()),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                challenge.iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              challenge.title,
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${challenge.totalDays} days',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleQuickActions(BuildContext context) {
    return _buildCollapsibleSection(
      title: 'Quick Actions',
      isExpanded: _quickActionsExpanded,
      onTap: () => setState(() => _quickActionsExpanded = !_quickActionsExpanded),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '🍃',
                  title: 'Ask Remedia',
                  subtitle: 'Natural remedies',
                  onTap: widget.onAskRemedia,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '🧠',
                  title: 'Wellness Quiz',
                  subtitle: 'Test knowledge',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '📖',
                  title: 'Daily Article',
                  subtitle: 'Learn new things',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '🏆',
                  title: 'Challenges',
                  subtitle: 'New journey',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChallengesScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RemediaColors.warmBeige.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: RemediaColors.warmBeige.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
