import 'package:club_user/profile/profile_page.dart';
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

class Searchpage extends StatefulWidget {
  @override
  State<Searchpage> createState() {
    return SearchpageState();
  }
}

class SearchpageState extends State<Searchpage> {
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
  // String searchcontent="";
  // Future<void> serarchforplayground() async {
  //   try {
  //     CollectionReference playerchat =
  //     FirebaseFirestore.instance.collection("AddPlayground");
  //
  //     QuerySnapshot querySnapshot = await playerchat.get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       String userInput = Searchcontrol.text; // Get the user's input from the TextField
  //
  //       List<AddPlayGroundModel> filteredPlaygrounds = [];
  //
  //       for (QueryDocumentSnapshot document in querySnapshot.docs) {
  //         Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
  //         AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
  //
  //         if (user.playgroundName!.toLowerCase().contains(userInput.toLowerCase())) {
  //           filteredPlaygrounds.add(user);
  //         }
  //       }
  //
  //       if (filteredPlaygrounds.isNotEmpty) {
  //         // Show the design with the filtered playgrounds
  //         searchcontent=filteredPlaygrounds.last.playgroundName!;
  //         print("searchcontent$searchcontent");
  //       } else {
  //
  //         print("this play round not found");
  //         // Show the "this play round not found" text
  //         // return Text("this play round not found");
  //       }
  //     }
  //   } catch (e) {
  //     print("Error getting playground: $e");
  //   }
  // }
  List<AddPlayGroundModel> searchPlaygrounds = [];

  Future<void> serarchforplayground() async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        String userInput = Searchcontrol.text; // Get the user's input from the TextField

        setState(() {
          searchPlaygrounds = []; // Clear the list before searching

          for (QueryDocumentSnapshot document in querySnapshot.docs) {
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
            AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

            if (user.playgroundName!.toLowerCase().contains(userInput.toLowerCase())) {
              searchPlaygrounds.add(user);
              user.id = document.id;
              print("shimaaaaaaaaaaaaaaaaa${user.id}");
            }
          }
        });

        if (searchPlaygrounds.isNotEmpty) {
          // Show the design with the filtered playgrounds
          print("searchPlaygrounds: $searchPlaygrounds");
        } else {

          print("this play round not found");
          // Show the "this play round not found" text
          // return Text("this play round not found");
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
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
          child: Padding(
            padding: EdgeInsets.only(top: 25.0, bottom: 12, right: 12, left: 12),
            // Add padding to the top of the title
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "المــلاعب".tr,
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
        body: SingleChildScrollView(
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
                    color: Color(0xFFF1F1F1), // Border color
        
                    border: Border.all(
                      color: Color(0xFFB8B8B8), // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  child:
                  Row(
                    children: [
                      GestureDetector(
                  onTap: (){
                    serarchforplayground();
                  },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.asset('assets/images/search.png',height: 20,width: 25,),
                        ),
                      ),
        
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20,top: 7,bottom: 7),
                          child: TextField(
                            controller: Searchcontrol,
                            // readOnly: true,
                            textAlign: TextAlign.right, // Align text to the right
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
                                  searchPlaygrounds = []; // Clear the list when the search controller is cleared
                                });
                              } else {
                                serarchforplayground(); // Call the search function when the text changes
                              }
                            },
                            onSubmitted: (value) {
                              serarchforplayground(); // Call the search function when the user submits the text field
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
        
        
        
                ),
              ),
              SizedBox(height: 10,),

              searchPlaygrounds.isNotEmpty?    SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true, // Reverses the scroll direction

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

                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 4, // Adjust elevation to control the shadow
                            margin: EdgeInsets.all(8), // Adjust margin as needed
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
                                    borderRadius: BorderRadius.circular(20.0), // Clip to match card radius
                                    child: Image.network(
                                      searchPlaygrounds[i].img![0],
                                      height: 163,
                                      width: 274,
                                      fit: BoxFit.cover, // Ensure image covers the container
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6, // Match the top position of the text
                                  right: 0,
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent, // Start with transparent
                                          Color(0x1F8C4B).withOpacity(0.0), // Start with #1F8C4B at 0% opacity (fully transparent)
                                          Color(0x1F8C4B).withOpacity(1.0), // End with #1F8C4B at 100% opacity (fully opaque)
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
                                  top: 113, // Adjust the top position
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
                                    textAlign: TextAlign.center, // Center text alignment
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ):Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:Container(),
              )),
              SizedBox(height: 20,),
            ],
          ),
        ),

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
        // ),
      ),
    );
  }
}
