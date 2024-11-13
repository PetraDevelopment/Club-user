import 'package:club_user/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Controller/NavigationController.dart';
import '../Menu/menu.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import '../Register/SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../booking_playground/AddbookingModel/AddbookingModel.dart';
import '../location/map_page.dart';
import '../my_reservation/my_reservation.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../search/search_page.dart';
import 'Userclass.dart';
import 'model_ratefetched.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  late List<User1> user1 = [];
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String start="";

  String end ="";
  Future<void> _loadData() async {

    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    setState(() {
      _isLoading = false; // set flag to false when data is loaded
    });
  }
  bool _isPermissionGranted = false;
  LatLng _initialPosition = LatLng(0.0, 0.0);
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _getPlaceName(_initialPosition);
      print("object_initialPosition$_initialPosition");
    });


  }
// Reverse geocode to get the place name from LatLng
  Future<String> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      // print("locality${place.subAdministrativeArea.toString()}");
      print("locality${place.country.toString()}");

      String locality=place.administrativeArea.toString();
      print("localitystring$locality");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('locationValue','$locality');
      String? loctionval=   prefs.getString('locationValue',);
      getNearbystadiums(loctionval!);
      print("loctionval$loctionval");
      print("country${place.country.toString()}");
      return "${place.street},${place.locality},${place.country},${place.administrativeArea}";
    } catch (e) {
      return "Unknown Location";
    }
  }
  void requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      _getCurrentLocation();
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getCurrentLocation();
      } else if (result.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();


    requestLocationPermission();
    getPlaygroundbyname();
    getfourplaygroundsbytype();
    _loadData();
    fetchBookingData();
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
    }
    else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }
  late List<AddbookingModel> playgroundbook = [];
  void _initialize() async {
    await checkInternetConnection();
    print("ggggg");
    setState(() {});
    // Other initialization tasks
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

  Future<void> fetchBookingData() async {

    try {

      CollectionReference bookingCollection = FirebaseFirestore.instance.collection("booking");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');
      print("newphoneValue${phoneValue.toString()}");

      if (phoneValue != null && phoneValue.isNotEmpty) {
        String normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');

        QuerySnapshot querySnapshot = await bookingCollection.get();

        playgroundbook = []; // Initialize as an empty list

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          var userDataList = data['AlluserData']?['UserData'] as List?;

          if (userDataList != null) {
            for (var userData in userDataList) {
              if (userData['UserPhone'] == normalizedPhoneNumber) {
                AddbookingModel booking = AddbookingModel.fromMap(data);
                playgroundbook.add(booking); // Add each booking to the list
                break;
              }
            }
          }
        }

        if (playgroundbook.isNotEmpty) {
          // Print and access specific fields for each booking
          for (int i = 0; i < playgroundbook.length; i++) {
            // formatDate(playgroundbook[i].dateofBooking!);

            print('AdminId: ${playgroundbook[i].AdminId}');
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('Name: ${playgroundbook[i].Name}');
            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].AllUserData![0].UserPhone!}');
          }
        } else {
          print('No matching bookings found for the phone number.');
        }
      } else if (user?.phoneNumber != null) {
        String? normalizedPhoneNumber = user?.phoneNumber!.replaceFirst('+20', '0');
        QuerySnapshot querySnapshot = await bookingCollection.get();

        playgroundbook = []; // Initialize as an empty list

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          var userDataList = data['AlluserData']?['UserData'] as List?;

          if (userDataList != null) {
            for (var userData in userDataList) {
              if (userData['UserPhone'] == normalizedPhoneNumber) {
                AddbookingModel booking = AddbookingModel.fromMap(data);
                playgroundbook.add(booking); // Add each booking to the list
                break;
              }
            }
          }
        }

        if (playgroundbook.isNotEmpty) {
          // Print and access specific fields for each booking
          for (int i = 0; i < playgroundbook.length; i++) {
            print('AdminId: ${playgroundbook[i].AdminId}');
            // formatDate(playgroundbook[i].dateofBooking!);
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('Name: ${playgroundbook[i].Name}');
            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].AllUserData![0].UserPhone!}');
            getPlaygroundbynameE(playgroundbook[i].NeededGroundData![0].GroundId!);
          }
        } else {
          print('No matching bookings found for the user’s phone number.');
        }
      }
    }
    catch (e) {
      print('Error fetching booking data: $e');
    }

  }
  late List<AddPlayGroundModel> playgroundAllData = [];
  late List<AddPlayGroundModel> basket = [];
  late List<AddPlayGroundModel> footbal = [];
  late List<AddPlayGroundModel> teniss = [];

  late List<AddPlayGroundModel> volly = [];
  late List<AddPlayGroundModel> fourtypes = [];

  late List<AddPlayGroundModel> Nearbystadiums = [];
  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime); // Parse the start time
    DateTime end = start.add(Duration(hours: 1)); // Add 1 hour for the end time

    // Format the time in Arabic but numbers in English
    String formattedStartTime = DateFormat('h:mm a', 'ar')
        .format(start)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(
          int.parse(match.group(0)!)); // Ensure numbers are in English
    });
    print("formattedStartTime$formattedStartTime");
    String formattedEndTime = DateFormat('h:mm a', 'ar')
        .format(end)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(int.parse(match.group(0)!));
    });
    print("formattedEndTime$formattedEndTime");

    return '$formattedStartTime الي $formattedEndTime';
  }
