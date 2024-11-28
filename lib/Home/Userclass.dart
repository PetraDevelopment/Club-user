class User1 {
  String? phoneNumber;
  String? name;
  String?fcm;
  String?img;

  User1({this.phoneNumber, this.name, this.img,this.fcm});

  factory User1.fromMap(Map<String, dynamic> map) {
    return User1(
      phoneNumber: map['phone'],
      img:map['profile_image'],
      name: map['name'],
      fcm:map['fcm'],
    );
  }

  @override
  String toString() {
    return 'User(phoneNumber: $phoneNumber, name: $name,img: $img,fcm: $fcm)';
  }
}