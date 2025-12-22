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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      height: isMobile ? 56 : 64,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha:0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(width: isMobile ? 8 : 16),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

