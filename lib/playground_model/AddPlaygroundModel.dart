class AddPlayGroundModel {
  String? id;  // Optional ID for the playground
  String? playgroundName;
  String? playType;
  bool?favourite;
  String? address;
  String? location;
  String? phoneCommunication;
  String? length;
  String? width;
  List<String>? img;  // Changed from String? to List<String>?
  List<String>? availableFacilities = [];
  String? notes;
  List<BookTypeEntry>? bookTypes; // List of booking entries
  String? adminId;  // Renamed to follow Dart naming conventions
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
    this.img,  // Now accepts a list of images
    this.availableFacilities,
    this.notes,
    this.bookTypes,
    this.cost,
    this.adminId,  // Use the new name for consistency
  });

  // Factory constructor to create the model from a Map
  factory AddPlayGroundModel.fromMap(Map<String, dynamic> map) {
    return AddPlayGroundModel(
      id: map['id'] ?? '',  // Fetch the ID from the map
      adminId: map['AdminId'] ?? '',  // Get AdminId directly from the map
      playgroundName: map['groundName'],
      playType: map['playType'],
      address: map['address'],
      location: map['location'],
      phoneCommunication: map['phone'],
      favourite: false,
      length: map['length'],
      width: map['width'],
      img: map['img'] is String
          ? [map['img']] // If it's a string, convert it to a list with one element
          : (map['img'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],  // If it's a list, handle it normally
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
      'id': id,  // Include id in the map if needed
      'AdminId': adminId,  // Add AdminId to the map
      'groundName': playgroundName,
      'playType': playType,
      'address': address,
      'location': location,
      'phone': phoneCommunication,
      'length': length,
      'width': width,
      'img': img ?? [],  // Ensure it's an empty list if null
      'availableFacilities': availableFacilities?.isNotEmpty == true ? availableFacilities : [],
      'notes': notes,
      'boooktybe': {
        'entries': bookTypes?.map((entry) => entry.toMap()).toList() ?? [],
      },
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playgroundName, playType: $playType, address: $address, location: $location, phoneCommunication: $phoneCommunication, length: $length, width: $width, img: $img, availableFacilities: $availableFacilities, notes: $notes, bookTypes: $bookTypes, adminId: $adminId, id: $id,favourite: $favourite)';  // Updated to include img
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