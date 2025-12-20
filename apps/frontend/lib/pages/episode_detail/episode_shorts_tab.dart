import 'package:flutter/material.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeShortsTab extends StatelessWidget {
  const EpisodeShortsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageTopBar(title: 'Shorts'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: EpisodeEmptyState(
              title: 'Shorts',
              icon: Icons.movie_outlined,
            ),
          ),
        ),
      ],
    );
  }
}


