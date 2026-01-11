import 'package:hive/hive.dart';

part 'scanned_product.g.dart';

enum SugarLevel {
  low,
  medium,
  high,
  veryHigh,
}

@HiveType(typeId: 6)
class ScannedProduct {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? barcode;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String? brand;

  @HiveField(4)
  final double sugarPer100g;

  @HiveField(5)
  final double sugarPerServing;

  @HiveField(6)
  final SugarLevel sugarLevel;

  @HiveField(7)
  final List<String> ingredients;

  @HiveField(8)
  final List<String> hiddenSugars;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final DateTime scannedAt;

  @HiveField(11)
  final String? userId;

  @HiveField(12)
  final Map<String, dynamic>? nutritionFacts;

  ScannedProduct({
    required this.id,
    this.barcode,
    required this.productName,
    this.brand,
    required this.sugarPer100g,
    required this.sugarPerServing,
    required this.sugarLevel,
    required this.ingredients,
    required this.hiddenSugars,
    this.imageUrl,
    required this.scannedAt,
    this.userId,
    this.nutritionFacts,
  });

  // Computed properties
  String get sugarGrade => _calculateGrade();
  int get hiddenSugarCount => hiddenSugars.length;

  String _calculateGrade() {
    if (sugarPer100g < 5) return 'A';
    if (sugarPer100g < 10) return 'B';
    if (sugarPer100g < 15) return 'C';
    if (sugarPer100g < 20) return 'D';
    return 'F';
  }

  // CopyWith method
  ScannedProduct copyWith({
    String? id,
    String? barcode,
    String? productName,
    String? brand,
    double? sugarPer100g,
    double? sugarPerServing,
    SugarLevel? sugarLevel,
    List<String>? ingredients,
    List<String>? hiddenSugars,
    String? imageUrl,
    DateTime? scannedAt,
    String? userId,
    Map<String, dynamic>? nutritionFacts,
  }) {
    return ScannedProduct(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      sugarPerServing: sugarPerServing ?? this.sugarPerServing,
      sugarLevel: sugarLevel ?? this.sugarLevel,
      ingredients: ingredients ?? this.ingredients,
      hiddenSugars: hiddenSugars ?? this.hiddenSugars,
      imageUrl: imageUrl ?? this.imageUrl,
      scannedAt: scannedAt ?? this.scannedAt,
      userId: userId ?? this.userId,
      nutritionFacts: nutritionFacts ?? this.nutritionFacts,
    );
  }

  // Serialization for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'sugarPer100g': sugarPer100g,
      'sugarPerServing': sugarPerServing,
      'sugarLevel': sugarLevel.toString(),
      'ingredients': ingredients,
      'hiddenSugars': hiddenSugars,
      'imageUrl': imageUrl,
      'scannedAt': scannedAt.toIso8601String(),
      'userId': userId,
      'nutritionFacts': nutritionFacts,
    };
  }

  factory ScannedProduct.fromMap(Map<String, dynamic> map) {
    return ScannedProduct(
      id: map['id'] as String,
      barcode: map['barcode'] as String?,
      productName: map['productName'] as String,
      brand: map['brand'] as String?,
      sugarPer100g: (map['sugarPer100g'] as num).toDouble(),
      sugarPerServing: (map['sugarPerServing'] as num).toDouble(),
      sugarLevel: SugarLevel.values.firstWhere(
        (e) => e.toString() == map['sugarLevel'],
        orElse: () => SugarLevel.medium,
      ),
      ingredients: List<String>.from(map['ingredients'] as List),
      hiddenSugars: List<String>.from(map['hiddenSugars'] as List),
      imageUrl: map['imageUrl'] as String?,
      scannedAt: DateTime.parse(map['scannedAt'] as String),
      userId: map['userId'] as String?,
      nutritionFacts: map['nutritionFacts'] as Map<String, dynamic>?,
    );
  }

  // Factory method for Open Food Facts API
  factory ScannedProduct.fromOpenFoodFacts(
    String barcode,
    Map<String, dynamic> json,
    List<String> detectedHiddenSugars,
  ) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('Invalid product data from Open Food Facts');
    }

    final productName = product['product_name'] as String? ?? 'Unknown Product';
    final brand = product['brands'] as String?;

    // Extract ingredients
    final ingredientsText = product['ingredients_text'] as String?;
    final ingredients = ingredientsText != null
        ? ingredientsText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    // Extract sugar information
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final sugarPer100g = (nutriments['sugars_100g'] as num?)?.toDouble() ?? 0.0;
    final sugarPerServing = (nutriments['sugars_serving'] as num?)?.toDouble() ?? 0.0;

    // Calculate sugar level
    final sugarLevel = _determineSugarLevel(sugarPer100g);

    final imageUrl = product['image_url'] as String?;

    return ScannedProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      barcode: barcode,
      productName: productName,
      brand: brand,
      sugarPer100g: sugarPer100g,
      sugarPerServing: sugarPerServing,
      sugarLevel: sugarLevel,
      ingredients: ingredients,
      hiddenSugars: detectedHiddenSugars,
      imageUrl: imageUrl,
      scannedAt: DateTime.now(),
      nutritionFacts: nutriments,
    );
  }

  static SugarLevel _determineSugarLevel(double sugarPer100g) {
    if (sugarPer100g < 5) return SugarLevel.low;
    if (sugarPer100g < 15) return SugarLevel.medium;
    if (sugarPer100g < 22.5) return SugarLevel.high;
    return SugarLevel.veryHigh;
  }

  @override
  String toString() {
    return 'ScannedProduct(id: $id, productName: $productName, sugarGrade: $sugarGrade, hiddenSugars: $hiddenSugarCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScannedProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
