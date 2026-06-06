enum PaymentProvider { razorpay, googlePlay, applePay }

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String priceLabel;
  final String period;
  final List<String> features;
  final bool isPopular;
  final bool isTeam;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.priceLabel,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.isTeam = false,
  });
}
