class AddbookingModel {
  String? iid;
  String? Name;
  bool?acceptorcancle;
  String? phoneCommunication;
  String? dateofBooking ;
  String?Day_of_booking;
  List<String>? timeofBooking = [];
  bool? rentTheBall;
  List<String>? availableTime = [];
  List<String>? availableDate = [];
  List<String>? selectedTimes = []; // Add this field to track selected times
  // List<String>? notavailable; // Ensure this matches your expected field name
  String? AdminId;
  String? groundID;
  AddbookingModel({
    this.Name,
    this.phoneCommunication,
    this.dateofBooking,
    this.timeofBooking,
    this.rentTheBall,
    this.acceptorcancle,
    this.availableTime,
    // this.notavailable,
    this.Day_of_booking,
    this.availableDate,
    this.selectedTimes,
    this.iid,
    this.AdminId,
    this.groundID,
  });

  // Factory constructor to create an instance from a map
  factory AddbookingModel.fromMap(Map<String, dynamic> map) {
    return AddbookingModel(
      iid: '',
      acceptorcancle:map['acceptorcancle']??false,
      AdminId: map['AdminId'] ?? '',  // Get AdminId directly from the map
      groundID:map['groundID'],
      Name: map['Name'],
      phoneCommunication: map['phoneCommunication'],
      dateofBooking: map['dateofBooking'],
      timeofBooking: (map['timeofBooking'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      rentTheBall: map['Rent_the_ball'],
      availableTime: (map['availableTime'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      availableDate: (map['availableDate'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      selectedTimes: (map['selectedTimes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      // notavailable: (map['not_available'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ?? [],
      Day_of_booking: map['Day_of_booking'],

    );
  }

  // Method to convert the instance to a map
  Map<String, dynamic> toMap() {
    return {
      'AdminId': AdminId,  // Add AdminId to the map
      'groundID':groundID,
      'Name': Name,
      'acceptorcancle':false,
      'Day_of_booking':Day_of_booking,
      'phoneCommunication': phoneCommunication,
      'dateofBooking': dateofBooking,
      'timeofBooking': timeofBooking?.isNotEmpty == true ? timeofBooking : [],
      'Rent_the_ball': rentTheBall,
      'availableTime': availableTime?.isNotEmpty == true ? availableTime : [],
      // 'not_available': notavailable?.isNotEmpty == true ? notavailable : [],
      'availableDate': availableDate?.isNotEmpty == true ? availableDate : [],
      'selectedTimes': selectedTimes?.isNotEmpty == true ? selectedTimes : [], // Include this
      'notavailable': availableDate?.isNotEmpty == true ? availableDate : [],

    };
  }

  @override
  String toString() {
    return 'AddbookingModel(name: $Name, phoneCommunication: $phoneCommunication, dateofBooking: $dateofBooking, timeofBooking: $timeofBooking, rentTheBall: $rentTheBall, availableTime: $availableTime, availableDate: $availableDate,selectedTimes: $selectedTimes,adminId: $AdminId,groundID:$groundID,acceptorcancle:$acceptorcancle)';
  }
}