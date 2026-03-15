class UserModel {
  final String name;
  final String email;
  final String userId;
  final String membershipId; // Added for your unique KES ID
  final String memberSince;
  final String subscriptionStatus; // Added to track 'free' or 'pro'
  final int reportCount; // Added to track the 1-report limit

  UserModel({
    required this.name,
    required this.email,
    required this.userId,
    required this.membershipId,
    required this.memberSince,
    required this.subscriptionStatus,
    required this.reportCount,
  });

  // This factory constructor takes the JSON from your Node.js response
  // and maps it to your Flutter variables.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'].toString(),
      // We map 'full_name' from the backend to 'name' in Flutter
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      membershipId: json['membership_id'] ?? 'N/A',
      memberSince: json['created_at'] ?? DateTime.now().toString(),
      subscriptionStatus: json['subscription_status'] ?? 'free',
      reportCount: json['free_pdf_count'] ?? 0,
    );
  }

  // Helpful for updating the UI after a subscription change
  UserModel copyWith({
    String? name,
    String? subscriptionStatus,
    int? reportCount,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: this.email,
      userId: this.userId,
      membershipId: this.membershipId,
      memberSince: this.memberSince,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}
