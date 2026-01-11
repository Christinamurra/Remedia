import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_plan.dart';
import '../models/meal_slot.dart';
import '../services/meal_plan_service.dart';
import '../widgets/week_selector.dart';
import '../widgets/meal_slot_card.dart';
import '../widgets/meal_plan_summary_card.dart';
import '../widgets/recipe_browser_sheet.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealPlanService _service = MealPlanService();
  MealPlan? _currentMealPlan;
  DateTime _selectedWeek = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    setState(() => _isLoading = true);

    try {
      final plan = await _service.getMealPlanForWeek(_selectedWeek);
      setState(() {
        _currentMealPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meal plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToNextWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    });
    _loadMealPlan();
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    });
    _loadMealPlan();
  }

  void _navigateToToday() {
    setState(() {
      _selectedWeek = DateTime.now();
    });
    _loadMealPlan();
  }

  Future<void> _handleSlotTap(MealSlot slot) async {
    if (slot.isEmpty) {
      // Show recipe browser when tapping empty slot
      await _showRecipeBrowser(slot);
    } else {
      // Show recipe details when tapping filled slot
      await _showRecipeDetails(slot);
    }
  }

  Future<void> _showRecipeBrowser(MealSlot slot) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeBrowserSheet(
        slot: slot,
        onRecipeSelected: (recipe) => _addRecipeToSlot(slot, recipe),
      ),
    );
  }

  Future<void> _addRecipeToSlot(MealSlot slot, Recipe recipe) async {
    try {
      // Add recipe to meal plan
      final updatedPlan = await _service.addRecipeToSlot(
        date: slot.date,
        mealType: slot.mealType,
        recipeId: recipe.id,
        servings: 1,
      );

      setState(() {
        _currentMealPlan = updatedPlan;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipe.title} added to ${slot.mealType.displayName}!'),
            backgroundColor: RemediaColors.mutedGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRecipeDetails(MealSlot slot) async {
    // Find the recipe
    final recipe = sampleRecipes.firstWhere(
      (r) => r.id == slot.recipeId,
      orElse: () => sampleRecipes.first, // Fallback
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
          mealSlot: slot,
          onServingsChanged: (newServings) => _updateServings(slot, newServings),
          onRemoveFromPlan: () => _removeRecipeFromSlot(slot),
          onSwapRecipe: () => _swapRecipe(slot),
        ),
      ),
    );

    // Reload meal plan after returning from detail screen
    await _loadMealPlan();
  }

  Future<void> _updateServings(MealSlot slot, int newServings) async {
    try {
      final updatedPlan = await _service.updateSlotServings(
        date: slot.date,
        mealType: slot.mealType,
        servings: newServings,
      );

      setState(() {
        _currentMealPlan = updatedPlan;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating servings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeRecipeFromSlot(MealSlot slot) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Recipe'),
        content: const Text('Are you sure you want to remove this recipe from your meal plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedPlan = await _service.removeRecipeFromSlot(
          date: slot.date,
          mealType: slot.mealType,
        );

        setState(() {
          _currentMealPlan = updatedPlan;
        });

        if (mounted) {
          Navigator.pop(context); // Close detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Recipe removed from meal plan'),
              backgroundColor: RemediaColors.mutedGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing recipe: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _swapRecipe(MealSlot slot) async {
    // Close detail screen first
    Navigator.pop(context);

    // Remove current recipe
    await _service.removeRecipeFromSlot(
      date: slot.date,
      mealType: slot.mealType,
    );

    // Show recipe browser to select new recipe
    await _showRecipeBrowser(slot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 My Meal Plan',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plan your plant-based week ahead',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Week Selector
            WeekSelector(
              weekStartDate: _currentMealPlan?.weekStartDate ?? _service.getToday(),
              onPreviousWeek: _navigateToPreviousWeek,
              onNextWeek: _navigateToNextWeek,
              onToday: _navigateToToday,
              isCurrentWeek: _service.isCurrentWeek(_selectedWeek),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentMealPlan == null
                      ? _buildEmptyState()
                      : _buildMealPlanContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: RemediaColors.cardLightGreen.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🍽️',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Plan Your Week Ahead',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start by adding your favorite\nplant-based recipes to each day.',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Recipes tab
                // Note: This will be handled by parent navigator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switch to Recipes tab to browse recipes!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Browse Recipes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanContent() {
    if (_currentMealPlan == null) return const SizedBox();

    final plan = _currentMealPlan!;
    final weekDates = plan.weekDates;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Summary Card
        MealPlanSummaryCard(mealPlan: plan),

        const SizedBox(height: 24),

        // Meal slots grouped by day
        ...weekDates.map((date) {
          final slots = plan.getMealSlotsForDate(date);
          final isToday = _isToday(date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Row(
                  children: [
                    Text(
                      _service.getDateWithDayString(date),
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RemediaColors.mutedGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Meal Slots for this day
              ...slots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MealSlotCard(
                    slot: slot,
                    onTap: () => _handleSlotTap(slot),
                  ),
                );
              }),

              const SizedBox(height: 12),
            ],
          );
        }),

        const SizedBox(height: 40),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
