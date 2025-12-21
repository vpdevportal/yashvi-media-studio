class Scene {
  final String id;
  final String screenplayId;
  final int sceneNumber;
  final String title;
  final String location;
  final String timeOfDay;
  final List<String> characters;
  final String action;
  final List<DialogueLine> dialogue;
  final String visualNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Scene({
    required this.id,
    required this.screenplayId,
    required this.sceneNumber,
    required this.title,
    required this.location,
    required this.timeOfDay,
    required this.characters,
    required this.action,
    required this.dialogue,
    required this.visualNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'],
      screenplayId: json['screenplay_id'],
      sceneNumber: json['scene_number'],
      title: json['title'],
      location: json['location'],
      timeOfDay: json['time_of_day'],
      characters: List<String>.from(json['characters']),
      action: json['action'],
      dialogue: (json['dialogue'] as List)
          .map((item) => DialogueLine.fromJson(item as Map<String, dynamic>))
          .toList(),
      visualNotes: json['visual_notes'],
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
      'location': location,
      'time_of_day': timeOfDay,
      'characters': characters,
      'action': action,
      'dialogue': dialogue.map((d) => d.toJson()).toList(),
      'visual_notes': visualNotes,
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

