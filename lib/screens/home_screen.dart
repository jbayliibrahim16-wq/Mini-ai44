import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final isConnected = await ApiService.healthCheck();
    setState(() {
      _isConnected = isConnected;
    });
  }

  Future<void> _createUser() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    try {
      final user = await ApiService.createUser(username);
      
      // Update providers
      ref.read(userIdProvider.notifier).state = user['id'];
      ref.read(usernameProvider.notifier).state = user['username'];

      // Navigate to chat
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Settings button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Text('Mini AI'),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
              // Header
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mini AI',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Savage, Funny, Helpful',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Connection status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isConnected
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isConnected
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isConnected
                                  ? 'Backend Connected'
                                  : 'Backend Offline',
                              style: TextStyle(
                                color: _isConnected
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Username input
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          prefixIcon: const Icon(Icons.person),
                          enabled: _isConnected,
                        ),
                        onSubmitted: (_) => _createUser(),
                      ),
                      const SizedBox(height: 16),
                      // Start button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isConnected ? _createUser : null,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Start Chatting',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No login required • Your data stays private',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
