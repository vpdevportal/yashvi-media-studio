import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/project.dart';
import '../core/services/api_service.dart';
import '../core/theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await _apiService.getProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(
        onProjectCreated: (project) {
          setState(() {
            _projects.insert(0, project);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _showCreateDialog,
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): _loadProjects,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              Sidebar(
                selectedIndex: _selectedNavIndex,
                onItemSelected: (index) {
                  setState(() => _selectedNavIndex = index);
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    TopBar(
                      title: 'Projects',
                      onRefresh: _loadProjects,
                      onAdd: _showCreateDialog,
                      addLabel: 'New Project',
                    ),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load projects',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _loadProjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.movie_creation_outlined,
                color: AppColors.primary.withValues(alpha: 0.5),
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No projects yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to get started',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showCreateDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create Project',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'or press Ctrl+N',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallScreen = screenWidth < 1200;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : (isSmallScreen ? 16 : 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards - horizontal scroll on small screens
          isSmallScreen
              ? SizedBox(
                  height: isMobile ? 100 : 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
                    children: [
                      _StatCard(
                        icon: Icons.folder,
                        label: 'Total Projects',
                        value: _projects.length.toString(),
                        color: AppColors.primary,
                        isMobile: isMobile,
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      _StatCard(
                        icon: Icons.play_circle_outline,
                        label: 'In Progress',
                        value: _projects
                            .where((p) => p.status == 'in_progress')
                            .length
                            .toString(),
                        color: AppColors.secondary,
                        isMobile: isMobile,
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      _StatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        value: _projects
                            .where((p) => p.status == 'completed')
                            .length
                            .toString(),
                        color: AppColors.success,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    _StatCard(
                      icon: Icons.folder,
                      label: 'Total Projects',
                      value: _projects.length.toString(),
                      color: AppColors.primary,
                      isMobile: false,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.play_circle_outline,
                      label: 'In Progress',
                      value: _projects
                          .where((p) => p.status == 'in_progress')
                          .length
                          .toString(),
                      color: AppColors.secondary,
                      isMobile: false,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Completed',
                      value: _projects
                          .where((p) => p.status == 'completed')
                          .length
                          .toString(),
                      color: AppColors.success,
                      isMobile: false,
                    ),
                  ],
                ),
          SizedBox(height: isMobile ? 20 : 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Projects',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${_projects.length} projects',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Grid view - use shrinkWrap on mobile to prevent overflow
          isMobile
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(
                      project: _projects[index],
                      onDelete: () async {
                        try {
                          await _apiService.deleteProject(_projects[index].id);
                          setState(() {
                            _projects.removeAt(index);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete project')),
                          );
                        }
                      },
                    );
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isSmallScreen ? 300 : 380,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: isSmallScreen ? 12 : 20,
                    mainAxisSpacing: isSmallScreen ? 12 : 20,
                  ),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    return ProjectCard(
                      project: _projects[index],
                      onDelete: () async {
                        try {
                          await _apiService.deleteProject(_projects[index].id);
                          setState(() {
                            _projects.removeAt(index);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete project')),
                          );
                        }
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 36 : 44,
            height: isMobile ? 36 : 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isMobile ? 18 : 22),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: isMobile ? 11 : 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

