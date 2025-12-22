import 'package:flutter/material.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeShortsTab extends StatelessWidget {
  const EpisodeShortsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTopBar(title: 'Shorts'),
        Expanded(
          child: Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 768;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  0,
                  isMobile ? 16 : 32,
                  isMobile ? 16 : 32,
                ),
                child: const EpisodeEmptyState(
                  title: 'Shorts',
                  icon: Icons.movie_outlined,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


