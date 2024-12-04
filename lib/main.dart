import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Controller/NavigationController.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'Splach/PlayGroundSplach.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  databaseFactory = databaseFactory;

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAr4vHDaUehgTeW1Utt7Vp9xefjNIjXWdQ",
      authDomain: "playgroundstudio-bf6c9.firebaseapp.com",
      projectId: "playgroundstudio-bf6c9",
      storageBucket: "playgroundstudio-bf6c9.appspot.com",
      messagingSenderId: "333511447622",
      appId: "1:333511447622:web:59b19d10a677cf62376647",
      measurementId: "G-QPB1L99TQ5",
    ),
  );
  await _initializeLocalNotifications();
  Get.put(NavigationController());
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token: $token");
  await initializeDateFormatting('ar', null);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );


  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('jjshsghshs');
    await Firebase.initializeApp();
  }

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xFF32AE64),
          selectionHandleColor: Color(0xFF32AE64),
          cursorColor: Colors.green.shade600,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: PlayGroundSplach(),
    ),
  );
}

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notification tapped: ${response.payload}");
    },
  );
}



void _showNotification(String title, String body) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_ID',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'notification_page',
  );
}