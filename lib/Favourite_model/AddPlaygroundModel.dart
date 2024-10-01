class Favouritemodel {
  String?playground_id;
  String?id;

  String? img;
  String? playground_name;
  String? user_phone;

  Favouritemodel({
  this.playground_id,this.img,this.playground_name,this.user_phone,this.id
  });

  // Factory constructor to create the model from a Map
  factory Favouritemodel.fromMap(Map<String, dynamic> map) {
    return Favouritemodel(
      img: map['img'],
      id:'',
      playground_id: map['playground_id'],
      user_phone: map['user_phone'],
      playground_name: map['playground_name'],


    );
  }
  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'playground_name': playground_name,
      'user_phone': user_phone,
      'playground_id': playground_id,
      'img': img,

    };
  }
  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playground_name, user_phone: $user_phone, playground_id: $playground_id,  img: $img,)';
  }
}

class BookTypeEntry {
  String? bookType;
  num? cost;
  num? costPerHour;
  String? day;
  String? time;

  BookTypeEntry({
    this.bookType,
    this.cost,
    this.costPerHour,
    this.day,
    this.time,
  });

  factory BookTypeEntry.fromMap(Map<String, dynamic> map) {
    return BookTypeEntry(
      bookType: map['BookType'],
      cost: map['cost'],
      costPerHour: map['costperhour'],
      day: map['day'] ?? " ",
      time: map['time'] ?? " ",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'BookType': bookType,
      'cost': cost,
      'costperhour': costPerHour,
      'day': day,
      'time': time,
    };
  }

  @override
  String toString() {
    return 'BookTypeEntry(bookType: $bookType, cost: $cost, costPerHour: $costPerHour, day: $day, time: $time)';
  }
}
