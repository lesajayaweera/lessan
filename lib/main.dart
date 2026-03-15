import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/chat_provider.dart';
import 'package:project/chat_sessions_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Hostel AI Support',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1A237E),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        // Replace with your existing home screen and add a nav item
        // that routes to ChatSessionsScreen
        home: const ChatSessionsScreen(),
      ),
    );
  }
}
