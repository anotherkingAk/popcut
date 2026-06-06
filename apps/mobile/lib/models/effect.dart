class Effect {
  final String id;
  final String name;
  final String category;
  final String iconData;
  final bool isPremium;

  Effect({
    required this.id,
    required this.name,
    required this.category,
    this.iconData = 'auto_awesome',
    this.isPremium = false,
  });
}

class EffectParameter {
  final String name;
  final double min;
  final double max;
  final double defaultValue;
  final double step;

  EffectParameter({
    required this.name,
    this.min = -100,
    this.max = 100,
    this.defaultValue = 0,
    this.step = 1,
  });
}
