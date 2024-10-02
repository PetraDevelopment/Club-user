import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Controller/NavigationController.dart';
import '../Favourite/Favourite_page.dart';
import '../Home/HomePage.dart';
import '../Home/Userclass.dart';
import '../Menu/menu.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import '../Register/SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';

class My_group extends StatefulWidget {
  @override
  State<My_group> createState() {
    return My_groupState();
  }
}

class My_groupState extends State<My_group> {
  late List<User1> user1 = [];
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true; // flag to control shimmer effect

  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }
  @override
  void initState() {
    super.initState();
    _loadData();
    getPlaygroundbyname();
    _loadUserData();
    print("njbjbhbbb");
    setState(() {});
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.round();
      });
    });
    // Call setState to rebuild the widget tree
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
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
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        User1 user = User1.fromMap(userData);

        // Update the list and UI inside setState
        setState(() {
          user1.add(user);
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


  final Searchcontrol = TextEditingController();
  late List<AddPlayGroundModel> allplaygrounds = [];
  int _currentIndex = 3;
  int _currentIndexcarousel_slider = 0;
  final PageController _pageController = PageController();

  Future<void> getPlaygroundbyname() async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

          allplaygrounds.add(user);
          print("PlayGroung Id : ${document.id}"); // Print the latest playground

          print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground
// Store the document ID in the AddPlayGroundModel object
          // user.id = document.id;
          user.id = document.id;
          print("Docummmmmm${user.id}");
          // Store the document ID in the AddPlayGroundModel object
          // idddddd1 = document.id;
          // idddddd2=document.id;
          // print("Docummmmmm$idddddd1    gggg$idddddd2");
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  final NavigationController navigationController = Get.put(NavigationController());

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
              "مجموعتى".tr,
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
            for(int i=0;i<5;i++)
            Padding(
              padding: const EdgeInsets.only(top: 10.0,bottom: 10,right: 20,left: 20),
              child: Container(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 33.0),

                      child: Image.asset('assets/images/callgroup.png',
                          color: Colors.green, width: 28,height: 28,),
                    ),


                     Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(bottom: 14.0, right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                  "ملعب وادى دجلــــة",
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                ),
                                user1.isNotEmpty && user1[0].phoneNumber!.isNotEmpty
                                    ? Text(
                                  user1[0].phoneNumber!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7D90AC),
                                  ),
                                )
                                    : Container()
                                // You can show a placeholder or nothing if the list is empty.
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Image.asset(
                              "assets/images/Wadi_Logo.png",
                               width: 32,
                              height: 60,
                              // Adjust size as needed
                            ),
                          ),
                        ],
                      ),

                  ],
                ),
              ),
            ),




          ],
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        index: 3,
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
            // Get.to(() => HomePage())?.then((_) {
            //   navigationController.updateIndex(3);
            // });
              break;
          }
        },
      ),
      // ),
    );
  }
}
