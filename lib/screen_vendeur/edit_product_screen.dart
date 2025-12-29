import 'package:flutter/material.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/model/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _characteristicController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _colorController = TextEditingController();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.productName;
    _characteristicController.text = widget.product.characteristic;
    _priceController.text = widget.product.price.toString();
    _quantityController.text = widget.product.quantity.toString();
    _colorController.text = widget.product.color.join(', ');
    _imagePath = widget.product.photo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _characteristicController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _colorController.dispose();
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

    final colors = _colorController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = await _productService.updateProduct(
      widget.product.productId!,
      {
        'productName': _nameController.text.trim(),
        'characteristic': _characteristicController.text.trim(),
        'color': colors.join(','),
        'photo': _imagePath ?? '',
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
      },
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  child: _imagePath != null && _imagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _imagePath!.startsWith('http')
                              ? Image.network(_imagePath!, fit: BoxFit.cover)
                              : Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            SizedBox(height: 10),
                            Text('Appuyez pour changer l\'image'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du produit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _characteristicController,
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
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix (FCFA) *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer une quantité valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Couleurs (séparées par des virgules)',
                  hintText: 'Rouge, Bleu, Vert',
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
                          'Enregistrer les modifications',
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


