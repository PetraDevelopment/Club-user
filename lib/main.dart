import 'package:club_user/location/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Controller/NavigationController.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'Splach/PlayGroundSplach.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This method will be called when the app is in the background
  print('Handling a background message: ${message.messageId}');
  // You can handle the message here
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
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

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize NavigationController
  Get.put(NavigationController());

  // Get FCM token
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Initialize date formatting for Arabic
  await initializeDateFormatting('ar', null);

  // Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Set up message handlers
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.notification?.title}');

    // Extract title and body from the RemoteMessage notification
    String title = message.notification?.title ?? 'No Title';
    String body = message.notification?.body ?? 'No Body';

    // Pass the title and body to the _showNotification function
    _showNotification(title, body);
  }); // Add the closing parenthesis and semicolon here

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked! ${message.data}');
    // Handle the message when the app is opened from a notification
  });

  // Run the app
  runApp(
    GetMaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xFF32AE64), // Color of selected text
          selectionHandleColor: Color(0xFF32AE64),
          cursorColor: Colors.green.shade600, // Color of the selection handles (cursors)
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
      // Handle notification tap
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