import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PageTopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const PageTopBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha:0.06)),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const Spacer(),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

