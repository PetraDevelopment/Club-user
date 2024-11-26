class AddbookingModel {
  String? iid;
  String? logoimage;

  bool?acceptorcancle;
  int?totalcost;
  String? dateofBooking ;
  String?Day_of_booking;
  bool? rentTheBall;
  List<String>? selectedTimes = [];
  String? AdminId;
  String? userID;
  String?  GroundId;
  String? groundImage;
  String? UserName;
  String? UserPhone;
  String? UserImg;
  String? groundName;
  String? groundphone;
  AddbookingModel({
    this.dateofBooking,
    this.rentTheBall,
    this.acceptorcancle,
    this.logoimage,
    this.Day_of_booking,
    this.selectedTimes,
    this.iid,
    this.AdminId,
    this.userID,
    this.GroundId,
    this.groundImage,
    this.totalcost,
    this.UserName,
    this.UserPhone,
    this.UserImg,
    this.groundName,
    this.groundphone,
  });

  factory AddbookingModel.fromMap(Map<String, dynamic> map) {
    return AddbookingModel(
      iid: '',
      logoimage:'',
      UserImg: '',
      UserName: '',
      UserPhone: '',
      groundName: '',
      groundphone: '',
      acceptorcancle:map['acceptorcancle']??'',
      AdminId: map['AdminId'] ?? '',
      userID:map['userID'],
      GroundId: map['GroundId'],
      dateofBooking: map['dateofBooking'],
      rentTheBall: map['Rent_the_ball'],
      totalcost: map['totalcost'],
      groundImage:'',
      selectedTimes: (map['selectedTimes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      Day_of_booking: map['Day_of_booking'] ,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AdminId': AdminId,
      'userID':userID,

      'acceptorcancle':acceptorcancle,
      'Day_of_booking':Day_of_booking,
      'GroundId':GroundId,
      'dateofBooking': dateofBooking,
      'Rent_the_ball': rentTheBall,
      'totalcost':totalcost,
      'selectedTimes': selectedTimes?.isNotEmpty == true ? selectedTimes : [],
    };
  }

  @override
  String toString() {
    return 'UserData( dateofBooking: $dateofBooking,  rentTheBall: $rentTheBall, selectedTimes: $selectedTimes,adminId: $AdminId,acceptorcancle:$acceptorcancle )';
  }
}
