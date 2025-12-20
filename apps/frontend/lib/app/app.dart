import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../pages/dashboard_page.dart';

class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class YashviMediaApp extends StatelessWidget {
  const YashviMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yashvi Media Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.macOS: _FadePageTransitionsBuilder(),
            TargetPlatform.windows: _FadePageTransitionsBuilder(),
            TargetPlatform.linux: _FadePageTransitionsBuilder(),
            TargetPlatform.iOS: _FadePageTransitionsBuilder(),
            TargetPlatform.android: _FadePageTransitionsBuilder(),
          },
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