//   String getTimeRange(String startTime) {
//     DateTime start = DateFormat.jm().parse(startTime);
//     DateTime end = start.add(Duration(hours: 1)); //if book one hour
//
//
//     String formattedStartTime = DateFormat('h:mm a', 'en_US').format(start);
//     String formattedEndTime = DateFormat('h:mm a', 'en_US').format(end);
//
//     return '$formattedStartTime    :   $formattedEndTime';
//   }
  Future<void> getPlaygroundbynameE(String iiid) async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData =
          document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
          if (document.id == iiid) {
            playgroundAllData.add(user);

            String?  bookType = playgroundAllData[0].bookTypes![0].time;
            // Assuming 'time' is the field you want to split into start and end time
            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");

            // Splitting time into startTime and endTime based on '-'
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];
              for(int i=0;i<playgroundAllData.length;i++){
                print("locattttion${playgroundAllData[i].location}");

              }
              start=startTime;
              print("Start Time: $startTime");
              end=endTime;
              print("End Time: $endTime");
              String adminId = userData['AdminId'] ?? ''; // Fetch AdminId directly from userData
              user.adminId = adminId; // Assuming your model has a property for AdminId
              print("Admin ID: $adminId");
              // USerID=adminId;
              // // You can use these times to update the UI or for other logic
              // timeSlots.add(startTime); // Add start time to the list
              // timeSlots.add(endTime);   // Add end time to the list

              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              setState(() {
                // Update any UI components with the start and end times
                // startTimeStr = startTime; // Assuming you have a state variable to store this
                // endTimeStr = endTime;     // Assuming you have a state variable to store this
              });

              // print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            // }
