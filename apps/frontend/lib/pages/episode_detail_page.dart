import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/episode.dart';
import '../core/models/story.dart';
import '../core/models/scene.dart';
import '../core/services/api_service.dart';
import '../core/theme/app_colors.dart';
import 'episode_detail/episode_screenplay_tab.dart';
import 'episode_detail/episode_shorts_tab.dart';
import 'episode_detail/episode_snapshots_tab.dart';
import 'episode_detail/episode_story_tab.dart';

class EpisodeDetailPage extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailPage({super.key, required this.episode});

  @override
  State<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends State<EpisodeDetailPage> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  Story? _story;
  bool _isStoryLoading = true;
  String? _storyError;
  List<Scene> _scenes = [];
  bool _isScreenplayLoading = true;
  String? _screenplayError;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: 'Story'),
    _TabItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Screenplay'),
    _TabItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Snapshots'),
    _TabItem(icon: Icons.movie_outlined, activeIcon: Icons.movie, label: 'Shorts'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStory();
    _loadScreenplay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStory() async {
    setState(() {
      _isStoryLoading = true;
      _storyError = null;
    });

    try {
      final story = await _apiService.getStoryByEpisode(widget.episode.id);
      setState(() {
        _story = story;
        _isStoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _storyError = e.toString().replaceAll('Exception: ', '');
        _isStoryLoading = false;
      });
    }
  }

  Future<void> _loadScreenplay() async {
    setState(() {
      _isScreenplayLoading = true;
      _screenplayError = null;
    });

    try {
      final scenes = await _apiService.getScreenplayScenes(widget.episode.id);
      setState(() {
        _scenes = scenes;
        _isScreenplayLoading = false;
      });
    } catch (e) {
      setState(() {
        _screenplayError = e.toString().replaceAll('Exception: ', '');
        _isScreenplayLoading = false;
      });
    }
  }

  Future<void> _updateStory(String content) async {
    setState(() {
      _isStoryLoading = true;
      _storyError = null;
    });

    try {
      final updatedStory = await _apiService.updateStory(widget.episode.id, content);
      setState(() {
        _story = updatedStory;
        _isStoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _storyError = e.toString().replaceAll('Exception: ', '');
        _isStoryLoading = false;
      });
      rethrow;
    }
  }

  Future<void> _handleScreenplayGenerated(List<Scene> scenes) async {
    setState(() {
      _scenes = scenes;
      _isScreenplayLoading = false;
      _screenplayError = null;
    });
  }

  Future<void> _handleScreenplayCleared() async {
    // Reload screenplay to reflect the cleared state
    await _loadScreenplay();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallScreen = screenWidth < 1024; // Small screens show icon-only sidebar
    
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Full-width navbar
              Container(
                height: isMobile ? 56 : 64,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : isTablet ? 24 : 32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navbar,
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary.withValues(alpha:0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back (Esc)',
                    ),
                    SizedBox(width: isMobile ? 8 : 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EP ${widget.episode.episodeNumber}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 16),
                    Expanded(
                      child: Text(
                        widget.episode.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: isMobile ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content area with left menu and right content
              Expanded(
                child: isMobile
                    ? Column(
                        children: [
                          // Mobile: Horizontal tab bar at top
                          Container(
                            height: 56,
                            color: AppColors.sidebar,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              children: List.generate(_tabs.length, (index) {
                                final tab = _tabs[index];
                                return _MobileTab(
                                  icon: tab.icon,
                                  activeIcon: tab.activeIcon,
                                  label: tab.label,
                                  isSelected: _selectedTab == index,
                                  onTap: () => _onTabSelected(index),
                                );
                              }),
                            ),
                          ),
                          // Mobile: Content area
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              scrollDirection: Axis.horizontal,
                              children: [
                                EpisodeStoryTab(
                                  episode: widget.episode,
                                  story: _story,
                                  isLoading: _isStoryLoading,
                                  error: _storyError,
                                  onUpdate: _updateStory,
                                  onRetry: _loadStory,
                                ),
                                EpisodeScreenplayTab(
                                  episode: widget.episode,
                                  scenes: _scenes,
                                  isLoading: _isScreenplayLoading,
                                  error: _screenplayError,
                                  onGenerate: _handleScreenplayGenerated,
                                  onRetry: _loadScreenplay,
                                  onClear: _handleScreenplayCleared,
                                ),
                                const EpisodeSnapshotsTab(),
                                const EpisodeShortsTab(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Desktop: Left sidebar menu (icon-only on small screens)
                          Container(
                            width: isSmallScreen ? 64 : (isTablet ? 200 : 240),
                            decoration: BoxDecoration(
                              color: AppColors.sidebar,
                              border: Border(
                                right: BorderSide(color: AppColors.primary.withValues(alpha:0.08)),
                              ),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.only(top: 16),
                              children: List.generate(_tabs.length, (index) {
                                final tab = _tabs[index];
                                return _SidebarTab(
                                  icon: tab.icon,
                                  activeIcon: tab.activeIcon,
                                  label: tab.label,
                                  isSelected: _selectedTab == index,
                                  onTap: () => _onTabSelected(index),
                                  showLabel: !isSmallScreen,
                                );
                              }),
                            ),
                          ),
                          // Desktop: Right content area - horizontal scrollable pages
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              scrollDirection: Axis.horizontal,
                              children: [
                                EpisodeStoryTab(
                                  episode: widget.episode,
                                  story: _story,
                                  isLoading: _isStoryLoading,
                                  error: _storyError,
                                  onUpdate: _updateStory,
                                  onRetry: _loadStory,
                                ),
                                EpisodeScreenplayTab(
                                  episode: widget.episode,
                                  scenes: _scenes,
                                  isLoading: _isScreenplayLoading,
                                  error: _screenplayError,
                                  onGenerate: _handleScreenplayGenerated,
                                  onRetry: _loadScreenplay,
                                  onClear: _handleScreenplayCleared,
                                ),
                                const EpisodeSnapshotsTab(),
                                const EpisodeShortsTab(),
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

}

class _MobileTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
  final bool showLabel;

  const _SidebarTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showLabel = true,
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
                  )
                : Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    color: widget.isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

