import 'package:flutter/material.dart';
import '../../core/models/episode.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatefulWidget {
  final Episode episode;

  const EpisodeScreenplayTab({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeScreenplayTab> createState() => _EpisodeScreenplayTabState();
}

class _EpisodeScreenplayTabState extends State<EpisodeScreenplayTab> {
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;
  String? _error;

  Future<void> _handleGenerate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      await _apiService.generateScreenplay(widget.episode.id);
      setState(() {
        _isGenerating = false;
      });
      // TODO: Handle generated screenplay data
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isGenerating = false;
      });
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
          child: _error != null
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
                        _error!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : const SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: EpisodeEmptyState(
                    title: 'Screenplay content',
                    icon: Icons.description_outlined,
                  ),
                ),
        ),
      ],
    );
  }
}


