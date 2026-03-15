import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NEW: Required for ConsumerWidget
import '../providers/finance_provider.dart'; // NEW: To access your saving logic

// 1. Changed from StatelessWidget to ConsumerWidget
class GoalNudgeSheet extends ConsumerWidget {
  final Map<String, dynamic> suggestion;

  const GoalNudgeSheet({super.key, required this.suggestion});

  @override
  // 2. Added 'WidgetRef ref' to the build method parameters
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.savings_rounded,
              size: 54,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            const Text(
              "Smart Saving Suggestion",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                suggestion['message'] ??
                    "We noticed a new income. Would you like to save some of it?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Not Now",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      // 3. ACTUAL LOGIC: Update the database via Riverpod
                      try {
                        await ref
                            .read(financeProvider.notifier)
                            .recordGoalSavings(
                              goalId: suggestion['goalId'],
                              amount: suggestion['suggestedAmount'],
                            );

                        if (context.mounted) {
                          Navigator.pop(context); // Close the sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "KES ${suggestion['suggestedAmount']} saved to your goal! 🎉",
                              ),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Failed to save goal progress: $e");
                      }
                    },
                    child: Text(
                      "Save KES ${suggestion['suggestedAmount']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
