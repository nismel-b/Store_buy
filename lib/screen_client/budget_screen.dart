import 'package:flutter/material.dart';
import 'package:store_buy/service/budget_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

/// Écran pour gérer la limite de budget mensuel
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  final TextEditingController _limitController = TextEditingController();
  Map<String, dynamic>? _currentBudget;
  bool _isLoading = true;
  bool _isExceeded = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadBudget() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final budget = await _budgetService.getCurrentBudget(authProvider.currentUser!.userId);
      final exceeded = await _budgetService.isBudgetExceeded(authProvider.currentUser!.userId);
      setState(() {
        _currentBudget = budget;
        _isExceeded = exceeded;
        if (budget != null) {
          _limitController.text = (budget['monthlyLimit'] as num).toString();
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBudget() async {
    if (_limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une limite')),
      );
      return;
    }

    final limit = double.tryParse(_limitController.text);
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une limite valide')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _budgetService.setMonthlyBudget(
        userId: authProvider.currentUser!.userId,
        monthlyLimit: limit,
      );
      _loadBudget();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget enregistré avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Limite de budget'),
          backgroundColor: const Color(0xFF3B82F6),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final limit = _currentBudget != null
        ? (_currentBudget!['monthlyLimit'] as num).toDouble()
        : 0.0;
    final spent = _currentBudget != null
        ? (_currentBudget!['currentSpent'] as num).toDouble()
        : 0.0;
    final remaining = limit - spent;
    final percentage = limit > 0 ? (spent / limit * 100).clamp(0.0, 100.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limite de budget'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget mensuel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Limite mensuelle (FCFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_currentBudget != null) ...[
              const SizedBox(height: 40),
              const Text(
                'Statut du budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isExceeded ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dépensé'),
                              Text(
                                '${spent.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Restant'),
                              Text(
                                '${remaining.toStringAsFixed(0)} FCFA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _isExceeded ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${percentage.toStringAsFixed(1)}% du budget utilisé',
                        style: TextStyle(
                          color: _isExceeded ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isExceeded)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            '⚠️ Budget dépassé!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


