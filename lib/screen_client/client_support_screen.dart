import 'package:flutter/material.dart';
import 'package:store_buy/service/support_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Écran de contact avec le service client pour les clients
class ClientSupportScreen extends StatefulWidget {
  const ClientSupportScreen({super.key});

  @override
  State<ClientSupportScreen> createState() => _ClientSupportScreenState();
}

class _ClientSupportScreenState extends State<ClientSupportScreen> {
  final SupportService _supportService = SupportService();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final tickets = await _supportService.getTicketsByUser(
        authProvider.currentUser!.userId,
      );
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTicket() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await _supportService.createTicket(
        userId: authProvider.currentUser!.userId,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );
      _subjectController.clear();
      _messageController.clear();
      setState(() => _showForm = false);
      _loadTickets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket créé avec succès'),
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
        title: const Text('Support client'),
        backgroundColor: const Color(0xFF3B82F6),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () {
              setState(() => _showForm = !_showForm);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_showForm)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Sujet',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() => _showForm = false);
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: _createTicket,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Envoyer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _tickets.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.support_agent, size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucun ticket',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Créez un ticket pour contacter le support',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTickets,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ticket['status'] == 'open'
                                        ? Colors.orange
                                        : Colors.green,
                                    child: const Icon(Icons.support_agent, color: Colors.white),
                                  ),
                                  title: Text(ticket['subject'] ?? 'Sujet'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ticket['message'] ?? ''),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Statut: ${ticket['status']}',
                                        style: TextStyle(
                                          color: ticket['status'] == 'open'
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                          DateTime.parse(ticket['createdAt']),
                                        ),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
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


