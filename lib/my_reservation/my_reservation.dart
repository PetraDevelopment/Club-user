import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/NavigationController.dart';
import '../Favourite/Favourite_page.dart';
import '../Home/HomePage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Home/Userclass.dart';
import '../Menu/menu.dart';
import '../Register/SignInPage.dart';
import 'package:shimmer/shimmer.dart';

import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../shimmer_effect/shimmer_lines.dart';

class my_reservation extends StatefulWidget {


  @override
  State<my_reservation> createState() {
    return my_reservationState();
  }
}

class my_reservationState extends State<my_reservation>
    with SingleTickerProviderStateMixin {
  final NavigationController navigationController =
  Get.put(NavigationController());
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true; // flag to control shimmer effect
  String groundIid = '';

  Future<void> _loadData() async {
    // Simulate data loading
    await Future.delayed(Duration(seconds: 2));

    // Check if the state is still mounted before calling setState
    if (mounted) {
      setState(() {
        _isLoading = false; // set flag to false when data is loaded
      });
    }
  }

  late List<User1> user1 = [];

  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      // Normalize the phone number by stripping the country code
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');

      // Reference to the Firestore collection
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection('Users');

      // Get the documents in the collection where phone number matches
      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      // Check if a document is found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document data
        Map<String, dynamic> userData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Create a User object from the map
        User1 user = User1.fromMap(userData);

        // Add the User object to the list
        user1.add(user);

        print("Loaded User: ${user1[0].name}");

        // Print the user data
        print("User data: $userData");
      } else {
        print("User not found with phone number $phoneNumber");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        // Clear SharedPreferences

        // Navigate to the SigninPage using GetX
        Get.offAll(() => SigninPage());
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
      setState(() {});
      _loadData();
    } else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
      setState(() {});
      _loadData();
    } else {
      print("No phone number available.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // print("groundId${widget.groundId}");
    setState(() {});
  }

  late List<AddPlayGroundModel> allplaygroundsData = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8), // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "الحجوزات".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true, // Center the title horizontally
            leading: IconButton(
              onPressed: () {
                Get.back();
                // Navigator.of(context).pop(true); // Navigate back to the previous page
              },
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color:  Color(0xFF62748E),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.asset('assets/images/notification.png', height: 28, width: 28,),
              ),

            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            SizedBox(
              height: 22,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 25,
                ),
                Container(
                  height: 93,
                  width: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(17),
                      bottomLeft: Radius.circular(17),
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    shape: BoxShape.rectangle,
                    color: Colors
                        .black, // This color will be visible at the bottom
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 92,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFF0F6FF), // Inner container color
                        ),
                        child: Column(
                          children: [
                            Text(
                              "0",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 30.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334154),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              "قيد الانتظار",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF495A71),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
                Container(
                  height: 93,
                  width: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(17),
                      bottomLeft: Radius.circular(17),
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    shape: BoxShape.rectangle,
                    color: Colors.red
                        .shade200, // This color will be visible at the bottom
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 92,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFF0F6FF), // Inner container color
                        ),
                        child: Column(
                          children: [
                            Text(
                              "0",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 30.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334154),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              "حجزات ملغية",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF495A71),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
                Container(
                  height: 93,
                  width: 87,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(17),
                      bottomLeft: Radius.circular(17),
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    shape: BoxShape.rectangle,
                    color: Colors.green
                        .shade400, // This color will be visible at the bottom
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 92,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFF0F6FF), // Inner container color
                        ),
                        child: Column(
                          children: [
                            Text(
                              "0",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 30.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334154),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              "حجزات مأكدة",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF495A71),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
              ],
            ),
            SizedBox(
              height: 28,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 26.0, left: 26),
              child: Text(
                "تاريخ الحجوزات".tr,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            for (var i = 0; i < 5; i++) // Repeat the container 5 times
              Padding(
                padding: const EdgeInsets.only(right: 12.0,bottom: 12,top: 10,left: 12),
                child: Center(
                  child: Container(

                    width: MediaQuery.of(context).size.width/1.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      shape: BoxShape.rectangle,
                      color: Color(0xFFF0F6FF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7), // Increase opacity for a darker shadow
                          spreadRadius: 0, // Increase spread to make the shadow larger
                          blurRadius: 2, // Increase blur radius for a more diffused shadow
                          offset: Offset(0, 0), // Increase offset for a more pronounced shadow effect
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0, left: 12, top: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Aligns the content to the right
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "ملعب وادى دجلــــة",
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                  Row(
                                    children: [

                                      Text(
                                        "   620 ج.م".tr,
                                        textDirection: TextDirection.rtl,  // Ensures the text direction is RTL

                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF7D90AC),
                                        ),
                                      ),
SizedBox( width: MediaQuery.of(context).size.width/4.2,),
                                      Text(
                                        "01025610549".tr,
                                        textDirection: TextDirection.rtl,  // Ensures the text direction is RTL

                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF7D90AC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 10), // Adds space between the text and the image
                              Image.asset(
                                "assets/images/Wadi_Logo.png",
                                height: 30,
                                width: 30,
                                // Adjust size as needed
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 18.0, left: 12, top: 11),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [

                                  Text(
                                    "التكلفة أجمالية  ".tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  Text(
                                    "13-08-2024".tr,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF7D90AC),
                                    ),
                                  ),
                                  SizedBox(width: 19,),
                                  RichText(
                                    textDirection: TextDirection.rtl, // Set the overall text direction to RTL
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF7D90AC),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '4:00 م', // Right-aligned part
                                        ),
                                        TextSpan(
                                          text: '  إلى  ', // Center part (extra spaces for spacing)
                                        ),
                                        TextSpan(
                                          text: '6:00 م', // Left-aligned part
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                height: 29,
                                width: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  shape: BoxShape.rectangle,
                                  color: Color(0xFFB3261E), // Background color of the container
                                  // border: Border.all(
                                  //   width: 1.0, // Border width
                                  //   color: Colors.black
                                  // ),
                                ),
                                child: Center(
                                  child: Text(
                                    "إلغاء الحجز".tr,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                height: 29,
                                width: 114,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  shape: BoxShape.rectangle,
                                  color: Color(0xFF064821), // Background color of the container
                                  // border: Border.all(
                                  //   width: 1.0, // Border width
                                  //   color: Colors.black
                                  // ),
                                ),
                                child: Center(
                                  child: Text(
                                    "الموقع".tr,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 5),

                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 55), // Adds space between the text and the image
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        index: 1,
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
        color: Color(0xFF064821),
        buttonBackgroundColor: Color(0xFFBACCE6),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          navigationController
              .updateIndex(index); // Update the index dynamically
          // Handle navigation based on index
          switch (index) {
            case 0:
              Get.to(() => menupage())?.then((_) {
                navigationController
                    .updateIndex(0); // Update index when navigating back
              });
              break;

            case 1:
              // Get.to(() => FavouritePage())?.then((_) {
              //   navigationController
              //       .updateIndex(1); // Update index when navigating back
              // });
              // break;
            case 2:
              Get.to(() => AppBarandNavigationBTN())?.then((_) {
                navigationController.updateIndex(2);
              });
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
}