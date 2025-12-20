import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeStoryTab extends StatefulWidget {
  final Episode episode;

  const EpisodeStoryTab({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeStoryTab> createState() => _EpisodeStoryTabState();
}

class _EpisodeStoryTabState extends State<EpisodeStoryTab> {
  final TextEditingController _storyController = TextEditingController();
  bool _isEditMode = false;
  String _savedStory = '';

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _savedStory = _storyController.text;
      _isEditMode = false;
    });
    // TODO: API integration - save story to backend
  }

  void _cancel() {
    setState(() {
      _storyController.text = _savedStory;
      _isEditMode = false;
    });
  }

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _storyController.text = _savedStory;
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
                    onPressed: _cancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
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
                    onPressed: _enterEditMode,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: _savedStory.isEmpty
          ? const EpisodeEmptyState(
              title: 'Story content',
              icon: Icons.auto_stories_outlined,
            )
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


