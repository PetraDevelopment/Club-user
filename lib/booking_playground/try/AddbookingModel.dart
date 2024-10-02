class AddbookingModel {
  String? Name;
  String? phoneCommunication;
  String? dateofBooking ;
  String?Day_of_booking;
  List<String>? timeofBooking = [];
  bool? rentTheBall;
  List<String>? availableTime = [];
  List<String>? availableDate = [];
  List<String>? selectedTimes = []; // Add this field to track selected times
  List<String>? notavailable; // Ensure this matches your expected field name
  AddbookingModel({
    this.Name,
    this.phoneCommunication,
    this.dateofBooking,
    this.timeofBooking,
    this.rentTheBall,
    this.availableTime,
    this.notavailable,
    this.Day_of_booking,
    this.availableDate,
    this.selectedTimes,
  });

  // Factory constructor to create an instance from a map
  factory AddbookingModel.fromMap(Map<String, dynamic> map) {
    return AddbookingModel(
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
      notavailable: (map['not_available'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      Day_of_booking: map['Day_of_booking'],

    );
  }

  // Method to convert the instance to a map
  Map<String, dynamic> toMap() {
    return {
      'Name': Name,
      'Day_of_booking':Day_of_booking,
      'phoneCommunication': phoneCommunication,
      'dateofBooking': dateofBooking,
      'timeofBooking': timeofBooking?.isNotEmpty == true ? timeofBooking : [],
      'Rent_the_ball': rentTheBall,
      'availableTime': availableTime?.isNotEmpty == true ? availableTime : [],
      'not_available': notavailable?.isNotEmpty == true ? notavailable : [],
      'availableDate': availableDate?.isNotEmpty == true ? availableDate : [],
      'selectedTimes': selectedTimes?.isNotEmpty == true ? selectedTimes : [], // Include this
      'notavailable': availableDate?.isNotEmpty == true ? availableDate : [],

    };
  }

  @override
  String toString() {
    return 'AddbookingModel(name: $Name, phoneCommunication: $phoneCommunication, dateofBooking: $dateofBooking, timeofBooking: $timeofBooking, rentTheBall: $rentTheBall, availableTime: $availableTime, availableDate: $availableDate,selectedTimes: $selectedTimes,notavailable:$notavailable)';
  }
}