import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../services/premium_service.dart';

class PremiumUpgradeDialog extends StatelessWidget {
  final String? featureName;

  const PremiumUpgradeDialog({
    super.key,
    this.featureName,
  });

  static Future<bool?> show(BuildContext context, {String? featureName}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PremiumUpgradeDialog(featureName: featureName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = PremiumService();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: RemediaColors.creamBackground,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    RemediaColors.mutedGreen,
                    RemediaColors.mutedGreen.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: RemediaColors.mutedGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'Unlock Premium',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              featureName != null
                  ? 'Get access to $featureName and 40+ premium recipes'
                  : 'Get access to all 50+ plant-based recipes',
              style: TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Features list
            _buildFeatureItem(Icons.restaurant_menu_rounded, 'All 50+ healing recipes'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.auto_awesome_rounded, 'Advanced meal planning'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.shopping_cart_rounded, 'Shopping list generator'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.analytics_rounded, 'Nutrition insights'),

            const SizedBox(height: 28),

            // Trial button
            if (!premiumService.isTrialActive && !premiumService.isPremium)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await premiumService.startTrial();
                        if (context.mounted) {
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.celebration_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('7-day free trial activated!'),
                                ],
                              ),
                              backgroundColor: RemediaColors.mutedGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RemediaColors.mutedGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start 7-Day Free Trial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement actual subscription flow
                  Navigator.pop(context, false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Subscription coming soon!'),
                      backgroundColor: RemediaColors.mutedGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: RemediaColors.mutedGreen,
                  side: BorderSide(color: RemediaColors.mutedGreen, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Subscribe - \$9.99/month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: RemediaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: RemediaColors.mutedGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: RemediaColors.mutedGreen,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: RemediaColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          color: RemediaColors.mutedGreen,
          size: 20,
        ),
      ],
    );
  }
}
