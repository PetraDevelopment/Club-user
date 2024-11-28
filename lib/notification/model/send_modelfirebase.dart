class NotificationModel {
  String adminId;
  String? idd;
  String?groundname;
  String date;
  int notificationType;
  String time;
  String userId;
  bool adminreply=false;
  bool click=false;
  String day;
  String bookingtime;
  String groundid;

  NotificationModel({
    required this.day,
   this.idd,
    required this.adminreply,
    required this.bookingtime,
    required this.adminId,
    required this.groundid,
    this.groundname,
    required  this.click,
    required this.date,
    required this.notificationType,
    required this.time,
    required this.userId,
  });
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      adminId: map['adminId'] ?? '',
      idd: '',
      groundname:'',
      adminreply:map['adminreply']??false,
      click:map['click']??false,
      day:map['day']??'',
      bookingtime:map['bookingtime']??'',
      date:map['date']??'',
    groundid: map['groundid']??'',
    notificationType:map['notification_type']??'',
      userId:map['userid']??'',
      time: map['time']??'',
    );
  }
  Map<String, dynamic> toMap() {
    return {

      'click':click,
      'adminid': adminId,
      'date': date,
      'day':day,
      'adminreply':adminreply,
      'bookingtime':bookingtime,
      'groundid':groundid,
      'notification_type': notificationType,
      'time': time,
      'userid': userId,
    };
  }

  @override
  String toString() {
    return 'NotificationModel(adminId: $adminId, date: $date, notificationType: $notificationType, time: $time,userId:$userId ,groundid: $groundid)';
  }
}