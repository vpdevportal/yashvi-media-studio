import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1024; // Small screens show icon-only sidebar
    
    return Container(
      width: isSmallScreen ? 64 : 260,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(
            color: AppColors.primary.withValues(alpha:0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha:0.06),
                ),
              ),
            ),
            child: isSmallScreen
                ? Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 40,
                      height: 40,
                    ),
                  )
                : Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => AppColors.logoGradient.createShader(bounds),
                            child: const Text(
                              'Yashvi Media',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Text(
                            'Studio',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 16),

          // Navigation items
          Builder(
            builder: (context) {
              final isSmallScreen = MediaQuery.of(context).size.width < 1024;
              return Column(
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                    showLabel: !isSmallScreen,
                  ),
                  _NavItem(
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder,
                    label: 'Projects',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                    showLabel: !isSmallScreen,
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: 'Characters',
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                    showLabel: !isSmallScreen,
                  ),
                  _NavItem(
                    icon: Icons.video_library_outlined,
                    activeIcon: Icons.video_library,
                    label: 'Episodes',
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                    showLabel: !isSmallScreen,
                  ),
                ],
              );
            },
          ),

          const Spacer(),

          // Bottom section
          Builder(
            builder: (context) {
              final isSmallScreen = MediaQuery.of(context).size.width < 1024;
              return Column(
                children: [
                  Divider(color: AppColors.primary.withValues(alpha:0.06), height: 1),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    isSelected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                    showLabel: !isSmallScreen,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showLabel = true,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.showLabel ? '' : widget.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(
              horizontal: widget.showLabel ? 12 : 8,
              vertical: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.showLabel ? 12 : 8,
              vertical: widget.showLabel ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha:0.12)
                  : _isHovered
                      ? AppColors.surfaceElevated.withValues(alpha:0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: widget.isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha:0.25))
                  : null,
            ),
            child: widget.showLabel
                ? Row(
                    children: [
                      Icon(
                        widget.isSelected ? widget.activeIcon : widget.icon,
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.isSelected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight:
                              widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

