import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/code_block.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  int? _chatId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = ref.read(userIdProvider);
    final username = ref.read(usernameProvider);

    if (userId != null && username != null) {
      try {
        final chat = await ApiService.createChat(userId, 'Chat ${DateTime.now()}');
        setState(() => _chatId = chat['id']);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatId == null) return;

    final userId = ref.read(userIdProvider);
    final username = ref.read(usernameProvider);

    if (userId == null || username == null) return;

    _messageController.clear();
    setState(() => _isLoading = true);

    try {
      // Add user message to UI
      ref.read(messagesProvider.notifier).state = [
        ...ref.read(messagesProvider),
        {'role': 'user', 'content': content}
      ];

      // Get streaming response
      final stream = await ApiService.sendMessage(
        userId: userId,
        chatId: _chatId!,
        username: username,
        content: content,
      );

      String assistantMessage = '';
      await for (final chunk in stream) {
        assistantMessage += chunk;
        setState(() {
          final messages = ref.read(messagesProvider);
          if (messages.isNotEmpty && messages.last['role'] == 'assistant') {
            messages.last['content'] = assistantMessage;
          } else {
            messages.add({'role': 'assistant', 'content': assistantMessage});
          }
          ref.read(messagesProvider.notifier).state = [...messages];
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 64,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['role'] == 'user';
                      final content = message['content'] ?? '';

                      // Check if content contains code block
                      if (content.contains('```')) {
                        return CodeBlock(
                          content: content,
                          isUser: isUser,
                        );
                      }

                      return MessageBubble(
                        content: content,
                        isUser: isUser,
                      );
                    },
                  ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  mini: true,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
