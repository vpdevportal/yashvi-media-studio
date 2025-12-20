import 'package:flutter/material.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeSnapshotsTab extends StatelessWidget {
  const EpisodeSnapshotsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageTopBar(title: 'Snapshots'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: EpisodeEmptyState(
              title: 'Snapshots',
              icon: Icons.camera_alt_outlined,
            ),
          ),
        ),
      ],
    );
  }
}


