import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart'; // Ensure this is imported

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? initialData; // Added for verification/pre-fill

  const AddTransactionScreen({super.key, this.initialData});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'General';
  bool _isIncome = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.blue},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
    {'name': 'Rent', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Airtime', 'icon': Icons.phone_android, 'color': Colors.teal},
    {'name': 'Utilities', 'icon': Icons.lightbulb, 'color': Colors.yellow[800]},
    {'name': 'Health', 'icon': Icons.medical_services, 'color': Colors.red},
    {'name': 'Family', 'icon': Icons.people, 'color': Colors.purple},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.cyan},
    {'name': 'Savings', 'icon': Icons.savings, 'color': Colors.green},
    {'name': 'General', 'icon': Icons.category, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if we are coming from the "Verify" nudge
    if (widget.initialData != null) {
      _merchantController.text = widget.initialData!.merchant;
      _amountController.text = widget.initialData!.amount.toString();
      _isIncome = widget.initialData!.type.toLowerCase() == 'income';

      // If the guessed category exists in our list, select it
      if (_categories.any((c) => c['name'] == widget.initialData!.category)) {
        _selectedCategory = widget.initialData!.category;
      }
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final String merchant = _merchantController.text.trim();
    final String amountText = _amountController.text.trim();

    if (amountText.isNotEmpty && merchant.isNotEmpty) {
      final double? amountValue = double.tryParse(amountText);

      if (amountValue != null) {
        final notifier = ref.read(financeProvider.notifier);

        // If we have initialData, we UPDATE. If not, we ADD.
        if (widget.initialData != null) {
          await notifier.updateTransactionCategory(
            widget.initialData!.id.toString(),
            _selectedCategory,
          );
          // Note: If you want to update amount/merchant too,
          // you'd need a full update API, but for now, we're verifying the category.
        } else {
          await notifier.addTransaction(
            merchant: merchant,
            category: _selectedCategory,
            amount: amountValue,
            type: _isIncome ? 'Income' : 'Expense',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.initialData != null ? "Verified!" : "Success! Recorded.",
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData != null ? "Verify Transaction" : "Add Transaction",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeToggle("Expense", !_isIncome, Colors.red, isDark),
                const SizedBox(width: 12),
                _buildTypeToggle("Income", _isIncome, Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Amount",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "0.00",
                prefixText: "KES ",
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            TextField(
              controller: _merchantController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "What was this for?",
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Text(
              "Select Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final bool isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : (isDark ? Colors.white10 : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : cat['color'],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  widget.initialData != null
                      ? "CONFIRM VERIFICATION"
                      : "SAVE TRANSACTION",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, bool active, Color color, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isIncome = label == "Income"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? color
                  : (isDark ? Colors.white12 : Colors.grey[300]!),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? color
                    : (isDark ? Colors.white38 : Colors.grey[600]),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
