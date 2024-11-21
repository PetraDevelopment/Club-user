

import 'dart:convert';

import 'model/notificationmodel.dart';

class GetWatchedRepo{
  Future<notificationmodel> getWatchDeuration(
      String student_id_v,
      String lessonId,
      ) async {
    Options options = Options(
      headers: {'Content-Type': 'application/json'},
    );
    Map<String, dynamic> formDataMap = {
      "device_token": lessonId,
      "student_id": student_id_v,
      "message": student_id_v,

    };
    Dio dio = await initializeDio();
    final response = await dio.post(
      'student_lesson_watch_duration_get.php',
      // options: options,
      data: formDataMap,
    );

    String formDataJson = jsonEncode(formDataMap);
    print('deuration response  ${response.toString()}');
    if (response.statusCode == 200) {
      print('ressssssss  ${formDataJson}');
      final jsonData = response.data;
      print('deuration iiii  ${jsonData.toString()}');
      // SharedPreferences prefs = await SharedPreferences.getInstance();

      // prefs.setString("dduration", response.data.toString());
      // print('dduration of repo ${response.data.toString()}');


      final Map<String, dynamic> responseData =
      jsonData as Map<String, dynamic>;
      return GetWatched.fromJson(responseData);
    } else {
      throw Exception('Failed to load deuration');
    }

  }
}