import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_slot.dart';
import '../models/recipe.dart';

class MealSlotCard extends StatelessWidget {
  final MealSlot slot;
  final VoidCallback onTap;

  const MealSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
  });

  Recipe? _getRecipe() {
    if (slot.recipeId == null) return null;

    try {
      return sampleRecipes.firstWhere(
        (recipe) => recipe.id == slot.recipeId,
      );
    } catch (e) {
      return null; // Recipe not found (deleted)
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _getRecipe();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: recipe == null
              ? RemediaColors.cardSand
              : RemediaColors.cardLightGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recipe == null
                ? RemediaColors.warmBeige
                : RemediaColors.mutedGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: recipe == null
            ? _buildEmptySlot()
            : _buildFilledSlot(recipe),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Row(
      children: [
        // Meal Type Emoji
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: RemediaColors.warmBeige,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              slot.mealType.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.mealType.displayName,
                style: const TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to add recipe',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Add Icon
        Icon(
          Icons.add_circle_outline_rounded,
          color: RemediaColors.mutedGreen,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildFilledSlot(Recipe recipe) {
    final adjustedCalories = _getAdjustedCalories(recipe);
    final hasMultipleServings = slot.servings > 1;

    return Row(
      children: [
        // Meal Type Emoji
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              slot.mealType.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Type Label
              Text(
                slot.mealType.displayName,
                style: TextStyle(
                  color: RemediaColors.mutedGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),

              // Recipe Name
              Text(
                recipe.title,
                style: const TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Metadata
              Row(
                children: [
                  Text(
                    '$adjustedCalories cal',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${recipe.prepTime} min',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (hasMultipleServings) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${slot.servings} servings',
                      style: TextStyle(
                        color: RemediaColors.mutedGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Checkmark Icon
        Icon(
          Icons.check_circle_rounded,
          color: RemediaColors.mutedGreen,
          size: 24,
        ),
      ],
    );
  }

  int _getAdjustedCalories(Recipe recipe) {
    final baseCalories = recipe.nutrition.calories;
    final recipeServings = recipe.servings;
    final slotServings = slot.servings;

    // Adjust calories based on servings
    return (baseCalories * slotServings / recipeServings).round();
  }
}
