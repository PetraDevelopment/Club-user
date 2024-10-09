class Favouritemodel {
  String? playground_id;
  String? id;
  bool isfav; // Update this field to be a boolean field
  String? img;
  String? playground_name;
  String? user_phone;

  Favouritemodel({
    this.playground_id,
    this.img,
    this.playground_name,
    this.user_phone,
    this.id,
    this.isfav = false, // Initialize the isfav field to false
  });

  // Factory constructor to create the model from a Map
  factory Favouritemodel.fromMap(Map<String, dynamic> map) {
    return Favouritemodel(
      img: map['img'],
      isfav: map['is_favourite'] ?? false, // Update this line to handle null values
      id: '',
      playground_id: map['playground_id'],
      user_phone: map['user_phone'],
      playground_name: map['playground_name'],
    );
  }

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'playground_name': playground_name,
      'is_favourite': isfav,
      'user_phone': user_phone,
      'playground_id': playground_id,
      'img': img,
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playground_name, user_phone: $user_phone, playground_id: $playground_id,  img: $img,isfav: $isfav)';
  }
}