class Story {
  final String id;
  final String episodeId;
  final String? content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.id,
    required this.episodeId,
    this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      episodeId: json['episode_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode_id': episodeId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

