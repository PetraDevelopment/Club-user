class Ratemodel {
  List<String>? img;
  String? name;
  String? phone;
  int?totalrating;
  String? playgroundIdstars;
  List<bool>? rate;

  Ratemodel({
    this.img,
    this.name,
    this.totalrating,
    this.phone,
    this.playgroundIdstars,
    this.rate,
  });
  factory Ratemodel.fromMap(Map<String, dynamic> map) {
    return Ratemodel(
      img: List<String>.from(map['img'] ?? []), // Convert to a list of strings
      name: map['name'],
      phone: map['phone'],
      totalrating:map['totalrating'],
      playgroundIdstars: map['playground_idstars'] ?? '',
      rate: List<bool>.from(map['rate'] ?? []), // Convert to a list of booleans
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'playground_name': name,
      'img': img,
      'totalrating':totalrating,
      'phone': phone,
      'playground_idstars': playgroundIdstars,
      'rate': rate,
    };
  }

  @override
  String toString() {
    return 'Ratemodel(playgroundName: $name, user_phone: $phone, playground_id: $playgroundIdstars, img: $img,totalrating:$totalrating)';
  }
}
