import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_slot.dart';
import '../models/recipe.dart';

class MealSlotCard extends StatelessWidget {
  final MealSlot slot;
  final VoidCallback onTap;
  final VoidCallback? onLogTap;
  final bool canLog;

  const MealSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
    this.onLogTap,
    this.canLog = false,
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
    final isLogged = slot.isLogged;

    // Different colors based on state
    Color backgroundColor;
    Color borderColor;
    if (recipe == null) {
      backgroundColor = RemediaColors.cardSand;
      borderColor = RemediaColors.warmBeige;
    } else if (isLogged) {
      backgroundColor = RemediaColors.mutedGreen.withValues(alpha: 0.2);
      borderColor = RemediaColors.mutedGreen.withValues(alpha: 0.5);
    } else {
      backgroundColor = RemediaColors.cardLightGreen;
      borderColor = RemediaColors.mutedGreen.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
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
    final isLogged = slot.isLogged;

    return Row(
      children: [
        // Meal Type Emoji with logged indicator
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLogged
                    ? RemediaColors.mutedGreen.withValues(alpha: 0.25)
                    : RemediaColors.mutedGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  slot.mealType.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            // Checkmark overlay if logged
            if (isLogged)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: RemediaColors.mutedGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Type Label with LOGGED badge
              Row(
                children: [
                  Text(
                    slot.mealType.displayName,
                    style: const TextStyle(
                      color: RemediaColors.mutedGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isLogged) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: RemediaColors.mutedGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LOGGED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
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

              // Metadata with notes indicator
              Row(
                children: [
                  Text(
                    '$adjustedCalories cal',
                    style: const TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    ' • ',
                    style: TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${recipe.prepTime} min',
                    style: const TextStyle(
                      color: RemediaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (hasMultipleServings) ...[
                    const Text(
                      ' • ',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${slot.servings} servings',
                      style: const TextStyle(
                        color: RemediaColors.mutedGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  // Notes indicator
                  if (slot.isLoggedWithNotes) ...[
                    const Text(
                      ' • ',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.notes_rounded,
                      size: 14,
                      color: RemediaColors.textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Action area: Log button or checkmark
        if (canLog && !isLogged)
          GestureDetector(
            onTap: onLogTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: RemediaColors.mutedGreen,
                size: 24,
              ),
            ),
          )
        else
          Icon(
            isLogged ? Icons.check_circle_rounded : Icons.check_circle_rounded,
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
