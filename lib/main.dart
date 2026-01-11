import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/remedia_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/track_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/community_screen.dart';
import 'screens/remedies_screen.dart';
import 'screens/experts_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/scan_screen.dart';
import 'models/meal_slot.dart';
import 'models/meal_plan.dart';
import 'models/meal_plan_preferences.dart';
import 'models/scanned_product.dart';
import 'models/user.dart';
import 'models/friendship.dart';
import 'models/login_streak.dart';
import 'models/meal_log.dart';
import 'models/community_post.dart';
import 'models/comment.dart';
import 'providers/scan_provider.dart';
import 'providers/activity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(MealSlotAdapter());
  Hive.registerAdapter(MealPlanAdapter());
  Hive.registerAdapter(MealPlanPreferencesAdapter());
  Hive.registerAdapter(ScannedProductAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FriendshipAdapter());
  Hive.registerAdapter(LoginStreakAdapter());
  Hive.registerAdapter(MealLogAdapter());
  Hive.registerAdapter(CommunityPostAdapter());
  Hive.registerAdapter(CommentAdapter());

  // Open Hive boxes
  await Hive.openBox<MealPlan>('meal_plans');
  await Hive.openBox<MealSlot>('meal_slots');
  await Hive.openBox<MealPlanPreferences>('preferences');
  await Hive.openBox<ScannedProduct>('scanned_products');
  await Hive.openBox<User>('users');
  await Hive.openBox<Friendship>('friendships');
  await Hive.openBox<LoginStreak>('login_streak');
  await Hive.openBox<MealLog>('meal_logs');
  await Hive.openBox<CommunityPost>('community_posts');
  await Hive.openBox<Comment>('comments');

  // Initialize activity provider and record login
  final activityProvider = ActivityProvider();
  await activityProvider.initialize();
  await activityProvider.recordLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider.value(value: activityProvider),
      ],
      child: const RemediaApp(),
    ),
  );
}

class RemediaApp extends StatelessWidget {
  const RemediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remedia',
      debugShowCheckedModeBanner: false,
      theme: RemediaTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _openRemediesChat() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RemediesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onAskRemedia: _openRemediesChat),
      const TrackScreen(),
      const ScanScreen(),
      const RecipesScreen(),
      const MealPlanScreen(),
      const LearnScreen(),
      const CommunityScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: RemediaColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.bar_chart_rounded,
                label: 'Track',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.search_rounded,
                label: 'Recipes',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.calendar_month_rounded,
                label: 'Plan',
              ),
              _buildNavItem(
                index: 5,
                icon: Icons.menu_book_rounded,
                label: 'Learn',
              ),
              _buildNavItem(
                index: 6,
                icon: Icons.people_rounded,
                label: 'Community',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? RemediaColors.navIconActive
                  : RemediaColors.navIconInactive,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? RemediaColors.navIconActive
                    : RemediaColors.navIconInactive,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
