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
          body: Column(
            children: [
              // Full-width navbar
              Container(
                height: 64,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.15),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.episode.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content area with left menu and right content
              Expanded(
                child: Row(
                  children: [
                    // Left sidebar menu
                    Container(
                      width: 240,
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
                          );
                        }),
                      ),
                    ),
                    // Right content area - horizontal scrollable pages
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
                ? AppColors.primary.withValues(alpha:0.12)
                : _isHovered
                    ? AppColors.surfaceElevated.withValues(alpha:0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha:0.25))
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

