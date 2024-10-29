import 'package:club_user/shimmer_effect/shimmer_lines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Register/SignInPage.dart';
import '../../Register/SignUp.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Favourite/Favourite_page.dart';
import '../Home/Userclass.dart';
import '../My_group/my_group.dart';
import '../my_reservation/my_reservation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../profile/profile_page.dart';
class menupage extends StatefulWidget {
  @override
  State<menupage> createState() {
    return menupageState();
  }
}
class menupageState extends State<menupage> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  final NavigationController navigationController = Get.put(NavigationController());

  Future<void> deleteUser(String phoneNumber) async {
    try {
      // Get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      // Get the SharedPreferences instance
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');
      print("newphoneValue${phoneValue.toString()}");

      // Decide which phone number to use (SharedPreferences or FirebaseAuth user)
      String? normalizedPhoneNumber;

      if (phoneValue != null && phoneValue.isNotEmpty) {
        normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');
      } else if (user != null && user.phoneNumber != null) {
        normalizedPhoneNumber = user.phoneNumber!.replaceFirst('+20', '0');
      }

      // Proceed if we have a phone number
      if (normalizedPhoneNumber != null) {
        // Reference to the Firestore collection
        CollectionReference playerchat = FirebaseFirestore.instance.collection('Users');

        // Get documents where phone number matches
        QuerySnapshot querySnapshot = await playerchat.where('phone', isEqualTo: normalizedPhoneNumber).get();

        // Check if a document is found
        if (querySnapshot.docs.isNotEmpty) {
          // Iterate over the documents and delete them
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
            print("Document with phone number $normalizedPhoneNumber deleted successfully.");
          }

          // Clear SharedPreferences after deletion
          await prefs.clear();
          print("SharedPreferences cleared.");

          // Sign the user out (optional)
          await FirebaseAuth.instance.signOut();

          // Navigate to SignUpPage after deletion
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
                (Route<dynamic> route) => false,
          );
        }
        else {
          print("No matching document found in Firestore.");
        }
        // Delete favorite data of the user
        if (phoneValue != null && phoneValue.isNotEmpty) {
          CollectionReference fav = FirebaseFirestore.instance.collection("Favourite");
          QuerySnapshot querySnapshotfav = await fav.where('user_phone', isEqualTo: phoneValue).get();
          if (querySnapshotfav.docs.isNotEmpty) {
            for (var doc in querySnapshotfav.docs) {
              await doc.reference.delete();
              print("Favorite data with phone number $normalizedPhoneNumber deleted successfully.");
            }
          }
        }
        else if (user != null && user.phoneNumber != null){
          CollectionReference fav = FirebaseFirestore.instance.collection("Favourite");
          QuerySnapshot querySnapshotfav = await fav.where('user_phone', isEqualTo: user.phoneNumber).get();
          if (querySnapshotfav.docs.isNotEmpty) {
            for (var doc in querySnapshotfav.docs) {
              await doc.reference.delete();
              print("Favorite data with phone number $normalizedPhoneNumber deleted successfully.");
            }
          }
        }

      } else {
        print("No valid phone number available.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
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
    return WillPopScope(
      onWillPop: () async {
        Get.off(HomePage()); // Navigate to HomePage
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
          child: Padding(
            padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8), // Add padding to the top of the title
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "المزيد".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true, // Center the title horizontally
              leading: IconButton(
                onPressed: () {
                  Get.off(HomePage()); // Navigate to HomePage
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
          child: SingleChildScrollView(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [

                    SizedBox(width: 8,),

                    Padding(
                      padding: const EdgeInsets.only(right: 12.0,left: 12,top: 11),
                      child:_isLoading?Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the right
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/profile.png",
                              width: 63,
                              height: 63,
                              // Adjust size as needed
                            ),
                            SizedBox(width: 10), // Adds space between the text and the image
                            _isLoading?ShimmerLoadingbig():
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  user1.isNotEmpty
                                      ? user1[0].name!.isNotEmpty
                                      ? Text(
                                    user1[0].name!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334154),
                                    ),
                                  )
                                      : Container()
                                      : Container(),
                                  user1.isNotEmpty
                                      ? user1[0].phoneNumber!.isNotEmpty
                                      ? Text(
                                    user1[0].phoneNumber!,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7D90AC),
                                    ),
                                  )
                                      : Container()
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ):Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the right
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          user1.isNotEmpty && user1[0].img!=null? ClipOval(
                            child: Image(image:  NetworkImage(
                              user1[0].img!,

                              // Adjust size as needed
                            ),    width: 63,
                              height: 63,
                              fit: BoxFit.fitWidth,),
                          ):
                          Padding(
                            padding: const EdgeInsets.only(right: 34.0),
                            child: Image.asset(
                              "assets/images/profile.png",
                              // Adjust size as needed
                            ),
                          ),
                          SizedBox(width: 10), // Adds space between the text and the image

                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                user1.isNotEmpty
                                    ? user1[0].name!.isNotEmpty
                                    ? Text(
                                  user1[0].name!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334154),
                                  ),
                                )
                                    : Container()
                                    : Container(),
                                user1.isNotEmpty
                                    ? user1[0].phoneNumber!.isNotEmpty
                                    ? Text(
                                  user1[0].phoneNumber!,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7D90AC),
                                  ),
                                )
                                    : Container()
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height:30 ,),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 5, bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profilepage(),  settings: RouteSettings(arguments: {
                          'from': 'menu_page'
                        }),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(

                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/name.png', height: 22, width: 22, color:Color(0xFF064821)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'الملف الشخصى'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C6A6A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.grey.shade600
                            ,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => My_group(),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(  // Wrap entire area with Container
                      color: Colors.transparent, // Add a background color to make the entire container tappable
                      padding: const EdgeInsets.only(right: 22.0, left: 22, top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset('assets/images/person.png', height: 22, width: 22, color: Color(0xFF064821)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'مجموعتى'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6C6A6A),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8,right: 8),

                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => my_reservation(),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(  // Wrap entire area with Container
                      color: Colors.transparent, // Add a background color to make the entire container tappable
                      padding: const EdgeInsets.only(right: 22.0, left: 22, top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset('assets/images/calendar.png', height: 22, width: 22, color: Color(0xFF064821)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'الحجوزات'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6C6A6A),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8,right: 8),

                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0,
                      left: 22,
                      top: 0,
                      bottom: 0
                  ),
                  child: Divider(
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness: 1, // Adjust the thickness of the line as needed
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppBarandNavigationBTN(),
                      ),
                    );
                  },
                  child: Container(  // Wrap entire area with Container
                    color: Colors.transparent, // Add a background color to make the entire container tappable
                    padding: const EdgeInsets.only(right: 22.0, left: 22, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/stade.png', height: 22, width: 22, color: Color(0xFF064821)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'الملاعب'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C6A6A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),

                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavouritePage(),
                      ),
                    );
                  },
                  child: Container(  // Wrap entire area with Container
                    color: Colors.transparent, // Add a background color to make the entire container tappable
                    padding: const EdgeInsets.only(right: 22.0, left: 22, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Image.asset('assets/images/active.png', height: 22, width: 22, color: Color(0xFF064821)),
                            Icon(Icons.favorite_border, color: Color(0xFF064821), size: 22),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'المفضلة'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C6A6A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),

                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 5, bottom: 5),
                  child: GestureDetector
                    (
                    onTap: () {

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(

                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/notification.png', height: 22, width: 22, color:Color(0xFF064821)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'الاشعارات'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C6A6A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),

                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.grey.shade600
                            ,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    // color: Color(0xFF091C3F14),
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 5, bottom: 5),
                  child: GestureDetector
                    (
                    onTap: () async {
                      final connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.none) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(
                                  child: Text("تسجيل الخروج".tr,
                                      style: TextStyle(
                                        color: Color(0xFF374957),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        fontFamily: 'Cairo',
                                      ))),
                              content: Text(
                                  "هل تريد التأكيد على تسجيل الخروج؟".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF374957),
                                    fontFamily: 'Cairo',
                                  )),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [

                                    ElevatedButton(
                                      onPressed: () async {

                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          await prefs.clear();
                                          FirebaseAuth.instance.signOut();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SigninPage()),
                                                (Route<dynamic> route) => false,
                                          );



                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Color(0xFF064821),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                      ),
                                      child: Text(
                                        "تسجيل الخروج".tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Color(0xFFFFBEC5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                      ),
                                      child: Text(
                                        "إلغاء".tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },


                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(

                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/logout.png', height: 22, width: 22, color:Color(0xFF064821)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'تسجيل الخروج'.tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C6A6A),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 0, bottom: 0),
                  child: Divider(
                    // color: Color(0xFF091C3F14),
                    color: Colors.grey.shade300,

                    // Adjust the color of the line as needed
                    thickness:
                    1, // Adjust the thickness of the line as needed
                  ),
                ),


                GestureDetector
                  (
                  onTap: () async {
                    final connectivityResult =
                    await Connectivity().checkConnectivity();
                    if (connectivityResult != ConnectivityResult.none) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                                child: Text("حذف الحساب".tr,
                                    style: TextStyle(
                                      color: Color(0xFF374957),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                    ))),
                            content: Text(
                                "هل تريد التأكيد على حذف حسابك ؟".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF374957),
                                  fontFamily: 'Cairo',
                                )),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [

                                  ElevatedButton(
                                    onPressed: () async {

                                      if ( user1.isNotEmpty && user1[0].phoneNumber!.isNotEmpty) {
                                        await deleteUser(user1[0].phoneNumber.toString());
                                      }
                                      else {
                                        print("No phone number found for the user.");
                                        // You could handle cases where the phone number or user is null here.
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Color(0xFF064821),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                    child: Text(
                                      " حذف الحساب".tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Color(0xFFFFBEC5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                    ),
                                    child: Text(
                                      "إلغاء".tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },

                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 22.0, left: 22, top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(

                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Image.asset('assets/images/logout.png', height: 22, width: 22, color:Color(0xFF064821)),
                              Icon(Icons.delete_outline, color: Color(0xFFB3261E), size: 25),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "مسح الحساب".tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color:  Color(0xFFB3261E),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40,),

              ],
            ),
          ),
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