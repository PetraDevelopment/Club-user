import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/NavigationController.dart';
import '../Menu/menu.dart';
import '../Register/SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../booking_playground/AddbookingModel/AddbookingModel.dart';
import '../location/map_page.dart';
import '../notification/model/modelsendtodevice.dart';
import '../notification/model/send_modelfirebase.dart';
import '../playground_model/AddPlaygroundModel.dart';
import '../Home/HomePage.dart';
import '../Home/Userclass.dart';

class my_reservation extends StatefulWidget {


  @override
  State<my_reservation> createState() {
    return my_reservationState();
  }
}

class my_reservationState extends State<my_reservation>
    with SingleTickerProviderStateMixin {
  final NavigationController navigationController =
  Get.put(NavigationController());
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String groundIid = '';
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
      click:false,
      date: daaate,
      day:day,
      bookingtime: booktime,
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

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  String toArabicNumerals(num number, int i) {
    const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String numberString = number.toString();

    String convertedNumber = numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkk$convertedNumber");

    print("number equal $convertedNumber");
    return convertedNumber;
  }
  late List<User1> user1 = [];
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

  void _load_cancel_book() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      String? normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');

      getcancel_bookDataByPhone(normalizedPhoneNumber);
    }
    else if (user?.phoneNumber != null) {
      String? normalizedPhoneNumber = user?.phoneNumber !.replaceFirst(
          '+20', '0');

      getcancel_bookDataByPhone(normalizedPhoneNumber!);
    }
  }

  int wait = 0;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _loadUserData();
    _load_cancel_book();
    _load_Accepted_book();

    fetchBookingData();

    setState(() {});
  }

  late List<AddbookingModel> playgroundbook = [];
  int numbercanceled = 0;
  int numberaccepted = 0;
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
  Future<void> getcancel_bookDataByPhone(String userPhone) async {
    final firestore = FirebaseFirestore.instance;

    try {

      final querySnapshot = await firestore
          .collection('cancel_book')
          .where('user_phone', isEqualTo: userPhone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {

        querySnapshot.docs.forEach((doc) {

          Map<String, dynamic> data = doc.data();
          int numberOfCancel = data['numberofcancel'] ?? 0;

          print('User Phone: ${data['user_phone']}');
          print('Number of Cancels: $numberOfCancel');
          numbercanceled = numberOfCancel;
        });
      } else {
        print('No data found for this phone number.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> getAccepted_bookDataByPhone(String userPhone) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print("uuuuusershimaaa: ${userPhone}");

      final querySnapshot = await firestore
          .collection('accepted')
          .where('phone_number', isEqualTo: userPhone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {

          Map<String, dynamic> data = doc.data();
          int numberOfaccepted = data['accepted_number'] ?? 0;

          print('User Phone: ${data['phone_number']}');
          print('Number of accepted: $numberOfaccepted');
          numberaccepted = numberOfaccepted;
        });
      } else {
        print('No data found for this phone number.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateFormat('dd MMMM yyyy').parse(dateString);
    return DateFormat('dd-MM-yyyy','ar').format(dateTime);
  }



  void _load_Accepted_book() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      String? normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');

      getAccepted_bookDataByPhone(normalizedPhoneNumber);
    }
    else if (user?.phoneNumber != null) {
      String? normalizedPhoneNumber = user?.phoneNumber !.replaceFirst(
          '+20', '0');

      getAccepted_bookDataByPhone(normalizedPhoneNumber!);
    }
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

            String playType = user.playType!.trim();
          }


          user.id = document.id;
        }
        wait = playgroundbook.length - numberaccepted;
        print("wait${wait}");
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  String useridddd="";
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
            bookingData.logoimage = Grounddata['LogoImg'];
            bookingData.groundImage = Grounddata['img'][0];
            playgroundbook.add(bookingData);
          }
          setState(() {

          });

        }

        if (playgroundbook.isNotEmpty) {

          for (int i = 0; i < playgroundbook.length; i++) {

            print('AdminId: ${playgroundbook[i].AdminId}');
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');

            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].UserPhone!}');
          }
        } else {
          print('No matching bookings found for the phone number.');
        }
      } else if (user?.phoneNumber != null) {
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
            bookingData.groundImage = Grounddata['img'][0];
            bookingData.logoimage = Grounddata['LogoImg'];

            playgroundbook.add(bookingData);
          }
          setState(() {

          });

        }

        if (playgroundbook.isNotEmpty) {
          for (int i = 0; i < playgroundbook.length; i++) {
            print('AdminId: ${playgroundbook[i].AdminId}');
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].UserPhone!}');
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
  String apiEndpoint = 'http://192.168.0.42/notificaions/send_notification.php';

  Future<http.Response> sendNotification(NotificationData data) async {
    final uri = Uri.parse(apiEndpoint);
    final response = await http.post(uri, body: data.toMap());
    return response;
  }

  Future<void> sp(String ms, title, d_token) async {
    final notificationData =
    NotificationData(message: ms, title: title, deviceToken: d_token);
    final response = await sendNotification(notificationData);

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Error sending notification: ${response.statusCode}');
      print(response.body);
    }
  }
  String adminoooken="";

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
            MaterialPageRoute(builder: (context) => my_reservation()),
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

  Future<void> updateCancelCount(String userPhone, String idAdmin,
      String idGround)
  async {
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('cancel_book')
        .where('user_phone', isEqualTo: userPhone)

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
        'user_phone': userPhone,
        'numberofcancel': 1,
        'playgroundId': idGround,
        'adminid': idAdmin,
      });
    }
  }

  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime);
    DateTime end = start.add(Duration(hours: 1));

    String formattedStartTime = DateFormat('h:mm a', 'ar')
        .format(start)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(
          int.parse(match.group(0)!));
    });

    String formattedEndTime = DateFormat('h:mm a', 'ar')
        .format(end)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(int.parse(match.group(0)!));
    });

    return '$formattedStartTime الي $formattedEndTime';
  }



  late List<AddPlayGroundModel> allplaygroundsData = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

          Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<dynamic, dynamic>?;
          if (arguments != null && arguments['from'] == 'home') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => menupage(),
              ),
            );
          }

        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Padding(
            padding: EdgeInsets.only(top: 25.0, right: 8, left: 8),
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "الحجوزات".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
                      ?.settings
                      .arguments as Map<dynamic, dynamic>?;
                  if (arguments != null && arguments['from'] == 'home') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => menupage(),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Directionality.of(context) == TextDirection.RTL
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
                    'assets/images/notification.png', height: 28, width: 28,),
                ),

              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body:isConnected? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              SizedBox(
                height: 22,
              ),
              Center(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Container(
                        height: 93,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(17),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          shape: BoxShape.rectangle,
                          color: Colors
                              .black,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "${wait}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  Text(
                                    "قيد الانتظار",
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF495A71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        height: 93,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(17),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          shape: BoxShape.rectangle,
                          color: Colors.red
                              .shade200,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF),
                              ),
                              child: Column(
                                children: [
                                  Text("$numbercanceled",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  Text(
                                    "حجزات ملغية",
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF495A71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        height: 93,
                        width: 87,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(17),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          shape: BoxShape.rectangle,
                          color: Colors.green
                              .shade400,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "${ numberaccepted}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334154),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  Text(
                                    "حجزات مأكدة",
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF495A71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 28,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 26.0, left: 26),
                child: Text(
                  "تاريخ الحجوزات".tr,
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
              if(playgroundAllData.isEmpty)Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height/2.5,
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
                                    "assets/images/reservationzerostate.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                                Text(
                                  'لا يوجد حجوزات حتى الأن',
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
              ),
              for (var i = 0; i < playgroundAllData.length; i++)
                playgroundAllData.isNotEmpty ?
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 10,),
                  child: Center(
                    child: Container(

                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        shape: BoxShape.rectangle,
                        color: Color(0xFFF0F6FF),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            spreadRadius: 0,
                            blurRadius: 2,

                            offset: Offset(0,
                                0),  ),
                        ],
                      ),
                      child: playgroundbook.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 12.0, left: 12, top: 11),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${playgroundbook[i].groundName!}",
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF334154),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "ج.م ",


                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        ),
                                        Text(
                                          "${playgroundbook[i].totalcost!}",

                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 4.2,),
                                        Text(
                                          "${playgroundbook[i].UserPhone}",

                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF7D90AC),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),

                                ClipOval(
                                  child: Image(image:  NetworkImage(
                                      playgroundbook[i].logoimage!,

                                      // Adjust size as needed

                                    ),
                                    fit: BoxFit.fitWidth,
                                    height: 30,
                                    width: 30,
                                  ),
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
                                  mainAxisAlignment: MainAxisAlignment.end,

                                  children: [
                                    Text(
                                      "التكلفة أجمالية  ".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 10.77,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF334154),
                                      ),
                                    ),
                                     SizedBox(width: MediaQuery.of(context).size.width/6.7,),
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
                                SizedBox(width: 10,),
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

                                      playgroundbook[i]
                                          .selectedTimes!.isNotEmpty?     TextSpan(
                                        text: getTimeRange(
                                            playgroundbook[i]
                                                .selectedTimes![0]),   ):TextSpan(
                            text:"",
                          ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),


                          playgroundbook[i].acceptorcancle == false?         Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 7, left: 22),
                                child: GestureDetector(
                                  onTap: () {
                                    print("phooonefff${playgroundbook[i].UserPhone!}");
                                    print("jjjjjjgroundd${

                                        playgroundbook[i].userID!

                                    }");
                                    updateCancelCount(
                                        playgroundbook[i].UserPhone!,
                                        playgroundbook[i].AdminId!,
                                        playgroundbook[i].GroundId!);
                                    deleteCancelByPhoneAndPlaygroundId(
                                        playgroundbook[i].userID!,
                                        playgroundbook[i].AdminId!,
                                        playgroundbook[i].groundName!,
                                        playgroundbook[i].GroundId!,
                                        playgroundbook[i].selectedTimes!.first,
                                        playgroundbook[i].dateofBooking!);
                                  },
                                  child: Container(
                                    height: 29,
                                    width: 114,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      shape: BoxShape.rectangle,
                                      color: Color(
                                          0xFFB3261E),

                                    ),
                                    child: Center(
                                      child: Text(
                                        "إلغاء الحجز".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 7, right: 22),
                                child: GestureDetector(
                                  onTap: () async {
                                    print("locattttion${playgroundAllData[i]
                                        .location!}");
                                    print(
                                        "convertmonthtonumber${playgroundbook[i]
                                            .dateofBooking!}");


                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          Maps(location: playgroundAllData[i]
                                              .location!)),
                                    );
                                  },
                                  child: Container(
                                    height: 29,
                                    width: 114,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      shape: BoxShape.rectangle,
                                      color: Color(
                                          0xFF064821),

                                    ),
                                    child: Center(
                                      child: Text(
                                        "الموقع".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 7, left: 22),
                                child: GestureDetector(

                                  child: Container(
                                    height: 29,
                                    width: 114,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      shape: BoxShape.rectangle,

                                    ),
                                    child: Center(
                                      child: Text(
                                        "".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 7, right: 22),
                                child: GestureDetector(

                                  child: Container(
                                    height: 29,
                                    width: 114,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),

                                    ),
                                    child: Center(
                                      child: Text(
                                        "".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
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
                      ) : Container(),
                    ),
                  ),
                ): Center(
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

                                  Image.asset(
                                    "assets/images/amico.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                  Text(
                                    'لا يوجد حجوزات حتى الأن',
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
                ),
              SizedBox(height: 55),

            ],
          ),
        ):_buildNoInternetUI(),
        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 1,

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
                Get.to(() => menupage())?.then((_) {
                  navigationController
                      .updateIndex(0);
                });
                break;

              case 1:

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