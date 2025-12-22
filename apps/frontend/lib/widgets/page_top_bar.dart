import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/extensions/media_query_extensions.dart';

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
      height: context.isMobile ? 56 : 64,
      padding: context.responsiveHorizontalPadding,
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
                fontSize: context.isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(width: context.isMobile ? 8 : 16),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

