import 'package:flutter/material.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeScreenplayTab extends StatelessWidget {
  const EpisodeScreenplayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageTopBar(title: 'Screenplay'),
        Expanded(
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


