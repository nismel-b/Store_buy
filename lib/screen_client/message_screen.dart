import 'package:flutter/material.dart';
import 'package:store_buy/service/message_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Écran de messagerie pour les clients
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  String? _selectedUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final conversations = await _messageService.getConversations(
        authProvider.currentUser!.userId,
      );
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final messages = await _messageService.getConversation(
        authProvider.currentUser!.userId,
        userId,
      );
      // Mark messages as read when opening conversation
      await _messageService.markMessagesAsRead(
        authProvider.currentUser!.userId,
        userId,
      );
      setState(() {
        _messages = messages;
        _selectedUserId = userId;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUserId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final senderName = authProvider.currentUser?.name ?? 'Vous';
      await _messageService.sendMessage(
        senderId: authProvider.currentUser!.userId,
        receiverId: _selectedUserId!,
        content: _messageController.text.trim(),
        senderName: senderName,
      );
      // Mark messages as read when sending
      await _messageService.markMessagesAsRead(
        authProvider.currentUser!.userId,
        _selectedUserId!,
      );
      _messageController.clear();
      _loadMessages(_selectedUserId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Conversations list
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: _conversations.isEmpty
                      ? const Center(
                          child: Text('Aucune conversation'),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conv = _conversations[index];
                            final isSelected = conv['otherUserId'] == _selectedUserId;
                            return ListTile(
                              selected: isSelected,
                              leading: CircleAvatar(
                                child: Text(
                                  (conv['otherUserName'] as String? ?? 'U')[0].toUpperCase(),
                                ),
                              ),
                              title: Text(conv['otherUserName'] ?? 'Vendeur'),
                              subtitle: Text(
                                conv['lastMessage'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _loadMessages(conv['otherUserId']),
                            );
                          },
                        ),
                ),
                // Messages
                Expanded(
                  child: _selectedUserId == null
                      ? const Center(
                          child: Text('Sélectionnez une conversation'),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  final isMe = message['senderId'] == authProvider.currentUser?.userId;
                                  return Align(
                                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? const Color(0xFF3B82F6)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message['content'] ?? '',
                                            style: TextStyle(
                                              color: isMe ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            DateFormat('HH:mm').format(
                                              DateTime.parse(message['createdAt']),
                                            ),
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
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
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: 'Tapez un message...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: _sendMessage,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
