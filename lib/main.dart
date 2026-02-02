import 'package:flutter/material.dart';
import 'constant/app_colors.dart';
import 'screen/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LHC Coaching',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: Scaffold(body: const LoginPage()),
      debugShowCheckedModeBanner: false,
    );
  }
}
