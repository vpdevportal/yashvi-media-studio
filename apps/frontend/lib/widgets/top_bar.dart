import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/extensions/media_query_extensions.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onAdd;
  final String? addLabel;

  const TopBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.onAdd,
    this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: context.isMobile ? 64 : 72,
      padding: EdgeInsets.symmetric(
        horizontal: context.isSmallScreen ? 16 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.navbar,
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
          if (!context.isMobile) ...[
            const SizedBox(width: 16),
            // Search bar - hide on very small screens
            if (!context.isSmallScreen)
              Container(
                width: 280,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceElevated),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.textMuted, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search projects...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⌘K',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (context.isSmallScreen && !context.isMobile) const SizedBox(width: 8),
            if (onRefresh != null)
              _ActionButton(
                icon: Icons.refresh,
                tooltip: 'Refresh',
                onTap: onRefresh!,
              ),
            if (onAdd != null) ...[
              SizedBox(width: context.isSmallScreen ? 8 : 12),
              _PrimaryButton(
                icon: Icons.add,
                label: context.isSmallScreen ? '' : (addLabel ?? 'Add New'),
                onTap: onAdd!,
              ),
            ],
          ] else ...[
            // Mobile: Show icon buttons only
            if (onRefresh != null)
              _ActionButton(
                icon: Icons.refresh,
                tooltip: 'Refresh',
                onTap: onRefresh!,
              ),
            if (onAdd != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? AppColors.primary.withValues(alpha:0.2) : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.icon,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isIconOnly = widget.label.isEmpty;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: isIconOnly ? (widget.label.isEmpty ? 'Add New' : widget.label) : '',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            width: isIconOnly ? 40 : null,
            padding: EdgeInsets.symmetric(
              horizontal: isIconOnly ? 0 : 16,
            ),
            decoration: BoxDecoration(
              gradient: _isHovered
                  ? const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary, AppColors.accent],
                    )
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha:0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isIconOnly
                ? Icon(widget.icon, color: Colors.white, size: 22)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

