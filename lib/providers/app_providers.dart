import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// User state
final userIdProvider = StateProvider<int?>((ref) => null);
final usernameProvider = StateProvider<String?>((ref) => null);

// Chat state
final currentChatProvider = StateProvider<int?>((ref) => null);
final messagesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

// User chats
final userChatsProvider = FutureProvider.family<List<dynamic>, int>((ref, userId) async {
  return await ApiService.getUserChats(userId);
});

// Chat messages
final chatMessagesProvider = FutureProvider.family<List<dynamic>, int>((ref, chatId) async {
  return await ApiService.getChatMessages(chatId);
});

// Create user
final createUserProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, username) async {
  return await ApiService.createUser(username);
});

// Send message
final sendMessageProvider = FutureProvider.family<Stream<String>, Map<String, dynamic>>((ref, params) async {
  return await ApiService.sendMessage(
    userId: params['userId'],
    chatId: params['chatId'],
    username: params['username'],
    content: params['content'],
  );
});

// Health check
final healthCheckProvider = FutureProvider<bool>((ref) async {
  return await ApiService.healthCheck();
});
