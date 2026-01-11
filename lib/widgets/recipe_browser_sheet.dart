import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/recipe.dart';
import '../models/meal_slot.dart';

class RecipeBrowserSheet extends StatefulWidget {
  final MealSlot slot;
  final Function(Recipe) onRecipeSelected;

  const RecipeBrowserSheet({
    super.key,
    required this.slot,
    required this.onRecipeSelected,
  });

  @override
  State<RecipeBrowserSheet> createState() => _RecipeBrowserSheetState();
}

class _RecipeBrowserSheetState extends State<RecipeBrowserSheet> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Raw',
    'Low Sugar',
    'Gut Healing',
    'High Protein'
  ];

  List<Recipe> get _filteredRecipes {
    var recipes = sampleRecipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      recipes = recipes
          .where((r) =>
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      recipes = recipes.where((r) => r.tags.contains(_selectedFilter)).toList();
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: RemediaColors.creamBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RemediaColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add ${widget.slot.mealType.displayName}',
                            style: const TextStyle(
                              color: RemediaColors.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose a plant-based recipe',
                            style: TextStyle(
                              color: RemediaColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: RemediaColors.textMuted,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: RemediaColors.mutedGreen,
                    ),
                    filled: true,
                    fillColor: RemediaColors.warmBeige,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          _buildFilterChips(),

          const SizedBox(height: 8),

          // Recipe List
          Expanded(
            child: _filteredRecipes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(_filteredRecipes[index]);
                    },
                  ),
          ),
        ],
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
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: RemediaColors.warmBeige,
              selectedColor: RemediaColors.mutedGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : RemediaColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        widget.onRecipeSelected(recipe);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RemediaColors.cardSand,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RemediaColors.warmBeige,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Recipe Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: RemediaColors.cardLightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getRecipeEmoji(recipe.category),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Recipe Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: RemediaColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.nutrition.calories} cal',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: RemediaColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime} min',
                        style: TextStyle(
                          color: RemediaColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: recipe.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: RemediaColors.mutedGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Add Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RemediaColors.mutedGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
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
            const Text(
              '🔍',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
