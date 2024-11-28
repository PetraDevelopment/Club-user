class AddPlayGroundModel {
  String? playgroundName;
  String? playType;
  String? address;
  String? logoimge;
  String? location;
  String? phoneCommunication;
  String? length;
  String? width;
  String? img;
  List<String>? bookTypes;
  List<String>? days;
  String? cost;
  List<String>? availableFacilities = [];
  String? notes;
String? day;
String? day2;
String? time1 ;
String? time2;

  AddPlayGroundModel({
    this.playgroundName,
    this.playType,
    this.address,
    this.logoimge,
    this.location,
    this.phoneCommunication,
    this.img,
    this.length,
    this.width,
    this.availableFacilities,
    this.notes,
    this.day,
    this.day2,
    this.time1,
    this.time2,
  });

  factory AddPlayGroundModel.fromMap(Map<String, dynamic> map) {
    return AddPlayGroundModel(
      playgroundName: map['groundName'],
      playType: map['playType'],
      address: map['address'],
      location: map['location'],
      logoimge: map['LogoImg'],
      phoneCommunication: map['phone'],
      length: map['length'],
      width: map['width'],
      img: map['img'],
      availableFacilities: (map['availableFacilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'LogoImg':logoimge,
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
    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playgroundName, playType: $playType, address: $address, location: $location, phoneCommunication: $phoneCommunication, length: $length, width: $width, img: $img, bookTypes: $bookTypes, days: $days,  cost: $cost, availableFacilities: $availableFacilities, notes: $notes ,LogoImg:$logoimge)';
  }
}
