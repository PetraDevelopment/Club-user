class User1 {
  // Assuming these are the properties of your User class
  String? phoneNumber;
  String? name;

  String?img;
  // Constructor
  User1({this.phoneNumber, this.name, this.img});

  // fromMap method to create a User object from a Map
  factory User1.fromMap(Map<String, dynamic> map) {
    return User1(
      phoneNumber: map['phone'],
      img:map['profile_image'],
      name: map['name'],

    );
  }

  // toString method to print the User object
  @override
  String toString() {
    return 'User(phoneNumber: $phoneNumber, name: $name,img: $img)';
  }
}