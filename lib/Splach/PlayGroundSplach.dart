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

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب موجود بالفعل برجاء تسجيل الدخول',
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تسجيل الدخول بنجاح',
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
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    playerChatSubscription = null;

    animationController.forward();

    Future.delayed(Duration(seconds: 3), () {
      navigateToPage();
    });

    addFirestoreListener();
  }

  void addFirestoreListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';

    if (phone.isNotEmpty) {
      CollectionReference playerChat =
      FirebaseFirestore.instance.collection('Users');
      playerChatSubscription = playerChat.snapshots().listen((snapshot) {
        bool phoneExists = snapshot.docs.any((doc) => doc['phone'] == phone);

        if (!phoneExists) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );
        }
      });


    }
  }

  Future<void> navigateToPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phoneotp') ?? '';
    String Phone011=prefs.getString('phonev')??'';
    print("Phone011$Phone011");
    print('shared phone $phone');

    if (!mounted) return;

    if (phone.isEmpty&&Phone011.isEmpty) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    } else if (Phone011.isEmpty && phone.isNotEmpty) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );}
    else if (Phone011.isNotEmpty && phone.isEmpty) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();

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
