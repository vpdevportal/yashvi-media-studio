import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/episode.dart';
import '../../../../core/theme/app_colors.dart';

class EpisodeDetailPage extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailPage({super.key, required this.episode});

  @override
  State<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends State<EpisodeDetailPage> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: 'Story'),
    _TabItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Screenplay'),
    _TabItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Snapshots'),
    _TabItem(icon: Icons.movie_outlined, activeIcon: Icons.movie, label: 'Shorts'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              // Left sidebar menu
              Container(
                width: 240,
                decoration: BoxDecoration(
                  color: AppColors.sidebar,
                  border: Border(
                    right: BorderSide(color: AppColors.primary.withOpacity(0.08)),
                  ),
                ),
                child: Column(
                  children: [
                    // Back button and episode info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary.withOpacity(0.06)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
                                onPressed: () => Navigator.pop(context),
                                tooltip: 'Back (Esc)',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'EP ${widget.episode.episodeNumber}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.episode.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Navigation tabs
                    Expanded(
                      child: ListView(
                        children: List.generate(_tabs.length, (index) {
                          final tab = _tabs[index];
                          return _SidebarTab(
                            icon: tab.icon,
                            activeIcon: tab.activeIcon,
                            label: tab.label,
                            isSelected: _selectedTab == index,
                            onTap: () => _onTabSelected(index),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppColors.navbar,
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary.withOpacity(0.06)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _tabs[_selectedTab].label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Action buttons can be added here based on tab
                        ],
                      ),
                    ),
                    // Content area - horizontal scrollable pages
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildStory(),
                          _buildScreenplay(),
                          _buildSnapshots(),
                          _buildShorts(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Story',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildEmptyState('Story content', Icons.auto_stories_outlined),
        ],
      ),
    );
  }

  Widget _buildScreenplay() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Screenplay',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildEmptyState('Screenplay content', Icons.description_outlined),
        ],
      ),
    );
  }

  Widget _buildSnapshots() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Snapshots',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildEmptyState('Snapshots', Icons.camera_alt_outlined),
        ],
      ),
    );
  }

  Widget _buildShorts() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shorts',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildEmptyState('Shorts', Icons.movie_outlined),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No $title yet',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _SidebarTab extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarTab> createState() => _SidebarTabState();
}

class _SidebarTabState extends State<_SidebarTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.12)
                : _isHovered
                    ? AppColors.surfaceElevated.withOpacity(0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: AppColors.primary.withOpacity(0.25))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                color: widget.isSelected ? AppColors.primary : AppColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
