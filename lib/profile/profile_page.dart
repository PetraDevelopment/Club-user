import 'package:club_user/shimmer_effect/shimmer_lines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Register/SignInPage.dart';
import '../../Register/SignUp.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Favourite/Favourite_page.dart';
import '../Home/Userclass.dart';
import '../my_reservation/my_reservation.dart';
class Profilepage extends StatefulWidget {
  @override
  State<Profilepage> createState() {
    return ProfilepageState();
  }
}
class ProfilepageState extends State<Profilepage> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  void _sendData() async {
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Not connected to any network
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد اتصال بالإنترنت'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
      return null;
    }
    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Users').add({
        'name': name,
        'phone': phoneNumber,

      });
      _nameController.clear();
      _phoneNumberController.clear();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب حدث به خطا', // "There was an error with this account"
            textAlign: TextAlign.center,
          ),
          backgroundColor:Color(0xFF1F8C4B),
        ),
      );
    }
  }


  final NavigationController navigationController = Get.put(NavigationController());

  bool _isLoading = true; // flag to control shimmer effect
  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }
  late List<User1> user1 = [];

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
    } else if (user?.phoneNumber != null) {

      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }

  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat = FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerchat.where('phone', isEqualTo: normalizedPhoneNumber).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        User1 user = User1.fromMap(userData);

        // Update the list and UI inside setState
        setState(() {
          user1.add(user);
          if (user1.isNotEmpty) { // Check if user1 is not empty
            _phoneNumberController.text = user1[0].phoneNumber!;
            _nameController.text=user1[0].name!;
          }
        });

        print("object${user1[0].name}");
        print("User data: $userData");
      } else {
        print("User not found with phone number $phoneNumber");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SigninPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }
  @override
  void  initState()  {
    super.initState();
    _loadUserData();
    _loadData();
    // Now you can access the user1 list
    // print('User data44444: ${user1[0].name}');
    setState(() {}); // Call setState to rebuild the widget tree
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8), // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "الملف الشخصى".tr,
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
      body: Directionality(

        textDirection: TextDirection.rtl,
        child:  SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child:    Center(
                            child: Container(
                              width: 164,
                              height: 164,
                              child: Image.asset(
                                "assets/images/profile_img.png",

                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 129,
                        left: 220,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                // Increase opacity for a darker shadow
                                spreadRadius: 0,
                                // Increase spread to make the shadow larger
                                blurRadius: 5,
                                // Increase blur radius for a more diffused shadow
                                offset: Offset(0, 0), // Increase offset for a more pronounced shadow effect
                              ),
                            ],),
                          child: FloatingActionButton(
                            onPressed: () {
                              // Get.to(() => AddNewPlayGround()); // Use GetX navigation
                            },
                            child: Icon(Icons.add, color: Colors.white,size: 26,),
                            backgroundColor:Color(0xFF064821),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Adjust the circular shape here
                            ),
                            // elevation: 6.0, // Adjust the elevation if needed
                          ),
                        ),
                      )


                    ],
                  ),
                  SizedBox(height: 16,),

                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)
                          ),
                          children: [

                            TextSpan(
                              text: 'الأسم ',
                            ),
                          ],
                        ),
                      ),
                      Text("")
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      shape: BoxShape.rectangle,
                      color: Colors.white70,
                      border: Border.all(
                        color: Color(0xFF9AAEC9), // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Image.asset(
                            'assets/images/name.png',
                            height: 19,
                            width: 19,
                            color: Color(0xFF495A71),
                          ),

                        ),
                        Expanded(
                          child:TextField(
                            controller: _nameController,
                            cursorColor: Color(0xFF064821),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.right, // Align text to the right
                            decoration: InputDecoration(
                              hintText: 'الأسم'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),

                            onEditingComplete: () async {
                              // Move focus to the next text field
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  if (_nameController.text.length >0 && _nameController.text.length <2)
                    Text(
                      // textAlign: TextAlign.end,
                      "برجاء ادخال الاسم",
                      style: TextStyle(
                        color: Colors.red.shade900, // Error message color
                        fontSize: 12.0,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  //phone
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)
                          ),
                          children: [

                            TextSpan(
                              text: 'رقم التليفون ',
                            ),
                          ],
                        ),
                      ),
                      Text(""),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      shape: BoxShape.rectangle,
                      color: Colors.white70,
                      border: Border.all(
                        color: Color(0xFF9AAEC9), // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Image.asset(
                            'assets/images/call.png',
                            height: 19,
                            width: 19,
                            color: Color(0xFF495A71),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneNumberController,
                            cursorColor: Color(0xFF064821),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(11),
                            ],
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.datetime, // Updated keyboard type for phone input
                            textAlign: TextAlign.right, // Align text to the right
                            decoration: InputDecoration(
                              hintText: 'رقم التليفون'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              // Phone = value;
                              // print("phoneeee" + " " + Phone);
                              // setState(() {
                              //   validatePhone(value);
                              // });
                            },
                            onSubmitted: (value) {
                              // Move focus to the next text field
                              // FocusScope.of(context).nextFocus();
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  if (PhoneErrorText.isNotEmpty)
                    Text(
                      PhoneErrorText,
                      style: TextStyle(
                        color: Colors.red.shade900, // Error message color
                        fontSize: 12.0,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  SizedBox(
                    height: 100,
                  ),


                  //btttttttttttttttttn
                  GestureDetector(
                    onTap: () async {
                      // // Check if any field is empty or if the passwords do not match
                      // if (_nameController.text.isEmpty ||
                      //     _phoneNumberController.text.isEmpty) {
                      //   setState(() {
                      //     // Show a SnackBar with the error message
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         content: Text(
                      //           'برجاء ادخال جميع البيانات', // "Please enter all the data"
                      //           textAlign: TextAlign.center,
                      //         ),
                      //         backgroundColor: Color(0xFF1F8C4B),
                      //       ),
                      //     );
                      //     // Ensure `isLoading` is set to false when there's a validation error
                      //     isLoading = false;
                      //   });
                      // } else {
                      //   setState(() {
                      //     // Clear any existing error message
                      //
                      //     isLoading = true;  // Set loading to true since we're starting an operation
                      //   });
                      //
                      //   // Prevent multiple navigation attempts
                      //   if (!_isNavigating) {
                      //     _isNavigating = true; // Set the flag to true
                      //
                      //     // Validate phone number in Firestore
                      //     await validatePhonefirebase(_phoneNumberController.text.trim(), context);
                      //
                      //     // Reset the flag after operation completes
                      //     _isNavigating = false;
                      //   }
                      //
                      //   setState(() {
                      //     isLoading = true;  // Set loading to false after the operation completes
                      //   });
                      // }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0, right: 20, left: 20),
                      child: Container(
                        height: 50,
                        width: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          shape: BoxShape.rectangle,
                          color: Color(0xFF064821), // Background color of the container
                        ),
                        child: Center(
                          child: Text(
                            'حفــــــظ'.tr,
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
                  ),
                  SizedBox(height: 5,),

                ]
            ),

          ),

        )
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        index: 0,
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
            // Get.to(() => menupage())?.then((_) {
            //   navigationController
            //       .updateIndex(0); // Update index when navigating back
            // });
              break;
            case 1:
              Get.to(() => my_reservation())?.then((_) {
                navigationController
                    .updateIndex(1); // Update index when navigating back
              });

              break;
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
  Future<bool> handleBackNavigation() async {
    int currentIndex = NavigationController().currentIndex.value;

    if (currentIndex == 3) {
      // If already on Home page, simply pop the route
      return true;
    } else {
      // Update index and navigate back correctly
      NavigationController().updateIndex(3); // Set index to Home
      Get.off(HomePage()); // Navigate to HomePage manually
      return false; // Prevent default pop behavior
    }
  }

}