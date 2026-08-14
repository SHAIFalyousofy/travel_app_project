class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? profileImageUrl;

  UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      email: json['email'] ?? 'N/A',
      name: json['name'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  // دالة مساعدة لتحويل الكائن إلى JSON لإرساله إلى الـ API
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
    };
  }
}
