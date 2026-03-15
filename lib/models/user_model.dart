class UserModel {
  final String name;
  final String email;
  final String userId;
  final String membershipId;
  final String memberSince;
  final String subscriptionStatus;
  final int reportCount;

  UserModel({
    required this.name,
    required this.email,
    required this.userId,
    required this.membershipId,
    required this.memberSince,
    required this.subscriptionStatus,
    required this.reportCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // id can be int or string depending on DB; toString() handles both
      userId: json['id']?.toString() ?? '',

      // Matches your Node.js 'full_name' key
      name: json['full_name'] ?? 'User',

      email: json['email'] ?? '',

      membershipId: json['membership_id'] ?? 'KES-0000',

      // Fallback to current date if backend doesn't provide created_at
      memberSince: json['created_at'] ?? DateTime.now().toIso8601String(),

      subscriptionStatus: json['subscription_status'] ?? 'free',

      // Ensures the value is treated as an integer even if it arrives as a string
      reportCount: json['free_pdf_count'] is int
          ? json['free_pdf_count']
          : int.tryParse(json['free_pdf_count']?.toString() ?? '0') ?? 0,
    );
  }

  // Modified to allow updating more fields if needed
  UserModel copyWith({
    String? name,
    String? email,
    String? subscriptionStatus,
    int? reportCount,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      userId: this.userId,
      membershipId: this.membershipId,
      memberSince: this.memberSince,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  // Added a toMap method—useful if you ever need to save user data locally in a DB
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'full_name': name,
      'email': email,
      'membership_id': membershipId,
      'created_at': memberSince,
      'subscription_status': subscriptionStatus,
      'free_pdf_count': reportCount,
    };
  }
}
