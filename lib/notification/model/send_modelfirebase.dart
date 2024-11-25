class NotificationModel {
  String adminId;
  String date;
  int notificationType;
  String time;
  String userId;
  bool adminreply=false;
  String day;
  String bookingtime;
  String groundid;

  NotificationModel({
    required this.day,
    required this.adminreply,
    required this.bookingtime,
    required this.adminId,
    required this.groundid,
    required this.date,
    required this.notificationType,
    required this.time,
    required this.userId,
  });

  // Factory constructor to create the model from a Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      adminId: map['adminId'] ?? '',
      adminreply:map['adminreply']??false,

      day:map['day']??'',
      bookingtime:map['bookingtime']??'',
      date:map['date']??'',
    groundid: map['groundid']??'',
    notificationType:map['notification_type']??'',
      userId:map['userid']??'',
      time: map['time']??'',
    );
  }

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
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