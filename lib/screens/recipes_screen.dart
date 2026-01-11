import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';
import '../models/meal_slot.dart';
import '../services/meal_plan_service.dart';
import '../widgets/meal_plan_slot_selector_sheet.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final MealPlanService _service = MealPlanService();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Raw', 'Low Sugar', 'Gut Healing', 'Favorites'];

  List<Recipe> get filteredRecipes {
    if (_selectedFilter == 'All') return sampleRecipes;
    if (_selectedFilter == 'Favorites') {
      return sampleRecipes.where((r) => r.isFavorite).toList();
    }
    return sampleRecipes.where((r) => r.tags.contains(_selectedFilter)).toList();
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
                    'Recipes',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nourishing food for your journey',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            _buildFilterChips(),
            const SizedBox(height: 8),

            // Recipe feed
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return _buildRecipeCard(filteredRecipes[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Add recipe coming soon!'),
              backgroundColor: RemediaColors.mutedGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        backgroundColor: RemediaColors.mutedGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              backgroundColor: RemediaColors.warmBeige,
              selectedColor: RemediaColors.mutedGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : RemediaColors.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: RemediaColors.warmBeige,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 48,
                    color: RemediaColors.textMuted,
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: recipe.isFavorite ? RemediaColors.terraCotta : RemediaColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  recipe.title,
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: recipe.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: RemediaColors.mutedGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Meta info
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: RemediaColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime} min',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: RemediaColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.nutrition.calories} cal',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Add to Plan Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSlotSelector(recipe),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Add to Plan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RemediaColors.mutedGreen,
                      side: const BorderSide(
                        color: RemediaColors.mutedGreen,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSlotSelector(Recipe recipe) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MealPlanSlotSelectorSheet(
        recipe: recipe,
        onSlotSelected: (slot) => _addRecipeToSlot(recipe, slot),
      ),
    );
  }

  Future<void> _addRecipeToSlot(Recipe recipe, MealSlot slot) async {
    try {
      await _service.addRecipeToSlot(
        date: slot.date,
        mealType: slot.mealType,
        recipeId: recipe.id,
        servings: 1,
      );

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
            action: SnackBarAction(
              label: 'View Plan',
              textColor: Colors.white,
              onPressed: () {
                // Switch to Plan tab (index 3)
                // This would require a callback from parent, for now just show message
              },
            ),
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
}
