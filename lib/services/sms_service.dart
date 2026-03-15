import 'package:another_telephony/telephony.dart'; // Updated for 2026 compatibility
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/finance_provider.dart';
import '../main.dart';
import '../widgets/goal_nudge_sheet.dart';

// 1. Background handler MUST be top-level and static
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  // Note: You cannot use 'ref' or UI code here because this runs
  // in a separate isolate (no UI context).
  debugPrint("Background SMS received from: ${message.address}");
}

class SmsService {
  final Telephony telephony = Telephony.instance;
  final WidgetRef ref;

  SmsService(this.ref);

  // 2. Add permission check to avoid crashes
  Future<void> startListening() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;

    if (permissionsGranted == true) {
      debugPrint("SMS Permissions granted. Starting M-Pesa listener...");

      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          debugPrint("Incoming SMS from: ${message.address}");
          // M-Pesa sender ID is usually "MPESA" or "M-PESA"
          if (message.address?.toUpperCase().contains("MPESA") ?? false) {
            _handleIncomingSms(message.body ?? "");
          }
        },
        onBackgroundMessage: backgroundMessageHandler,
        listenInBackground: true,
      );
    } else {
      debugPrint("SMS Permissions denied. Listener not started.");
    }
  }

  Future<void> _handleIncomingSms(String rawText) async {
    try {
      // 3. autoProcessSms triggers the Gemini parsing in your backend
      final suggestion = await ref
          .read(financeProvider.notifier)
          .autoProcessSms(rawText);

      // 4. Trigger the UI Nudge if Gemini finds a savings opportunity
      if (suggestion != null) {
        _showGoalNudge(suggestion);
      }
    } catch (e) {
      debugPrint("Auto-processing failed: $e");
    }
  }

  void _showGoalNudge(Map<String, dynamic> suggestion) {
    final context = navigatorKey.currentContext;

    if (context != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        // Ensure GoalNudgeSheet handles its own internal padding/borders
        builder: (context) => GoalNudgeSheet(suggestion: suggestion),
      );
    }
  }
}
