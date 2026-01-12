import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';
import '../services/premium_service.dart';
import 'premium_upgrade_dialog.dart';

class MealSuggestionCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const MealSuggestionCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  bool get _isLocked {
    final premiumService = PremiumService();
    return recipe.isPremium && !premiumService.hasFullAccess;
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

  @override
  Widget build(BuildContext context) {
    final isLocked = _isLocked;

    return GestureDetector(
      onTap: () async {
        if (isLocked) {
          await PremiumUpgradeDialog.show(
            context,
            featureName: recipe.title,
          );
          return;
        }
        onTap();
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isLocked
              ? RemediaColors.cardSand.withValues(alpha: 0.7)
              : RemediaColors.cardSand,
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
                  ColorFiltered(
                    colorFilter: isLocked
                        ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          ),
                    child: Image.network(
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
                  // PRO badge for premium recipes
                  if (recipe.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Lock overlay for locked recipes
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
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
                    style: TextStyle(
                      color: isLocked
                          ? RemediaColors.textDark.withValues(alpha: 0.6)
                          : RemediaColors.textDark,
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
                        color: isLocked
                            ? RemediaColors.textMuted.withValues(alpha: 0.5)
                            : RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime}m',
                        style: TextStyle(
                          color: isLocked
                              ? RemediaColors.textMuted.withValues(alpha: 0.5)
                              : RemediaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: isLocked
                            ? RemediaColors.textMuted.withValues(alpha: 0.5)
                            : RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.nutrition.calories}',
                        style: TextStyle(
                          color: isLocked
                              ? RemediaColors.textMuted.withValues(alpha: 0.5)
                              : RemediaColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      // Add button or lock
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.amber.shade700
                              : RemediaColors.mutedGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_rounded : Icons.add_rounded,
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
