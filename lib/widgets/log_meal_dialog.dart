import 'package:flutter/material.dart';
import '../theme/remedia_theme.dart';
import '../models/meal_slot.dart';
import '../models/recipe.dart';

class LogMealDialog extends StatefulWidget {
  final MealSlot slot;
  final Recipe recipe;

  const LogMealDialog({
    super.key,
    required this.slot,
    required this.recipe,
  });

  /// Shows the dialog and returns the notes string (or null if cancelled, empty string if no notes)
  static Future<String?> show(
    BuildContext context, {
    required MealSlot slot,
    required Recipe recipe,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => LogMealDialog(slot: slot, recipe: recipe),
    );
  }

  @override
  State<LogMealDialog> createState() => _LogMealDialogState();
}

class _LogMealDialogState extends State<LogMealDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: RemediaColors.creamBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RemediaColors.mutedGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                widget.slot.mealType.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log ${widget.slot.mealType.displayName}',
                  style: const TextStyle(
                    color: RemediaColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    color: RemediaColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a note (optional)',
            style: TextStyle(
              color: RemediaColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'e.g., "ate half portion", "substituted tofu"',
              hintStyle: const TextStyle(
                color: RemediaColors.textLight,
                fontSize: 14,
              ),
              filled: true,
              fillColor: RemediaColors.warmBeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterStyle: const TextStyle(
                color: RemediaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text(
            'Cancel',
            style: TextStyle(color: RemediaColors.textMuted),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final notes = _notesController.text.trim();
            Navigator.pop(context, notes);
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Log Meal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: RemediaColors.mutedGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
