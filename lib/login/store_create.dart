import 'package:flutter/material.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LoginStore extends StatefulWidget {
  const LoginStore({super.key});

  @override
  State<StatefulWidget> createState() => _LoginStoreState();
}

class _LoginStoreState extends State<LoginStore> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sloganController = TextEditingController();
  final _regleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adresseController = TextEditingController();
  final _codeController = TextEditingController();
  final _openingtimeController = TextEditingController();
  final _closetimeController = TextEditingController();
  final StoreService _storeService = StoreService();
  final ImagePicker _picker = ImagePicker();
  Category _selectedCategory = Category.freshProduct;
  String _imagePath = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': Category.freshProduct, 'label': 'Produit frais'},
    {'value': Category.cosmetique, 'label': 'Cosmétique'},
    {'value': Category.accessoire, 'label': 'Accessoire'},
    {'value': Category.electromenager, 'label': 'Électroménager'},
    {'value': Category.bazar, 'label': 'Bazar'},
    {'value': Category.vetementTextile, 'label': 'Vêtements'},
    {'value': Category.materielScolaire, 'label': 'Matériel scolaire'},
    {'value': Category.ustensile, 'label': 'Ustensile de cuisine'},
    {'value': Category.meche, 'label': 'Coiffure et mèche'},
    {'value': Category.shoes, 'label': 'Chaussures'},
    {'value': Category.bijoux, 'label': 'Bijoux'},
    {'value': Category.construction, 'label': 'Matériaux de construction'},
    {'value': Category.hygiene, 'label': 'Produit d\'hygiène'},
    {'value': Category.luminaire, 'label': 'Luminaire'},
    {'value': Category.literieMeuble, 'label': 'Literie et meuble'},
    {'value': Category.restauration, 'label': 'Restauration'},
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _sloganController.dispose();
    _regleController.dispose();
    _passwordController.dispose();
    _adresseController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
        );
      }
      return;
    }

    final success = await _storeService.createStore(
      userId: authProvider.currentUser!.userId,
      storename: _storeNameController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      slogan: _sloganController.text.trim(),
     // regle: _regleController.text.trim(),
      password: _passwordController.text,
      adresse: _adresseController.text.trim(),
      photo: _imagePath,
      code: _codeController.text.trim(),
      openingTime: _codeController.text.trim(),
      closeTime: _codeController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Magasin créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/vendor-home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création du magasin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer son magasin"),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath.isNotEmpty
                      ? Image.file(
                          File(_imagePath),
                          fit: BoxFit.cover,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50),
                            SizedBox(height: 10),
                            Text('Appuyez pour ajouter une photo du magasin'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du magasin *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du magasin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'Catégorie *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<Category>(
                    value: cat['value'] as Category,
                    child: Text(cat['label'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _sloganController,
                decoration: const InputDecoration(
                  labelText: 'Slogan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _regleController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Règles et politiques',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _openingtimeController,
                decoration: const InputDecoration(
                  labelText: "Heure d'ouverture",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _closetimeController,
                decoration: const InputDecoration(
                  labelText: "Heure de fermeture",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe du magasin *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 12) {
                    return 'Le mot de passe doit contenir au moins 12 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code d\'accès (pour employés)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Créer le magasin',
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
    );
  }
}
