import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'group2.dart';
import 'modelofgroup.dart';

class My_group extends StatefulWidget {
  @override
  State<My_group> createState() {
    return My_groupState();
  }
}

class My_groupState extends State<My_group> {
  late List<User1> user1 = [];
  List<GroupModel2> stordataofgroup = [];
  User? user = FirebaseAuth.instance.currentUser;
  bool isConnected = true; // Default to true assuming there's internet at start
  bool isLoading = true;
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
        docId = playerDoc.id; // Get the docId of the matching Phoone number
        print("Document ID for the Phoone number: $docId");
      await  getUserGroup(docId);
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
  Future<void> getUserGroup(String id) async {
    try {

      CollectionReference playerchat =
          FirebaseFirestore.instance.collection('teamData');

      QuerySnapshot querySnapshot = await playerchat
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<userDataofgroup> groupdata = querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return userDataofgroup.fromMap(userData);
        }).toList();

        print("GroupModel : $groupdata");
        await getGroupdata(groupdata[0].TeamId!);
      }
    } catch (e) {
      print("Error getting user: $e");
    } finally {
      isLoading = false;
      setState(() {});
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
  Future<void> getGroupdata(String adminid) async {
    try {
      CollectionReference playerchat =
          FirebaseFirestore.instance.collection('MyTeam');
      print("idddddddddddddddddddddddddddd $adminid");

      DocumentSnapshot documentSnapshot = await playerchat.doc(adminid).get();
      print("ffffffffffffffffffff${documentSnapshot.exists}");

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          GroupModel2 group = GroupModel2.fromMap(data);
          stordataofgroup.add(group);

          print("documentSnapshot : ${documentSnapshot.data().toString()}");
          print("shoka dataaaaaaaa ${stordataofgroup[0]}");
        }
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }



  @override
  void initState() {
    checkInternetConnection();

    super.initState();

    _loadUserData();

    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final Searchcontrol = TextEditingController();
  late List<AddPlayGroundModel> allplaygrounds = [];
  int _currentIndex = 3;
  int _currentIndexcarousel_slider = 0;
  final PageController _pageController = PageController();

  final NavigationController navigationController =
      Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, right: 8, left: 8),
          // Add padding to the top of the title
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
            centerTitle: true,
            // Center the title horizontally
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
                color: Color(0xFF62748E),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
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
      backgroundColor: Colors.white,
      body: isConnected?SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                      color: Colors.green,
                                        ),
                    ))
                : stordataofgroup.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10, right: 20, left: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            shape: BoxShape.rectangle,
                            color: Color(0xFFF0F6FF),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.7),
                                // Increase opacity for a darker shadow
                                spreadRadius: 0,
                                // Increase spread to make the shadow larger
                                blurRadius: 2,
                                // Increase blur radius for a more diffused shadow
                                offset: Offset(0,
                                    0), // Increase offset for a more pronounced shadow effect
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 33.0),
                                child: Image.asset(
                                  'assets/images/callgroup.png',
                                  color: Colors.green,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 14.0, right: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            "${stordataofgroup[0].name!}",
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF334154),
                                            ),
                                          ),
                                        ),

                                        Text(
                                          stordataofgroup[0].phone!,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        )

                                        // You can show a placeholder or nothing if the list is empty.
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 22.0,right: 10),
                                    child: ClipOval(
                                      child: Image(image:  NetworkImage(
                                        stordataofgroup[0].profileImage!,

                                        // Adjust size as needed
                                      ),
                                        fit: BoxFit.fitWidth,
                                        height: 32,
                                        width: 32,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    :Center(
                      child: SizedBox(
                                    height: MediaQuery.of(context).size.height/2,
                        child: Stack(
                          children: [
                            Center(
                              child: Align(
                                            alignment: Alignment.bottomCenter,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                    Opacity(
                                      opacity: 0.5,
                                      child: Image.asset(
                                        "assets/images/Group4.png",
                                      width: 200,
                                      height: 200,
                                      ),
                                    ),
                                      Text(
                                        'لم يتم أضافتك فى مجموعة حتى الأن',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14.62,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF181A20),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
            ,
          ],
        ),
      ):_buildNoInternetUI(),

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
  Widget _buildNoInternetUI() {
    // Your UI design when there's no internet connection
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
                'assets/images/nointernetconnection.png',
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
