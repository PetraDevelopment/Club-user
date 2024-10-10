class Ratemodel {
  String? img;
  String? name;
  String? phone;
  String? playgroundIdstars;
  List<bool>? rate;
  Ratemodel({
    this.img,
    this.name,
    this.phone,
    this.playgroundIdstars,
    this.rate,
  });

  // Factory constructor to create the model from a Map
  factory Ratemodel.fromMap(Map<String, dynamic> map) {
    return Ratemodel(
      img: map['img'],
      name: map['name'],
      phone: map['phone'],
      playgroundIdstars: map['playground_idstars'] ?? '',
      rate: map['rate']?.cast<bool>() ?? [],

    );
  }

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'playground_name': name,
      'img': img,
      'phone':phone,
      'playground_idstars':playgroundIdstars,
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $name, user_phone: $phone, playground_id: $playgroundIdstars,  img: $img,)';
  }
}