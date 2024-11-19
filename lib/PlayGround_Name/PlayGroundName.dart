import 'package:club_user/location/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:share/share.dart';
import '../Controller/NavigationController.dart';
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

import '../Splach/LoadingScreen.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../booking_playground/try/book_playground_page.dart';
import '../model_rate/model_rate.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../shimmer_effect/shimmer_lines.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  bool star = false;
  bool _isLoading = true; // flag to control shimmer effect
  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }
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
  int count = 0;

  List<Favouritemodel> favlist = [];
  late List<User1> user1 = [];
  List<bool> isstared = [false, false, false, false, false];

  String idddddd = '';

  // bool fetchfav = false;
  bool isFavorite = false;

  Future<void> _sendData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
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

    // Assuming you have access to 'allplaygrounds', 'widget.id', 'user.phoneNumber', and 'context'
    if (allplaygrounds.isNotEmpty) {
      if (allplaygrounds[0].favourite == true) {
        // Check if the playground is already a favorite
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? phoneValue = prefs.getString('phonev');
        print("newphoneValue${phoneValue.toString()}");

        if (phoneValue != null && phoneValue.isNotEmpty) {
          try {
            isFavorite = await checkIfFavoriteExists(widget.id!, phoneValue);
          } catch (e) {
            print('Error checking if favorite exists: $e');
            isFavorite = false;
          }
        } else if (user?.phoneNumber != null) {
          try {
            isFavorite =
                await checkIfFavoriteExists(widget.id!, user!.phoneNumber!);
          } catch (e) {
            print('Error checking if favorite exists: $e');
            isFavorite = false;
          }
        }

        if (isFavorite) {
          setState(() {
            _isLoading = true; // set flag to false when data is loaded
          });
          // If the playground is already a favorite, update the existing record
          await updateFavoritePlayground(widget.id!, favlist[0]);
        } else {
          // If the playground is not a favorite, add it to the favorites collection
          if (phoneValue != null && phoneValue.isNotEmpty) {
            await FirebaseFirestore.instance.collection('Favourite').add({
              'playground_id': widget.id!,
              'playground_name': allplaygrounds[0].playgroundName!,
              'user_phone': phoneValue,
              'img': allplaygrounds[0].img!,
              'is_favourite': allplaygrounds[0].favourite!,
            });
            setState(() {
              _isLoading = false; // set flag to false when data is loaded
            });
          } else if (user?.phoneNumber != null) {
            await FirebaseFirestore.instance.collection('Favourite').add({
              'playground_id': widget.id!,
              'playground_name': allplaygrounds[0].playgroundName!,
              'user_phone': user?.phoneNumber!,
              'img': allplaygrounds[0].img!,
              'is_favourite': allplaygrounds[0].favourite,
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الحساب حدث به خطا',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
      }
    }
  }

  Future<bool> checkIfFavoriteExists(
      String playgroundId, String userPhone) async {
    try {
      print("kkkkk$userPhone");
      // Query Firebase to check if the playground is already marked as a favorite
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Favourite')
          .where('playground_id', isEqualTo: playgroundId)
          .where('user_phone', isEqualTo: userPhone)
          .get();

      // Check if any documents match the query
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors that occur during the query process
      print('Error checking if favorite exists: $e');
      return false; // Return false in case of an error
    }
  }

  Future<void> updateFavoritePlayground(
      String playgroundId, Favouritemodel playground) async {
    // Implement the logic to update the existing favorite playground in Firebase
    // You can update the record based on the playgroundId
  }

  Future<void> getfavdata(String phoneNumber) async {
    try {
      CollectionReference fav =
          FirebaseFirestore.instance.collection("Favourite");

      QuerySnapshot querySnapshot = await fav.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          Favouritemodel favourite = Favouritemodel.fromMap(userData);

          if (favourite.user_phone == phoneNumber &&
              favourite.playground_id == widget.id) {
            favlist.add(favourite);
            print("Fav Id : ${document.id}"); // Print the latest playground

            print(
                "allplaygrounds[i] : ${favlist.last}"); // Print the latest playground
            // Store the document ID in the AddPlayGroundModel object
            favourite.id = document.id;
            print("favourite${favourite.id}");
            print("shimaa${favourite.isfav}");

            // Update allplaygrounds[0].favourite
            if (allplaygrounds.isNotEmpty) {
              setState(() {
                allplaygrounds[0].favourite = favourite.isfav;
                print("pppppppppppppppppp${allplaygrounds[0].favourite}");
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }

  Future<void> _loadgetfavdataData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      setState(() {
        _isLoading = true; // set flag to false when data is loaded
      });
      await getfavdata(phoneValue); // simulate data loading
      setState(() {
        _isLoading = false; // set flag to false when data is loaded
      });
    } else if (user?.phoneNumber != null) {
      setState(() {
        _isLoading = true; // set flag to false when data is loaded
      });
      await getfavdata(user!.phoneNumber!.toString()); // simulate data loading
      setState(() {
        _isLoading = false; // set flag to false when data is loaded
      });
    }
  }

  List<User1> userdata = [];
  double opacity = 1.0; // Initial opacity value
  Future<void> deleteFavoriteData() async {
    try {
      // Query Firebase to find the document to delete based on certain conditions
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Favourite')
          .where('playground_id', isEqualTo: widget.id)
          .where('user_phone', isEqualTo: user?.phoneNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Delete the document from Firebase if it exists
        await FirebaseFirestore.instance
            .collection('Favourite')
            .doc(snapshot.docs.first.id)
            .delete();
      } else {
        // Handle the case where the document to delete is not found
        print('Document not found to delete.');
      }
    } catch (e) {
      // Handle any errors that occur during the deletion process
      print('Error deleting document: $e');
    }
  }

  late List<AddPlayGroundModel> allplaygrounds = [];

  Future<void> getPlaygroundbyid() async {
    try {
      CollectionReference playerchat =
          FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          if (document.id == widget.id) {
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;
            AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

            allplaygrounds.add(user);
            print(
                "PlayGroung Id : ${document.id}"); // Print the latest playground

            print(
                "allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground

            // Store the document ID in the AddPlayGroundModel object
            idddddd = document.id;
            allplaygrounds.last.favourite = favlist[0].isfav;
            print("init${favlist[0].isfav}");
            // allplaygrounds[0].favourite=favlist[0].isfav;
            // print("fav done ${ allplaygrounds[0].favourite}");
            print("Docummmmmm$idddddd");
          }
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }

  int _selectedStars = 0;

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
        userdata = user1;
        print("userdata User: ${userdata[0].name}");
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

  List<Ratemodel> rat_list = [];

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _loadgetfavdataData();
    fetchRatings();
    getPlaygroundbyid();
    print("objectiddddddddd${widget.id}");

    _loadUserData();
    print("Docummmmmmentis${widget.id}");
    // Now you can access the user1 list
    // print('User data44444: ${user1[0].name}');
    setState(() {}); // Call setState to rebuild the widget tree
  }

  int _averageRating = 0;

  int totalRating = 0;

  Future<void> sendRating(List<bool> isstared) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');
      print("new phoneValue ${phoneValue.toString()}");

      if (phoneValue != null && phoneValue.isNotEmpty) {
        CollectionReference playerchat =
            FirebaseFirestore.instance.collection("Playground_Rate");
        QuerySnapshot querySnapshot = await playerchat
            .where('phone', isEqualTo: phoneValue)
            .where('playground_idstars', isEqualTo: widget.id)
            .get();
//to avoid add to total rate that already exist
        int newTotalRating = 0;
        for (bool star in isstared) {
          if (star) {
            newTotalRating++;
          }
        }

        if (newTotalRating > 5) newTotalRating = 5; // Cap the rating at 5

        if (querySnapshot.docs.isNotEmpty) {
          // Document exists, update the rating
          DocumentReference docRef = querySnapshot.docs.first.reference;
          await docRef.update({
            'rate': isstared, // Update with the new stars only
            'totalrating': newTotalRating // Use only the new rating value
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PlaygroundName(widget.id)),
          );
        } else {
          // Document doesn't exist, create a new one
          await playerchat.add({
            'rate': isstared,
            'phone': phoneValue,
            'playground_idstars': widget.id,
            'img': allplaygrounds[0].img!,
            'name': allplaygrounds[0].playgroundName!,
            'totalrating': newTotalRating
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PlaygroundName(widget.id)),
          );
        }
      } else if (user?.phoneNumber != null) {
        // Similar logic if phone number is obtained from `user`
        CollectionReference playerchat =
            FirebaseFirestore.instance.collection("Playground_Rate");
        QuerySnapshot querySnapshot = await playerchat
            .where('phone', isEqualTo: user?.phoneNumber)
            .where('playground_idstars', isEqualTo: widget.id)
            .get();

        int newTotalRating = 0;
        for (bool star in isstared) {
          if (star) {
            newTotalRating++;
          }
        }

        if (newTotalRating > 5) newTotalRating = 5; // Cap the rating at 5

        if (querySnapshot.docs.isNotEmpty) {
          // Document exists, update the rating
          DocumentReference docRef = querySnapshot.docs.first.reference;
          await docRef
              .update({'rate': isstared, 'totalrating': newTotalRating});
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PlaygroundName(widget.id)),
          );
        } else {
          // Document doesn't exist, create a new one
          await playerchat.add({
            'rate': isstared,
            'phone': user?.phoneNumber,
            'playground_idstars': widget.id,
            'img': allplaygrounds[0].img!,
            'name': allplaygrounds[0].playgroundName!,
            'totalrating': newTotalRating
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PlaygroundName(widget.id)),
          );
        }
      } else {
        print("No phone number available.");
      }
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  // Future<void> sendRating(List<bool> isstared) async {
  //   try {
  //    for(bool star in isstared){
  //      if(star==true){
  //        totalRating++;
  //
  //      }
  //    }
  //
  //     print("Total rate for this playground is $totalRating");
  //
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? phoneValue = prefs.getString('phonev');
  //     print("new phoneValue ${phoneValue.toString()}");
  //
  //     if (phoneValue != null && phoneValue.isNotEmpty) {
  //       CollectionReference playerchat = FirebaseFirestore.instance.collection("Playground_Rate");
  //       QuerySnapshot querySnapshot = await playerchat
  //           .where('phone', isEqualTo: phoneValue)
  //           .where('playground_idstars', isEqualTo: widget.id)
  //           .get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         // Document exists, update the rating
  //         DocumentReference docRef = querySnapshot.docs.first.reference;
  //         await docRef.update({
  //           'rate': isstared,
  //           'totalrating': totalRating
  //         });
  //       } else {
  //         // Document doesn't exist, create a new one
  //         await playerchat.add({
  //           'rate': isstared,
  //           'phone': phoneValue,
  //           'playground_idstars': widget.id,
  //           'img': allplaygrounds[0].img!,
  //           'name': allplaygrounds[0].playgroundName!,
  //           'totalrating': totalRating
  //         });
  //       }
  //     } else if (user?.phoneNumber != null) {
  //       CollectionReference playerchat = FirebaseFirestore.instance.collection("Playground_Rate");
  //       QuerySnapshot querySnapshot = await playerchat
  //           .where('phone', isEqualTo: user?.phoneNumber)
  //           .where('playground_idstars', isEqualTo: widget.id)
  //           .get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         // Document exists, update the rating
  //         DocumentReference docRef = querySnapshot.docs.first.reference;
  //         await docRef.update({
  //           'rate': isstared,
  //           'totalrating': totalRating
  //         });
  //       } else {
  //         // Document doesn't exist, create a new one
  //         await playerchat.add({
  //           'rate': isstared,
  //           'phone': user?.phoneNumber,
  //           'playground_idstars': widget.id,
  //           'img': allplaygrounds[0].img!,
  //           'name': allplaygrounds[0].playgroundName!,
  //           'totalrating': totalRating
  //         });
  //       }
  //     } else {
  //       print("No phone number available.");
  //     }
  //   } catch (e) {
  //     print('Error updating rating: $e');
  //   }
  // }

  Future<void> fetchRatings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');

      if (phoneValue != null && phoneValue.isNotEmpty) {
        // Fetch ratings for the specific phone number and playground ID
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Playground_Rate')
            .where('playground_idstars', isEqualTo: widget.id)
            .get();

        rat_list = querySnapshot.docs
            .map((doc) => Ratemodel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        for (int y = 0; y < rat_list.length; y++) {
          print("rat_listrat_listrat_list${rat_list[y].phone}");
        }
        _calculateAverageRating();
        setState(() {});
      } else if (user?.phoneNumber != null) {
        // Fetch ratings for the user's phone number and playground ID
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Playground_Rate')
            .where('playground_idstars', isEqualTo: widget.id)
            .get();

        rat_list = querySnapshot.docs
            .map((doc) => Ratemodel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        for (int y = 0; y < rat_list.length; y++) {
          print("rat_listrat_listrat_list${rat_list[y].phone}");
        }
        print("rat_list${rat_list[0].playgroundIdstars}");
        print("rat_list[0]${rat_list[0].rate}");
        _calculateAverageRating();
        setState(() {});
      } else {
        print("No phone number available for fetching ratings.");
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }

  String _getIconForFacility(String facility) {
    if (facility == "كافتيريا") {
      return "assets/images/ion_cafe.png";
    } else if (facility == 'الحمامات') {
      return "assets/images/bathroom.png";
    } else if (facility == 'موقف سيارات') {
      return "assets/images/car-door.png";
    } else if (facility == 'غرف تغيير الملابس') {
      return "assets/images/materialcloth.png";
    } else {
      return "assets/images/car-door.png";
    }
  }

  void _calculateAverageRating() {
    if (rat_list.isNotEmpty) {
      for (int i = 0; i < rat_list.length; i++) {
        print("ratephoneuser${rat_list[i].phone}");
        totalRating += rat_list[i].totalrating!;

        count++;
      }
      print("conteeeer${count}");
      print("total rate${totalRating}");

      if (count > 1) {
        _averageRating = (totalRating / count).toInt();
        print("_averageRating = $_averageRating");
      } else {
        _averageRating = totalRating;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<bool>> allRatings = rat_list.map((r) => r.rate!).toList();

    double filledStars = _averageRating.toDouble();

    return Scaffold(
      // backgroundColor: Colors.white,
      body: isConnected?Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      child: allplaygrounds.isNotEmpty
                          ? CarouselSlider.builder(
                              itemCount: allplaygrounds[0].img?.length ?? 0,
                              itemBuilder: (context, index, realIndex) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  // Add some space between images
                                  child: Stack(
                                    children: [
                                      Material(
                                        elevation: 4, // Elevation of 4
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Container(
                                          height: 200,
                                          width: 274,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: allplaygrounds[0]
                                                    .img!
                                                    .isNotEmpty
                                                ? Image.network(
                                                    allplaygrounds[0]
                                                        .img![index],
                                                    height: 200,
                                                    width: 274,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/images/newwadi.png',
                                                    height: 163,
                                                    width: 274,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   top: 6,
                                      //   right: 0,
                                      //   left: 0,
                                      //   bottom: 0,
                                      //   child: Container(
                                      //     decoration: BoxDecoration(
                                      //       gradient: LinearGradient(
                                      //         colors: [
                                      //           Colors.transparent,
                                      //           Color(0x1F8C4B).withOpacity(0.0),
                                      //           Color(0x1F8C4B).withOpacity(1.0),
                                      //         ],
                                      //         begin: Alignment.topCenter,
                                      //         end: Alignment.bottomCenter,
                                      //       ),
                                      //       borderRadius: BorderRadius.only(
                                      //         bottomLeft: Radius.circular(20.0),
                                      //         bottomRight: Radius.circular(20.0),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 200,
                                viewportFraction: 0.9,
                                // Adjust this value to change the width of each image
                                enableInfiniteScroll: true,
                                enlargeCenterPage: true,
                                // Makes the current image larger in the center
                                autoPlay: true, // Enables automatic sliding
                              ),
                            )
                          : Image.asset(
                              'assets/images/newwadi.png',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit
                                  .fill, // Ensure the placeholder image covers the container
                            ),
                    ),

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
                    allplaygrounds.isNotEmpty
                        ? Positioned(
                            top: 150,
                            right: 40,
                            left: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                 allplaygrounds[0].playgroundName!,
                                  // Updated English text
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  "assets/images/Wadi_Logo.png",
                                  height: 30,
                                  width: 30,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    // Top left icon with green shadow
                    Positioned(
                      top: 40,
                      left: 20,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 25),
                        onPressed: () {
                          print("Back button pressed"); // Debugging statement
                          Get.back(); // Navigate back to the previous page
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
                          allplaygrounds[0].favourite =
                              !allplaygrounds[0].favourite!;
                        });

                        if (allplaygrounds[0].favourite == true) {
                          // If favorite is true, add playground to Firebase
                          await _sendData();
                        } else {
                          // If favorite is false, delete playground from Firebase
                          await deleteFavoriteData();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Icon(
                          allplaygrounds.isNotEmpty &&
                                  allplaygrounds[0].favourite!
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: const Color(0xFF4AD080),
                          size: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 13, top: 8, bottom: 8),
                      child: allplaygrounds.isNotEmpty
                          ? Text(
                              allplaygrounds[0].playgroundName!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF064821),
                              ),
                            )
                          : Text(
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
                  padding:
                      const EdgeInsets.only(right: 15.0, left: 26, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 30.0,left: 10),
                                        child: Text(
                                          "أضافة تقييم",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF334154),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 1,
                                      bottom: 16,
                                      left: 201,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.grey.shade900,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                content: StatefulBuilder(
                                  //
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Container(
                                      height: 45.82,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0; i < 5; i++)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isstared[i] = !isstared[i];
                                                  if (totalRating < 5 &&
                                                      isstared[i] == true) {
                                                    totalRating += 1;
                                                  }
                                                  // if( isstared[i]==true){
                                                  //   totalRating=totalRating+1;
                                                  // }
                                                  print(
                                                      "starrrr value${isstared[i]}");
                                                });
                                              },
                                              child: Icon(
                                                isstared[i]
                                                    ? Icons.star
                                                    : Icons
                                                        .star_border_outlined,
                                                color: isstared[i]
                                                    ? Color(0xFFFFCC00)
                                                    : Colors.grey,
                                              ),
                                            )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                actions: [
                                  GestureDetector(
                                    onTap: () {
                                      List<bool> rating = List.generate(
                                        5,
                                            (index) => isstared[index],
                                      );
                                      sendRating(rating);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5,
                                          right: 20,
                                          left: 20,
                                          bottom: 20),
                                      child: Container(
                                        height: 45,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(30.0),
                                          color: Color(0xFF064821),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'تقديـــم تقييــم',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          "أضافة تقييم".tr,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF064821)),
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     for (int i = 5; i >0; i--)
                      //       GestureDetector(
                      //         // onTap: () {
                      //         //   setState(() {
                      //         //     if (i < _selectedStars) {
                      //         //       _selectedStars = i;
                      //         //     } else {
                      //         //       _selectedStars = i + 1;
                      //         //     }
                      //         //     List<bool> rating = List.generate(
                      //         //         5, (index) => index < _selectedStars);
                      //         //     sendRating(rating);
                      //         //   });
                      //         // },
                      //         child: Icon(
                      //           i < filledStars
                      //               ? Icons.star
                      //               : Icons.star_border_outlined,
                      //           color: Color(0xFFFFCC00),
                      //         ),
                      //       )
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (int i = 5; i > 0; i--)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Handle onTap logic here if needed
                                });
                              },
                              child: Icon(
                                i <= filledStars ? Icons.star : Icons.star_border_outlined,
                                color: i <= filledStars ? Color(0xFFFFCC00) : Colors.grey,
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(right: 26.0, left: 26, bottom: 20),
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
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                allplaygrounds.isNotEmpty
                                    ? Text(
                                        allplaygrounds[0].playType!,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF106A35),
                                        ),
                                      )
                                    : Text(
                                        'كرة طائرة',
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
                            SizedBox(
                              width: 100,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                allplaygrounds.isNotEmpty
                                    ? Text(
                                  allplaygrounds[0].width!.length < 5 && allplaygrounds[0]
                                      .length!
                                      .length < 5
                                            ? '   ${allplaygrounds[0].width!}x${allplaygrounds[0].length!} م '
                                           :  '   ${allplaygrounds[0].width!.length>10?allplaygrounds[0].width!.substring(0,5):allplaygrounds[0].width!}x${allplaygrounds[0].length!.length>10?allplaygrounds[0].length!.substring(0,5):allplaygrounds[0].length!} م ',
                                        textDirection: TextDirection.rtl,
                                        // Ensures the text direction is RTL

                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF106A35),
                                        ),
                                      )
                                    : Text(
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
                  padding: const EdgeInsets.only(right: 25.0),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: allplaygrounds.isNotEmpty
                          ? Text(
                              allplaygrounds[0].bookTypes!.isNotEmpty &&
                                      allplaygrounds[0]
                                              .bookTypes?[0]
                                              .costPerHour !=
                                          null
                                  ? 'السعر : ' +
                                      '${allplaygrounds[0].bookTypes?[0].costPerHour} / ساعة'
                                  : 'السعر : ' + "0 / ساعة",
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF106A35),
                              ),
                            )
                          : Text(
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
                  padding: const EdgeInsets.only(right: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                List<Location> locations =
                                    await locationFromAddress(
                                        allplaygrounds[0].location!);

                                Location location = locations.first;
                                double latitude = location.latitude;
                                double longitude = location.longitude;

                                String url =
                                    'https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}';

                                await Share.share(url);
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  shape: BoxShape.rectangle,
                                  color: Color(0xFF106A35),
                                ),
                                child: Icon(Icons.share,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                print(
                                    "locattttion${allplaygrounds[0].location!}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Maps(
                                          location:
                                              allplaygrounds[0].location!)),
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
                      Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          allplaygrounds.isNotEmpty
                              ? Text(
                                  allplaygrounds[0].location!.length > 12
                                      ? allplaygrounds[0]
                                          .location!
                                          .substring(0, 10)
                                      : allplaygrounds[0].location!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF106A35),
                                  ),
                                )
                              : Text(
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
                allplaygrounds.isNotEmpty &&
                        allplaygrounds[0].notes != null &&
                        allplaygrounds[0].notes!.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 26.0, left: 26),
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
                            padding:
                                const EdgeInsets.only(right: 26.0, left: 26),
                            child: Text(
                              allplaygrounds[0].notes!,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF106A35)),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      )
                    : Container(),

                //               allplaygrounds.isNotEmpty &&
                //                       allplaygrounds[0].availableFacilities != null &&
                //                       allplaygrounds[0].availableFacilities!.isNotEmpty
                //                   ? Column(
                //                       mainAxisAlignment: MainAxisAlignment.end,
                //                       crossAxisAlignment: CrossAxisAlignment.end,
                //                       children: [
                //                         Padding(
                //                           padding:
                //                               const EdgeInsets.only(right: 26.0, left: 26),
                //                           child: Text(
                //                             "المرفقات".tr,
                //                             style: TextStyle(
                //                                 fontFamily: 'Cairo',
                //                                 fontSize: 14.0,
                //                                 fontWeight: FontWeight.w700,
                //                                 color: Color(0xFF495A71)),
                //                           ),
                //                         ),
                //                         SizedBox(
                //                           height: 12,
                //                         ),
                //                         Padding(
                //                           padding: const EdgeInsets.only(right: 26),
                //                           child: Column(
                //                             children: allplaygrounds[0].availableFacilities!.map((facility) {
                //
                //   return Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     facility=="حجز نصف ساعة"?Container():
                //   Text(
                //   facility,
                //   style: TextStyle(
                //   fontFamily: 'Cairo',
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: Color(0xFF106A35),
                //   ),
                //   ),
                //   SizedBox(width: 8),
                //     facility=="حجز نصف ساعة"?Container():   Image.asset(
                //   _getIconForFacility(facility),
                //   color: Color(0xFF106A35),
                //   height: 20,
                //   width: 22,
                //   ),
                //   ],
                //   );
                // }).toList(),
                // ),
                // ),
                // SizedBox(height: 50),
                // ],
                // ):Container(),
                allplaygrounds.isNotEmpty &&
                        allplaygrounds[0].availableFacilities != null &&
                        allplaygrounds[0].availableFacilities!.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 26.0, left: 26),
                            child: Text(
                              "المرفقات".tr,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF495A71)),
                            ),
                          ),
                          SizedBox(height: 12),
                          Column(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.end, // Aligns the content to the right
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(
                              (allplaygrounds[0].availableFacilities!
                                  .where((facility) => facility != "حجز نصف ساعة")
                                  .length / 2)
                                  .ceil(),
                                  (index) {
                                // Get two items at a time, skipping "حجز نصف ساعة"
                                final facilitiesChunk = allplaygrounds[0].availableFacilities!
                                    .where((facility) => facility != "حجز نصف ساعة")
                                    .skip(index * 2)
                                    .take(2)
                                    .toList();

                                return Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    mainAxisAlignment: MainAxisAlignment.end, // Aligns the content to the right
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(
                                      2,
                                          (facilityIndex) {
                                        if (facilityIndex >= facilitiesChunk.length) {
                                          // Add Spacer if facilitiesChunk has only 1 item in this row
                                          return Spacer(flex: 1);
                                        }
                                        return Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end, // Aligns the content to the right
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  textDirection: TextDirection.rtl,
                                                  children: [
                                                    Image.asset(
                                                      _getIconForFacility(facilitiesChunk[facilityIndex]),
                                                      color: Color(0xFF106A35),
                                                      height: 20,
                                                      width: 22,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      facilitiesChunk[facilityIndex],
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF106A35),
                                                      ),
                                                    ),


                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),



                          // Column(
                          //   children: List.generate(
                          //     (allplaygrounds[0]
                          //                 .availableFacilities!
                          //                 .where((facility) =>
                          //                     facility != "حجز نصف ساعة")
                          //                 .length /
                          //             2)
                          //         .ceil(),
                          //     (index) {
                          //       // Get two items at a time, skipping "حجز نصف ساعة"
                          //       final facilitiesChunk = allplaygrounds[0]
                          //           .availableFacilities!
                          //           .where((facility) =>
                          //               facility != "حجز نصف ساعة")
                          //           .skip(index * 2)
                          //           .take(2)
                          //           .toList();
                          //
                          //       return Row(
                          //         mainAxisAlignment: MainAxisAlignment.start,
                          //         crossAxisAlignment:
                          //             CrossAxisAlignment.center,
                          //         children:
                          //             List.generate(facilitiesChunk.length,
                          //                 (facilityIndex) {
                          //           // Aligns first and third items to the same start point and second, fourth items to another start point
                          //           return Expanded(
                          //             flex: 1,
                          //             child: Row(
                          //               mainAxisAlignment:
                          //                   facilityIndex % 2 == 0
                          //                       ? MainAxisAlignment.end
                          //                       : MainAxisAlignment.center,
                          //               children: [
                          //                 Text(
                          //                   facilitiesChunk[facilityIndex],
                          //                   style: TextStyle(
                          //                     fontFamily: 'Cairo',
                          //                     fontSize: 14,
                          //                     fontWeight: FontWeight.w500,
                          //                     color: Color(0xFF106A35),
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 8),
                          //                 Image.asset(
                          //                   _getIconForFacility(
                          //                       facilitiesChunk[
                          //                           facilityIndex]),
                          //                   color: Color(0xFF106A35),
                          //                   height: 20,
                          //                   width: 22,
                          //                 ),
                          //               ],
                          //             ),
                          //           );
                          //         }),
                          //       );
                          //     },
                          //   ),
                          // ),
                          SizedBox(height: 50),
                        ],
                      )
                    : Container(),

                GestureDetector(
                  onTap: () {
                    print("ppppppppppppppppppppppppp${widget.id}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => book_playground_page(widget.id!),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      height: 50,
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        shape: BoxShape.rectangle,
                        color: Color(
                            0xFF064821), // Background color of the container
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
        ],
      ):_buildNoInternetUI(),
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
          navigationController.updateIndex(index);
          setState(() {
            // Update opacity based on the selected index
            opacity = index == 2 ? 0.5 : 1.0;
          }); // Update the index dynamically
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
  Widget _buildNoInternetUI() {

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height/3,

          ),
          Center(
            child: Container(
              height: 200,
              child: Image.asset(
                'assets/images/wifirr.png',
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
