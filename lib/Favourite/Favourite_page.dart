import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Controller/NavigationController.dart';
import '../Favourite_model/AddPlaygroundModel.dart';
import '../Home/HomePage.dart';
import '../Menu/menu.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';
class FavouritePage extends StatefulWidget {
  @override
  State<FavouritePage> createState() {
    return FavouritePageState();
  }
}

class FavouritePageState extends State<FavouritePage> {
  final NavigationController navigationController = Get.put(NavigationController());
  late List<AddPlayGroundModel> allplaygrounds = [];
  String idddddd='';
  bool _isLoading = true;
  List<Favouritemodel>favlist=[];
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> getfavdata() async {
    try {
      CollectionReference fav =
      FirebaseFirestore.instance.collection("Favourite");

      QuerySnapshot querySnapshot = await fav.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          Favouritemodel favourite = Favouritemodel.fromMap(userData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String Phone011=prefs.getString('phonev')??'';
          print("phone011$Phone011");
          print("user${user?.phoneNumber}");
          if (favourite.user_phone?.replaceAll(RegExp(r'\D'), '') == user?.phoneNumber?.replaceAll(RegExp(r'\D'), '') ||
              favourite.user_phone?.replaceAll(RegExp(r'\D'), '') == Phone011.replaceAll(RegExp(r'\D'), '')) {
            favlist.add(favourite);
            print("Fav Id : ${document.id}"); // Print the playground ID
            print('Fav list: $favlist');
            print("allplaygrounds[i] : ${favourite}"); // Print the playground
            // Store the document ID in the AddPlayGroundModel object
            favourite.id = document.id;
            print("favouriteid${favourite.id}");
            print("favourite${favourite.playground_id}");
          } else {
            print("this user not have favourite playground");
          }
        }
        print("All Fav list: $favlist"); // Print all playgrounds
      }
    } catch (e) {
      print("Error getting playground: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    getfavdata();
  }
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
          idddddd = document.id;
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
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
              'المفضلات',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                height: 29.98 / 16,
                letterSpacing: 0.04,
                color:  Color(0xFF334154), // Add this line
              ),
            ),
            centerTitle: true, // Center the title horizontally
            leading: IconButton(
              onPressed: () {
                // Get.back();
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
                padding: const EdgeInsets.only(right: 18.0),
                child: Image.asset('assets/images/notification.png', height: 28, width: 28,),

              ),
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

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4AD080),))
          : SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              for (var i = 0; i < favlist.length; i++)
                GestureDetector(
                  onTap: (){
                    print("favlist${favlist[i].playground_id}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaygroundName(favlist[i].playground_id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0,left: 8),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 4, // Adjust elevation to control the shadow
                        margin: EdgeInsets.all(8), // Adjust margin as needed
                        child: Stack(
                          children: [
                            Container(
                              // height: 163,
                              // width: 274,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                shape: BoxShape.rectangle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0), // Clip to match card radius
                                child:Image.network(
                                  favlist[i].img![0],
                                  height: 163,
                                  width: MediaQuery.of(context).size.width,
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
                                favlist[i].playground_name!,
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
                  ),
                ),
            ],
          ),
        ),
      )


    );
  }
}