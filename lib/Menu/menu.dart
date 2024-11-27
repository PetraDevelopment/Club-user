import 'package:club_user/shimmer_effect/shimmer_lines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import 'package:http/http.dart' as http;
import '../../Register/SignInPage.dart';
import '../../Register/SignUp.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Favourite/Favourite_page.dart';
import '../Home/Userclass.dart';
import '../My_group/my_group.dart';
import '../my_reservation/my_reservation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../notification/model/modelsendtodevice.dart';
import '../notification/model/send_modelfirebase.dart';
import '../notification/notification_page.dart';
import '../profile/profile_page.dart';
class menupage extends StatefulWidget {
  @override
  State<menupage> createState() {
    return menupageState();
  }
}
class menupageState extends State<menupage> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  String adminoooken="";
  String convertTo12HourFormat(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  final NavigationController navigationController = Get.put(NavigationController());

  String apiEndpoint = 'http://192.168.0.42/notificaions/send_notification.php';
  Future<http.Response> sendNotification(NotificationData data) async {
    final uri = Uri.parse(apiEndpoint);
    final response = await http.post(uri, body: data.toMap());
    return response;
  }
  Future<void> sp(String ms,title,d_token) async {
    final notificationData = NotificationData(
        message: ms,
        title: title,
        deviceToken: d_token);
    final response = await sendNotification(notificationData);

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Error sending notification: ${response.statusCode}');
      print(response.body);
    }
  }


  Future<void> deleteUser(String useridd) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if ( useridd!= null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QuerySnapshot querySnapshotbook = await firestore.collection('booking')
            .where('userID', isEqualTo: docId)
            .get();
        CollectionReference fav = FirebaseFirestore.instance.collection('Favourite');
        CollectionReference teamData = FirebaseFirestore.instance.collection('teamData');
        CollectionReference accepted = FirebaseFirestore.instance.collection('accepted');
        DocumentSnapshot documentSnapshot = await firestore.collection('Users').doc(useridd).get();
        QuerySnapshot querySnapshotfav = await fav.where('userid', isEqualTo: useridd).get();
        QuerySnapshot querySnapshotteamData = await teamData.where('userId', isEqualTo: useridd).get();
        QuerySnapshot querySnapshotaccepted = await accepted.where('userId', isEqualTo: useridd).get();
        if (documentSnapshot.exists) {

            await documentSnapshot.reference.delete();
            if(querySnapshotbook.docs.isNotEmpty){
              for (var doc in querySnapshotbook.docs){
                await doc.reference.delete();
                print("querySnapshotbook data with user id $useridd deleted successfully.");

              }
            }
            if(querySnapshotaccepted.docs.isNotEmpty){
              for (var doc in querySnapshotaccepted.docs){
                await doc.reference.delete();
                print("Favorite data with phone number $useridd deleted successfully.");

              }
            }
            if(querySnapshotfav.docs.isNotEmpty){
              for (var doc in querySnapshotfav.docs){
                await doc.reference.delete();
                print("Favorite data with phone number $useridd deleted successfully.");

              }
            }
            if(querySnapshotteamData.docs.isNotEmpty){
              for (var doc in querySnapshotteamData.docs){
                await doc.reference.delete();
                print("teamData data with phone number $useridd deleted successfully.");

              }
            }

            print("Document with phone number $useridd deleted successfully.");

          await prefs.clear();
          print("SharedPreferences cleared.");
          await FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
                (Route<dynamic> route) => false,
          );
        }
        else {
          print("No matching document found in Firestore.");
        }

      } else {
        print("No valid phone number available.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
  bool _isLoading = true;
  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }
  late List<User1> user1 = [];
  bool isConnected=true;
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
  String docId='';
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
        docId = playerDoc.id;
        print("Document ID for the Phoone number: $docId");
        Map<String, dynamic> userData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        User1 user = User1.fromMap(userData);
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
    checkInternetConnection();
    _loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(HomePage());
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Padding(
            padding: EdgeInsets.only(top: 25.0,right: 8,left: 8),
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
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Get.off(HomePage());
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

                    isConnected?    Padding(
                      padding: const EdgeInsets.only(left: 12,top: 11),
                      child:_isLoading?Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/profile.png",
                              width: 35,
                              height: 35,
                            ),
                            SizedBox(width: 10),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          user1.isNotEmpty && user1[0].img!=null &&user1[0].img!=""? Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                            child: ClipOval(
                              child: Image(image:  NetworkImage(
                                user1[0].img!,
                              ),    width: 63,
                                height: 63,
                                fit: BoxFit.fitWidth,),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                            child: Image.asset(
                              "assets/images/profile.png",
                              width: 60,
                              height: 50,
                            ),
                          ),
                          SizedBox(width: 10),

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
                    ): Padding(
                      padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                      child: Image.asset(
                        "assets/images/profile.png",
                        width: 60,
                        height: 50,
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
                    thickness:
                    1,
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
                    child: Container(
                      color: Colors.transparent,
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

                    thickness:
                    1,
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
                    child: Container(
                      color: Colors.transparent,
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
                    thickness: 1,
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
                  child: Container(
                    color: Colors.transparent,
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
                    thickness:
                    1,
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
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(right: 22.0, left: 22, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

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
                    thickness:
                    1,
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(
                      right: 22.0, left: 22, top: 5, bottom: 5),
                  child: GestureDetector
                    (
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notification_page()),

                      );
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

                    color: Colors.grey.shade300,
                    thickness:
                    1,
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
                    color: Colors.grey.shade300,
                    thickness:
                    1,
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

                                      await deleteUser(docId);


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
                .updateIndex(index);
            switch (index) {
              case 0:

                break;
              case 1:
                Get.to(() => my_reservation())?.then((_) {
                  navigationController
                      .updateIndex(1);
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
      return true;
    } else {
      NavigationController().updateIndex(3);
      Get.off(HomePage());
      return false;
    }
  }
  Widget _buildNoInternetUI() {

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height/5,

          ),
          Center(
            child: Container(
              height: 200,
              child: Image.asset(
                'assets/images/wifirr.png',
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