class Template {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? thumbnailUrl;
  final bool isPremium;
  final int durationSeconds;
  final int usageCount;

  Template({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.thumbnailUrl,
    this.isPremium = false,
    this.durationSeconds = 15,
    this.usageCount = 0,
  });
}
