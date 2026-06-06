enum AiToolType {
  captions,
  voiceClone,
  musicGenerator,
  textToVideo,
  thumbnail,
  enhance,
}

class AiTool {
  final AiToolType type;
  final String name;
  final String subtitle;
  final String iconData;
  final int colorValue;

  AiTool({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.iconData,
    required this.colorValue,
  });
}

class AiGenerationResult {
  final String id;
  final AiToolType toolType;
  final String label;
  final DateTime createdAt;
  final String? filePath;

  AiGenerationResult({
    required this.id,
    required this.toolType,
    required this.label,
    DateTime? createdAt,
    this.filePath,
  }) : createdAt = createdAt ?? DateTime.now();
}
