import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';

class YashviMediaApp extends StatelessWidget {
  const YashviMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yashvi Media Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

