class NotificationData {
  final String message;
  final String title;
  final String deviceToken;

  NotificationData({
    required this.message,
    required this.title,
    required this.deviceToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'title': title,
      'device_token': deviceToken,
    };
  }
}