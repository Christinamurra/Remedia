import 'package:flutter/foundation.dart';
import '../models/scanned_product.dart';
import '../services/scan_service.dart';

class ScanProvider with ChangeNotifier {
  final ScanService _scanService = ScanService();

  List<ScannedProduct> _recentScans = [];
  ScannedProduct? _currentScan;
  bool _isScanning = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ScannedProduct> get recentScans => _recentScans;
  ScannedProduct? get currentScan => _currentScan;
  bool get isScanning => _isScanning;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Initialize and load recent scans
  Future<void> initialize() async {
    await loadRecentScans();
  }

  // Load recent scans from Hive
  Future<void> loadRecentScans({int limit = 10}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _recentScans = await _scanService.getRecentScans(limit: limit);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load scan history: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading recent scans: $e');
    }
  }

  // Scan barcode and fetch product
  Future<ScannedProduct?> scanBarcode(String barcode) async {
    try {
      _isScanning = true;
      _errorMessage = null;
      _currentScan = null;
      notifyListeners();

      final product = await _scanService.fetchProductByBarcode(barcode);

      if (product != null) {
        _currentScan = product;
        await _scanService.saveScan(product);

        // Reload recent scans to include the new one
        await loadRecentScans();

        _isScanning = false;
        notifyListeners();
        return product;
      } else {
        _errorMessage = 'Product not found in database';
        _isScanning = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to scan barcode: $e';
      _isScanning = false;
      notifyListeners();
      debugPrint('Error scanning barcode: $e');
      return null;
    }
  }

  // Scan ingredients from image
  Future<List<String>?> scanIngredients(String imagePath) async {
    try {
      _isScanning = true;
      _errorMessage = null;
      notifyListeners();

      final ingredients = await _scanService.scanIngredients(imagePath);

      _isScanning = false;
      notifyListeners();
      return ingredients;
    } catch (e) {
      _errorMessage = 'Failed to scan ingredients: $e';
      _isScanning = false;
      notifyListeners();
      debugPrint('Error scanning ingredients: $e');
      return null;
    }
  }

  // Detect hidden sugars in ingredients
  List<String> detectHiddenSugars(List<String> ingredients) {
    return _scanService.detectHiddenSugars(ingredients);
  }

  // Get full scan history
  Future<List<ScannedProduct>> getScanHistory() async {
    try {
      return await _scanService.getScanHistory();
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      return [];
    }
  }

  // Delete scan
  Future<void> deleteScan(String scanId) async {
    try {
      await _scanService.deleteScan(scanId);

      // Remove from local list
      _recentScans.removeWhere((scan) => scan.id == scanId);

      // Clear current scan if it's the deleted one
      if (_currentScan?.id == scanId) {
        _currentScan = null;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete scan: $e';
      notifyListeners();
      debugPrint('Error deleting scan: $e');
    }
  }

  // Clear all scans
  Future<void> clearAllScans() async {
    try {
      await _scanService.clearAllScans();
      _recentScans = [];
      _currentScan = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear scans: $e';
      notifyListeners();
      debugPrint('Error clearing scans: $e');
    }
  }

  // Get scan count
  Future<int> getScanCount() async {
    return await _scanService.getScanCount();
  }

  // Get scans by sugar level
  Future<List<ScannedProduct>> getScansBySugarLevel(SugarLevel level) async {
    return await _scanService.getScansBySugarLevel(level);
  }

  // Get average sugar content
  Future<double> getAverageSugarContent() async {
    return await _scanService.getAverageSugarContent();
  }

  // Set current scan (for viewing scan details)
  void setCurrentScan(ScannedProduct scan) {
    _currentScan = scan;
    notifyListeners();
  }

  // Clear current scan
  void clearCurrentScan() {
    _currentScan = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanService.dispose();
    super.dispose();
  }
}
