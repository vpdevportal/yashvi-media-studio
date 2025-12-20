import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatelessWidget {
  const EpisodeScreenplayTab({super.key});

  void _handleGenerate() {
    // TODO: Implement screenplay generation logic
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTopBar(
          title: 'Screenplay',
          actions: [
            ElevatedButton.icon(
              onPressed: _handleGenerate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const Expanded(
          child: SingleChildScrollView(
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


