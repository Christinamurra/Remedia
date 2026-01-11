import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';
import '../models/meal_slot.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final MealSlot? mealSlot; // Optional: if viewing from meal plan
  final Function(int)? onServingsChanged;
  final VoidCallback? onRemoveFromPlan;
  final VoidCallback? onSwapRecipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.mealSlot,
    this.onServingsChanged,
    this.onRemoveFromPlan,
    this.onSwapRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInMealPlan = mealSlot != null;
    final int currentServings = mealSlot?.servings ?? recipe.servings;

    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: RemediaColors.mutedGreen,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      RemediaColors.mutedGreen,
                      RemediaColors.sageGreen,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _getRecipeEmoji(recipe.category),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags & Metadata
                  _buildMetadataSection(currentServings),

                  const SizedBox(height: 24),

                  // Meal Plan Actions (if from meal plan)
                  if (isInMealPlan) ...[
                    _buildMealPlanActions(context, currentServings),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (recipe.description.isNotEmpty) ...[
                    _buildSectionHeader('About'),
                    const SizedBox(height: 12),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Nutrition
                  _buildSectionHeader('Nutrition'),
                  const SizedBox(height: 12),
                  _buildNutritionCard(currentServings),

                  const SizedBox(height: 24),

                  // Ingredients
                  _buildSectionHeader('Ingredients'),
                  const SizedBox(height: 12),
                  _buildIngredientsCard(currentServings),

                  const SizedBox(height: 24),

                  // Instructions
                  _buildSectionHeader('Instructions'),
                  const SizedBox(height: 12),
                  _buildInstructionsCard(),

                  const SizedBox(height: 24),

                  // Expert Note (if available)
                  if (recipe.expertNote != null) ...[
                    _buildExpertNoteCard(),
                    const SizedBox(height: 24),
                  ],

                  // Tip (if available)
                  if (recipe.tip != null) ...[
                    _buildTipCard(),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: RemediaColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMetadataSection(int servings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: RemediaColors.mutedGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Metadata Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetadataItem(
                Icons.timer_outlined,
                '${recipe.prepTime} min',
                'Prep Time',
              ),
              Container(
                width: 1,
                height: 40,
                color: RemediaColors.warmBeige,
              ),
              _buildMetadataItem(
                Icons.restaurant_menu_rounded,
                '$servings',
                'Servings',
              ),
              Container(
                width: 1,
                height: 40,
                color: RemediaColors.warmBeige,
              ),
              _buildMetadataItem(
                Icons.show_chart_rounded,
                recipe.difficulty.name.toUpperCase(),
                'Difficulty',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: RemediaColors.mutedGreen, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: RemediaColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlanActions(BuildContext context, int currentServings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardLightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RemediaColors.mutedGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: RemediaColors.mutedGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'In Your Meal Plan',
                style: const TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Servings Adjuster
          Row(
            children: [
              const Text(
                'Servings:',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: currentServings > 1
                    ? () => onServingsChanged?.call(currentServings - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: RemediaColors.mutedGreen,
                iconSize: 28,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$currentServings',
                  style: const TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: currentServings < 10
                    ? () => onServingsChanged?.call(currentServings + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: RemediaColors.mutedGreen,
                iconSize: 28,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSwapRecipe,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Swap'),
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
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemoveFromPlan,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
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
        ],
      ),
    );
  }

  Widget _buildNutritionCard(int servings) {
    final nutrition = recipe.nutrition;
    final multiplier = servings / recipe.servings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNutritionRow(
            'Calories',
            '${(nutrition.calories * multiplier).round()}',
            'cal',
          ),
          const Divider(height: 24),
          _buildNutritionRow(
            'Protein',
            '${(nutrition.protein * multiplier).round()}',
            'g',
          ),
          const Divider(height: 24),
          _buildNutritionRow(
            'Carbs',
            '${(nutrition.carbs * multiplier).round()}',
            'g',
          ),
          const Divider(height: 24),
          _buildNutritionRow(
            'Fiber',
            '${(nutrition.fiber * multiplier).round()}',
            'g',
          ),
          const Divider(height: 24),
          _buildNutritionRow(
            'Sugar',
            '${(nutrition.sugar * multiplier).round()}',
            'g',
          ),
          const Divider(height: 24),
          _buildNutritionRow(
            'Fat',
            '${(nutrition.fat * multiplier).round()}',
            'g',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: RemediaColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$value $unit',
          style: const TextStyle(
            color: RemediaColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsCard(int servings) {
    final multiplier = servings / recipe.servings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recipe.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: RemediaColors.mutedGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: ingredient.amount.isNotEmpty
                              ? _adjustAmount(ingredient.amount, multiplier)
                              : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' ${ingredient.name}'),
                        if (ingredient.note != null && ingredient.note!.isNotEmpty)
                          TextSpan(
                            text: ' (${ingredient.note})',
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _adjustAmount(String amount, double multiplier) {
    // Simple amount adjustment - in production, you'd parse fractions etc.
    try {
      final number = double.parse(amount.split(' ')[0]);
      final adjusted = (number * multiplier);
      final rest = amount.substring(amount.indexOf(' '));
      return '${adjusted.toStringAsFixed(adjusted.truncateToDouble() == adjusted ? 0 : 1)}$rest';
    } catch (e) {
      return amount; // Return original if can't parse
    }
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recipe.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: RemediaColors.mutedGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: const TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpertNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.cardLightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                color: RemediaColors.mutedGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Expert Note',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipe.expertNote!,
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RemediaColors.terraCotta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RemediaColors.terraCotta.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: RemediaColors.terraCotta,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip',
                  style: TextStyle(
                    color: RemediaColors.terraCotta,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.tip!,
                  style: const TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecipeEmoji(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.smoothie:
        return '🥤';
      case RecipeCategory.juice:
        return '🧃';
      case RecipeCategory.shot:
        return '🥃';
      case RecipeCategory.bowl:
        return '🥗';
      case RecipeCategory.salad:
        return '🥬';
      case RecipeCategory.soup:
        return '🍲';
      case RecipeCategory.mainDish:
        return '🍽️';
      case RecipeCategory.snack:
        return '🍎';
      case RecipeCategory.dessert:
        return '🍰';
      case RecipeCategory.dressing:
        return '🥗';
      case RecipeCategory.dip:
        return '🥙';
    }
  }
}
