import 'package:flutter/material.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/service/employee_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:store_buy/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Écran pour intégrer un magasin existant avec un code secret
class JoinStoreScreen extends StatefulWidget {
  const JoinStoreScreen({super.key});

  @override
  State<JoinStoreScreen> createState() => _JoinStoreScreenState();
}

class _JoinStoreScreenState extends State<JoinStoreScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _storenameController = TextEditingController();
  final StoreService _storeService = StoreService();
  final EmployeeService _employeeService = EmployeeService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _joinStore() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer un code secret');
      return;
    }
    if (_storenameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer le nom du magasin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) {
        setState(() {
          _errorMessage = 'Vous devez être connecté';
          _isLoading = false;
        });
        return;
      }

      // Find store by code
      final stores = await _storeService.getAllStores();
      final store = stores.firstWhere(
        (s) => s['code'] == _codeController.text.trim(),
        orElse: () => {},
      );
      // Find store by name
      final magasin = stores.firstWhere(
            (s) => s['storename'] == _storenameController.text.trim(),
        orElse: () => {},
      );

      if (store.isEmpty) {
        setState(() {
          _errorMessage = 'Code secret invalide';
          _isLoading = false;
        });
        return;
      }
      if (magasin.isEmpty){
        setState(() {
          _errorMessage = 'Nom du magasin invalide';
          _isLoading = false;
        });
        return;
      }

      // Add user as employee using code
      final success = await _employeeService.addEmployeeByCode(
        storeId: store['storeId'],
        userId: authProvider.currentUser!.userId,
        code: _codeController.text.trim(),
        role: 'employee',
      );

      if (success) {
        // Mark user type as selected
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_type_selected_${authProvider.currentUser!.userId}', true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous avez rejoint le magasin avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/vendor-home');
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'ajout au magasin';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _storenameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intégrer un magasin'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom du magasin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Code secret du magasin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Le propriétaire du magasin vous a fourni un code secret. Entrez-le ci-dessous pour rejoindre le magasin.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _storenameController,
              decoration: InputDecoration(
                labelText: 'Nom du magasin',
                hintText: 'Entrez le nom du magasin ',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _errorMessage,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code secret',
                hintText: 'Entrez le code secret',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _errorMessage,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Rejoindre le magasin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Le code secret est différent du mot de passe du magasin. Demandez-le au propriétaire.',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

