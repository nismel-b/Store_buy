import 'package:flutter/material.dart';
import 'package:store_buy/service/employee_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EmployeesScreen extends StatefulWidget {
  final String? storeId;
  const EmployeesScreen({super.key, this.storeId});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _employees = [];
  String? _selectedStoreId;
  String? _storeCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.storeId != null) {
      _selectedStoreId = widget.storeId;
    } else if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      if (stores.isNotEmpty) {
        _selectedStoreId = stores.first['storeId'];
        _storeCode = stores.first['code'];
      }
    }

    if (_selectedStoreId != null) {
      final employees = await _employeeService.getEmployeesByStore(_selectedStoreId!);
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeEmployee(String employeeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer l\'employé'),
        content: const Text('Êtes-vous sûr de vouloir retirer cet employé?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _employeeService.removeEmployee(employeeId);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employés'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_storeCode != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Code d\'accès pour employés',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _storeCode!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                // Copy to clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copié')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text(
                          'Partagez ce code avec vos employés pour qu\'ils puissent se connecter',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _employees.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucun employé',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _employees.length,
                            itemBuilder: (context, index) {
                              final employee = _employees[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      (employee['name'] as String? ?? 'E')[0].toUpperCase(),
                                    ),
                                  ),
                                  title: Text(employee['name'] ?? 'Employé'),
                                  subtitle: Text(employee['role'] ?? 'employee'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeEmployee(employee['employeeId']),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}


