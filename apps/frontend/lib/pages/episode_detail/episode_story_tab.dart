import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import '../../core/models/story.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeStoryTab extends StatefulWidget {
  final Episode episode;
  final Story? story;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String content) onUpdate;
  final VoidCallback onRetry;

  const EpisodeStoryTab({
    super.key,
    required this.episode,
    required this.story,
    required this.isLoading,
    this.error,
    required this.onUpdate,
    required this.onRetry,
  });

  @override
  State<EpisodeStoryTab> createState() => _EpisodeStoryTabState();
}

class _EpisodeStoryTabState extends State<EpisodeStoryTab> {
  final TextEditingController _storyController = TextEditingController();
  bool _isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _updateControllerFromStory();
  }

  @override
  void didUpdateWidget(EpisodeStoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story != widget.story && !_isEditMode) {
      _updateControllerFromStory();
    }
  }

  void _updateControllerFromStory() {
    _storyController.text = widget.story?.content ?? '';
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onUpdate(_storyController.text);
      setState(() {
        _isEditMode = false;
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancel() {
    setState(() {
      _storyController.text = widget.story?.content ?? '';
      _isEditMode = false;
    });
  }

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _storyController.text = widget.story?.content ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTopBar(
          title: 'Story',
          actions: _isEditMode
              ? [
                  TextButton(
                    onPressed: _isSaving ? null : _cancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                    onPressed: widget.isLoading ? null : _enterEditMode,
                    tooltip: 'Edit story',
                  ),
                ],
        ),
        Expanded(
          child: _isEditMode ? _buildEditor() : _buildView(),
        ),
      ],
    );
  }

  Widget _buildView() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.error!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final content = widget.story?.content;
    if (content == null || content.trim().isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: EpisodeEmptyState(
          title: 'Story content',
          icon: Icons.auto_stories_outlined,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
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
            color: AppColors.textMuted.withValues(alpha:0.5),
            fontSize: 15,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }
}


