import 'package:club_user/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
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
import '../notification/model/modelsendtodevice.dart';
import '../notification/model/send_modelfirebase.dart';
import '../notification/notification_page.dart';
import '../notification/utils/setting.dart';
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
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
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
  Future<String> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
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
    fetchBookingData();

    requestLocationPermission();
    getPlaygroundbyname();
    getfourplaygroundsbytype();
    _loadData();

    _loadUserData();

    print("njbjbhbbb");
    setState(() {});
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.round();
      });
    });
    notificationHandleClose(context);
    notificationHandleBackground(context);
    notificationHandleOpened(context);
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
    setState(() {});
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
  fetchuserdatabyid(AddbookingModel userid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('Users').doc(userid.userID).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;


        if (data != null ) {
          return data;

        }
        else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $userid');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }
  fetchgrounddatabyid(AddbookingModel ground) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('AddPlayground').doc(ground.GroundId).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;


        if (data != null ) {
          print("grounddaaaaaaaaaaaaata$data");
          return data;

        }
        else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $ground');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }
  String useridddd="";
  Future<void> fetchBookingData() async {

    try {
      CollectionReference bookingdataa = FirebaseFirestore.instance.collection("booking");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');
      print("newphoneValue${phoneValue.toString()}");

      if (phoneValue != null && phoneValue.isNotEmpty) {
        String normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');
        CollectionReference uuuserData = FirebaseFirestore.instance.collection('Users');

  QuerySnapshot adminSnapshot = await uuuserData.where('phone', isEqualTo: normalizedPhoneNumber).get();
        print('shared phooone $normalizedPhoneNumber');
        if(adminSnapshot.docs.isNotEmpty){
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc.id;
          print("Matched user docId: $docId");
          useridddd=docId;

        }
        QuerySnapshot bookingSnapshot =
        await bookingdataa.where('userID', isEqualTo: useridddd).get();

        if(bookingSnapshot.docs.isNotEmpty){
          playgroundbook = [];
          for (var document in bookingSnapshot.docs) {
            Map<String, dynamic> userData =
            document.data() as Map<String, dynamic>;
            AddbookingModel bookingData = AddbookingModel.fromMap(userData);
            Map<String, dynamic>? user =   await fetchuserdatabyid(bookingData);

            bookingData.UserName = user!['name'];
            bookingData.UserPhone = user['phone'];
            bookingData.UserImg = user['profile_image'];
            Map<String, dynamic>? Grounddata =   await fetchgrounddatabyid(bookingData);
            bookingData.groundName = Grounddata!['groundName'];
            bookingData.groundphone = Grounddata['phone'];
            bookingData.groundImage = Grounddata['img'][0];
            bookingData.logoimage=Grounddata['LogoImg'];
            playgroundbook.add(bookingData);
            print("bookingData is equal $bookingData");
          }
          setState(() {

          });

        }


        if (playgroundbook.isNotEmpty) {
          for (int i = 0; i < playgroundbook.length; i++) {

            if (playgroundbook[i].AdminId != null) {
              print('AdminIdforbook: ${playgroundbook[i].AdminId}');
            }
            if (playgroundbook[i].Day_of_booking != null) {
              print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            }
            if (playgroundbook[i].rentTheBall != null) {
              print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            }
            if (playgroundbook[i].UserPhone != null) {
              print('phoneshoka: ${playgroundbook[i].UserPhone!}');
            }
          }
        } else {
          print('No matching bookings found for the phone number.');
        }
      }
      else if (user?.phoneNumber != null) {
        String? normalizedPhoneNumber = user?.phoneNumber!.replaceFirst('+20', '0');
        CollectionReference uuuserData = FirebaseFirestore.instance.collection('Users');

  QuerySnapshot adminSnapshot = await uuuserData.where('phone', isEqualTo: normalizedPhoneNumber).get();
        print('shared phooone $normalizedPhoneNumber');
        if(adminSnapshot.docs.isNotEmpty){
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc.id;
          print("Matched user docId: $docId");
          useridddd=docId;

        }
        QuerySnapshot bookingSnapshot =
        await bookingdataa.where('userID', isEqualTo: useridddd).get();

        if(bookingSnapshot.docs.isNotEmpty){
          playgroundbook = [];
          for (var document in bookingSnapshot.docs) {
            Map<String, dynamic> userData =
            document.data() as Map<String, dynamic>;
            AddbookingModel bookingData = AddbookingModel.fromMap(userData);
            Map<String, dynamic>? user =   await fetchuserdatabyid(bookingData);

            bookingData.UserName = user!['name'];
            bookingData.UserPhone = user['phone'];
            bookingData.UserImg = user['profile_image'];
            Map<String, dynamic>? Grounddata =   await fetchgrounddatabyid(bookingData);
            bookingData.groundName = Grounddata!['groundName'];
            bookingData.groundphone = Grounddata['phone'];
            bookingData.logoimage=Grounddata['LogoImg'];
            bookingData.groundImage = Grounddata['img'][0];

            playgroundbook.add(bookingData);

          }
          setState(() {

          });

        }

        if (playgroundbook.isNotEmpty) {

          for (int i = 0; i < playgroundbook.length; i++) {
            if (playgroundbook[i].AdminId != null) {
              print('AdminIdforbook: ${playgroundbook[i].AdminId}');
            }
            if (playgroundbook[i].Day_of_booking != null) {
              print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            }
            if (playgroundbook[i].rentTheBall != null) {
              print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            }
            if (playgroundbook[i].UserPhone != null) {
              print('phoneshoka: ${playgroundbook[i].UserPhone!}');
            }
            getPlaygroundbynameE(playgroundbook[i].GroundId!);
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
  late List<AddbookingModel> playgroundAllDatabook = [];

  late List<AddPlayGroundModel> basket = [];
  late List<AddPlayGroundModel> footbal = [];
  late List<AddPlayGroundModel> teniss = [];

  late List<AddPlayGroundModel> volly = [];
  late List<AddPlayGroundModel> fourtypes = [];

  late List<AddPlayGroundModel> Nearbystadiums = [];
  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime);
    DateTime end = start.add(Duration(hours: 1));
    String formattedStartTime = DateFormat('h:mm a', 'ar')
        .format(start)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(
          int.parse(match.group(0)!));
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
            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");
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
              String adminId = userData['AdminId'] ?? '';
              user.adminId = adminId;
              print("Admin ID: $adminId");
              setState(() {
                 });

            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }

            print(
                "PlayGroungboook Iiid : ${document.id}");

          }

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

            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");
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
              String adminId = userData['AdminId'] ?? '';
              user.adminId = adminId;
              print("Admin ID: $adminId");

              setState(() {
              });

            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            print(
                "PlayGroungboook Iiid : ${document.id}");

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
  List<Rate_fetched> rat_list = [];
  List<Rate_fetched> rat_list2 = [];
  bool isConnected=false;
String adminoooken="";
  String convertTo12HourFormat(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _sendnotificationtofirebase(int type,String Groundid,day,booktime) async {
    setState(() {
      _isLoading = true;
    });

    DateTime now = DateTime.now();
    String timeIn12HourFormat = convertTo12HourFormat(now);
    String time = timeIn12HourFormat;
    print("time converted to be 12 hour $time");
    print(now.year.toString() +
        ":" +
        now.month.toString() +
        ":" +
        now.day.toString());
    String daaate = now.year.toString() +
        ":" +
        now.month.toString() +
        ":" +
        now.day.toString();

    final notificationModel = NotificationModel(

      adminId: playgroundAllData[0].adminId!,
      groundid:Groundid,
      userId: useridddd,
      adminreply:false,
      time: time,
      date: daaate,
      click:false,
      day:day,
      bookingtime: booktime.toString(),
      notificationType: type,
    );

    await FirebaseFirestore.instance
        .collection('notification')
        .add(notificationModel.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم ارسال البيانات بنجاح',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xFF1F8C4B),
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> deleteCancelByPhoneAndPlaygroundId(
      String userid,
      String a_id,
      String g_name,
      String playgroundId,
      String selectedTime,
      String bookingDate,
      )
  async {
    final firestore = FirebaseFirestore.instance;
    bool documentDeleted = false;
    print("Normalized Phone: $userid");
    print("Playground ID: $playgroundId");
    print("Selected Time: $selectedTime");
    print("Booking Date: $bookingDate");
    print("g_name Date: $g_name");

    List<String> dateParts = bookingDate.split(' ');
    int day = int.parse(dateParts[0]);
    String monthName = dateParts[1];
    int year = int.parse(dateParts[2]);

    Map<String, int> monthMap = {
      "يناير": 1,
      "فبراير": 2,
      "مارس": 3,
      "أبريل": 4,
      "مايو": 5,
      "يونيو": 6,
      "يوليو": 7,
      "أغسطس": 8,
      "سبتمبر": 9,
      "أكتوبر": 10,
      "نوفمبر": 11,
      "ديسمبر": 12,
    };


    int month = monthMap[monthName] ?? 0;
    DateTime date = DateTime(year, month, day);

    List<String> dayNames = [
      "الأحد",
      "الاثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة",
      "السبت"
    ];


    String dayName = dayNames[date.weekday % 7];

    print("Booking Date: $bookingDate");
    print("Day Name: $dayName");


    try {
      QuerySnapshot querySnapshot = await firestore.collection('booking')
          .where('GroundId', isEqualTo: playgroundId)
          .where('userID', isEqualTo: userid)
          .where('dateofBooking', isEqualTo: bookingDate)
          .where('selectedTimes', arrayContains: selectedTime)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          print('Document ID: ${doc.id}');
          print('Selected Times: ${doc['selectedTimes']}');
          DocumentSnapshot documentSnapshot = await firestore
              .collection('PlayersChat')
              .doc(a_id)
              .get();
          if (documentSnapshot.exists) {
            var data = documentSnapshot.data() as Map<String, dynamic>;
print(data);

            adminoooken = data['FCMToken'];
            print ("admintoken is $adminoooken");
          }

          await firestore.collection('booking').doc(doc.id).delete();
if(selectedTime.contains("PM")){
  String ms=" "+"تم إلغاء حجز ملعب "+" $g_name "+"يوم"+ " ${dayName} "+" ${selectedTime.substring(0,4)} "+"م";
  print("message of delete is $ms");

  String title = "الغاء حجز ";
  await _sendnotificationtofirebase(2,playgroundId,dayName,selectedTime);
  await sp(ms, title,
      adminoooken);
}else{
  String ms=" "+"تم إلغاء حجز ملعب "+" $g_name "+"يوم"+ " ${dayName} "+" ${selectedTime.substring(0,4)} "+"ص";
  print("message of delete is $ms");
  String title = "الغاء حجز ";
  await sp(ms, title,
      adminoooken);
  await _sendnotificationtofirebase(2,playgroundId,dayName,selectedTime);
}

          print('Document with phone $userid, playgroundId $playgroundId, dayName $dayName, and selectedTime $selectedTime deleted successfully.');
          documentDeleted = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          return;
        }
      }

      if (!documentDeleted) {
        print('No matching document found for deletion.');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
  fetchrateofgrounddatabyid(Rate_fetched ground) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('AddPlayground').doc(ground.playgroundIdstars).get();

      if (docSnapshot.exists) {

        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

 if (data != null ) {
          print("grounddaaaaaaaaaaaaata$data");
          return data;

        }
        else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $ground');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }
  Future<void> fetchRatings(String id) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Playground_Rate')
          .where('playground_idstars', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("IDrate: $id");

        rat_list = querySnapshot.docs
            .map((doc) => Rate_fetched.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        rat_list.sort((a, b) => b.totalRating.compareTo(a.totalRating));
        print("Sorted Ratings: $rat_list");
       for(int i=0;i<rat_list.length;i++){
         Map<String, dynamic>? user =   await fetchrateofgrounddatabyid(rat_list[i]);
         rat_list[i].PlayGroundName=user!['groundName'];
         rat_list[i].PlayGroundimg=user['img'][0];
         print("image of rate ${user['img'][0]}");
       }
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

    String numberString = number.toString();

    String convertedNumber = numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkتتتتتتk$convertedNumber");
    print("number equal $convertedNumber");
    return convertedNumber;
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

          if (user.playType == "كرة تنس" && teniss.isEmpty) {
            teniss.add(user);
          } else if (user.playType == "كرة سلة" && basket.isEmpty) {
            basket.add(user);
          } else if (user.playType == "كرة قدم" && footbal.isEmpty) {
            footbal.add(user);
          } else if (user.playType == "كرة طائرة" && volly.isEmpty) {
            volly.add(user);
          }

          user.id = document.id;
        }

        loadfourtype();
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

    setState(() {});
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
          print("PlayGroung Id shoka: ${document.id}");

          print("allplaygrounds[i] : ${allplaygrounds.last}");

          user.id = document.id;
          print("Docummmmmm${user.id}");
          for(int m=0;m<allplaygrounds.length;m++){
            print("kkkkkkkkshok${allplaygrounds[m]}");
            print("shimaaaaaaaplaygroundiddddd${allplaygrounds[m].id}");
        await    fetchRatings(allplaygrounds[m].id!);

          }

        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }

  final NavigationController navigationController = Get.put(NavigationController());
  double opacity = 1.0;
  Future<void> updateCancelCount(String userid)
  async {
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('cancel_book')
        .where('userid', isEqualTo: docId)

        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final currentCount = doc['numberofcancel'] ?? 0;
      await firestore
          .collection('cancel_book')
          .doc(doc.id)
          .update({'numberofcancel': currentCount + 1});
      print("dooooc$doc");
    } else {

      await firestore.collection('cancel_book').add({
        'userid': docId,
        'numberofcancel': 1,

      });
    }
  }
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
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Notification_page()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 33.0),
                        child: Image.asset(
                          'assets/images/notification.png',
                          height: 28,
                          width: 28,
                        ),
                      ),
                    ),
                    _isLoading?   Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
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
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334154),
                                  ),
                                )
                                    : Container()
                             ],
                            ),
                          ),
                          user1.isNotEmpty && user1[0].img!=null&&user1[0].img!=""? Padding(
                              padding: const EdgeInsets.only(right: 34.0),
                              child:ClipOval(
                                child:   CachedNetworkImage(
                                  imageUrl:    user1[0].img!,
                                     width: 63,
                                  height: 63,
                                  fit: BoxFit.fitWidth,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              )
                          ):
                          Padding(
                            padding: const EdgeInsets.only(right: 34.0),

                            child: Image.asset(
                              "assets/images/profile.png",
                              width: 63,
                              height: 63,

                            ),
                          ),
                        ],
                      ),
                    )
                        :GestureDetector(
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
                                  user1[0].name!.length<20? user1[0].name!:user1[0].name!.substring(0,20),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334154),
                                  ),
                                )
                                    : Container()
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
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    user1[0].img!,
                                     width: 63,
                                    height: 63,
                                    fit: BoxFit.fitWidth,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40,
                                    ),

                                  ),
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

                              ),
                            ),
                          ),
                                                ],
                                              ),
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
                                            ? CachedNetworkImage(
                                          imageUrl:  fourtypes[i].img![0],
                                          height: 163,
                                          width: 274,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40,
                                          ),

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
                    reverse: true,

                    child:Row(
                      children: [
                        for (var i = 0; i < playgroundbook.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 12,bottom: 3),
                            child: Container(

                              width: 230,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                shape: BoxShape.rectangle,
                                color: Color(0xFFF0F6FF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.7),
                                    spreadRadius: 0,
                                    blurRadius: 2,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 17.0, left: 17, top: 9),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                "${ playgroundbook[i].groundName.toString()!}",
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
                                        SizedBox(width: 10),
                                        ClipOval(
                                          child: Image(
                                            image: NetworkImage(
                                            playgroundbook [i].logoimage!,),


                                            fit: BoxFit.fitWidth,
                                            height: 30,
                                            width: 30,
                                          )
                                        )
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
                                                    playgroundbook[i].selectedTimes![0]??""),
                                              ):TextSpan(
                                                text:"",
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


                                  playgroundbook[i].acceptorcancle==false?          Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          print("groundName${playgroundbook[i]
                                              .groundName!}");
                                            updateCancelCount(
                                          playgroundbook[i].userID!,);
                                          deleteCancelByPhoneAndPlaygroundId(
                                              playgroundbook[i].userID!,
                                              playgroundbook[i].AdminId!,
                                              playgroundbook[i].groundName!,
                                              playgroundbook[i].GroundId!,
                                              playgroundbook[i].selectedTimes!.first,
                                              playgroundbook[i].dateofBooking!);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),
                                          child: Container(
                                            height: 23,
                                            width: 74,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),
                                              shape: BoxShape.rectangle,
                                              color: Color(0xFFB3261E),

                                            ),
                                            child: Center(
                                              child: Text(
                                                "إلغاء الحجز".tr,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
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
                                              color: Color(0xFF064821),

                                            ),
                                            child: Center(
                                              child: Text(
                                                "الموقع".tr,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize : 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ):Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(

                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),
                                          child: Container(
                                            height: 23,
                                            width: 74,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),
                                              shape: BoxShape.rectangle,

                                            ),
                                            child: Center(
                                              child: Text(
                                                "".tr,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(

                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 14.0,left: 14.0,top: 5,bottom: 5),

                                          child: Container(
                                            height: 23,
                                            width: 66,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.0),

                                            ),
                                            child: Center(
                                              child: Text(
                                                "".tr,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize : 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
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
                    reverse: true,

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
                                        child: Nearbystadiums[i].img!.isNotEmpty?CachedNetworkImage(
                                          imageUrl:   Nearbystadiums[i].img![0],
                                          height: 163,
                                          width: 274,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40,
                                          ),
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
                                        Nearbystadiums[i].playgroundName!,
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
                                      child: playgroundAllData[i].img!.isNotEmpty?CachedNetworkImage(
                                        imageUrl:     playgroundAllData[i].img![0],
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 40,
                                        ),
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
                                      playgroundAllData[i].playgroundName!,
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
                  reverse: true,
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
                                      child: rat_list2[i].PlayGroundimg!.isNotEmpty ?CachedNetworkImage(
                                        imageUrl:  rat_list2[i].PlayGroundimg!,
                                        height: 163,
                                        width: 274,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(color: Color(0xFF4AD080),),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 40,
                                        ),
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
                                      rat_list2[i].PlayGroundName!,
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
                Get.to(
                  menupage(),
                  arguments: {'from': 'home'},
                )?.then((_){
                  navigationController
                      .updateIndex(0);
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
                      .updateIndex(1);
                });

                break;

              case 3:

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
            height: MediaQuery.of(context).size.height/3,

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