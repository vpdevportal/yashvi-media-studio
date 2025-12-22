import 'package:flutter/material.dart';
import '../../core/extensions/media_query_extensions.dart';
import '../../widgets/page_top_bar.dart';
import 'episode_empty_state.dart';

class EpisodeSnapshotsTab extends StatelessWidget {
  const EpisodeSnapshotsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTopBar(title: 'Snapshots'),
        Expanded(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: const EpisodeEmptyState(
              title: 'Snapshots',
              icon: Icons.camera_alt_outlined,
            ),
          ),
        ),
      ],
    );
  }
}


