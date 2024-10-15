import 'package:club_user/location/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Controller/NavigationController.dart';
import 'package:get/get.dart';
import 'Splach/PlayGroundSplach.dart';
import 'package:intl/date_symbol_data_local.dart';
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAr4vHDaUehgTeW1Utt7Vp9xefjNIjXWdQ",
        authDomain: "playgroundstudio-bf6c9.firebaseapp.com",
        projectId: "playgroundstudio-bf6c9",
        storageBucket: "playgroundstudio-bf6c9.appspot.com",
        messagingSenderId: "333511447622",
        appId: "1:333511447622:web:59b19d10a677cf62376647",
        measurementId: "G-QPB1L99TQ5"
    ),
  );
  Get.put(NavigationController());
  await initializeDateFormatting('ar', null); // Initialize the locale for Arabic

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
            selectionColor: Color(0xFF32AE64), // Color of selected text
            selectionHandleColor: Color(0xFF32AE64),
            cursorColor: Colors.green.shade600// Color of the selection handles (cursors)
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: PlayGroundSplach(),
    ),
  );
}


