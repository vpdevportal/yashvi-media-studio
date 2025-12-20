import 'package:flutter/material.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatelessWidget {
  const EpisodeScreenplayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTopBar(title: 'Screenplay'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: const EpisodeEmptyState(
              title: 'Screenplay content',
              icon: Icons.description_outlined,
            ),
          ),
        ),
      ],
    );
  }
}


