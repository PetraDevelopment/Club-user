import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Home/Userclass.dart';
import '../../Menu/menu.dart';
import '../../Register/SignInPage.dart';
import '../../Splach/LoadingScreen.dart';
import '../../my_reservation/my_reservation.dart';
import '../../notification/model/modelsendtodevice.dart';
import '../../notification/notification_repo.dart';
import '../../playground_model/AddPlaygroundModel.dart';

class Notification_page extends StatefulWidget {

  @override
  State<Notification_page> createState() {
    return Notification_pageState();
  }
}

class Notification_pageState extends State<Notification_page> with TickerProviderStateMixin {

  bool isLoading = false;

  int selectedIndex=3;
  double opacity = 1.0;

  bool isConnected=false;
  final NavigationController navigationController = Get.put(NavigationController());

  Future<void> checkInternetConnection() async {

    print("bvbbvbvbb$isConnected");

    var connectivityResult = await (Connectivity().checkConnectivity());
    print("connectivityResult$connectivityResult");
    print("connectivityResult${ConnectivityResult.none}");

    if (connectivityResult[0] == ConnectivityResult.none) {
      setState(() {
        isConnected = false;
        print("bvbbvbvbb$isConnected");
      });
    }else{
      isConnected = true;

    }
    print("bvbbvbvbb$isConnected");

  }
  void initState() {
    checkInternetConnection();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, right: 12, left: 12),
          // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "حجز ملعب".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            // Center the title horizontally
            leading: IconButton(
              onPressed: () {
                Get.back();
                // Navigator.of(context).pop(true); // Navigate back to the previous page
              },
              icon: Icon(
                Directionality.of(context) == TextDirection
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: Color(0xFF62748E),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  'assets/images/notification.png',
                  height: 28,
                  width: 28,
                ),
              ),
            ],
          ),
        ),
      ),
      body:isConnected? Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 25.0, left: 25, top: 15, bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(

                    child: Text('تم تأكيد الحجز بنجاح', style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                    ),)
                    )
                  ]
            ),
          ),
          )
        ],
      ):                        _buildNoInternetUI(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        index: 2,
        // Use the dynamic index
        items: [
          Icon(Icons.more_horiz, color: Colors.white, size: 25),

          Image.asset('assets/images/calendar.png',
              height: 21, width: 21, color: Colors.white),
          Image.asset('assets/images/stade.png',
              height: 21, width: 21, color: Colors.white),
          Image.asset('assets/images/home.png',
              height: 21, width: 21, color: Colors.white),
        ],
        // buttonBackgroundColor: Colors.transparent, // Set button background color to transparent
        // backgroundColor: Colors.transparent, // Set background color to transparent

        color: Color(0xFF064821),
        buttonBackgroundColor: Color(0xFFBACCE6),
        backgroundColor: Colors.white,


        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            // Update opacity based on the selected index
            opacity= 0.5;
          });
          // setState(() {
          //   navigationController.updateIndex(index);
          //   // Update opacity based on the selected index
          //   opacity = index == 2 ? 0.9 : 1.0;
          // });// Update the index dynamically
          // Handle navigation based on index
          switch (index) {
            case 0:
              Get.to(() => menupage())?.then((_) {
                navigationController
                    .updateIndex(0); // Update index when navigating back
              });
              break;

            case 1:
              Get.to(() => my_reservation())?.then((_) {
                navigationController
                    .updateIndex(1); // Update index when navigating back
              });
              break;
            case 2:
            // Get.to(() => AppBarandNavigationBTN())?.then((_) {
            //   navigationController.updateIndex(2);
            // });
              break;

            case 3:
              Get.to(() => HomePage())?.then((_) {
                navigationController.updateIndex(3);
              });
              break;
          }
        },
      ),
    );
  }
  Widget _buildNoInternetUI() {

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height/3,

          ),
          Center(
            child: Container(
              height: 200,
              child: Image.asset(
                'assets/images/wifirr.png',
                // Adjust the height as needed
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "لا يوجد اتصال بالانترنت".tr,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),

        ],
      ),
    );
  }


}

