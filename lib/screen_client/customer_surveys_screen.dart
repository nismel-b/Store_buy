import 'package:flutter/material.dart';
import 'package:store_buy/service/survey_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Écran pour voir et répondre aux sondages (clients)
class CustomerSurveysScreen extends StatefulWidget {
  const CustomerSurveysScreen({super.key});

  @override
  State<CustomerSurveysScreen> createState() => _CustomerSurveysScreenState();
}

class _CustomerSurveysScreenState extends State<CustomerSurveysScreen> {
  final SurveyService _surveyService = SurveyService();
  List<Map<String, dynamic>> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final surveys = await _surveyService.getSurveysForCustomer(
        authProvider.currentUser!.userId,
      );
      setState(() {
        _surveys = surveys;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToSurvey(Map<String, dynamic> survey) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    String? answer;
    final type = survey['type'] as String;

    if (type == 'yes_no') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(survey['question'] ?? ''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Oui'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Non'),
              ),
            ],
          ),
        ),
      );
      answer = result == true ? 'Oui' : 'Non';
    } else if (type == 'multiple_choice') {
      final options = (survey['options'] as String?)?.split('|') ?? [];
      answer = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(survey['question'] ?? ''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      final controller = TextEditingController();
      answer = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(survey['question'] ?? ''),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Votre réponse',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Envoyer'),
            ),
          ],
        ),
      );
    }

    if (answer != null && answer.isNotEmpty) {
      await _surveyService.respondToSurvey(
        surveyId: survey['surveyId'],
        userId: authProvider.currentUser!.userId,
        answer: answer,
      );
      _loadSurveys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci pour votre réponse!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondages'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.poll, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Aucun sondage disponible',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSurveys,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _surveys.length,
                    itemBuilder: (context, index) {
                      final survey = _surveys[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.poll, color: Color(0xFF3B82F6)),
                          title: Text(survey['question'] ?? ''),
                          subtitle: Text('Magasin: ${survey['storename'] ?? ''}'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => _respondToSurvey(survey),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


