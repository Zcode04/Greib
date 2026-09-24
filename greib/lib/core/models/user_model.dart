class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String avatar;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar': avatar,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
        avatar: json['avatar'],
      );
}

class AppUserProfile {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String? address;
  final String? avatarUrl;
  final String membershipTier;
  final int loyaltyPoints;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.address,
    this.avatarUrl,
    this.membershipTier = 'regular',
    this.loyaltyPoints = 1250,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
        'address': address,
        'avatarUrl': avatarUrl,
        'membershipTier': membershipTier,
        'loyaltyPoints': loyaltyPoints,
      };

  factory AppUserProfile.fromJson(Map<String, dynamic> json) => AppUserProfile(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        avatarUrl: json['avatarUrl'],
        membershipTier: json['membershipTier'] ?? 'regular',
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
      );
}