// الوقت  هو سبب المشكله
            print(
                "PlayGroungboook Iiid : ${document.id}"); // Print the latest playground
            // groundIiid = document.id;
            // print("Docummmmmmbook$groundIiid");
            // Normalize playType before comparing
            String playType = user.playType!.trim();
          }

          // Store the document ID in the AddPlayGroundModel object
          user.id = document.id;
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  Future<void> getNearbystadiums(String city) async {
    try {
      print("cittttty${city}");
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData =
          document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
          if(user.location!.isNotEmpty&&user.location!.contains(city)){
            print("yes, there are some of playgrounds in this city");
            Nearbystadiums.add(user);

            for(int i=0;i<Nearbystadiums.length;i++){
              print("neeeeeeeear${Nearbystadiums[i].location}");

            }
            String?  bookType = Nearbystadiums[0].bookTypes![0].time;
            // Assuming 'time' is the field you want to split into start and end time
            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");

            // Splitting time into startTime and endTime based on '-'
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];
              for(int i=0;i<Nearbystadiums.length;i++){
                print("locattttion${Nearbystadiums[i].location}");

              }
              start=startTime;
              print("Start Time: $startTime");
              end=endTime;
              print("End Time: $endTime");
              String adminId = userData['AdminId'] ?? ''; // Fetch AdminId directly from userData
              user.adminId = adminId; // Assuming your model has a property for AdminId
              print("Admin ID: $adminId");
              // USerID=adminId;
              // // You can use these times to update the UI or for other logic
              // timeSlots.add(startTime); // Add start time to the list
              // timeSlots.add(endTime);   // Add end time to the list

              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              setState(() {
                // Update any UI components with the start and end times
                // startTimeStr = startTime; // Assuming you have a state variable to store this
                // endTimeStr = endTime;     // Assuming you have a state variable to store this
              });

              // print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            // }
// الوقت  هو سبب المشكله
            print(
                "PlayGroungboook Iiid : ${document.id}"); // Print the latest playground
            // groundIiid = document.id;
            // print("Docummmmmmbook$groundIiid");
            // Normalize playType before comparing
            String playType = user.playType!.trim();


            // Store the document ID in the AddPlayGroundModel object
            user.id = document.id;
          }else{

          }



        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  String docId='';
  String date='';
  String formatDate(String dateString) {
    DateTime dateTime = DateFormat('dd MMMM yyyy').parse(dateString);
    return DateFormat('dd-MM-yyyy','ar').format(dateTime);
  }
  int reversed=0;
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
  List<Rate_fetched> rat_list = [];
  List<Rate_fetched> rat_list2 = [];
  bool isConnected=false;


  // Future<void> deleteCancelByPhoneAndPlaygroundId(String phone, String playgroundId,String selectedTime) async {
  //   final firestore = FirebaseFirestore.instance;
  //   print("phoneggggg${phone}");
  //   try {
  //     // Query to find the document where 'user_phone' matches the provided phone number
  //     // and 'playgroundId' matches the provided playgroundId
  //     final querySnapshot = await firestore
  //         .collection('booking')
  //         .where('phoneCommunication', isEqualTo: phone)
  //         .where('groundID', isEqualTo: playgroundId)
  //         .where('selectedTimes', arrayContains: selectedTime)
  //         .get();
  //
  //     // Check if any documents were found
  //     if (querySnapshot.docs.isNotEmpty) {
  //       // Loop through the documents and delete them
  //       for (var doc in querySnapshot.docs) {
  //         await firestore.collection('booking').doc(doc.id).delete();
  //         print('Document X phone $phone, playgroundId $playgroundId, and selectedTime $selectedTime deleted successfully.');
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => HomePage()),
  //         );
  //       }
  //     } else {
  //       print('No document found for phone number: $phone and playgroundId: $playgroundId');
  //     }
  //   } catch (e) {
  //     print('Error deleting document: $e');
  //   }
  // }
  Future<void> deleteCancelByPhoneAndPlaygroundId(
      String normalizedPhoneNumber,
      String playgroundId,
      String selectedTime,
      String bookingDate,
      )
  async {
    final firestore = FirebaseFirestore.instance;
    bool documentDeleted = false;
    print("phoneee$normalizedPhoneNumber");
    try {
      // Get all documents from the booking collection
      QuerySnapshot querySnapshot = await firestore.collection('booking').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Retrieve user data list
        var userDataList = data['AlluserData']?['UserData'] as List?;
        var groundDataList = data['NeededGroundData']?['GroundData'] as List?;

        // Debugging output
        print('User  Data List: $userDataList');
        print('Ground Data List: $groundDataList');
        print('Document dateofBooking: ${data['dateofBooking']}');
        print('Document selectedTimes: ${data['selectedTimes']}');

        // Check if userDataList is not null
        if (userDataList != null) {
          bool userMatch = userDataList.any((userData) =>
          userData['UserPhone'] == normalizedPhoneNumber
          );

          // Check if document-level dateofBooking and selectedTimes match
          if (userMatch &&
              data['dateofBooking'] == bookingDate &&
              (data['selectedTimes'] as List).contains(selectedTime)) {
            // All conditions are met, delete the document
            await firestore.collection('booking').doc(doc.id).delete();
            print(
                'Document with phone $normalizedPhoneNumber, playgroundId $playgroundId, and selectedTime $selectedTime deleted successfully.');
            // await firestore.collection('booking').doc(doc.id).delete();
            print('Document with phone: $normalizedPhoneNumber, playgroundId: $playgroundId, date: $bookingDate, and selectedTime: $selectedTime deleted successfully.');
            documentDeleted = true;

            // Navigate to HomePage after successful deletion
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            return; // Exit the function after deletion
          }
        }
      }

      if (!documentDeleted) {
        print('No document found matching the specified phone, playgroundId, date, and selectedTime.');
      }

    }
    catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> fetchRatings(String id) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Playground_Rate')
          .where('playground_idstars', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("ID: $id");

        rat_list = querySnapshot.docs
            .map((doc) => Rate_fetched.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        rat_list.sort((a, b) => b.totalRating.compareTo(a.totalRating));
        print("Sorted Ratings: $rat_list");


        Map<String, Rate_fetched> idToHighestRatingMap = {};
        for (var rating in rat_list2) {

          if (idToHighestRatingMap.containsKey(rating.playgroundIdstars!)) {
            if (rating.totalRating > idToHighestRatingMap[rating.playgroundIdstars!]!.totalRating) {
              idToHighestRatingMap[rating.playgroundIdstars!] = rating;
              if (rat_list2.length < 5) {
                var uniqueRatings = rat_list.where((rating) => !idToHighestRatingMap.containsKey(rating.playgroundIdstars!));
                rat_list2.addAll(uniqueRatings.take(5 -rat_list2.length ));
                print("erooooooooooooooooooooooooooooooooooooooooooooo   :${rat_list2.length}");
              }
            }
          }
          else {
            idToHighestRatingMap[rating.playgroundIdstars!] = rating;
          }
        }

        // If there are less than five unique ratings, include them
        rat_list2 = idToHighestRatingMap.values.toList();
        if (rat_list2.length < 5) {
          var uniqueRatings = rat_list.where((rating) => !idToHighestRatingMap.containsKey(rating.playgroundIdstars!));
          for(int k=0;k<uniqueRatings.length;k++){
            if(rat_list2.contains(rat_list[k].playgroundIdstars)){

            }else{
              rat_list2.addAll(uniqueRatings.take(5 -rat_list2.length ));
              print("erooooooooooooooooooooooooooooooooooooooooooooo${rat_list2.length}");
            }
          }


        }

        print("Final Ratings: $rat_list2");
        print("legthikfjkvhk Ratings: ${rat_list2.length}");

        setState(() {});
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }
  String toArabicNumerals(num number) {
    const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    // Convert the number to a string for processing
    String numberString = number.toString();

    // Replace each digit in the number string with its Arabic equivalent
    String convertedNumber = numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkتتتتتتk$convertedNumber");
    // If you want to assign the converted number back to the cost
    // playgroundAllData[i].bookTypes![0].cost = convertedNumber; // Assuming cost is a String

    print("number equal $convertedNumber");
    return convertedNumber; // Return the converted number
  }


  int selectedIndex=3;
  final Searchcontrol = TextEditingController();
  late List<AddPlayGroundModel> allplaygrounds = [];
  int _currentIndex = 3;
  int countnumoffourplaygrounds = 0;

  final PageController _pageController = PageController();
  List<String> missingTypes = [];

  Future<void> getfourplaygroundsbytype() async {
    try {

      CollectionReference playerchat = FirebaseFirestore.instance.collection("AddPlayground");
      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

          allplaygrounds.add(user);

          // Add playground to appropriate category
          if (user.playType == "كرة تنس" && teniss.isEmpty) {
            teniss.add(user);
          } else if (user.playType == "كرة سلة" && basket.isEmpty) {
            basket.add(user);
          } else if (user.playType == "كرة قدم" && footbal.isEmpty) {
            footbal.add(user);
          } else if (user.playType == "كرة طائرة" && volly.isEmpty) {
            volly.add(user);
          }

          user.id = document.id; // Store document ID
        }

        loadfourtype();

        // Update missingTypes list with any empty types
        updateMissingTypes();
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }

  void loadfourtype() {
    if (teniss.isNotEmpty) fourtypes.add(teniss[0]);
    if (basket.isNotEmpty) fourtypes.add(basket[0]);
    if (volly.isNotEmpty) fourtypes.add(volly[0]);
    if (footbal.isNotEmpty) fourtypes.add(footbal[0]);

    print("shokaaaaaaaf${fourtypes.length}");
  }

  void updateMissingTypes() {
    missingTypes.clear();

    if (teniss.isEmpty) missingTypes.add("كرة تنس");
    if (basket.isEmpty) missingTypes.add("كرة سلة");
    if (footbal.isEmpty) missingTypes.add("كرة قدم");
    if (volly.isEmpty) missingTypes.add("كرة طائرة");

    setState(() {}); // Update the UI to show the missing types
  }



//   Future<void>getfourplaygroundsbytype() async {
//     try {
//
//       CollectionReference playerchat =
//       FirebaseFirestore.instance.collection("AddPlayground");
//
//       QuerySnapshot querySnapshot = await playerchat.get();
//
//       if (querySnapshot.docs.isNotEmpty) {
//         for (QueryDocumentSnapshot document in querySnapshot.docs) {
//           Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
//           AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
//
//           allplaygrounds.add(user);
//           for(int m=0;m<allplaygrounds.length;m++) {
//             print("kkkkkkkkshok${allplaygrounds[m]}");
//             print("dddddddddddddddddddddd${allplaygrounds[m].id}");
//
//
//
//
//
//           }
//           if (user.playType == "كرة تنس"&&teniss.isEmpty) {
//             teniss.add(user);
//             print("tenisssssss$teniss");
//           }
//           else{
//             print("teniss.length${teniss.length}");
//           }
//           if (user.playType == "كرة سلة"&&basket.isEmpty) {
//             basket.add(user);
//
//
//
//             print("basket$basket");
//
//           }
//           else{
//             print("basket.length${basket.length}");
//           }
//           if (user.playType == "كرة قدم"&&footbal.isEmpty) {
//             footbal.add(user);
//             print("footbal$footbal");
//
//
//           }
//           else{
//             print("footbal.length${footbal.length}");
//
//           }
//           if (user.playType == "كرة طائرة"&&volly.isEmpty) {
//             volly.add(user);
//             print("volly$volly");
//
//
//           }else{
//             print("volly.length${volly.length}");
//
//           }
//           if(footbal.isNotEmpty&&footbal.length==1)
//           {
//
//             print("objectfootbal.first${footbal.first}");
//           }
//
//
//
//           print("PlayGroung Id : ${document.id}"); // Print the latest playground
//
//           print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground
// // Store the document ID in the AddPlayGroundModel object
//           // user.id = document.id;
//           user.id = document.id;
//           print("Docummmmmm${user.id}");
//           // Store the document ID in the AddPlayGroundModel object
//           // idddddd1 = document.id;
//           // idddddd2=document.id;
//           // print("Docummmmmm$idddddd1    gggg$idddddd2");
//         }
//
//         loadfourtype();
//       }
//     } catch (e) {
//       print("Error getting playground: $e");
//     }
//   }
//   void loadfourtype(){
//
//     fourtypes.add(teniss[0]);
//     fourtypes.add(basket[0]);
//     fourtypes.add(volly[0]);
//     fourtypes.add(footbal[0]);
//
//     print("shokaaaaaaa${fourtypes.length}");
//   }
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
          print("PlayGroung Id shoka: ${document.id}"); // Print the latest playground

          print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground
// Store the document ID in the AddPlayGroundModel object
          // user.id = document.id;
          user.id = document.id;
          print("Docummmmmm${user.id}");
          for(int m=0;m<allplaygrounds.length;m++){
            print("kkkkkkkkshok${allplaygrounds[m]}");
            print("shimaaaaaaaplaygroundiddddd${allplaygrounds[m].id}");

            fetchRatings(allplaygrounds[m].id!);

          }

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
// Function to update the cancel count
  Future<void> updateCancelCount(String userPhone) async {
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('cancel_book')
        .where('user_phone', isEqualTo: userPhone)
        .get();

    if (query.docs.isNotEmpty) {
      // Document exists, increment the numberofcancel field
      final doc = query.docs.first;
      final currentCount = doc['numberofcancel'] ?? 0;

      await firestore
          .collection('cancel_book')
          .doc(doc.id)
          .update({'numberofcancel': currentCount + 1});
    } else {
      // Document does not exist, create a new one with numberofcancel set to 1
      await firestore.collection('cancel_book').add({
        'user_phone': userPhone,
        'numberofcancel': 1,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body:  isConnected
      ? Padding(
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
                                user1[0].name!.length<20? user1[0].name!:user1[0].name!.substring(0,20),
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
                            child: Image.asset(
                              "assets/images/profile.png",
                              width: 63,
                              height: 63,
                              // Adjust size as needed
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Searchpage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 33, right: 33),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color(0xFFF1F1F1),
                        border: Border.all(
                          color: Color(0xFFB8B8B8),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20, top: 7, bottom: 7),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: Searchcontrol,
                                  readOnly: true,
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
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              'assets/images/search.png',
                              height: 20,
                              width: 25,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10,),

                fourtypes.isNotEmpty?
                // Stack(
                //   children: [
                //     Padding(
                //
                //       padding: const EdgeInsets.only(right: 5,left: 5,bottom: 10),
                //
                //       child: CarouselSlider(
                //         options: CarouselOptions(
                //           height: 165.0,
                //           aspectRatio: 16 / 9,
                //           viewportFraction: 0.7,
                //           initialPage: 1,
                //           enableInfiniteScroll: false,
                //           autoPlay: false,
                //           enlargeCenterPage: true,
                //           onPageChanged: (index, reason) {},
                //           scrollDirection: Axis.horizontal,
                //           reverse: true, // Reverses the scroll direction
                //
                //         ),
                //         items: [
                //           for (int i = 0; i < fourtypes.length; i++)
                //             GestureDetector(
                //               onTap: (){
                //                 print("111114${fourtypes[i].id!}");
                //                 Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) => PlaygroundName(fourtypes[i].id!),
                //                   ),
                //                 );
                //               },
                //               child: Padding(
                //                 padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 5), // Add space between items
                //                 child: Stack(
                //                   children: [
                //                     Material(
                //                       elevation: 4, // Elevation of 4
                //                       borderRadius: BorderRadius.circular(20.0),
                //                       child: Container(
                //                         height: 163,
                //                         width: 274,
                //                         decoration: BoxDecoration(
                //                           borderRadius: BorderRadius.circular(20.0),
                //                           shape: BoxShape.rectangle,
                //
                //                         ),
                //                         child: ClipRRect(
                //                           borderRadius: BorderRadius.circular(20.0),
                //                           child: fourtypes[i].img!.isNotEmpty?  Image.network(
                //                             fourtypes[i].img![0],
                //                             height: 163,
                //                             width: 274,
                //                             fit: BoxFit.cover,)
                //                               : Image.asset(
                //                             'assets/images/newwadi.png',
                //                             height: 163,
                //                             width: 274,
                //                             fit: BoxFit.cover,
                //                           )
                //                           ,
                //                         ),
                //                       ),
                //                     ),
                //                     Positioned(
                //                       top: 6,
                //                       right: 0,
                //                       left: 0,
                //                       bottom: 0,
                //                       child: Container(
                //                         decoration: BoxDecoration(
                //                           gradient: LinearGradient(
                //                             colors: [
                //                               Colors.transparent,
                //                               Color(0x1F8C4B).withOpacity(0.0),
                //                               Color(0x1F8C4B).withOpacity(1.0),
                //                             ],
                //                             begin: Alignment.topCenter,
                //                             end: Alignment.bottomCenter,
                //                           ),
                //                           borderRadius: BorderRadius.only(
                //                             bottomLeft: Radius.circular(20.0),
                //                             bottomRight: Radius.circular(20.0),
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                     Positioned(
                //                       top: 113,
                //                       right: 40,
                //                       left: 55,
                //                       child: Text(
                //                         fourtypes[i].playgroundName!, // Updated English text
                //                         style: TextStyle(
                //                           fontFamily: 'Cairo',
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.w700,
                //                           color: Colors.white,
                //                         ),
                //                         textAlign: TextAlign.center,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //         ],
                //       ),
                //     ),
                //
                //   ],
                // )
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5, bottom: 10,top: 10),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 165.0,
                          aspectRatio: 16 / 10,
                          viewportFraction: 0.75,
                          initialPage: 1,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                        ),
                        items: [
                          for (int i = 0; i < fourtypes.length; i++)
                            GestureDetector(
                              onTap: () {
                                print("Selected playground ID: ${fourtypes[i].id!}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaygroundName(fourtypes[i].id!),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Material(
                                    // elevation: 4,
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
                                        child: fourtypes[i].img!.isNotEmpty
                                            ? Image.network(
                                          fourtypes[i].img![0],
                                          height: 163,
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
                                      fourtypes[i].playgroundName!,
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
                )
                    :
                allplaygrounds.isEmpty&&fourtypes.isEmpty&&rat_list2.isEmpty &&playgroundbook.isEmpty?   Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 142.51,
                          width: 142.51,

                          child:  Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              "assets/images/amico.png",

                              // Adjust size as needed
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Text(
                        'لم يتم اضافة بيانات يمكن عرضها بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.62,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF181A20),
                        ),
                      ),
                    ],
                  ),
                ):Container(),
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
                playgroundAllData.isNotEmpty?   Padding(
                  padding: const EdgeInsets.only(right: 17.0,bottom: 9,top: 9,left: 17),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // Reverses the scroll direction

                    child:Row(
                      children: [
                        for (var i = 0; i < playgroundAllData.length; i++) // Repeat the container 5 times
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 12,bottom: 3), // Adds spacing between containers
                            child: Container(

                              width: 230,
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
                                    padding: const EdgeInsets.only(right: 17.0, left: 17, top: 9),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end, // Aligns the content to the right
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                "${ playgroundAllData[i].playgroundName!}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF334154),
                                                ),
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
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0, left: 8, top: 4),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(

                                              "${formatDate(playgroundbook[i].dateofBooking!)}",
                                              textAlign: TextAlign.end,
                                              style: TextStyle(

                                                fontFamily: 'Cairo',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF7D90AC),
                                              ),
                                            ),


                                          ],
                                        ),
                                        SizedBox(width: 30,),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Color(
                                                  0xFF7C90AB),
                                              fontSize: 12,
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight
                                                  .w400,
                                              height: 0,
                                              letterSpacing: 0.36,
                                            ),
                                            children: [

                                              playgroundbook[i].selectedTimes!.isNotEmpty?   TextSpan(
                                                text: getTimeRange(
                                                    playgroundbook[i].selectedTimes![0]??""), // Add formatted time range
                                              ):TextSpan(
                                                text:"", // Add formatted time range
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0, left: 8, top: 1,bottom: 4),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "  ج.م  ",


                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        ),
                                        Text(
                                          // " ${playgroundAllData[i].bookTypes![0].cost!}",

                                          toArabicNumerals(playgroundbook[i].totalcost!),
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        ),
                                        Text(
                                          "  " +":"+ "  التكلفة الأجمالية   ".tr,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF334154),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          print("phooonefff${playgroundbook[i]
                                              .AllUserData![0].UserPhone!}");
                                          updateCancelCount(playgroundbook[i]
                                              .AllUserData![0].UserPhone!);
                                          deleteCancelByPhoneAndPlaygroundId(playgroundbook[i]
                                              .AllUserData![0].UserPhone!,playgroundbook[i]
                                              .NeededGroundData![0].GroundId!,playgroundbook[i].selectedTimes!.first,playgroundbook[i].dateofBooking!);

                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),
                                          child: Container(
                                            height: 23,
                                            width: 74,
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
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white, // Text color
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          print("locattttion${playgroundAllData[i].location!}");

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Maps(location: playgroundAllData[i].location!)),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),

                                          child: Container(
                                            height: 23,
                                            width: 66,
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
                                                  fontSize : 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white, // Text color
                                                ),
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
                ):
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 142.51,
                        width: 142.51,

                        child:  Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            "assets/images/Folder.png",

                            // Adjust size as needed
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Text(
                        'لم يتم اضافة حجوزات يمكن عرضها بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.62,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF181A20),
                        ),
                      ),
                    ],
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
                Nearbystadiums.isNotEmpty? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // Reverses the scroll direction

                    child:Nearbystadiums.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),

                      child: Row(

                        children: [
                          for (var i = 0; i < Nearbystadiums.length; i++)
                            GestureDetector(
                              onTap: (){
                                print("111114${Nearbystadiums[i].id!}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaygroundName(Nearbystadiums[i].id!),
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
                                        child: Nearbystadiums[i].img!.isNotEmpty?Image.network(
                                          // Check if img is a list and has at least one image, otherwise use it as a string

                                          Nearbystadiums[i].img![0], // Use the first image in the list (or the only image if it's a single string turned into a list)
                                          // Fallback to an empty string if no image is available
                                          height: 163,
                                          width: 274,
                                          fit: BoxFit.fill, // Ensure the image covers the container
                                        ):Image(
                                          image: AssetImage("assets/images/newground.png"),
                                          color: Colors.white,
                                          height: 163,
                                          width: 274,
                                          fit: BoxFit.fill,
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
                                        Nearbystadiums[i].playgroundName!,
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
                    )
                        :Nearbystadiums.isEmpty&&playgroundAllData.isNotEmpty&&playgroundAllData.length>3?
                    Row(

                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: (){
                              print("111114${playgroundAllData[i].id!}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaygroundName(playgroundAllData[i].id!),
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
                                      child: playgroundAllData[i].img!.isNotEmpty?Image.network(
                                        // Check if img is a list and has at least one image, otherwise use it as a string

                                        playgroundAllData[i].img![0], // Use the first image in the list (or the only image if it's a single string turned into a list)
                                        // Fallback to an empty string if no image is available
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill, // Ensure the image covers the container
                                      ):Image(
                                        image: AssetImage("assets/images/newground.png"),
                                        color: Colors.white,
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill,
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
                                      playgroundAllData[i].playgroundName!,
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
                    ):
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              height: 142.51,
                              width: 142.51,

                              child:  Image.asset(
                                "assets/images/amico.png",

                                // Adjust size as needed
                              ),
                            ),
                          ),
                          SizedBox(height: 2,),
                          Text(
                            'لم يتم اضافة بيانات يمكن عرضها بعد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.62,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF181A20),
                            ),
                          ),
                        ],
                      ),
                    )
                ): Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 142.51,
                          width: 142.51,

                          child:  Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              "assets/images/amico.png",

                              // Adjust size as needed
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Text(
                        'لم يتم اضافة بيانات يمكن عرضها بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.62,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF181A20),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(right: 25,left: 26,top: 10,bottom: 10,),
                  child: Text(
                    "الملاعب الاعلى تقييم".tr,
                    style: TextStyle(
                      color: Color(0xFF495A71),
                      fontFamily: 'Cairo',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                rat_list2.isNotEmpty?    SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Reverses the scroll direction
                  child: rat_list2.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),

                    child: Row(
                      children: [
                        for (var i = 0; i < rat_list2.length; i++)
                          GestureDetector(
                            onTap: () {
                              print("length equal ${rat_list2.length}");
                              print("objectidddddd ${rat_list2[i].playgroundIdstars!}");

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaygroundName(rat_list2[i].playgroundIdstars!),
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
                                    width: 274,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: rat_list2[i].img!.isNotEmpty ? Image.network(
                                        rat_list2[i].img![0],
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill,
                                      ) : Image(
                                        image: AssetImage("assets/images/newground.png"),
                                        color: Colors.white,
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill,
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
                                      rat_list2[i].name!,
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
                  ) : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: 142.51,
                            width: 142.51,

                            child:  Image.asset(
                              "assets/images/amico.png",

                              // Adjust size as needed
                            ),
                          ),
                        ),
                        SizedBox(height: 2,),
                        Text(
                          'لم يتم اضافة بيانات يمكن عرضها بعد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.62,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF181A20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ): Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: 142.51,
                          width: 142.51,

                          child:  Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              "assets/images/amico.png",

                              // Adjust size as needed
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2,),
                      Text(
                        'لم يتم اضافة بيانات يمكن عرضها بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.62,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF181A20),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
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
                Get.to(
                  menupage(),
                  arguments: {'from': 'home'},
                )?.then((_){
                  navigationController
                      .updateIndex(0); // Update index when navigating back
                });
                break;

              case 1:
                Get.to(() => my_reservation(), arguments: {'from': 'home'},)?.then((_) {
                  navigationController.updateIndex(2);
                });

                break;
              case 2:
                Get.to(
                  AppBarandNavigationBTN(),
                  arguments: {'from': 'home'},
                )?.then((_){
                  navigationController
                      .updateIndex(1); // Update index when navigating back
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
    // Your UI design when there's no internet connection

  }
