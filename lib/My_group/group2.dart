class GroupModel2 {
  final String? adminId;
  final String? name;
  final String? phone;
  final String? profileImage;

  GroupModel2({
    required this.adminId,
    required this.name,
    required this.phone,
    required this.profileImage,
  });

  factory GroupModel2.fromMap(Map<String, dynamic> map) {
    return GroupModel2(
      adminId: map['AdminId'],

      name: map['name'] ?? '',
      phone:map['phone'],
      profileImage: map['profile_image'],

    );
  }
 @override
  String toString() {
    return 'GroupModel(name: $name, phone: $phone, adminId: $adminId), photo: $profileImage';
  }
}