import 'package:flutter/material.dart';
import 'package:store_buy/model/login_model.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  final UserType? userType;
  const RegisterScreen({super.key, this.userType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  UserType _selectedUserType = UserType.customer;

  @override
  void initState() {
    super.initState();
    if (widget.userType != null) {
      _selectedUserType = widget.userType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phonenumber: _phoneController.text.trim(),
      password: _passwordController.text,
      location: _locationController.text.trim(),
      userType: _selectedUserType,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      if (_selectedUserType == UserType.vendor) {
        Navigator.pushReplacementNamed(context, '/create-store');
      } else {
        // Redirect to user type selection after registration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_type_selected_${authProvider.currentUser!.userId}', false);
        if(!mounted) return;
        {Navigator.pushReplacementNamed(context, '/user-type-selection');}
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'inscription. Le nom d'utilisateur existe peut-être déjà."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            if (widget.userType == null)
                              Column(
                                children: [
                                  const Text('Type de compte'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<UserType>(
                                          title: const Text('Client'),
                                          value: UserType.customer,
                                          groupValue: _selectedUserType,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedUserType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<UserType>(
                                          title: const Text('Vendeur'),
                                          value: UserType.vendor,
                                          groupValue: _selectedUserType,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedUserType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom complet',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: "Nom d'utilisateur",
                                prefixIcon: Icon(Icons.alternate_email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un nom d\'utilisateur';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email (optionnel)',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone (optionnel)',
                                prefixIcon: Icon(Icons.phone),
                                prefixText: '+237 ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                if (value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Adresse (optionnel)',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'S\'inscrire',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "J'ai déjà un compte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,

                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

