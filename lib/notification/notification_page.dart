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
import 'model/send_modelfirebase.dart';

class Notification_page extends StatefulWidget {

  @override
  State<Notification_page> createState() {
    return Notification_pageState();
  }
}

class Notification_pageState extends State<Notification_page> with TickerProviderStateMixin {

  bool isLoading = false;
  String useridddd="";
  late List<User1> user1 = [];
  late List<NotificationModel> notificationlist = [];

  User? user = FirebaseAuth.instance.currentUser;
  int selectedIndex=3;
  double opacity = 1.0;
  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var playerDoc = querySnapshot.docs.first;
        useridddd = playerDoc.id; // Get the docId of the matching Phoone number
        print("Document ID for the Phoone number: $useridddd");
        await fetchnotificationdatabyid(useridddd);
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
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
    }
    else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }
  bool isConnected=false;
  final NavigationController navigationController = Get.put(NavigationController());

  Future<void> fetchnotificationdatabyid(String userid) async {

      CollectionReference notificationdata =
      FirebaseFirestore.instance.collection("notification");

      QuerySnapshot anotificationdataSnapshot = await notificationdata
          .where('userid', isEqualTo: userid)
          .get();

      if (anotificationdataSnapshot.docs.isNotEmpty) {
        for (int i = 0; i < anotificationdataSnapshot.docs.length; i++) {
          var docData = anotificationdataSnapshot.docs[i].data() as Map<String, dynamic>;

          NotificationModel notification = NotificationModel.fromMap(docData);
if(notification.adminreply==true){
  notificationlist.add(notification);
  print("Notification data: ${docData}");
}

        }
      } else {
        print('No notifications found for this userid.');
      }

  }
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
    _loadUserData();
    super.initState();

  }
int x=0;
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
              "الأشعارات".tr,
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
      body:notificationlist.isNotEmpty?Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 25.0, left: 25, top: 15, bottom: 12),
              child: GestureDetector(
                onTap: (){
setState(() {
  x=1;
});
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                        x<1?  Visibility(
                            child: Padding(
                              padding:  EdgeInsets.only(left: 5,right: 5),
                              child: Container(

                                child: ClipOval(
                                  child: Icon(
                                    Icons.circle,
                                    size: 15,
                                    color: Color(0xFFEB5757),
                                  ),
                                ),
                              ),
                            ),
                          ):Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text('تم تأكيد الحجز بنجاح', style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF091C3F)
                              ),),
                              SizedBox(width: 12,),
                              Image.asset(
                                'assets/images/notification-bing.png.png',
                                height: 18,
                                width: 18,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 6,)
                            ],
                          ),

                        ],
                      )
                      ),
                      Padding(
                        padding:  EdgeInsets.only(right: 34.0,top: 5),
                        child: Text('Aug 12, 2020 at 12:08 PM', style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 0),
                        child: Divider(
                          // color: Color(0xFF091C3F14),
                          color: Colors.grey.shade300,

                          // Adjust the color of the line as needed
                          thickness:
                          1, // Adjust the thickness of the line as needed
                        ),
                      ),
                    ]
                            ),
              ),
          ),
          )
        ],
      ):Container(),
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

