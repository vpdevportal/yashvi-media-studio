import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/episode.dart';
import '../../core/models/scene.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/extensions/media_query_extensions.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatefulWidget {
  final Episode episode;
  final List<Scene>? scenes;
  final bool isLoading;
  final String? error;
  final Function(List<Scene>)? onGenerate;
  final VoidCallback? onRetry;
  final VoidCallback? onClear;

  const EpisodeScreenplayTab({
    super.key,
    required this.episode,
    this.scenes,
    this.isLoading = false,
    this.error,
    this.onGenerate,
    this.onRetry,
    this.onClear,
  });

  @override
  State<EpisodeScreenplayTab> createState() => _EpisodeScreenplayTabState();
}

class _EpisodeScreenplayTabState extends State<EpisodeScreenplayTab> {
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;
  bool _isClearing = false;

  Future<void> _handleClear() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Screenplay'),
        content: const Text('Are you sure you want to clear all screenplays for this episode? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await _apiService.clearScreenplays(widget.episode.id);
      setState(() {
        _isClearing = false;
      });
      // Clear scenes by calling onClear callback or onGenerate with empty list
      if (widget.onClear != null) {
        widget.onClear!();
      } else if (widget.onGenerate != null) {
        widget.onGenerate!([]);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenplay cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isClearing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGenerate() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final scenes = await _apiService.generateScreenplay(widget.episode.id);
      setState(() {
        _isGenerating = false;
      });
      if (widget.onGenerate != null) {
        widget.onGenerate!(scenes);
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        PageTopBar(
          title: 'Screenplay',
          actions: context.isMobile
              ? [
                  // Mobile: Stack buttons vertically or use icon buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: (_isClearing || _isGenerating || widget.scenes == null || widget.scenes!.isEmpty)
                            ? null
                            : _handleClear,
                        icon: _isClearing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red,
                        tooltip: 'Clear',
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: (_isGenerating || _isClearing) ? null : _handleGenerate,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 20),
                        color: AppColors.primary,
                        tooltip: _isGenerating ? 'Generating...' : 'Generate',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ]
              : [
                  // Desktop: Full buttons with labels
                  OutlinedButton.icon(
                    onPressed: (_isClearing || _isGenerating || widget.scenes == null || widget.scenes!.isEmpty)
                        ? null
                        : _handleClear,
                    icon: _isClearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.delete_outline, size: 18),
                    label: Text(_isClearing ? 'Clearing...' : 'Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: (_isGenerating || _isClearing) ? null : _handleGenerate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : widget.error != null
                  ? Center(
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
                          if (widget.onRetry != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: widget.onRetry,
                              child: const Text('Retry'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : (widget.scenes == null || widget.scenes!.isEmpty)
                      ? SingleChildScrollView(
                          padding: context.responsivePadding,
                          child: const EpisodeEmptyState(
                            title: 'No screenplay generated yet',
                            icon: Icons.description_outlined,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: context.responsivePadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: context.isMobile ? 16 : 24),
                              Text(
                                'Scenes (${widget.scenes!.length})',
                                style: TextStyle(
                                  fontSize: context.isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: context.isMobile ? 12 : 16),
                              ...widget.scenes!.map((scene) => _buildSceneCard(scene)),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildSceneCard(Scene scene) {
    return Builder(
      builder: (context) {
        return Card(
          margin: EdgeInsets.only(bottom: context.isMobile ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(context.isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.isMobile ? 10 : 12,
                        vertical: context.isMobile ? 5 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Scene ${scene.sceneNumber}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                    SizedBox(width: context.isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        scene.title,
                        style: TextStyle(
                          fontSize: context.isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.isMobile ? 10 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: context.isMobile ? 14 : 16,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: context.isMobile ? 4 : 4),
                    Text(
                      '${scene.durationSeconds}s',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.isMobile ? 12 : 14,
                      ),
                    ),
                  ],
                ),
                if (scene.characters.isNotEmpty) ...[
                  SizedBox(height: context.isMobile ? 10 : 12),
                  Wrap(
                    spacing: context.isMobile ? 6 : 8,
                    children: scene.characters.map((character) {
                      return Chip(
                        label: Text(character),
                        labelStyle: TextStyle(fontSize: context.isMobile ? 11 : 12),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
                if (scene.dialogue.isNotEmpty) ...[
                  SizedBox(height: context.isMobile ? 12 : 16),
                  Text(
                    'Dialogue',
                    style: TextStyle(
                      fontSize: context.isMobile ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: context.isMobile ? 6 : 8),
                  ...scene.dialogue.map((dialogue) => Padding(
                        padding: EdgeInsets.only(bottom: context.isMobile ? 6 : 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dialogue.character}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.isMobile ? 13 : 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                dialogue.line,
                                style: TextStyle(
                                  fontSize: context.isMobile ? 13 : 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                SizedBox(height: context.isMobile ? 12 : 16),
                Container(
                  padding: EdgeInsets.all(context.isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.movie_creation,
                            size: context.isMobile ? 14 : 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: context.isMobile ? 4 : 4),
                          Expanded(
                            child: Text(
                              'Video Generation Prompt',
                              style: TextStyle(
                                fontSize: context.isMobile ? 11 : 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(text: scene.prompt));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Prompt copied to clipboard'),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.copy,
                                  size: context.isMobile ? 14 : 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.isMobile ? 6 : 8),
                      Text(
                        scene.prompt,
                        style: TextStyle(
                          fontSize: context.isMobile ? 12 : 13,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


