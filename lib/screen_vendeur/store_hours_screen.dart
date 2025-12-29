import 'package:flutter/material.dart';
import 'package:store_buy/service/store_service.dart';


/// Écran pour gérer les heures d'ouverture et de fermeture
class StoreHoursScreen extends StatefulWidget {
  final String storeId;
  const StoreHoursScreen({super.key, required this.storeId});

  @override
  State<StoreHoursScreen> createState() => _StoreHoursScreenState();
}

class _StoreHoursScreenState extends State<StoreHoursScreen> {
  final StoreService _storeService = StoreService();
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  bool _isOpen = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreHours();
  }

  Future<void> _loadStoreHours() async {
    final store = await _storeService.getStoreById(widget.storeId);
    if (store != null) {
      setState(() {
        if (store['openingTime'] != null) {
          final parts = (store['openingTime'] as String).split(':');
          _openingTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        if (store['closingTime'] != null) {
          final parts = (store['closingTime'] as String).split(':');
          _closingTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        _isOpen = (store['isOpen'] as int? ?? 1) == 1;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectOpeningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openingTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _openingTime = picked);
    }
  }

  Future<void> _selectClosingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closingTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() => _closingTime = picked);
    }
  }

  Future<void> _saveHours() async {
    if (_openingTime == null || _closingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez définir les heures d\'ouverture et de fermeture')),
      );
      return;
    }

    await _storeService.updateStore(widget.storeId, {
      'openingTime': '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}',
      'closingTime': '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}',
      'isOpen': _isOpen ? 1 : 0,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Heures enregistrées avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heures d\'ouverture'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gérer les heures d\'ouverture',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SwitchListTile(
                    title: const Text('Magasin ouvert'),
                    subtitle: const Text('Le magasin est actuellement ouvert'),
                    value: _isOpen,
                    onChanged: (value) {
                      setState(() => _isOpen = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Heure d\'ouverture'),
                    subtitle: Text(
                      _openingTime != null
                          ? '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}'
                          : 'Non définie',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectOpeningTime,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Heure de fermeture'),
                    subtitle: Text(
                      _closingTime != null
                          ? '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}'
                          : 'Non définie',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectClosingTime,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveHours,
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
                ],
              ),
            ),
    );
  }
}


