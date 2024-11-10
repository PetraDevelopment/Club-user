class AddbookingModel {
  String? iid;
  int?totalcost;
  String? Name;
  bool?acceptorcancle;
  // String? phoneCommunication;
  String? dateofBooking ;
  String?Day_of_booking;
  bool? rentTheBall;
  List<String>? selectedTimes = []; // Add this field to track selected times
  // List<String>? notavailable; // Ensure this matches your expected field name
  String? AdminId;
  // String? groundID;
  // String?groundName;
  // String? userImage; // Add a variable to hold the user's image URL
  // String? groundPhone;
  List<UserData>? AllUserData; // List of booking entries
  List<PlayGroundData>? NeededGroundData; // List of booking entries


  AddbookingModel({
    this.Name,
    // this.phoneCommunication,
    this.dateofBooking,
    this.totalcost,
    // this.timeofBooking,
    this.rentTheBall,
    this.acceptorcancle,
    // this.availableTime,
    // this.notavailable,
    this.Day_of_booking,
    // this.availableDate,
    this.selectedTimes,
    this.iid,
    this.AdminId,
    // this.groundID,
    // this.groundName,
    // this.userImage,
    // this.groundPhone,
    this.AllUserData,
    this.NeededGroundData,
  });

  // Factory constructor to create an instance from a map
  factory AddbookingModel.fromMap(Map<String, dynamic> map) {
    return AddbookingModel(
      iid: '',
      totalcost: map['totalcost'],
      acceptorcancle:map['acceptorcancle']??'',
      AdminId: map['AdminId'] ?? '',  // Get AdminId directly from the map
      // groundID:map['groundID'],
      Name: map['Name'],
      // phoneCommunication: map['phoneCommunication'],
      dateofBooking: map['dateofBooking'],
      // timeofBooking: (map['timeofBooking'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ?? [],
      rentTheBall: map['Rent_the_ball'],
      // availableTime: (map['availableTime'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ?? [],
      // availableDate: (map['availableDate'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ?? [],
      selectedTimes: (map['selectedTimes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      // notavailable: (map['not_available'] as List<dynamic>?)
      //     ?.map((e) => e.toString())
      //     .toList() ?? [],
      Day_of_booking: map['Day_of_booking'] ,
      // groundName: '',
      //   userImage:map['userImage'],
      // groundPhone: map['groundPhone'],

      AllUserData: (map['AlluserData']['UserData'] as List<dynamic>?)
          ?.map((entry) => UserData.fromMap(entry as Map<String, dynamic>))
          .toList() ?? [],

      NeededGroundData: (map['NeededGroundData']['GroundData'] as List<dynamic>?)
          ?.map((entry) => PlayGroundData.fromMap(entry as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Method to convert the instance to a map
  Map<String, dynamic> toMap() {
    return {
      'totalcost':totalcost,
      'AdminId': AdminId,  // Add AdminId to the map
      // 'groundID':groundID,
      'Name': Name,
      'acceptorcancle':acceptorcancle,
      'Day_of_booking':Day_of_booking,
      // 'phoneCommunication': phoneCommunication,
      'dateofBooking': dateofBooking,
      // 'timeofBooking': timeofBooking?.isNotEmpty == true ? timeofBooking : [],
      'Rent_the_ball': rentTheBall,
      // 'availableTime': availableTime?.isNotEmpty == true ? availableTime : [],
      // 'not_available': notavailable?.isNotEmpty == true ? notavailable : [],
      // 'availableDate': availableDate?.isNotEmpty == true ? availableDate : [],
      'selectedTimes': selectedTimes?.isNotEmpty == true ? selectedTimes : [], // Include this
      // 'notavailable': availableDate?.isNotEmpty == true ? availableDate : [],
//       'groundName': groundName,
// 'userImage':userImage,
//       'groundPhone':groundPhone,


      'AlluserData': {
        'UserData': AllUserData?.map((entry) => entry.toMap()).toList() ?? [],
      },
      'NeededGroundData': {
        'GroundData': NeededGroundData?.map((entry) => entry.toMap()).toList() ?? [],
      },
    };
  }

  @override
  String toString() {
    return 'UserData(name: $Name, dateofBooking: $dateofBooking,  rentTheBall: $rentTheBall, selectedTimes: $selectedTimes,adminId: $AdminId,acceptorcancle:$acceptorcancle )';
  }
}


class UserData {
  String? UserName;
  String? UserPhone;
  String? UserImg;

  UserData({
    this.UserName,
    this.UserPhone,
    this.UserImg,

  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      UserName: map['UserName'],
      UserPhone: map['UserPhone'],
      UserImg: map['UserImg'],

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserName': UserName,
      'UserPhone': UserPhone,
      'UserImg': UserImg,

    };
  }

  @override
  String toString() {
    return 'BookTypeEntry(UserName: $UserName, UserPhone: $UserPhone, UserImg$UserImg)';
  }
}
class PlayGroundData {
  String? GroundName;
  String? GroundPhone;
  String? GroundId;
  PlayGroundData({
    this.GroundName,
    this.GroundPhone,
    this.GroundId
  });

  factory PlayGroundData.fromMap(Map<String, dynamic> map) {
    return PlayGroundData(
        GroundName: map['GroundName'],
        GroundPhone: map['GroundPhone'],
        GroundId: map['GroundId']

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'GroundName': GroundName,
      'GroundPhone': GroundPhone,
      'GroundId':GroundId
    };
  }

  @override
  String toString() {
    return 'PlayGroundData(GroundName: $GroundName, GroundPhone: $GroundPhone)';
  }
}