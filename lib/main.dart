import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MilkApp());
}

class MilkApp extends StatelessWidget {
  const MilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '牛奶计算器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9), // 奶蓝
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const HomeScreen(),
    );
  }
}
