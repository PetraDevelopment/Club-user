
import 'package:dio/dio.dart';
import 'model/notificationmodel.dart';

class Sendnotification {
  Future<NotificationModel> sendnotification(
      String mess,
      String title,
      String token,
      ) async {
    final dio = Dio();

    Options options = Options(
      headers: {'Content-Type': 'application/json'},
    );

    Map<String, dynamic> formDataMap = {
      "device_token": token,
      "title": title,
      "message": mess,
    };

    try {
      final response = await dio.post(
        'http://192.168.0.42/notifications/send_notification.php',
        options: options,
        data: formDataMap,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData is Map<String, dynamic>) {
          return NotificationModel.fromJson(jsonData);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load notification');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error sending notification: $e');
    }
  }
}
