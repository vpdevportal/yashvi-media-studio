class Episode {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final int episodeNumber;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Episode({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.episodeNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      projectId: json['project_id'],
      title: json['title'],
      description: json['description'],
      episodeNumber: json['episode_number'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'episode_number': episodeNumber,
      'status': status,
    };
  }
}

