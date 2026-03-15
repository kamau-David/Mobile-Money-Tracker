import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_money_tracker/screens/settings_screen.dart';
import 'package:mobile_money_tracker/screens/add_transaction_screen.dart'; // Ensure this is imported
import '../providers/finance_provider.dart';
import '../providers/user_provider.dart';
import '../models/transaction.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final userData = ref.watch(userProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    // DYNAMIC: Filter transactions that Gemini isn't sure about
    final pendingTransactions = recentTransactions
        .where(
          (tx) =>
              tx.category.toLowerCase() == 'unsure' ||
              tx.category.toLowerCase() == 'uncategorized',
        )
        .toList();

    final int pendingCount = pendingTransactions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          "KES Tracker",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(financeProvider.notifier).refreshHomeData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sticky Balance Header
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF2E7D32),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
                title: Text(
                  "KES ${finance.balance.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                background: Container(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${userData.name}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "M-Pesa Balance",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Banner appears only if there are unsure transactions
            if (pendingCount > 0)
              SliverToBoxAdapter(
                child: _buildActionRequiredBanner(
                  context,
                  pendingCount,
                  pendingTransactions.first, // Pass the first one to verify
                ),
              ),

            // Section Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
                child: Text(
                  "Recent Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Main Content Logic
            if (finance.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                ),
              )
            else if (recentTransactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tx = recentTransactions[index];
                  final isIncome = tx.type.toLowerCase() == 'income';
                  final bool isUnsure =
                      tx.category.toLowerCase() == 'unsure' ||
                      tx.category.toLowerCase() == 'uncategorized';

                  return _TransactionCard(
                    title: tx.merchant,
                    category: tx.category,
                    amount: isIncome
                        ? "+ KES ${tx.amount.toStringAsFixed(0)}"
                        : "- KES ${tx.amount.toStringAsFixed(0)}",
                    color: isIncome ? Colors.green : Colors.redAccent,
                    needsVerification: isUnsure,
                    onTap: () {
                      // Optional: Allow tapping individual cards to verify
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTransactionScreen(initialData: tx),
                        ),
                      );
                    },
                  );
                }, childCount: recentTransactions.length),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ), // Space for FAB if you have one
          ],
        ),
      ),
    );
  }

  // UPDATED: Now accepts the TransactionModel to pre-fill the next screen
  Widget _buildActionRequiredBanner(
    BuildContext context,
    int count,
    TransactionModel transaction,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.orange, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Help Gemini out!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  "$count transactions need a category",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // NAVIGATE: Send user to AddTransactionScreen with the unsure data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddTransactionScreen(initialData: transaction),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("VERIFY"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "No transactions yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final Color color;
  final bool needsVerification;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.title,
    required this.category,
    required this.amount,
    required this.color,
    required this.onTap,
    this.needsVerification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: needsVerification
              ? Colors.orange.shade200
              : Colors.grey.shade200,
          width: needsVerification ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap, // Added tap functionality
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(_getIconForCategory(category), color: color, size: 20),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(category, style: const TextStyle(fontSize: 12)),
            if (needsVerification) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Colors.orange,
              ),
            ],
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_bus;
      case 'utilities':
        return Icons.bolt;
      case 'income':
        return Icons.add_chart;
      case 'unsure':
      case 'uncategorized':
        return Icons.help_outline;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
