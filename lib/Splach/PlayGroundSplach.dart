import 'dart:async';
import 'package:flutter/material.dart';
import '../Home/HomePage.dart';
import '../Register/SignInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Register/SignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayGroundSplach extends StatefulWidget {
  @override
  PlayGroundSplashState createState() => PlayGroundSplashState();
}

class PlayGroundSplashState extends State<PlayGroundSplach>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
   StreamSubscription<QuerySnapshot>? playerChatSubscription;

  Future<void> validatePhonefirebase(String value, BuildContext context) async {
    CollectionReference playerChat =
    FirebaseFirestore.instance.collection('PlayersChat');

    QuerySnapshot querySnapshot =
    await playerChat.where('phone', isEqualTo: value).get();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phone', value);
    print('shared phone ${prefs.getString('phone') ?? ''}');

    // Check if the phone number was found
    if (querySnapshot.docs.isNotEmpty) {
      // Phone number exists, navigate to the Sign-in page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب موجود بالفعل برجاء تسجيل الدخول', // "This account already exists. Please sign in."
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
      print('Phone number exists, navigating to Sign-in page');
    } else {
      // Phone number does not exist, proceed to send data and call verifyPhone
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تسجيل الدخول بنجاج', // "Successfully registered"
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Define animation controller
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    );

    // Define animation
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    playerChatSubscription = null; // Initialize it here

    // Start the animation
    animationController.forward();

    // Navigate to the next page after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      navigateToPage();
    });

    // Add Firestore listener for phone deletion
    addFirestoreListener();
  }

  void addFirestoreListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';

    if (phone.isNotEmpty) {
      CollectionReference playerChat =
      FirebaseFirestore.instance.collection('PlayersChat');
      playerChatSubscription = playerChat.snapshots().listen((snapshot) {
        bool phoneExists = snapshot.docs.any((doc) => doc['phone'] == phone);

        if (!phoneExists) {
          // Phone number has been deleted, navigate to SignUpPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );
        }
      });

      // playerChatSubscription = playerChat.snapshots().listen((snapshot) {
      //   bool phoneExists = snapshot.docs.any((doc) => doc['phone'] == phone);
      //
      //   if (!phoneExists) {
      //     // Phone number has been deleted, navigate to SignUpPage
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => SignUpPage()),
      //     );
      //   }
      // });
    }
  }

  Future<void> navigateToPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phoneotp') ?? '';
    String Phone011=prefs.getString('phonev')??'';
    print('shared phone $phone');

    if (!mounted) return; // Ensure the widget is still mounted

    if (phone.isEmpty&&Phone011.isEmpty) {
      // Phone is empty, navigate to the sign-up page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    } else if (Phone011.isEmpty && phone.isNotEmpty) {
      // Phone is not empty, navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );}
    else if (Phone011.isNotEmpty && phone.isEmpty) {
      // Phone is not empty, navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    // Check if playerChatSubscription is not null before canceling
    playerChatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F8C4B),
      body: Center(
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: child,
            );
          },
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}
