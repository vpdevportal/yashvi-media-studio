import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import '../../core/models/scene.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatefulWidget {
  final Episode episode;
  final List<Scene>? scenes;
  final bool isLoading;
  final String? error;
  final Function(List<Scene>)? onGenerate;
  final VoidCallback? onRetry;

  const EpisodeScreenplayTab({
    super.key,
    required this.episode,
    this.scenes,
    this.isLoading = false,
    this.error,
    this.onGenerate,
    this.onRetry,
  });

  @override
  State<EpisodeScreenplayTab> createState() => _EpisodeScreenplayTabState();
}

class _EpisodeScreenplayTabState extends State<EpisodeScreenplayTab> {
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;

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
          actions: [
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _handleGenerate,
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
                      ? const SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
                          child: EpisodeEmptyState(
                            title: 'No screenplay generated yet',
                            icon: Icons.description_outlined,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                'Scenes (${widget.scenes!.length})',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...widget.scenes!.map((scene) => _buildSceneCard(scene)),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildSceneCard(Scene scene) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Scene ${scene.sceneNumber}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    scene.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  scene.location,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  scene.timeOfDay,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
            if (scene.characters.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: scene.characters.map((character) {
                  return Chip(
                    label: Text(character),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Action',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scene.action,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (scene.dialogue.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Dialogue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              ...scene.dialogue.map((dialogue) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dialogue.character}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dialogue.line,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: AppColors.textMuted),
                      SizedBox(width: 4),
                      Text(
                        'Visual Notes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scene.visualNotes,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


