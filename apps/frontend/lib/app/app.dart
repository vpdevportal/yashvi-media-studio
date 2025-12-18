import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';

class YashviMediaApp extends StatelessWidget {
  const YashviMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yashvi Media Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}

