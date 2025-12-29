import 'package:flutter/material.dart';
import 'package:store_buy/service/report_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Écran pour signaler un vendeur ou un client
class ReportScreen extends StatefulWidget {
  final String? reportedUserId;
  final String? storeId;
  const ReportScreen({super.key, this.reportedUserId, this.storeId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedReason = 'spam';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reasons = [
    {'value': 'spam', 'label': 'Spam'},
    {'value': 'fraud', 'label': 'Fraude'},
    {'value': 'inappropriate', 'label': 'Contenu inapproprié'},
    {'value': 'harassment', 'label': 'Harcèlement'},
    {'value': 'other', 'label': 'Autre'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez décrire le problème')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null && widget.reportedUserId != null) {
      await _reportService.reportUser(
        reporterId: authProvider.currentUser!.userId,
        reportedUserId: widget.reportedUserId!,
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signalement envoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signaler un utilisateur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Raison du signalement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason['label']),
                value: reason['value'],
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value!);
                },
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Décrivez le problème...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Envoyer le signalement',
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
    );
  }
}

