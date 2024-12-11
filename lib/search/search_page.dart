import 'package:club_user/profile/profile_page.dart';
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
import '../notification/notification_page.dart';
import '../playground_model/AddPlaygroundModel.dart';

class Searchpage extends StatefulWidget {
  @override
  State<Searchpage> createState() {
    return SearchpageState();
  }
}

class SearchpageState extends State<Searchpage> {
  late List<User1> user1 = [];
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
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
  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
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

  List<AddPlayGroundModel> searchPlaygrounds = [];

  Future<void> serarchforplayground() async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        String userInput = Searchcontrol.text;

        setState(() {
          searchPlaygrounds = [];

          for (QueryDocumentSnapshot document in querySnapshot.docs) {
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
            AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

            if (user.playgroundName!.toLowerCase().contains(userInput.toLowerCase().trim())) {
              searchPlaygrounds.add(user);
              user.id = document.id;
              print("shimaaaaaaaaaaaaaaaaa${user.id}");
            }
          }
        });

        if (searchPlaygrounds.isNotEmpty) {
          print("searchPlaygrounds: $searchPlaygrounds");
        } else {
first++;
          print("this play round not found");
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
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

  int selectedIndex=3;
  final Searchcontrol = TextEditingController();
  late List<AddPlayGroundModel> allplaygrounds = [];
  int _currentIndex = 3;
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
          print("PlayGroung Id : ${document.id}");

          print("allplaygrounds[i] : ${allplaygrounds.last}");
          user.id = document.id;
          print("Docummmmmm${user.id}");
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  final NavigationController navigationController = Get.put(NavigationController());
  double opacity = 1.0;
int first=0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Padding(
            padding: EdgeInsets.only(top: 25.0,  right: 12, left: 12),

            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "البحــــــث".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,

              leading: IconButton(
                onPressed: () {
                  Get.back();
                 },
                icon: Icon(
                  Directionality.of(context) == TextDirection
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios_new_rounded,


                  color: Color(0xFF62748E),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Notification_page()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      'assets/images/notification.png', height: 28, width: 28,),
                  ),
                ),
              ],
            ),
          ),
        ),
        body:isConnected? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
        
              SizedBox(
                height: 20,
              ),
        
              Padding(
                padding: const EdgeInsets.only(left: 33,right: 33),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    shape: BoxShape.rectangle,
                    color: Color(0xFFF1F1F1),
        
                    border: Border.all(
                      color: Color(0xFFB8B8B8),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  child:
                  Row(
                    children: [


                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20,top: 7,bottom: 7),
                          child: TextField(
                            controller: Searchcontrol,
textDirection: TextDirection.rtl,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(

                              hintText: 'البحث'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Color(0xFFC1C1C1),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  searchPlaygrounds = [];
                                });
                              } else {
                                serarchforplayground();
                              }
                            },
                            onSubmitted: (value) {
                              serarchforplayground();
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          serarchforplayground();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Image.asset('assets/images/search.png',height: 20,width: 25,),
                        ),
                      ),
                    ],
                  ),
        
        
        
                ),
              ),
              SizedBox(height: 10,),

              searchPlaygrounds.isNotEmpty?    SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,

                child: Center(
                  child: Column(
                    children: [
                      for (var i = 0; i <searchPlaygrounds.length; i++)
                        GestureDetector(

                          onTap: (){
                            print("objectidddddd${searchPlaygrounds[i].id!}");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaygroundName(searchPlaygrounds[i].id!),
                                settings: RouteSettings(arguments: {
                              'from': 'search'
                              }),

                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.all(8),
                            child: Stack(
                              children: [
                                Container(
                                  height: 163,
                                  width:   MediaQuery.of(context).size.width/1.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.network(
                                      searchPlaygrounds[i].img![0],
                                      height: 163,
                                      width: 274,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 0,
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0x1F8C4B).withOpacity(0.0),
                                          Color(0x1F8C4B).withOpacity(1.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 113,
                                  right: 40,
                                  left: 55,
                                  child: Text(
                                    searchPlaygrounds[i].playgroundName!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ):
              first>0? Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 142.51,
                          width: 142.51,

                          child:  Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              "assets/images/searchzero.png",

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          'لا يوجد نتائج لهذا البحث',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.62,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF181A20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ):Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 142.51,
                          width: 142.51,

                          child:  Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              "assets/images/searchzero.png",

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Opacity(
                        opacity: 0.2,
                        child: Text(
                          'لا يوجد نتائج لهذا البحث',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.62,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF181A20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ):_buildNoInternetUI(),

        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 2,

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
            setState(() {
              selectedIndex = index;

              opacity= 0.5;
            });

            switch (index) {
              case 0:
                Get.to(() => menupage())?.then((_) {
                  navigationController
                      .updateIndex(0);
                });
                break;

              case 1:
                Get.to(() => my_reservation())?.then((_) {
                  navigationController
                      .updateIndex(1);
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

      ),
    );
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
