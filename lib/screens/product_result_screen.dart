import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/scanned_product.dart';
import '../theme/remedia_theme.dart';

class ProductResultScreen extends StatelessWidget {
  final ScannedProduct product;

  const ProductResultScreen({super.key, required this.product});

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return RemediaColors.successGreen;
      case 'B':
        return RemediaColors.mutedGreen;
      case 'C':
        return RemediaColors.terraCotta;
      case 'D':
        return RemediaColors.warmRust;
      case 'F':
        return Colors.red;
      default:
        return RemediaColors.textMuted;
    }
  }

  String _getSugarLevelText(SugarLevel level) {
    switch (level) {
      case SugarLevel.low:
        return 'Low Sugar';
      case SugarLevel.medium:
        return 'Moderate Sugar';
      case SugarLevel.high:
        return 'High Sugar';
      case SugarLevel.veryHigh:
        return 'Very High Sugar';
    }
  }

  Color _getSugarLevelColor(SugarLevel level) {
    switch (level) {
      case SugarLevel.low:
        return RemediaColors.successGreen;
      case SugarLevel.medium:
        return RemediaColors.terraCotta;
      case SugarLevel.high:
        return Colors.orange;
      case SugarLevel.veryHigh:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RemediaColors.creamBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with product image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: RemediaColors.creamBackground,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: RemediaColors.textDark,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductHeader(),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Sugar Grade Card
                _buildSugarGradeCard(),
                const SizedBox(height: 20),

                // Sugar Details
                _buildSugarDetails(),
                const SizedBox(height: 20),

                // Hidden Sugars
                if (product.hiddenSugars.isNotEmpty) ...[
                  _buildHiddenSugarsCard(),
                  const SizedBox(height: 20),
                ],

                // Ingredients
                if (product.ingredients.isNotEmpty) ...[
                  _buildIngredientsCard(),
                  const SizedBox(height: 20),
                ],

                // Nutrition Facts
                if (product.nutritionFacts != null &&
                    product.nutritionFacts!.isNotEmpty) ...[
                  _buildNutritionCard(),
                  const SizedBox(height: 20),
                ],

                // Scan another button
                _buildScanAnotherButton(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RemediaColors.warmBeige,
            RemediaColors.creamBackground,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Product image
          if (product.imageUrl != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.inventory_2_rounded,
                    size: 48,
                    color: RemediaColors.textMuted,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 48,
                color: RemediaColors.textMuted,
              ),
            ),
          const SizedBox(height: 16),
          // Product name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              product.productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RemediaColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (product.brand != null) ...[
            const SizedBox(height: 4),
            Text(
              product.brand!,
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSugarGradeCard() {
    final gradeColor = _getGradeColor(product.sugarGrade);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradeColor.withValues(alpha: 0.15),
            gradeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Grade circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: gradeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradeColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                product.sugarGrade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Grade info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sugar Grade',
                  style: TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSugarLevelText(product.sugarLevel),
                  style: TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.sugarPer100g.toStringAsFixed(1)}g per 100g',
                  style: TextStyle(
                    color: gradeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugarDetails() {
    final levelColor = _getSugarLevelColor(product.sugarLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RemediaColors.warmBeige,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: RemediaColors.mutedGreen,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Sugar Content',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: 'Per 100g',
                  value: '${product.sugarPer100g.toStringAsFixed(1)}g',
                  color: levelColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: 'Per Serving',
                  value: product.sugarPerServing > 0
                      ? '${product.sugarPerServing.toStringAsFixed(1)}g'
                      : 'N/A',
                  color: levelColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenSugarsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
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
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hidden Sugars Detected',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${product.hiddenSugars.length} sugar type${product.hiddenSugars.length > 1 ? 's' : ''} found',
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.hiddenSugars.map((sugar) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  sugar,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RemediaColors.warmBeige,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color: RemediaColors.mutedGreen,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Ingredients',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.ingredients.join(', '),
            style: TextStyle(
              color: RemediaColors.textDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    final facts = product.nutritionFacts!;

    // Extract common nutrition values
    final nutritionItems = <Map<String, dynamic>>[];

    if (facts['energy-kcal_100g'] != null) {
      nutritionItems.add({
        'label': 'Calories',
        'value': '${(facts['energy-kcal_100g'] as num).toInt()} kcal',
      });
    }
    if (facts['fat_100g'] != null) {
      nutritionItems.add({
        'label': 'Fat',
        'value': '${(facts['fat_100g'] as num).toStringAsFixed(1)}g',
      });
    }
    if (facts['saturated-fat_100g'] != null) {
      nutritionItems.add({
        'label': 'Saturated Fat',
        'value': '${(facts['saturated-fat_100g'] as num).toStringAsFixed(1)}g',
      });
    }
    if (facts['carbohydrates_100g'] != null) {
      nutritionItems.add({
        'label': 'Carbs',
        'value': '${(facts['carbohydrates_100g'] as num).toStringAsFixed(1)}g',
      });
    }
    if (facts['proteins_100g'] != null) {
      nutritionItems.add({
        'label': 'Protein',
        'value': '${(facts['proteins_100g'] as num).toStringAsFixed(1)}g',
      });
    }
    if (facts['fiber_100g'] != null) {
      nutritionItems.add({
        'label': 'Fiber',
        'value': '${(facts['fiber_100g'] as num).toStringAsFixed(1)}g',
      });
    }
    if (facts['salt_100g'] != null) {
      nutritionItems.add({
        'label': 'Salt',
        'value': '${(facts['salt_100g'] as num).toStringAsFixed(2)}g',
      });
    }
    if (facts['sodium_100g'] != null) {
      nutritionItems.add({
        'label': 'Sodium',
        'value': '${(facts['sodium_100g'] as num).toStringAsFixed(2)}g',
      });
    }

    if (nutritionItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RemediaColors.warmBeige,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_rounded,
                color: RemediaColors.mutedGreen,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Nutrition Facts (per 100g)',
                style: TextStyle(
                  color: RemediaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...nutritionItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: RemediaColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item['value'] as String,
                      style: TextStyle(
                        color: RemediaColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildScanAnotherButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RemediaColors.mutedGreen,
              RemediaColors.sageGreen,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Scan Another Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
