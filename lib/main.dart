import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MiniAIApp(),
    ),
  );
}

class MiniAIApp extends StatelessWidget {
  const MiniAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
      navigatorObservers: [],
      routes: {
        '/chat': (context) => const ChatScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
