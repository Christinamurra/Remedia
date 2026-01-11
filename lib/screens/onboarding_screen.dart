import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme/remedia_theme.dart';
import '../main.dart';
import '../data/goals_data.dart';
import '../models/user.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selectedGoals = {};

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.bar_chart_rounded,
      title: 'Track Your Health Journey',
      description: 'Monitor your symptoms, medications, and progress all in one place',
    ),
    OnboardingPage(
      icon: Icons.restaurant_rounded,
      title: 'Discover Healthy Recipes',
      description: 'Personalized meal plans and recipes tailored to your health needs',
    ),
    OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Join a Supportive Community',
      description: 'Connect with others, share experiences, and learn from experts',
    ),
  ];

  // Total pages = intro pages + goals page
  int get _totalPages => _pages.length + 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _saveGoalsAndNavigate() async {
    // Save goals to Hive
    final usersBox = Hive.box<User>('users');
    final now = DateTime.now();

    // Create or update user with goals
    final existingUser = usersBox.get('current_user');
    final user = existingUser?.copyWith(
      goals: _selectedGoals.toList(),
      updatedAt: now,
    ) ?? User(
      id: 'current_user',
      email: '',
      displayName: 'User',
      createdAt: now,
      updatedAt: now,
      goals: _selectedGoals.toList(),
    );

    await usersBox.put('current_user', user);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _navigateToMainApp() {
    _saveGoalsAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  if (index < _pages.length) {
                    return _buildPage(_pages[index]);
                  } else {
                    return _buildGoalsPage();
                  }
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'What are your goals?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: RemediaColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select all that apply',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: RemediaColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: predefinedGoals.map((goal) {
                  final isSelected = _selectedGoals.contains(goal.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGoals.remove(goal.id);
                        } else {
                          _selectedGoals.add(goal.id);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RemediaColors.mutedGreen
                            : RemediaColors.warmBeige,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? RemediaColors.mutedGreen
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            goal.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : RemediaColors.textDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            goal.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : RemediaColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: RemediaColors.mutedGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: RemediaColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: RemediaColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentPage == _totalPages - 1;
    final buttonText = isLastPage ? 'Get Started' : 'Next';

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => _buildDot(index),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isLastPage) {
                  _navigateToMainApp();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RemediaColors.mutedGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (!isLastPage)
            TextButton(
              onPressed: () {
                // Skip to goals page
                _pageController.animateToPage(
                  _pages.length,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  color: RemediaColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? RemediaColors.mutedGreen
            : RemediaColors.mutedGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
