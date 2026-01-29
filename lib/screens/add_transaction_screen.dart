import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/finance_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  // 1. Controllers to capture text input
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Default category
  String _selectedCategory = "Shopping";

  @override
  void dispose() {
    // 2. Always dispose controllers to prevent memory leaks
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final String title = _titleController.text.trim();
    final double? amount = double.tryParse(_amountController.text);

    // Basic Validation
    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid title and amount")),
      );
      return;
    }

    // 3. Call the Provider to save data
    ref
        .read(financeProvider.notifier)
        .addTransaction(
          title: title,
          category: _selectedCategory,
          amount: amount,
          isIncome: _selectedCategory == "Salary",
        );

    // 4. Feedback and Navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction saved successfully!")),
    );

    // Clear fields
    _titleController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Add Transaction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                suffixText: "KES",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              items: ["Shopping", "Salary", "Transfer", "Food", "Bills"]
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Note / Title",
                hintText: "e.g., Monthly Groceries",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 30),

            // Save Button with Gradient
            GestureDetector(
              onTap: _saveTransaction,
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Save Transaction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
