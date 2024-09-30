class AddPlayGroundModel2 {
  String? playgroundName;
  String? playType;
  String? address;
  String? location;
  String? phoneCommunication;
  String? length;
  String? width;
  String? img;
  String? bookType;
  String? day;
  String? time1;
  String? time2;
  String? secondBookType;
  String? day2;
  String? time3;
  String? time4;
  String? cost;
  bool? halfHourBook;
  List<String>? availableFacilities = [];
  String? notes;

  AddPlayGroundModel2({
    this.playgroundName,
    this.playType,
    this.address,
    this.location,
    this.phoneCommunication,
    this.img,
    this.length,
    this.width,
    this.bookType,
    this.day,
    this.time1,
    this.time2,
    this.secondBookType,
    this.day2,
    this.time3,
    this.time4,
    this.cost,
    this.halfHourBook,
    this.availableFacilities,
    this.notes,
  });

  factory AddPlayGroundModel2.fromMap(Map<String, dynamic> map) {
    return AddPlayGroundModel2(
      playgroundName: map['groundName'],
      playType: map['playType'],
      address: map['address'],
      location: map['location'],
      phoneCommunication: map['phone'],
      length: map['length'],
      width: map['width'],
      img: map['img'],
      bookType: map['bookType'],
      day: map['day'],
      time1: map['time1'],
      time2: map['time2'],
      secondBookType: map['secondBookType'],
      day2: map['day2'],
      time3: map['time3'],
      time4: map['time4'],
      cost: map['cost'],
      // Correctly handling halfHourBook to ensure it's a boolean

      // Safely handling availableFacilities list to avoid null issues
      availableFacilities: (map['availableFacilities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      notes: map['notes'],
    );
  }

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
      'bookType': bookType,
      'day': day,
      'time1': time1,
      'time2': time2,
      'secondBookType': secondBookType,
      'day2': day2,
      'time3': time3,
      'time4': time4,
      'cost': cost,
      'halfHourBook': halfHourBook ?? false, // Defaults to false if null
      'availableFacilities': availableFacilities?.isNotEmpty == true ? availableFacilities : [],
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playgroundName, playType: $playType, address: $address, location: $location, phoneCommunication: $phoneCommunication, length: $length, width: $width, img: $img, bookType: $bookType, day: $day, time1: $time1, time2: $time2, secondBookType: $secondBookType, day2: $day2, time3: $time3, time4: $time4, cost: $cost, halfHourBook: $halfHourBook, availableFacilities: $availableFacilities, notes: $notes)';
  }
}
