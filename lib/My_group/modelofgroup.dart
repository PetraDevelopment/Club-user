class GroupModel {
  final String? adminId;
  final String? teamId;
  final String? name;
  final String? phone;
  final String? profileImage;

  GroupModel({
    required this.adminId,
    required this.teamId,
    required this.name,
    required this.phone,
    required this.profileImage,
  });


  // Factory constructor to create an instance from a map
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      adminId: map['AdminId'],
      teamId:map['TeamId']??false,
      name: map['name'] ?? '',  // Get AdminId directly from the map
      phone:map['phone'],
      profileImage: map['profile_image'],

    );
  }

  // Method to convert the instance to

  @override
  String toString() {
    return 'GroupModel(name: $name, phone: $phone, adminId: $adminId),TeamId: $teamId, photo: $profileImage';
  }
}