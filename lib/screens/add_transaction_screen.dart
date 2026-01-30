import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _titleController = TextEditingController();
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
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final String title = _titleController.text.trim();
    final String amountText = _amountController.text.trim();

    if (amountText.isNotEmpty && title.isNotEmpty) {
      final double? amountValue = double.tryParse(amountText);

      if (amountValue != null) {
        ref
            .read(financeProvider.notifier)
            .addTransaction(
              title: title,
              category: _selectedCategory,
              amount: amountValue,
              isIncome: _isIncome,
            );

        setState(() {
          _titleController.clear();
          _amountController.clear();
          _selectedCategory = 'General';
          _isIncome = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Success! $title has been recorded."),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 400));

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } else {
      _showErrorSnackBar("Please fill in all fields");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Added explicit back button check
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeToggle("Expense", !_isIncome, Colors.red),
                const SizedBox(width: 12),
                _buildTypeToggle("Income", _isIncome, Colors.green),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "0.00",
                prefixText: "KES ",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
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
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "What was this for?",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              "Select Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        width: 1.5,
                      ),
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
                            color: isSelected ? Colors.white : Colors.black87,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "SAVE TRANSACTION",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, bool active, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isIncome = label == "Income"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? color : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
