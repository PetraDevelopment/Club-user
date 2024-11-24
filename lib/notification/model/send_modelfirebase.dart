class NotificationModel {
  String adminId;
  String date;
  int notificationType;
  String time;
  String userId;

  NotificationModel({
    required this.adminId,
    required this.date,
    required this.notificationType,
    required this.time,
    required this.userId,
  });

  // Factory constructor to create the model from a Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      adminId:map['adminId'],
      date:map['date'],
    notificationType:map['notification_type'],
      userId:map['userid'],
      time: map['time'],
    );
  }

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'adminid': adminId,
      'date': date,
      'notification_type': notificationType,
      'time': time,
      'userid': userId,
    };
  }

  @override
  String toString() {
    return 'NotificationModel(adminId: $adminId, date: $date, notificationType: $notificationType, time: $time,userId:$userId)';
  }
}