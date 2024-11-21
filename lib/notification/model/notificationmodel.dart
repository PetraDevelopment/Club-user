class NotificationModel {
  final String status;
  final String message;
  final int notificationId;

  NotificationModel({
    required this.status,
    required this.message,
    required this.notificationId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      notificationId: json['notification_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'notification_id': notificationId,
    };
  }
}
