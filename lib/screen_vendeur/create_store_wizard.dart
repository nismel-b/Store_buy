import 'package:flutter/material.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateStoreWizard extends StatefulWidget {
  const CreateStoreWizard({super.key});

  @override
  State<CreateStoreWizard> createState() => _CreateStoreWizardState();
}

class _CreateStoreWizardState extends State<CreateStoreWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Basic Info
  final _storeNameController = TextEditingController();
  final _sloganController = TextEditingController();
  Category _selectedCategory = Category.freshProduct;
  String _imagePath = '';

  // Step 2: Description
  final _descriptionController = TextEditingController();
  final _openingtimeController = TextEditingController();
  final _closetimeController = TextEditingController();

  // Step 3: Policies
  //final _regleController = TextEditingController();

  // Step 4: Location & Security
  final _adresseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  // Step 5: Delivery & Payment
  String _deliveryMode = 'both';
  // 'delivery', 'pickup', 'both'
  //String _paymentMethods = 'all'; // 'all', 'card', 'mobile_money'

  final StoreService _storeService = StoreService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': Category.freshProduct, 'label': 'Produit frais', 'icon': Icons.shopping_basket},
    {'value': Category.cosmetique, 'label': 'Cosmétique', 'icon': Icons.face},
    {'value': Category.accessoire, 'label': 'Accessoire', 'icon': Icons.watch},
    {'value': Category.electromenager, 'label': 'Électroménager', 'icon': Icons.microwave},
    {'value': Category.bazar, 'label': 'Bazar', 'icon': Icons.store},
    {'value': Category.vetementTextile, 'label': 'Vêtements', 'icon': Icons.checkroom},
    {'value': Category.materielScolaire, 'label': 'Matériel scolaire', 'icon': Icons.school},
    {'value': Category.ustensile, 'label': 'Ustensile de cuisine', 'icon': Icons.restaurant},
    {'value': Category.meche, 'label': 'Coiffure et mèche', 'icon': Icons.content_cut},
    {'value': Category.shoes, 'label': 'Chaussures', 'icon': Icons.shopping_bag},
    {'value': Category.bijoux, 'label': 'Bijoux', 'icon': Icons.diamond},
    {'value': Category.construction, 'label': 'Matériaux de construction', 'icon': Icons.build},
    {'value': Category.hygiene, 'label': 'Produit d\'hygiène', 'icon': Icons.clean_hands},
    {'value': Category.luminaire, 'label': 'Luminaire', 'icon': Icons.lightbulb},
    {'value': Category.literieMeuble, 'label': 'Literie et meuble', 'icon': Icons.bed},
    {'value': Category.restauration, 'label': 'Restauration', 'icon': Icons.restaurant_menu},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
   // _regleController.dispose();
    _adresseController.dispose();
    _passwordController.dispose();
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

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _storeNameController.text.isNotEmpty;
      case 1:
        return _descriptionController.text.isNotEmpty;
      case 2:
        return true; // Optional
      case 3:
        return _passwordController.text.length >= 8;
      case 4:
        return true; // Optional
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submit();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
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
        openingTime: _openingtimeController.text.trim(),
        closeTime: _closetimeController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success != null && mounted) {
      // Get the created store ID
      final stores = await _storeService.getStoresByUserId(authProvider.currentUser!.userId);
      if (stores.isNotEmpty) {
        if(!mounted)return;
        Navigator.pushReplacementNamed(
          context,
          '/vendor-home',
          arguments: stores.first['storeId'],
        );
      } else {
        if(!mounted)return;
        Navigator.pushReplacementNamed(context, '/vendor-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un magasin (${_currentStep + 1}/$_totalSteps)'),
        backgroundColor: const Color(0xFF3B82F6),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        children: [
          _buildStep1(),
          _buildStep2(),
          //_buildStep3(),
          _buildStep4(),
          _buildStep5(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Précédent'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_currentStep == _totalSteps - 1 ? 'Créer' : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de base',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Commencez par les informations essentielles de votre magasin',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(_imagePath), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50),
                        SizedBox(height: 10),
                        Text('Ajouter une photo du magasin'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du magasin *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _sloganController,
            decoration: const InputDecoration(
              labelText: 'Slogan *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Catégorie *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat['value'] as Category;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Décrivez votre magasin et son histoire',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _descriptionController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText: 'Parlez de votre magasin, son histoire, ses valeurs...',
              border: OutlineInputBorder(),
            ),
          ),
          const Text(
            "Ajouter les heures de fermeture et d'ouverture",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _openingtimeController,
            decoration: const InputDecoration(
              labelText: "Heure d'ouverture",
              hintText: '8 H 00',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _closetimeController,
            decoration: const InputDecoration(
              labelText: "Heure de fermeture",
              hintText: '20 H 00',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
/*
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Politiques',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Définissez vos règles de remboursement, garanties et promotions',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _regleController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Règles et politiques',
              hintText: 'Remboursements, garanties, réductions, promotions...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Localisation et sécurité',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ajoutez votre adresse et sécurisez votre magasin',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _adresseController,
            decoration: const InputDecoration(
              labelText: 'Adresse du magasin *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe du magasin *',
              hintText: 'Minimum 8 caractères',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Code d\'accès pour employés *',
              hintText: 'Les employés utiliseront ce code pour se connecter',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Livraison',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Configurez vos options de livraison',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text(
            'Mode de livraison',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Livraison uniquement'),
                  value: 'delivery',
                  groupValue: _deliveryMode,
                  onChanged: (value) => setState(() => _deliveryMode = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Retrait en magasin uniquement'),
                  value: 'pickup',
                  groupValue: _deliveryMode,
                  onChanged: (value) => setState(() => _deliveryMode = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Les deux'),
                  value: 'both',
                  groupValue: _deliveryMode,
                  onChanged: (value) => setState(() => _deliveryMode = value!),

                ),
              ],
            ),
          const SizedBox(height: 30),


          /*const Text(
            'Méthodes de paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RadioListTile<String>(
            title: const Text('Toutes les méthodes'),
            value: 'all',
            groupValue: _paymentMethods,
            onChanged: (value) => setState(() => _paymentMethods = value!),
          ),
          RadioListTile<String>(
            title: const Text('Carte uniquement'),
            value: 'card',
            groupValue: _paymentMethods,
            onChanged: (value) => setState(() => _paymentMethods = value!),
          ),
          RadioListTile<String>(
            title: const Text('Mobile Money uniquement'),
            value: 'mobile_money',
            groupValue: _paymentMethods,
            onChanged: (value) => setState(() => _paymentMethods = value!),
          ),*/
        ],
      ),

    );
  }
}

