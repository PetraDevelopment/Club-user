import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../notification_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin fltNotification =
FlutterLocalNotificationsPlugin();
FlutterLocalNotificationsPlugin rideNotification =
FlutterLocalNotificationsPlugin();
bool isGeneral = false;
int id = 0;
bool background=false;

void notificationTapBackground(NotificationResponse notificationResponse) {
  isGeneral = true;
}

var androidDetails = const AndroidNotificationDetails(
  '54321',
  'normal_notification',
  enableVibration: true,
  enableLights: true,
  importance: Importance.high,
  playSound: true,
  priority: Priority.high,
  visibility: NotificationVisibility.private,
);

const iosDetails = DarwinNotificationDetails(
    presentAlert: true, presentBadge: true, presentSound: true);

var generalNotificationDetails =
NotificationDetails(android: androidDetails, iOS: iosDetails);

var androiInit =
const AndroidInitializationSettings('@mipmap/ic_launcher');
var iosInit = const DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);
var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);

notificationHandleClose(context){

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    print('data:::1');

    if((!background) && (message != null && (message!.data['title'] != null || message.notification!.title != null))){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              Notification_page()));
      message=null;
    }
  });
}
notificationHandleOpened(context){

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('data:::2');
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      showGeneralNotification(message.notification,context);

    }
  });
}
notificationHandleBackground(context){

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('data:::0');
    background =true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
           Notification_page()));



  });
}
Future<void> showGeneralNotification(message,context) async {
  print(message.toString()+'hhhhsss');


  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails(
    'notification_1',
    'general notification',
    channelDescription: 'general notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);
  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  await fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse : (payload) async {
        print(payload.toString());
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
            Notification_page()));


      });
  await fltNotification.show(
      id++, message.title, message.body, notificationDetails);
  id = id++;


}
