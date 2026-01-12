import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _boxName = 'premium_status';
  static const String _isPremiumKey = 'is_premium';
  static const String _trialStartKey = 'trial_start';
  static const int trialDurationDays = 7;

  Box? _box;
  bool _isPremium = false;
  DateTime? _trialStartDate;

  bool get isPremium => _isPremium;
  bool get isTrialActive {
    if (_trialStartDate == null) return false;
    final trialEnd = _trialStartDate!.add(const Duration(days: trialDurationDays));
    return DateTime.now().isBefore(trialEnd);
  }

  int get trialDaysRemaining {
    if (_trialStartDate == null) return 0;
    final trialEnd = _trialStartDate!.add(const Duration(days: trialDurationDays));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  bool get hasFullAccess => _isPremium || isTrialActive;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    _isPremium = _box?.get(_isPremiumKey, defaultValue: false) ?? false;
    final trialStartMillis = _box?.get(_trialStartKey);
    if (trialStartMillis != null) {
      _trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStartMillis);
    }
    notifyListeners();
  }

  Future<void> startTrial() async {
    if (_trialStartDate != null) return; // Trial already started
    _trialStartDate = DateTime.now();
    await _box?.put(_trialStartKey, _trialStartDate!.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    await _box?.put(_isPremiumKey, value);
    notifyListeners();
  }

  // For testing/development - unlock premium
  Future<void> unlockPremium() async {
    await setPremium(true);
  }

  // For testing/development - reset to free
  Future<void> resetToFree() async {
    _isPremium = false;
    _trialStartDate = null;
    await _box?.delete(_isPremiumKey);
    await _box?.delete(_trialStartKey);
    notifyListeners();
  }

  bool canAccessRecipe(bool recipePremium) {
    if (!recipePremium) return true; // Free recipes always accessible
    return hasFullAccess;
  }
}
