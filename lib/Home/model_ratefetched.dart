class Rate_fetched {
  List<String>? img;
  String? name;
  String? phone;
  String? playgroundIdstars;
  List<bool>? rate;

  Rate_fetched({
    this.img,
    this.name,
    this.phone,
    this.playgroundIdstars,
    this.rate,
  });

  // Factory constructor to create the model from a Map
  factory Rate_fetched.fromMap(Map<String, dynamic> map) {
    return Rate_fetched(
      img: List<String>.from(map['img'] ?? []), // Convert to a list of strings
      name: map['name'],
      phone: map['phone'],
      playgroundIdstars: map['playground_idstars'] ?? '',
      rate: List<bool>.from(map['rate'] ?? []), // Convert to a list of booleans
    );
  }

  // Method to calculate the overall rating score
  int get totalRating => rate?.where((r) => r).length ?? 0;

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'playground_name': name,
      'img': img,
      'phone': phone,
      'playground_idstars': playgroundIdstars,
      'rate': rate,
    };
  }

  @override
  String toString() {
    return 'Ratemodel(playgroundName: $name, user_phone: $phone, playground_id: $playgroundIdstars, img: $img, totalRating: $totalRating)';
  }
}


