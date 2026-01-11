import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';

class MealSuggestionCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const MealSuggestionCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    recipe.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: RemediaColors.warmBeige,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: RemediaColors.textMuted,
                          size: 32,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        color: RemediaColors.warmBeige,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              RemediaColors.mutedGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRecipeEmoji(recipe.category),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata row
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime}m',
                        style: const TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.nutrition.calories}',
                        style: const TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      // Add button
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: RemediaColors.mutedGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
