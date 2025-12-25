class Scene {
  final String id;
  final String screenplayId;
  final int sceneNumber;
  final String title;
  final int durationSeconds;
  final List<String> characters;
  final List<DialogueLine> dialogue;
  final String prompt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Scene({
    required this.id,
    required this.screenplayId,
    required this.sceneNumber,
    required this.title,
    required this.durationSeconds,
    required this.characters,
    required this.dialogue,
    required this.prompt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      screenplayId: json['screenplay_id'],
      sceneNumber: json['scene_number'],
      title: json['title'],
      durationSeconds: json['duration_seconds'],
      characters: List<String>.from(json['characters']),
      dialogue: (json['dialogue'] as List)
          .map((item) => DialogueLine.fromJson(item as Map<String, dynamic>))
          .toList(),
      prompt: json['prompt'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'scene_number': sceneNumber,
      'title': title,
      'duration_seconds': durationSeconds,
      'characters': characters,
      'dialogue': dialogue.map((d) => d.toJson()).toList(),
      'prompt': prompt,
    };
  }
}

class DialogueLine {
  final String character;
  final String line;

  DialogueLine({
    required this.character,
    required this.line,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      character: json['character'],
      line: json['line'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'line': line,
    };
  }
}
