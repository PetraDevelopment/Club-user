import 'package:club_user/location/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/NavigationController.dart';
import '../Favourite/Favourite_page.dart';
import '../Favourite_model/AddPlaygroundModel.dart';
import '../Home/HomePage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../Home/Userclass.dart';
import '../Menu/menu.dart';
import '../Register/SignInPage.dart';
import 'package:shimmer/shimmer.dart';

import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../booking_playground/try/book_playground_page.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../shimmer_effect/shimmer_lines.dart';

class PlaygroundName extends StatefulWidget {
  String? id;
  PlaygroundName(this.id);
  @override
  State<PlaygroundName> createState() {
    return PlaygroundNameState();
  }
}

class PlaygroundNameState extends State<PlaygroundName>
    with SingleTickerProviderStateMixin {
  final NavigationController navigationController =
      Get.put(NavigationController());
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true; // flag to control shimmer effect
  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }
List<Favouritemodel>favlist=[];
  late List<User1> user1 = [];
  String idddddd='';
  Future<void> _sendData() async {

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
    if (allplaygrounds.isNotEmpty && allplaygrounds[0].favourite==true) {
      await FirebaseFirestore.instance.collection('Favourite').add({
        'playground_id':  widget.id!,
        'playground_name':allplaygrounds[0].playgroundName!,
        'user_phone': user?.phoneNumber!,
        'img':allplaygrounds[0].img!

      });


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
  Future<void> getfavdata() async {
    try {
      CollectionReference fav =
      FirebaseFirestore.instance.collection("Favourite");

      QuerySnapshot querySnapshot = await fav.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          Favouritemodel favourite = Favouritemodel.fromMap(userData);

          favlist.add(favourite);
          print("Fav Id : ${document.id}"); // Print the latest playground

          print("allplaygrounds[i] : ${favlist.last}"); // Print the latest playground
// Store the document ID in the AddPlayGroundModel object
          // user.id = document.id;
          favourite.id = document.id;
          print("favourite${favourite.id}");
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
  double opacity = 1.0; // Initial opacity value

  late List<AddPlayGroundModel> allplaygrounds = [];
  Future<void> getPlaygroundbyid() async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          if (document.id == widget.id) {
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
            AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

            allplaygrounds.add(user);
            print("PlayGroung Id : ${document.id}"); // Print the latest playground

            print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground

            // Store the document ID in the AddPlayGroundModel object
            idddddd = document.id;
            print("Docummmmmm$idddddd");
          }
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
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
    getfavdata();
    getPlaygroundbyid();
    _loadUserData();
    print("Docummmmmmentis${widget.id}");
    // Now you can access the user1 list
    // print('User data44444: ${user1[0].name}');
    setState(() {}); // Call setState to rebuild the widget tree
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                // Full-width image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  child: allplaygrounds.isNotEmpty? Image.network(
                    allplaygrounds[0].img!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover, // Ensure the image covers the container
                  ):Image.asset(
                    'assets/images/newwadi.png',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.fill, // Ensure image covers the container
                  ),
                ),
                // Gradient overlay container to add shadow or overlay effect
                Positioned(
                  top: 5,
                  // Match the top position of the text
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    // Prevents this container from capturing any gestures
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            // Start with transparent
                            Color(0x1F8C4B).withOpacity(0.0),
                            // Start with #1F8C4B at 0% opacity (fully transparent)
                            Color(0x1F8C4B).withOpacity(1.0),
                            // End with #1F8C4B at 100% opacity (fully opaque)
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
                ),
                // Top left icon with green shadow
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 25),
                    onPressed: () {
                      print("Back button pressed"); // Debugging statement
                      Get.back();// Navigate back to the previous page
                    },
                  ),
                ),
                // Top right icon with green shadow
              ],
            ),
            SizedBox(
              height: 22,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
    onTap: () async {
    setState(() {
    allplaygrounds[0].favourite = true;
    });
    print("hghhhhh${widget.id}");
    await _sendData();
    },
    child: Padding(
    padding: const EdgeInsets.only(left: 20.0),
    child: Icon(
    allplaygrounds.isNotEmpty && allplaygrounds[0].favourite!
    ? Icons.favorite
        : Icons.favorite_outline,
    color: const Color(0xFF4AD080),
    size: 25,
    ),
    ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 13, top: 8, bottom: 8),
                  child:  allplaygrounds.isNotEmpty?Text(
                    allplaygrounds[0].playgroundName!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF064821),
                    ),
                  ): Text(
                    'ملعب وادى دجـــلة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF064821),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 26.0, left: 26,bottom: 20),

              child: Text(
                "بيانات الملعب".tr,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF495A71)),
              ),
            ),
            // Data in Column after the text 'ملعب وادى دجـــلة'
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
  width:   MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30.0),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            allplaygrounds.isNotEmpty?Text(
                              allplaygrounds[0].playType!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF106A35),
                              ),
                            ):   Text(
                              'كرة الطائرة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF106A35),
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              "assets/images/volly.png",
                              color: Color(0xFF106A35),
                              height: 20,
                              width: 22,
                            )
                          ],
                        ),
                        SizedBox(width: 100,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                      allplaygrounds.isNotEmpty ? Text(
                        allplaygrounds[0].width!.length<5 && allplaygrounds[0].length!.length<5?
                        '   ${allplaygrounds[0].width!}x${allplaygrounds[0].length!} م ':

                        '   ${allplaygrounds[0].width!.substring(0,4)}x${allplaygrounds[0].length!.substring(0,4)} م ',
                        textDirection: TextDirection.rtl,
                        // Ensures the text direction is RTL

                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF106A35),
                        ),
                      ):
                      Text(
                      '   20x50 م ',
                        textDirection: TextDirection.rtl,
                        // Ensures the text direction is RTL
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF106A35),
                        ),
                      ),
                            SizedBox(width: 8),
                            Image.asset(
                              "assets/images/size.png",
                              color: Color(0xFF106A35),
                              height: 13,
                              width: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child:allplaygrounds.isNotEmpty? Text(
                    'السعر : ' + '${allplaygrounds[0].bookTypes?[0].costPerHour} / ساعة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF106A35),
                    ),
                  ):Text(
                    'السعر : ' + '300 / ساعة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF106A35),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  "assets/images/hour.png",
                  color: Color(0xFF106A35),
                  height: 19,
                  width: 23,
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 30.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                shape: BoxShape.rectangle,
                                color: Color(0xFF106A35)),
                            child: Icon(Icons.share,
                                color: Colors.white, size: 20)),
                        SizedBox(width: 40,),
                        GestureDetector(
                          onTap: (){
                            print("locattttion${allplaygrounds[0].location!}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Maps()),
                            );

                          },
                          child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  shape: BoxShape.rectangle,
                                  color: Color(0xFF106A35)),
                              child: Icon(Icons.location_on_outlined,
                                  color: Colors.white, size: 20)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 100,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      allplaygrounds.isNotEmpty? Text(
                       allplaygrounds[0].location!.length>12? allplaygrounds[0].location!.substring(0,10):allplaygrounds[0].location!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF106A35),
                        ),
                      ):  Text(
                'أسيوط الجديدة',
                style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF106A35),
                ),
                ),
                      SizedBox(width: 8), // Space between icon and text
                      Icon(Icons.location_on_outlined,
                          color: Color(0xFF106A35), size: 20),
                    ],
                  ),
                ],
              ),
            ),
            // Pricing and location info

            SizedBox(
              height: 28,
            ),
            allplaygrounds.isNotEmpty &&allplaygrounds[0].notes!=null &&allplaygrounds[0].notes!.isNotEmpty ?
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Padding(
              padding: const EdgeInsets.only(right: 26.0, left: 26),
              child: Text(
                textAlign: TextAlign.end,
                "الملاحظات".tr,
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
            Padding(
              padding: const EdgeInsets.only(right: 26.0, left: 26),
              child: Text(
               allplaygrounds[0] .notes!,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF495A71)),
              ),
            ),
              SizedBox(height: 30),
          ],):Container(),

            allplaygrounds.isNotEmpty &&allplaygrounds[0].availableFacilities!=null &&allplaygrounds[0].availableFacilities!.isNotEmpty ?
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 26.0, left: 26),
                  child: Text(
                    "المرفقات".tr,
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
                Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                'كافتيريا',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF106A35),
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                "assets/images/ion_cafe.png",
                                color: Color(0xFF106A35),
                                height: 20,
                                width: 22,
                              )
                            ],
                          ),
                          SizedBox(width: 110,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'حمامات',
                                textDirection: TextDirection.rtl,
                                // Ensures the text direction is RTL

                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF106A35),
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                "assets/images/bathroom.png",
                                color: Color(0xFF106A35),
                                height: 13,
                                width: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),// Adds space between the text and the image
                SizedBox(
                  height: 12,
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'موقف سيارات',
                                textDirection: TextDirection.rtl,
                                // Ensures the text direction is RTL

                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF106A35),
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                "assets/images/car-door.png",
                                color: Color(0xFF106A35),
                                height: 20,
                                width: 25,
                              ),
                            ],
                          ),
                          SizedBox(width: 40,),
                          Row(
                            children: [
                              Text(
                                'غرف تغيير الملابس',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF106A35),
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                "assets/images/materialcloth.png",
                                color: Color(0xFF106A35),
                                height: 20,
                                width: 22,
                              )
                            ],
                          ),


                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ):Container(),

            GestureDetector(
              onTap: (){
                print("ppppppppppppppppppppppppp${widget.id}");
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => book_playground_page(widget.id),
                //   ),
                // );
              },
              child: Center(
                child: Container(
                  height: 50,
                  width: 320,
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
                      "أحجـــــز الأن".tr,
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
            SizedBox(
              height: 12,
            ),

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
        color: Color(0xFF064821),
        buttonBackgroundColor: Color(0xFFBACCE6),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          navigationController
              .updateIndex(index);
          setState(() {
            // Update opacity based on the selected index
            opacity = index == 2 ? 0.5 : 1.0;
          });// Update the index dynamically
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
