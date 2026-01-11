import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/scanned_product.dart';

class ScanService {
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v2';

  // Sugar detection database (56+ sugar names and aliases)
  static const List<String> sugarAliases = [
    'sugar',
    'sucrose',
    'glucose',
    'fructose',
    'maltose',
    'dextrose',
    'lactose',
    'galactose',
    'corn syrup',
    'high fructose corn syrup',
    'hfcs',
    'maple syrup',
    'honey',
    'agave nectar',
    'agave syrup',
    'molasses',
    'cane juice',
    'evaporated cane juice',
    'cane sugar',
    'brown sugar',
    'raw sugar',
    'turbinado',
    'muscovado',
    'demerara',
    'coconut sugar',
    'date sugar',
    'rice syrup',
    'brown rice syrup',
    'barley malt',
    'barley malt syrup',
    'maltodextrin',
    'dextrin',
    'caramel',
    'carob syrup',
    'golden syrup',
    'invert sugar',
    'refiner\'s syrup',
    'treacle',
    'blackstrap molasses',
    'sorghum syrup',
    'fruit juice concentrate',
    'grape juice concentrate',
    'apple juice concentrate',
    'pear juice concentrate',
    'diastatic malt',
    'ethyl maltol',
    'florida crystals',
    'sucanat',
    'panocha',
    'piloncillo',
    'nectar',
    'syrup',
    'sweetener',
    'crystalline fructose',
    'd-ribose',
    'diastase',
    'maltodextrose',
  ];

  // Get Hive box for scans
  Box<ScannedProduct>? _scansBox;

  Future<Box<ScannedProduct>> get scansBox async {
    if (_scansBox != null && _scansBox!.isOpen) {
      return _scansBox!;
    }
    _scansBox = await Hive.openBox<ScannedProduct>('scanned_products');
    return _scansBox!;
  }

  // Fetch product by barcode from Open Food Facts
  Future<ScannedProduct?> fetchProductByBarcode(String barcode) async {
    try {
      final url = '$openFoodFactsUrl/product/$barcode.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 1) {
          final product = json['product'] as Map<String, dynamic>;

          // Extract ingredients text
          final ingredientsText = product['ingredients_text'] as String?;
          final ingredients = ingredientsText != null
              ? ingredientsText
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : <String>[];

          // Detect hidden sugars in ingredients
          final hiddenSugars = detectHiddenSugars(ingredients);

          // Create scanned product from Open Food Facts data
          final scannedProduct = ScannedProduct.fromOpenFoodFacts(
            barcode,
            json,
            hiddenSugars,
          );

          return scannedProduct;
        }
      }

      return null; // Product not found
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  // Scan ingredients from image using OCR
  Future<List<String>> scanIngredients(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      // Extract text and parse ingredients
      final text = recognizedText.text;

      // Look for "Ingredients:" section
      final ingredientsRegex = RegExp(
        r'ingredients?:(.+?)(?=\n\n|nutrition|$)',
        caseSensitive: false,
        dotAll: true,
      );

      final match = ingredientsRegex.firstMatch(text);
      if (match != null) {
        final ingredientsText = match.group(1)!;
        final ingredients = ingredientsText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        return ingredients;
      }

      // If no "Ingredients:" label found, try to parse the entire text
      return text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error scanning ingredients: $e');
      return [];
    }
  }

  // Detect hidden sugars in ingredient list
  List<String> detectHiddenSugars(List<String> ingredients) {
    final detectedSugars = <String>[];

    for (final ingredient in ingredients) {
      final lowerIngredient = ingredient.toLowerCase();

      for (final sugarAlias in sugarAliases) {
        if (lowerIngredient.contains(sugarAlias.toLowerCase())) {
          if (!detectedSugars.contains(ingredient)) {
            detectedSugars.add(ingredient);
          }
          break; // Found a sugar match, move to next ingredient
        }
      }
    }

    return detectedSugars;
  }

  // Calculate sugar level based on sugar per 100g
  SugarLevel calculateSugarLevel(double sugarPer100g) {
    if (sugarPer100g < 5) return SugarLevel.low;
    if (sugarPer100g < 15) return SugarLevel.medium;
    if (sugarPer100g < 22.5) return SugarLevel.high;
    return SugarLevel.veryHigh;
  }

  // Save scan to history
  Future<void> saveScan(ScannedProduct product) async {
    try {
      final box = await scansBox;
      await box.put(product.id, product);
      debugPrint('Scan saved: ${product.productName}');
    } catch (e) {
      debugPrint('Error saving scan: $e');
      rethrow;
    }
  }

  // Get scan history
  Future<List<ScannedProduct>> getScanHistory({int? limit}) async {
    try {
      final box = await scansBox;
      final scans = box.values.toList();

      // Sort by scan date (most recent first)
      scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

      if (limit != null && limit > 0) {
        return scans.take(limit).toList();
      }

      return scans;
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      return [];
    }
  }

  // Get recent scans
  Future<List<ScannedProduct>> getRecentScans({int limit = 5}) async {
    return getScanHistory(limit: limit);
  }

  // Get scan by ID
  Future<ScannedProduct?> getScanById(String id) async {
    try {
      final box = await scansBox;
      return box.get(id);
    } catch (e) {
      debugPrint('Error getting scan by ID: $e');
      return null;
    }
  }

  // Delete scan
  Future<void> deleteScan(String scanId) async {
    try {
      final box = await scansBox;
      await box.delete(scanId);
      debugPrint('Scan deleted: $scanId');
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      rethrow;
    }
  }

  // Clear all scans
  Future<void> clearAllScans() async {
    try {
      final box = await scansBox;
      await box.clear();
      debugPrint('All scans cleared');
    } catch (e) {
      debugPrint('Error clearing scans: $e');
      rethrow;
    }
  }

  // Get total scan count
  Future<int> getScanCount() async {
    try {
      final box = await scansBox;
      return box.length;
    } catch (e) {
      debugPrint('Error getting scan count: $e');
      return 0;
    }
  }

  // Get scans by sugar level
  Future<List<ScannedProduct>> getScansBySugarLevel(SugarLevel level) async {
    try {
      final scans = await getScanHistory();
      return scans.where((scan) => scan.sugarLevel == level).toList();
    } catch (e) {
      debugPrint('Error getting scans by sugar level: $e');
      return [];
    }
  }

  // Get average sugar content from scan history
  Future<double> getAverageSugarContent() async {
    try {
      final scans = await getScanHistory();
      if (scans.isEmpty) return 0.0;

      final totalSugar = scans.fold<double>(
        0.0,
        (sum, scan) => sum + scan.sugarPer100g,
      );

      return totalSugar / scans.length;
    } catch (e) {
      debugPrint('Error calculating average sugar: $e');
      return 0.0;
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_scansBox != null && _scansBox!.isOpen) {
      await _scansBox!.close();
    }
  }
}
