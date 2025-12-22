import 'package:flutter/material.dart';
import '../core/models/project.dart';
import '../core/theme/app_colors.dart';
import '../pages/project_detail_page.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (project.status) {
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'archived':
        return AppColors.textMuted;
      default:
        return AppColors.secondary;
    }
  }

  String _getStatusLabel() {
    switch (project.status) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'archived':
        return 'Archived';
      default:
        return 'Draft';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailPage(project: project),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textMuted,
                        size: isMobile ? 20 : 24,
                      ),
                      color: AppColors.surface,
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 12),
                if (project.description != null && project.description!.isNotEmpty)
                  Text(
                    project.description!,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: isMobile ? 13 : 14,
                    ),
                    maxLines: isMobile ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: isMobile ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 12,
                    vertical: isMobile ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

