import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/episode.dart';
import '../core/theme/app_colors.dart';
import '../widgets/page_top_bar.dart';

class EpisodeDetailPage extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailPage({super.key, required this.episode});

  @override
  State<EpisodeDetailPage> createState() => _EpisodeDetailPageState();
}

class _EpisodeDetailPageState extends State<EpisodeDetailPage> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();
  final TextEditingController _storyController = TextEditingController();
  bool _isStoryEditMode = false;
  String _savedStory = '';

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: 'Story'),
    _TabItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Screenplay'),
    _TabItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Snapshots'),
    _TabItem(icon: Icons.movie_outlined, activeIcon: Icons.movie, label: 'Shorts'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  void _saveStory() {
    setState(() {
      _savedStory = _storyController.text;
      _isStoryEditMode = false;
    });
    // TODO: API integration - save story to backend
  }

  void _cancelStoryEdit() {
    setState(() {
      _storyController.text = _savedStory;
      _isStoryEditMode = false;
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
                    bottom: BorderSide(color: AppColors.primary.withOpacity(0.06)),
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
                          right: BorderSide(color: AppColors.primary.withOpacity(0.08)),
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
    return Column(
      children: [
        PageTopBar(
          title: 'Story',
          actions: _isStoryEditMode
              ? [
                  TextButton(
                    onPressed: _cancelStoryEdit,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                    onPressed: () {
                      setState(() {
                        _isStoryEditMode = true;
                        _storyController.text = _savedStory;
                      });
                    },
                    tooltip: 'Edit story',
                  ),
                ],
        ),
        // Story content area
        Expanded(
          child: _isStoryEditMode ? _buildStoryEditor() : _buildStoryView(),
        ),
      ],
    );
  }

  Widget _buildStoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _savedStory.isEmpty
          ? _buildEmptyState('Story content', Icons.auto_stories_outlined)
          : Text(
              _savedStory,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.8,
              ),
            ),
    );
  }

  Widget _buildStoryEditor() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: TextField(
        controller: _storyController,
        autofocus: true,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.8,
        ),
        decoration: InputDecoration(
          hintText: 'Write your story here...',
          hintStyle: TextStyle(
            color: AppColors.textMuted.withOpacity(0.5),
            fontSize: 15,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildScreenplay() {
    return Column(
      children: [
        const PageTopBar(title: 'Screenplay'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildEmptyState('Screenplay content', Icons.description_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshots() {
    return Column(
      children: [
        const PageTopBar(title: 'Snapshots'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildEmptyState('Snapshots', Icons.camera_alt_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildShorts() {
    return Column(
      children: [
        const PageTopBar(title: 'Shorts'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _buildEmptyState('Shorts', Icons.movie_outlined),
          ),
        ),
      ],
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

