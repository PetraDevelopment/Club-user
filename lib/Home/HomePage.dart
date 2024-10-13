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
import '../Menu/menu.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import '../Register/SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../search/search_page.dart';
import 'Userclass.dart';
import 'carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
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

 int selectedIndex=3;
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
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Padding(
          padding: const EdgeInsets.only(top: 66.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 33.0),
                      child: Image.asset(
                        'assets/images/notification.png',
                        height: 28,
                        width: 28,
                      ),
                    ),
                    _isLoading?   Shimmer.fromColors(
            baseColor: Colors.grey[300]!, // base color
            highlightColor: Colors.grey[300]!,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 14.0, right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "مرحبا بك".tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7D90AC),
                                  ),
                                ),
                                user1.isNotEmpty && user1[0].name!.isNotEmpty
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
                                // You can show a placeholder or nothing if the list is empty.
                              ],
                            ),
                          ),
                          user1.isNotEmpty && user1[0].img!=null&&user1[0].img!=""? Padding(
                            padding: const EdgeInsets.only(right: 34.0),
                            child:ClipOval(
                              child: Image(image:  NetworkImage(
                                user1[0].img!,
                              
                                // Adjust size as needed
                              ),     width: 63,
                                height: 63,
                                fit: BoxFit.fitWidth,),
                            )
                          ):
                          Padding(
                            padding: const EdgeInsets.only(right: 34.0),

                            child: Image.asset(
                              "assets/images/profile.png",
                              width: 63,
                              height: 63,
                              // Adjust size as needed
                            ),
                          ),
                        ],
                      ),
                    ):Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(bottom: 14.0, right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "مرحبا بك".tr,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7D90AC),
                                ),
                              ),
                              user1.isNotEmpty && user1[0].name!.isNotEmpty
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
                              // You can show a placeholder or nothing if the list is empty.
                            ],
                          ),
                        ),

                        user1.isNotEmpty && user1[0].img!=null&&user1[0].img!=""?
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profilepage(),
                                settings: RouteSettings(arguments: {
                                  'from': 'home'
                                }),
                              ),
                            );
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(right: 34.0),
                              child:ClipOval(
                                child: Image(image:  NetworkImage(
                                  user1[0].img!,

                                  // Adjust size as needed
                                ),    width: 63,
                                  height: 63,
                                  fit: BoxFit.fitWidth,),
                              )
                          ),
                        ):
                        Padding(
                          padding: const EdgeInsets.only(right: 34.0),
                          child: Image.asset(
                            "assets/images/profile.png",
                            width: 63,
                            height: 63,
                            // Adjust size as needed
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                        GestureDetector(
                          onTap: (){
                            print("kokokoko");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Searchpage(),
                                //   settings: RouteSettings(arguments: {
                                //   'from': 'search_page'
                                // }),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Image.asset('assets/images/search.png',height: 20,width: 25,),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20,top: 7,bottom: 7),
                                  child: TextField(
                                      controller: Searchcontrol,
                                     readOnly: true,
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
                                      // onChanged: (value) {
                                      //
                                      //   setState(() {
                                      //
                                      //   });
                                      // },
                                      // onSubmitted: (value) {
                                      //   // Move focus to the next text field
                                      //
                                      // },
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),



                  ),
                ),
                SizedBox(height: 10,),

                Stack(
                  children: [
                    Padding(

                      padding: const EdgeInsets.only(right: 5,left: 5,bottom: 10),

                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 165.0,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.7,
                          initialPage: 1,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {},
                          scrollDirection: Axis.horizontal,
                          reverse: true, // Reverses the scroll direction

                        ),
                        items: [
                          for (int i = 0; i < 3; i++)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 5), // Add space between items
                              child: Stack(
                                children: [
                                  Material(
                                    elevation: 4, // Elevation of 4
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                      height: 163,
                                      width: 274,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        shape: BoxShape.rectangle,

                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20.0),
                                        child: Image.asset(
                                          'assets/images/newwadi.png',
                                          height: 163,
                                          width: 274,
                                          fit: BoxFit.cover,
                                        ),
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
                                      'ملاعب نادى الرجاء', // Updated English text
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
                        ],
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(right: 25,left: 26,top: 10,bottom: 10,),
                  child: Text(
                    "حجوزاتى".tr,
                    style: TextStyle(
                      color: Color(0xFF495A71),
                      fontFamily: 'Cairo',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0,bottom: 12,top: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // Reverses the scroll direction

                    child:Row(
                      children: [
                        for (var i = 0; i < 5; i++) // Repeat the container 5 times
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 12,bottom: 3), // Adds spacing between containers
                            child: Container(

                              width: 252,
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
                                            )

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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "13-08-2024".tr,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF7D90AC),
                                            ),
                                          ),
                                          SizedBox(width: 19,),
                                          RichText(
                                            textDirection: TextDirection.rtl, // Set the overall text direction to RTL
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
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
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                      Text(
                                        "  التكلفة أجمالية   ".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF334154),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Container(
                                          height: 29,
                                          width: 92,
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
                                          width: 75,
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
                      ],
                    ),

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 25,left: 26,top: 10,bottom: 10,),
                  child: Text(
                    "الملاعب القريبة".tr,
                    style: TextStyle(
                      color: Color(0xFF495A71),
                      fontFamily: 'Cairo',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Reverses the scroll direction

                  child:allplaygrounds.isNotEmpty? Row(

                    children: [
                      for (var i = 0; i < allplaygrounds.length; i++)
                        GestureDetector(
                          onTap: (){
                            print("111114${allplaygrounds[i].id!}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaygroundName(allplaygrounds[i].id!),
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
                                  width: 274,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0), // Clip to match card radius
                                    child:Image.network(
                                      // Check if img is a list and has at least one image, otherwise use it as a string
                                      allplaygrounds[i].img!.isNotEmpty
                                          ? allplaygrounds[i].img![0] // Use the first image in the list (or the only image if it's a single string turned into a list)
                                          :  "assets/images/newground.png",// Fallback to an empty string if no image is available
                                      height: 163,
                                      width: 274,
                                      fit: BoxFit.fill, // Ensure the image covers the container
                                    )
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
                                    allplaygrounds[i].playgroundName!,
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
                  ):Container(),
                ),
      SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(right: 25,left: 26,top: 10,bottom: 10,),
                  child: Text(
                    "الملاعب العلى تقييم".tr,
                    style: TextStyle(
                      color: Color(0xFF495A71),
                      fontFamily: 'Cairo',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Reverses the scroll direction

                  child: Row(
                    children: [
                      for (var i = 0; i < allplaygrounds.length; i++)
                        GestureDetector(

                          onTap: (){
                            print("objectidddddd${allplaygrounds[i].id!}");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                   builder: (context) => PlaygroundName(allplaygrounds[i].id!),

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
                                  width: 274,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0), // Clip to match card radius
                                    child:Image.network(
                                      // Check if img is a list and has at least one image, otherwise use it as a string
                                      allplaygrounds[i].img!.isNotEmpty
                                          ? allplaygrounds[i].img![0] // Use the first image in the list (or the only image if it's a single string turned into a list)
                                          :  "assets/images/newground.png",// Fallback to an empty string if no image is available
                                      height: 163,
                                      width: 274,
                                      fit: BoxFit.fill, // Ensure the image covers the container
                                    )
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
                                  allplaygrounds[i].playgroundName!,
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
                SizedBox(height: 20,),
              ],
            ),
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
      ),
    );
  }
}
