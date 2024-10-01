class AddPlayGroundModel {
  String?id;
  bool?favourite;
  String? playgroundName;
  String? playType;
  String? address;
  String? location;
  String? phoneCommunication;
  String? length;
  String? width;
  String? img;
  List<String>? availableFacilities = [];
  String? notes;
  List<BookTypeEntry>? bookTypes;  // List of booking entries

  String? cost;

  AddPlayGroundModel({
    this.playgroundName,
    this.id,
    this.favourite,
    this.playType,
    this.address,
    this.location,
    this.phoneCommunication,
    this.length,
    this.width,
    this.img,
    this.availableFacilities,
    this.notes,
    this.bookTypes,
    this.cost,
  });

  // Factory constructor to create the model from a Map
  factory AddPlayGroundModel.fromMap(Map<String, dynamic> map) {
    return AddPlayGroundModel(
      id: '',
      favourite: false,
      playgroundName: map['groundName'],
      playType: map['playType'],
      address: map['address'],
      location: map['location'],
      phoneCommunication: map['phone'],
      length: map['length'],
      width: map['width'],
      img: map['img'],
      availableFacilities: (map['availableFacilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: map['notes'],
      bookTypes: (map['boooktybe']['entries'] as List<dynamic>?)
          ?.map((entry) => BookTypeEntry.fromMap(entry as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'groundName': playgroundName,
      'playType': playType,
      'address': address,
      'location': location,
      'phone': phoneCommunication,
      'length': length,
      'width': width,
      'img': img,
      'availableFacilities': availableFacilities?.isNotEmpty == true ? availableFacilities : [],
      'notes': notes,
      'boooktybe': {
        'entries': bookTypes?.map((entry) => entry.toMap()).toList() ?? [],
      },
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playgroundName, playType: $playType, address: $address, location: $location, phoneCommunication: $phoneCommunication, length: $length, width: $width, img: $img, availableFacilities: $availableFacilities, notes: $notes, bookTypes: $bookTypes)';
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
