enum SubscriptionTier { free, proMonthly, proYearly, team }

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final SubscriptionTier tier;
  final int credits;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.tier = SubscriptionTier.free,
    this.credits = 15,
  });

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    SubscriptionTier? tier,
    int? credits,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tier: tier ?? this.tier,
      credits: credits ?? this.credits,
    );
  }

  bool get isPro => tier != SubscriptionTier.free;
}
