import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Home/Userclass.dart';
import '../../Menu/menu.dart';
import '../../Register/SignInPage.dart';
import '../../Splach/LoadingScreen.dart';
import '../../my_reservation/my_reservation.dart';
import '../../notification/model/modelsendtodevice.dart';
import '../../notification/model/send_modelfirebase.dart';
import '../../notification/notification_repo.dart';
import '../../playground_model/AddPlaygroundModel.dart';
import '../AddbookingModel/AddbookingModel.dart';
import '../widgets_for_popover_cancel_and_add/reservation.dart';

class book_playground_page extends StatefulWidget {
  String IdData;

  book_playground_page(this.IdData);

  @override
  State<book_playground_page> createState() {
    return book_playground_pageState();
  }
}

class book_playground_pageState extends State<book_playground_page>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  int PhooneNumberMaxLength = 10;
  Set<String> selectedTimes = {};
  bool isLoading = false;
  late List<AddPlayGroundModel> playgroundAllData = [];
  List<String> dayss = [];
  String date = '';
  String date2 = '';

  List<DateTime> datees = [];
  int _currentIndex = 0; // Add this state variable to track the current page

  late List<AddbookingModel> playgroundbook = [];
  List<AddbookingModel> matchedPlaygrounds = [];
  late List<AddPlayGroundModel> matchedplaygroundAllData = [];

  Future<String> convertmonthtonumber(date, int index) async {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    for (int k = 0; k < months.length; k++) {
      if (date.contains(months[k])) {
        date = date.replaceAll(months[k], '-${k + 1}-');
        print("updated done with ${date}");
        playgroundbook[index].dateofBooking = date;
      }
    }
//loop in date to convert every en number to ar

    date = date.replaceAllMapped(RegExp(r'\d'), (match) {
      const englishToArabicNumbers = [
        '٠',
        '١',
        '٢',
        '٣',
        '٤',
        '٥',
        '٦',
        '٧',
        '٨',
        '٩'
      ];

      playgroundbook[index].dateofBooking =
          englishToArabicNumbers[int.parse(match.group(0)!)];
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });

    print(" date in Arabic : $date");
    playgroundbook[index].dateofBooking = date;

    return date;
  }

  Future<String> convertmonthtonumberforlastwidget(date2, int index) async {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    for (int k = 0; k < months.length; k++) {
      if (date2.contains(months[k])) {
        date2 = date2.replaceAll(months[k], '-${k + 1}-');
        print("updated matchedPlaygrounds done with ${date2}");
        // matchedPlaygrounds[index].dateofBooking=date2;
// print("shokaaaa matchedPlaygrounds[index].dateofBooking${ matchedPlaygrounds[index].dateofBooking!}");
      }
    }
//loop in date to convert every en number to ar

    date2 = date2.replaceAllMapped(RegExp(r'\d'), (match) {
      const englishToArabicNumbers = [
        '٠',
        '١',
        '٢',
        '٣',
        '٤',
        '٥',
        '٦',
        '٧',
        '٨',
        '٩'
      ];

      englishToArabicNumbers[int.parse(match.group(0)!)];
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });

    print(" date in Arabic : $date2");

    return date2;
  }

  String toArabicNumerals(num number, int i) {
    const englishToArabicNumbers = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩'
    ];

    // Convert the number to a string for processing
    String numberString = number.toString();

    String convertedNumber =
        numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkknum$convertedNumber");
    print("number equal $convertedNumber");
    return convertedNumber; // Return the converted number
  }

  late DateTime Day1;
  late DateTime Day2;
  var Phoone = '';
  String PhooneErrorText = '';
  String SelectedTimeErrorText = '';

  List<User> users = [];
  final NavigationController navigationController =
      Get.put(NavigationController());
  List<bool> _isCheckedList = [false, false, false, false, false];
  List<String> timeSlots = [];
  String startTimeStr = '';

  String endTimeStr = '';
  List<Map<String, DateTime>> selectedDates = [];
  String selectedDayName = '';
  String? storeDate;
  int tappedIndex = 0;
  late AnimationController _animationController;

  String normalizeText(String text) {
    return text.trim(); // Trims any leading or trailing spaces
  }

  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime); // Parse the start time
    DateTime end = start.add(Duration(hours: 1)); // Add 1 hour for the end time

    // Format the time in Arabic but numbers in English
    String formattedStartTime = DateFormat('h:mm a', 'ar')
        .format(start)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en')
          .format(int.parse(match.group(0)!)); // Ensure numbers are in English
    });

    String formattedEndTime = DateFormat('h:mm a', 'ar')
        .format(end)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(int.parse(match.group(0)!));
    });

    return '$formattedStartTime     الي     $formattedEndTime';
  }

  String useridddd = "";

  fetchuserdatabyid(AddbookingModel userid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
          await firestore.collection('Users').doc(userid.userID).get();

      if (docSnapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
// for(int ii = 0; ii <playgroundbook.length ;ii++){

        if (data != null) {
          return data;
// userid.UserName= data['name'];
// userid.UserPhone = data['phone'];
// userid.UserImg = data['profile_image'];
//
// print("playgroundbook[0].UserName ${userid.UserName }");
// print("playgroundbook[0].UserPhonee${userid.UserPhone }");
// print("playgroundbook[0].UserImg ${userid.UserImg }");
//           print('Data for this daaata: $data');
        } else {
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
      DocumentSnapshot docSnapshot = await firestore
          .collection('AddPlayground')
          .doc(ground.GroundId)
          .get();

      if (docSnapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          print("grounddaaaaaaaaaaaaata$data");
          return data;

        } else {
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
      CollectionReference bookingdataa =
          FirebaseFirestore.instance.collection("booking");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneValue = prefs.getString('phonev');
      print("newphoneValue${phoneValue.toString()}");

      if (phoneValue != null && phoneValue.isNotEmpty) {
        String normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');
        CollectionReference uuuserData =
            FirebaseFirestore.instance.collection('Users');

// Query the PlayersChat collection to find the document where phone number matches
        QuerySnapshot adminSnapshot = await uuuserData
            .where('phone', isEqualTo: normalizedPhoneNumber)
            .get();
        print('shared phooone $normalizedPhoneNumber');
        if (adminSnapshot.docs.isNotEmpty) {
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc
              .id; // Get the document ID (this will be the AdminId for playgrounds)
          print("Matched user docId: $docId");
          useridddd = docId;
        }
        QuerySnapshot bookingSnapshot = await bookingdataa
            .where('GroundId', isEqualTo: widget.IdData)
            .where('userID', isEqualTo: useridddd)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          playgroundbook = []; // Initialize as an empty list
          for (var document in bookingSnapshot.docs) {
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;
            AddbookingModel bookingData = AddbookingModel.fromMap(userData);
            Map<String, dynamic>? user = await fetchuserdatabyid(bookingData);

            bookingData.UserName = user!['name'];
            bookingData.UserPhone = user['phone'];
            bookingData.UserImg = user['profile_image'];
            Map<String, dynamic>? Grounddata =
                await fetchgrounddatabyid(bookingData);
            bookingData.groundName = Grounddata!['groundName'];
            bookingData.groundphone = Grounddata['phone'];
            bookingData.groundImage = Grounddata['img'][0];
            // Store the document ID in the model
            playgroundbook.add(bookingData); // Add playground to the list

            // print("Stored document ID in model: ${user.id}");
          }
          setState(() {});
        }

        if (playgroundbook.isNotEmpty) {
          // Print and access specific fields for each booking
          for (int i = 0; i < playgroundbook.length; i++) {
            // formatDate(playgroundbook[i].dateofBooking!);

            print('AdminId: ${playgroundbook[i].AdminId}');
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');

            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].UserPhone!}');
          }
        } else {
          print('No matching bookings found for the phone number.');
        }
      } else if (user?.phoneNumber != null) {
        String? normalizedPhoneNumber =
            user?.phoneNumber!.replaceFirst('+20', '0');
        CollectionReference uuuserData =
            FirebaseFirestore.instance.collection('Users');

// Query the PlayersChat collection to find the document where phone number matches
        QuerySnapshot adminSnapshot = await uuuserData
            .where('phone', isEqualTo: normalizedPhoneNumber)
            .get();
        print('shared phooone $normalizedPhoneNumber');
        if (adminSnapshot.docs.isNotEmpty) {
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc
              .id; // Get the document ID (this will be the AdminId for playgrounds)
          print("Matched user docId: $docId");
          useridddd = docId;
        }
        QuerySnapshot bookingSnapshot = await bookingdataa
            .where('GroundId', isEqualTo: widget.IdData)
            .where('userID', isEqualTo: useridddd)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          playgroundbook = []; // Initialize as an empty list
          for (var document in bookingSnapshot.docs) {
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;
            AddbookingModel bookingData = AddbookingModel.fromMap(userData);
            Map<String, dynamic>? user = await fetchuserdatabyid(bookingData);

            bookingData.UserName = user!['name'];
            bookingData.UserPhone = user['phone'];
            bookingData.UserImg = user['profile_image'];
            Map<String, dynamic>? Grounddata =
                await fetchgrounddatabyid(bookingData);
            bookingData.groundName = Grounddata!['groundName'];
            bookingData.groundphone = Grounddata['phone'];
            bookingData.groundImage = Grounddata['img'][0];
            // Store the document ID in the model
            playgroundbook.add(bookingData); // Add playground to the list

            // print("Stored document ID in model: ${user.id}");
          }
          setState(() {});
        }

        if (playgroundbook.isNotEmpty) {
          for (int i = 0; i < playgroundbook.length; i++) {
            if (playgroundbook[i].UserPhone == normalizedPhoneNumber) {
              setState(() {
                matchedPlaygrounds.add(playgroundbook[i]);

                print("matchedPlaygrounds.1${matchedPlaygrounds.length}");

                getmaatchedPlaygroundbyname(matchedPlaygrounds[i].GroundId!);
                print("shimaaaa${matchedPlaygrounds.length}");
                print("shimaaaa dataaaaaa${matchedPlaygrounds[i]}");
                convertmonthtonumberforlastwidget(
                    matchedPlaygrounds[0].dateofBooking!, i);
              });
            }
            print('AdminId: ${playgroundbook[i].AdminId}');
            // formatDate(playgroundbook[i].dateofBooking!);
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].UserPhone!}');
            getPlaygroundbyname(playgroundbook[i].GroundId!);
          }
          if (timeSlots.isNotEmpty) {
            startendtime(timeSlots.first, timeSlots.last);
            print("time for start: ${timeSlots.first} + ${timeSlots.last}");
          } else {
            print("timeSlots is empty.");
          }
        } else {
          print('No matching bookings found for the user’s phone number.');
        }
      }
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }

  num costboll = 0;

  String? USerID;
  String? timeofAddedPlayground;

  String groundIiid = '';
  String sellll = '';

  String groundIiid2 = '';

  Future<void> _handleSlotTap(String slot) async {
    setState(() {
      isLoading = true; // Start loading
    });

    // Simulate a delay for processing the selection
    await Future.delayed(Duration(seconds: 2));

    // Here you can perform your reservation logic
    setState(() {
      isLoading = false; // Stop loading
    });
  }

  int cnt = 0;
  List<num> selectedCosts = [];
  List<num> selectedCostsperhour = [];

  Future<void> notifyAdmin(String adminId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
          await firestore.collection('PlayersChat').doc(adminId).get();

      if (docSnapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('FCMToken')) {
          String? fcmToken = data['FCMToken'];
          print('Data for this admin: $fcmToken');
        } else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $adminId');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> getPlaygroundbyname(String iiid) async {
    try {
      CollectionReference playerchat =
          FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
          if (document.id == widget.IdData) {
            playgroundAllData.add(user);
            String? bookType = playgroundAllData[0].bookTypes![0].time;

            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");

            // Splitting time into startTime and endTime based on '-'
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];

              print("Start Time: $startTime");
              print("End Time: $endTime");
              String adminId = playgroundAllData[0]
                  .adminId!; // Fetch AdminId directly from userData
              groundPhoneee = playgroundAllData[0].phoneCommunication!;
              groundNamee = playgroundAllData[0].playgroundName!;

              // You can use these times to update the UI or for other logic
              timeSlots.add(startTime); // Add start time to the list
              timeSlots.add(endTime); // Add end time to the list
              num ttt = 0;
              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              for (var bookType in playgroundAllData[0].bookTypes!) {
                print("hhhselectedDayName$selectedDayName");
                if (bookType.day == selectedDayName) {
                  setState(() {
                    costboll = 0;
                    costboll += bookType.cost!;
                    print("coopppppppp$costboll");
                  });
                  print("tessst${bookType.cost! + bookType.costPerHour!}");
                }
              }
              setState(() {
                // Update any UI components with the start and end times
                startTimeStr =
                    startTime; // Assuming you have a state variable to store this
                endTimeStr = endTime;
              });

              print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            // }
// الوقت  هو سبب المشكله
            print(
                "PlayGroungboook Iiid : ${document.id}"); // Print the latest playground
            groundIiid = document.id;
            print("Docummmmmmbook$groundIiid");
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

  Future<void> getmaatchedPlaygroundbyname(String iiid) async {
    try {
      CollectionReference playerchat =
          FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
          if (document.id == widget.IdData) {
            matchedplaygroundAllData.add(user);

            String? bookType = matchedplaygroundAllData[0].bookTypes![0].time;
            // Assuming 'time' is the field you want to split into start and end time
            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");

            // Splitting time into startTime and endTime based on '-'
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];

              print("Start Time: $startTime");
              print("End Time: $endTime");
              String adminId = matchedplaygroundAllData[0]
                  .adminId!; // Fetch AdminId directly from userData

              // You can use these times to update the UI or for other logic
              timeSlots.add(startTime); // Add start time to the list
              timeSlots.add(endTime); // Add end time to the list

              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              setState(() {
                // Update any UI components with the start and end times
                startTimeStr =
                    startTime; // Assuming you have a state variable to store this
                endTimeStr =
                    endTime; // Assuming you have a state variable to store this
              });

              print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            // }
// الوقت  هو سبب المشكله
            print(
                "PlayGroungboook Iiid : ${document.id}"); // Print the latest playground
            groundIiid2 = document.id;
            print("Docummmmmmbook$groundIiid2");
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

  int selectedIndex = 3;
  double opacity = 1.0;
  Map<String, Set<String>> fetchedSelectedTimesPerDay = {};

  Map<String, Set<String>> alreadySelectedTimesPerDay = {};

  Future<void> _fetchData() async {
    final playgrounddata = await FirebaseFirestore.instance
        .collection('booking')
        .where('GroundId', isEqualTo: widget.IdData)
        .get();

    List<AddbookingModel> bookings = playgrounddata.docs.map((doc) {
      return AddbookingModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Initialize the map to store selected times per day

    // Loop through each booking and add its selected times to the correct day
    for (var booking in bookings) {
      String day =
          booking.Day_of_booking ?? ''; // Replace with correct day field
      Set<String> selectedTimes = booking.selectedTimes?.toSet() ?? {};

      // Ensure the times are in a standard format (e.g., "9:00 PM", "5:00 PM")
      Set<String> formattedTimes = selectedTimes.map((time) {
        // Here you can format time if necessary, for example using DateFormat or custom formatting
        return time
            .trim(); // For simplicity, just trimming extra spaces in this example
      }).toSet();

      // If the day already exists in the map, add the times to the set
      if (fetchedSelectedTimesPerDay.containsKey(day)) {
        fetchedSelectedTimesPerDay[day]!.addAll(formattedTimes);
        print("fetchbooking${formattedTimes}");
      } else {
        // Otherwise, create a new entry for that day
        fetchedSelectedTimesPerDay[day] = formattedTimes;
        print("fetchbooking${formattedTimes}");
      }
    }

    // Optionally, you can print out the fetched data to verify
    print("Fetched times per day: $fetchedSelectedTimesPerDay");

    // Update the state with the fetched data
    setState(() {
      // Update state variables if needed
      // alreadySelectedTimesPerDay = fetchedSelectedTimesPerDay;
      // print("alllllldata ${playgroundbook.length}");
    });
  }

  String? groundNamee;

  String? groundPhoneee;
  String? useridd = "";

  fetchadmindatabyid(String admin) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
          await firestore.collection('PlayersChat').doc(admin).get();

      if (docSnapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
// for(int ii = 0; ii <playgroundbook.length ;ii++){

        if (data != null) {
          print("PlayersChat data is $data");
          return data;
// userid.UserName= data['name'];
// userid.UserPhone = data['phone'];
// userid.UserImg = data['profile_image'];
//
// print("playgroundbook[0].UserName ${userid.UserName }");
// print("playgroundbook[0].UserPhonee${userid.UserPhone }");
// print("playgroundbook[0].UserImg ${userid.UserImg }");
//           print('Data for this daaata: $data');
        } else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $admin');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  String convertTo12HourFormat(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert hour '0' to '12'
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _sendnotificationtofirebase(int type,String Groundid,day,booktime) async {
    setState(() {
      _isLoading = true; // Set loading to true when starting the operation
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
      day:day,
      bookingtime: booktime,
      notificationType: type,
    );

    // Add booking to Firestore
    await FirebaseFirestore.instance
        .collection('notification')
        .add(notificationModel.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم ارسال البيانات بنجاح', // "Data registered successfully"
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xFF1F8C4B),
      ),
    );

    // Clear inputs after successful booking

    setState(() {
      _isLoading = false; // Set loading to false when operation is complete
    });
  }

  Future<void> _sendData(BuildContext context, bool x) async {
    setState(() {
      _isLoading = true; // Set loading to true when starting the operation
    });
    final name = user1[0].name!;
    final phooneNumber = user1[0].phoneNumber!;
    num cooooooooooost = playgroundAllData[0].bookTypes![0].cost!;
    final selectedDay = selectedDayName; // The day the user selects for booking

    // Step 1: Initialize total cost
    num totalCost = 0;

    // Step 2: Calculate the total cost based on the selected day and time
    // Loop through each selected time and match with the costs in playgroundAllData
    for (var selectedTime in selectedTimes) {
      print("shokddddddddda${selectedTime}");
      print("shokddddddddda${selectedDay}");
      sellll = selectedTime;
      print("selllllllllllllllllll$sellll");
      for (var bookType in playgroundAllData[0].bookTypes!) {
        if (bookType.day == selectedDay) {
          totalCost = 0;
          if (x == true) {
            totalCost += bookType.costPerHour! + costboll;
            print("tesssttruee$totalCost");
          } else {
            totalCost += bookType.costPerHour!;
            print("tessst$totalCost");
          }
        }
      }
    }
    print("Total cost test: $totalCost");

    print("Checking phone number: $phooneNumber");

    // Check for empty fields
    if (name.isNotEmpty &&
        phooneNumber.isNotEmpty &&
        selectedTimes.isNotEmpty) {
      print("Selected date: $storeDate");
      // Query the 'booking' collection for documents that match date, day, and any overlapping times
      final bookingQuery = await FirebaseFirestore.instance
          .collection('booking')
          .where('GroundId', isEqualTo: widget.IdData)
          .where('dateofBooking', isEqualTo: storeDate) // Check date
          .where('Day_of_booking', isEqualTo: selectedDayName) // Check day
          .where('selectedTimes', arrayContainsAny: selectedTimes)
          .get();

      if (bookingQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الحجز موجود بالفعل', // "This booking already exists"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String phoooone = prefs.getString('phone') ?? '';

        final bookingModel = AddbookingModel(
            GroundId: widget.IdData,
            groundImage: playgroundAllData[0].img![0],
            totalcost: totalCost.toInt(),
            dateofBooking: storeDate,
            Day_of_booking: selectedDayName,
            rentTheBall: _isCheckedList[0],
            selectedTimes: selectedTimes.toList(),
            AdminId: playgroundAllData[0].adminId,
            acceptorcancle: false,
            userID: useridd);

        // Add booking to Firestore
        await FirebaseFirestore.instance
            .collection('booking')
            .add(bookingModel.toMap());
        Map<String, dynamic>? user =
            await fetchadmindatabyid(playgroundAllData[0].adminId!);
        String ms = "تم اضافة حجز جديد";
        String title = "حجز جديد";
        String token = user!['FCMToken'];

        print("toooooooooook$token");
        await _sendnotificationtofirebase(1,groundIiid,selectedDayName,selectedTimes);
        await sp(ms, title,
            token); // await sendnotfication(playgroundAllData[0].adminId!);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل البيانات بنجاح', // "Data registered successfully"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );

        // Clear inputs after successful booking
        selectedTimes.clear();

        _isCheckedList[0] = false;
        setState(() {
          matchedPlaygrounds.clear(); // Clear previous entries
        });
        fetchBookingData();
      }
    } else {
      // Show message if required fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء جميع البيانات', // "Please fill in all fields"
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
    setState(() {
      _isLoading = false; // Set loading to false when operation is complete
    });
  }

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

  bool isAlreadySelected = false;

  String formatDate(String dateString) {
    DateTime dateTime = DateFormat('dd MMMM yyyy').parse(dateString);
    return DateFormat('dd-MM-yyyy', 'ar').format(dateTime);
  }

  late List<User1> user1 = [];
  User? user = FirebaseAuth.instance.currentUser;

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
        var useridd444 = querySnapshot.docs.first.id;
        print("Matched user docId: $useridd444");
        useridd = useridd444;
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

  void validateSelectedTimeAndDate() {
    if (selectedTimes.isEmpty) {
      setState(() {
        SelectedTimeErrorText = ' يجب اختيار وقت *'.tr;
      });
    } else {
      setState(() {
        SelectedTimeErrorText = ''; // No error message if time is selected
      });
    }
  }

  List<String> startendtime(String startTimeStr, String endTimeStr) {
    // Clean up non-standard spaces
    startTimeStr = startTimeStr.replaceAll(RegExp(r'\u202F'), ' ').trim();
    endTimeStr = endTimeStr.replaceAll(RegExp(r'\u202F'), ' ').trim();

    DateTime startTime = Jiffy.parse(startTimeStr, pattern: 'h:mm a').dateTime;
    DateTime endTime = Jiffy.parse(endTimeStr, pattern: 'h:mm a').dateTime;

    print("starttimmme$startTime");
    intl.DateFormat timeFormat = intl.DateFormat.jm();

    DateTime currentTime = startTime;
    List<String> timeSlots = [];

    while (currentTime.isBefore(endTime) ||
        currentTime.isAtSameMomentAs(endTime)) {
      timeSlots.add(timeFormat.format(currentTime));
      currentTime = currentTime.add(Duration(hours: 1));
    }

    for (String slot in timeSlots) {
      print("sl00ot$slot");
    }

    return timeSlots;
  }

  bool isConnected = true;

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
    } else {
      isConnected = true;
    }
    print("bvbbvbvbb$isConnected");
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
              .doc(a_id) // Use adminid as the document ID
              .get();
          if (documentSnapshot.exists) {
            var data = documentSnapshot.data() as Map<String, dynamic>;
            print(data);

            adminoooken = data['FCMToken'];
            print ("admintoken is $adminoooken");
          }
          // Delete the document
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
String iddd=widget.IdData;
          // Navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => book_playground_page(iddd)),
          );
          return; // Exit after deletion
        }
      }

      if (!documentDeleted) {
        print('No matching document found for deletion.');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
  void initState() {
    checkInternetConnection();
    _loadUserData();
    fetchBookingData();

    _fetchData();
    getAllBookingDocuments();
    getPlaygroundbyname(widget.IdData);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get today's date
    DateTime today = DateTime.now();

    // List to store days and their corresponding dates
    List<Map<String, String>> daysOfWeek = [];

    // Loop to get the next 7 days (including today)
    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));

      // Format day name and date
      String dayName =
          DateFormat('EEEE', 'ar').format(day); // Full day name, e.g., Monday
      String dayDate = DateFormat('dd MMMM yyyy').format(day);

      // Add to the list as a map
      daysOfWeek.add({'dayName': dayName, 'dayDate': dayDate});

      // Store the day name and date in the selectedDates list as a Map<String, DateTime>
      selectedDates.add({dayName: day});

      // print("Selected Dates: $selectedDates");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, right: 12, left: 12),
          // Add padding to the top of the title
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "حجز ملعب".tr,
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
      body: isConnected
          ? Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25, top: 15, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'تاريخ الحجز'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Cairo',
                              color: Color(0xFF495A71), // اللون الأساسي
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        //show day with date
                        playgroundAllData.isNotEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return Center(
                                    child: Stack(
                                      children: [
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            height: 125,
                                            viewportFraction: 0.2,
                                            // Adjust this value as needed
                                            initialPage: _currentIndex,
                                            // Start with the center item
                                            enableInfiniteScroll: false,
                                            autoPlay: false,
                                            enlargeCenterPage: true,
                                            // Ensure the center item is enlarged
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex =
                                                    index; // Update the current index on page change
                                                selectedDayName = daysOfWeek[
                                                        index][
                                                    'dayName']!; // Update the selected day name
                                                storeDate = daysOfWeek[index]
                                                    ['dayDate'];
                                              });
                                            },
                                            scrollDirection: Axis.horizontal,
                                          ),
                                          items: daysOfWeek.map((dayInfo) {
                                            int itemIndex = daysOfWeek.indexOf(
                                                dayInfo); // Get the index of the item

                                            return GestureDetector(
                                              onTap: () {
                                                print(
                                                    "Tapped on ${dayInfo['dayName']} - ${dayInfo['dayDate']}");
                                                storeDate = dayInfo['dayDate'];
                                                print(
                                                    "objectstoreDate$storeDate");
                                                setState(() {
                                                  _currentIndex =
                                                      itemIndex; // Update the current index when an item is tapped
                                                  selectedDayName =
                                                      dayInfo['dayName']!;
                                                  print(
                                                      "objectselectedDayName$selectedDayName");
                                                  // Save the selected day name
                                                  getPlaygroundbyname(
                                                      widget.IdData);
                                                  selectedTimes = {};
                                                });
                                              },
                                              child: Center(
                                                child: AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  // Add smooth transition for color changes
                                                  width: 87,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(17),
                                                      bottomLeft:
                                                          Radius.circular(17),
                                                      topRight:
                                                          Radius.circular(22),
                                                      topLeft:
                                                          Radius.circular(22),
                                                    ),
                                                    // Highlight with green if it is the center item (current index)
                                                    color: _currentIndex ==
                                                            itemIndex
                                                        ? Colors.green.shade500
                                                        : Colors.transparent,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        IntrinsicHeight(
                                                          child: Container(
                                                            height: 92,
                                                            width: 87,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              color: Color(
                                                                  0xFFF0F6FF), // Inner container color
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 2.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                // Center the content
                                                                children: [
                                                                  Text(
                                                                    dayInfo[
                                                                        'dayName']!,
                                                                    // Display day name
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Cairo',
                                                                      fontSize:
                                                                          10.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                          0xFF334154),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8),
                                                                  Text(
                                                                    DateFormat(
                                                                            'dd')
                                                                        .format(
                                                                            DateFormat('dd MMMM yyyy').parse(dayInfo['dayDate']!) // Parse the date
                                                                            ),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Cairo',
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                          0xFF495A71),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 18.0,
                                                                  left: 12),
                                                          child: Container(
                                                            height: 2.5,
                                                            // Height of the green color section
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            22),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        22),
                                                              ),
                                                              // Green color for the selected (centered) day
                                                              color: _currentIndex ==
                                                                      itemIndex
                                                                  ? Colors.green
                                                                      .shade500
                                                                  : Colors
                                                                      .transparent,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )
                            : SizedBox(
                                height: 125,
                                child: Center(
                                    child: Text("لم يتم اضافة تاريخ بعد "))),

                        Padding(
                          padding: const EdgeInsets.all(.0),
                          child: Text(
                            'موعد الحجز'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Cairo',
                              color: Color(0xFF495A71), // اللون الأساسي
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        playgroundAllData.isNotEmpty &&
                                playgroundAllData.any((data) => data.bookTypes!
                                    .any((bt) => bt.day == selectedDayName))
                            ? playgroundAllData.isNotEmpty &&
                                    playgroundAllData.any((data) => data
                                        .bookTypes!
                                        .any((bt) => bt.day == selectedDayName))
                                ? FutureBuilder<List<Widget>>(
                                    future: _generateRows(
                                        selectedTimes, selectedDayName),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: _isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.green,
                                                ) // Show a loading indicator
                                              : Container(), // Show an empty container or other content
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                "Error: ${snapshot.error}"));
                                      }
                                      if (snapshot.hasData) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children:
                                              snapshot.data!.map((slotWidget) {
                                            return GestureDetector(
                                              onTap: () {
                                                _handleSlotTap(slotWidget
                                                    .toString()); // Pass the slot value
                                              },
                                              child:
                                                  slotWidget, // Use the slot widget
                                            );
                                          }).toList(),
                                        );
                                      }
                                      return Center(
                                          child: Text("No data available"));
                                    },
                                  )
                                : Container(
                                    height: 99,
                                    child: Center(
                                        child: Text(
                                            "لا يوجد حجز متاح لهذا اليوم")),
                                  )
                            : Container(
                                height: 99,
                                child: Center(
                                    child: Text("لا يوجد حجز متاح لهذا اليوم")),
                              ),
                        playgroundAllData.isNotEmpty &&
                                playgroundAllData.any((data) => data.bookTypes!
                                    .any((bt) => bt.day == selectedDayName))
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '    تأجير الكره   :', // النص الأساسي
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Cairo',
                                            color: Color(
                                                0xFF495A71), // اللون الأساسي
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   ${costboll}  ' + '  جنية  ',
                                          // النص الذي تريد جعله أبهت
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Cairo',
                                            color:
                                                Color(0xFFB0B0B0), // لون أبهت
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    activeColor: Color(0xFF106A35),
                                    // Check color when checked
                                    checkColor: Color(0xFF106A35),
                                    // Check color when checked
                                    focusColor: Color(0xFF106A35),
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => Colors.white),
                                    // Background color
                                    side: MaterialStateBorderSide.resolveWith(
                                        (states) => states.contains(
                                                MaterialState.selected)
                                            ? BorderSide(
                                                width: 2,
                                                color: Color(0xFF106A35))
                                            : BorderSide(
                                                width: 2,
                                                color: Color(0xFF106A35))),
                                    value: _isCheckedList[0],
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _isCheckedList[0] = newValue ?? false;
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () async {
                                  // Step 2: Disable button when loading
                                  await _sendData(context, _isCheckedList[0]);
                                  await _fetchData();
                                  print(
                                      "addddmin${playgroundAllData[0].adminId!}");
                                  await notifyAdmin(
                                      playgroundAllData[0].adminId!);
                                },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, right: 20, left: 20, bottom: 30),
                            child: Container(
                              height: 50,
                              width: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                shape: BoxShape.rectangle,
                                color: Color(
                                    0xFF064821), // Background color of the container
                              ),
                              child: Center(
                                child: Text(
                                  'حجز الموعد'.tr,
                                  textAlign: TextAlign.center,
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

                        //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@222
                        matchedPlaygrounds.isNotEmpty &&
                                matchedplaygroundAllData.isNotEmpty
                            ? IntrinsicHeight(
                                child: Container(
                                  child: Wrap(
                                    children: List.generate(
                                        matchedPlaygrounds.length, (index) {
                                      final user = matchedPlaygrounds[index];
                                      print(
                                          "objectmatching${matchedPlaygrounds.length}");
                                      return Dismissible(
                                        key: Key('${user.UserPhone}_${index}'),
                                        // Ensure the key is unique
                                        direction: DismissDirection.horizontal,
                                        onDismissed: (direction) async {
                                          await deleteCancelByPhoneAndPlaygroundId(
                                              user.userID!,
                                              user.AdminId!,
                                              user.groundName!,
                                              user.GroundId!,
                                              user.selectedTimes!.first,
                                              user.dateofBooking!
                                          );
                                          setState(() {
                                            matchedPlaygrounds.removeAt(
                                                index); // Use removeAt to remove by index
                                            String i = widget.IdData;
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      book_playground_page(i)),
                                              (Route<dynamic> route) => false,
                                            );
                                          });
                                        },
                                        confirmDismiss: (direction) async {
                                          // Show a confirmation dialog before dismissing
                                          return await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Deletion'),
                                                content: Text(
                                                    'Are you sure you want to delete this item?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    // Cancel the delete
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    // Confirm the delete
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        background: Container(
                                          height: 72,
                                          color: Colors.red.shade800,
                                          // Background color when swiped
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Image(
                                                  image: AssetImage(
                                                      "assets/images/trush-square.png"),
                                                  color: Colors.white,
                                                  width: 40.0,
                                                  height: 30.0,
                                                ),
                                              ),
                                              Expanded(
                                                  child:
                                                      Container()), // Fill space
                                            ],
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          height: 72,
                                          color: Colors.red.shade800,
                                          // Background color when swiped
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                  child:
                                                      Container()), // Fill space
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Image(
                                                  image: AssetImage(
                                                      "assets/images/trush-square.png"),
                                                  color: Colors.white,
                                                  width: 40.0,
                                                  height: 30.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 17.0,
                                              left: 17,
                                              bottom: 9,
                                              top: 9),
                                          child: Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: Color(0xFFF0F6FF),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'ج.م   ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF7C90AB),
                                                                    fontSize:
                                                                        21.55,
                                                                    fontFamily:
                                                                        'Cairo',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height: 0,
                                                                    letterSpacing:
                                                                        -0.43,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  " ${toArabicNumerals(matchedPlaygrounds[index].totalcost!, 0)}",
                                                                  // '${matchedplaygroundAllData[0].bookTypes![0].cost} ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF7C90AB),
                                                                    fontSize:
                                                                        21.55,
                                                                    fontFamily:
                                                                        'Cairo',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height: 0,
                                                                    letterSpacing:
                                                                        -0.43,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8,
                                                                      left: 8),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    formatDate(matchedPlaygrounds[
                                                                            index]
                                                                        .dateofBooking!),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xFF324054),
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Cairo',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      height: 0,
                                                                      letterSpacing:
                                                                          0.64,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    matchedPlaygrounds[index]
                                                                            .Day_of_booking ??
                                                                        " ",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xFF334154),
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Cairo',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      height: 0,
                                                                      letterSpacing:
                                                                          0.64,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8,
                                                                      left: 8),
                                                              child: Text(
                                                                "التكلفة الاجمالية",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFF324054),
                                                                  fontSize:
                                                                      10.77,
                                                                  fontFamily:
                                                                      'Cairo',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  height: 0,
                                                                  letterSpacing:
                                                                      0.32,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          14.0,
                                                                      bottom:
                                                                          10),
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF7C90AB),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Cairo',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    height: 0,
                                                                    letterSpacing:
                                                                        0.36,
                                                                  ),
                                                                  children: [
                                                                    for (var i =
                                                                            0;
                                                                        i < matchedPlaygrounds[index].selectedTimes!.length;
                                                                        i++)
                                                                      TextSpan(
                                                                        text: getTimeRange(
                                                                            matchedPlaygrounds[index].selectedTimes![0]), // Add formatted time range
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              )
                            : Container(),

                        SizedBox(
                          height: 16,
                        )
                      ],
                    ),
                  ),
                ),
                (isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container(),
              ],
            )
          : _buildNoInternetUI(),
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
            opacity = 0.5;
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
    );
  }


  Future<Widget> _generateTimeSlotWidget(
    String slot,
    bool isSelected,
    bool isAlreadySelected,
  ) async {
    // Fetch selected times for the current day from the fetchedSelectedTimesPerDay map
    String currentDay =
        selectedDayName; // Get the correct day for the current slot
    bool isSlotBooked =
        fetchedSelectedTimesPerDay[currentDay]?.contains(slot) ?? false;

    // Determine the color based on booking status
    bool isClickable = !isSlotBooked;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Opacity(
        opacity: isClickable ? 1.0 : 0.5,
        child: GestureDetector(
          onTap: () {
            if (isClickable) {
              setState(() {
                selectedTimes.clear();
                selectedTimes.add(slot); // Add the clicked slot
              });
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
              color: selectedTimes.contains(slot)
                  ? Color(0xFFC3FFDC) // If selected by the user
                  : isSlotBooked
                      ? Color(0xFFFFBEC5) // If already booked
                      : Color(0xFFEFF6FF), // Default color
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                slot.characters.length == 7 ? "$slot   " : slot,
                // Adjust text formatting
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: isSelected ? Colors.black87 : Color(0xFF495A71),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _fetchBookedTimes(String selectedDay) async {
    final existingBookingQuery = FirebaseFirestore.instance
        .collection('booking')
        .where('Day_of_booking', isEqualTo: selectedDay)
        .where('dateofBooking', isEqualTo: storeDate)
        .where('GroundId', isEqualTo: widget.IdData);

    final existingBookings = await existingBookingQuery.get();
    List<String> bookedTimes = [];
    if (existingBookings.docs.isNotEmpty) {
      for (var doc in existingBookings.docs) {
        // Assuming 'selectedTimes' is a field in your document that holds the booked time slots
        List<String> times = List<String>.from(doc['selectedTimes']);
        bookedTimes.addAll(times);
        print("ooootimes$times");
      }
    } else {
      print("lllllllllllllllllll");
    }

    return bookedTimes;
  }

  List<String> _getHoursBetween(String timeRange) {
    DateFormat formatter = DateFormat.jm();
    List<String> hours = [];

    try {
      List<String> times = timeRange.split(' - ');
      DateTime start = formatter.parse(times[0].trim());
      DateTime end = formatter.parse(times[1].trim());

      for (DateTime time = start;
          time.isBefore(end) || time == end;
          time = time.add(Duration(hours: 1))) {
        hours.add(formatter.format(time));
      }
    } catch (e) {
      print('Error parsing time range: $e');
    }

    return hours;
  }

  List<String> _getCombinedTimeSlotsForSelectedDay(String selectedDay) {
    List<String> combinedTimeSlots = [];

    for (var bookTypeEntry in playgroundAllData[0].bookTypes!) {
      if (bookTypeEntry.day == selectedDay) {
        String? time = bookTypeEntry.time;
        List<String> times = time!.split(' - ');

        if (times.length == 2) {
          // Generate hours for this range
          combinedTimeSlots.addAll(_getHoursBetween(time));
        }
      }
    }
    // Remove duplicates and sort the times
    combinedTimeSlots = combinedTimeSlots.toSet().toList();
    combinedTimeSlots.sort(
        (a, b) => DateFormat.jm().parse(a).compareTo(DateFormat.jm().parse(b)));

    return combinedTimeSlots;
  }

  Future<List<Widget>> _generateRows(
      Set<String> selectedTimes, String selectedDay) async {
    List<Widget> rows = [];
    List<Widget> currentRowChildren = [];

    print("selectedddddddddddday: $selectedDay");

    // Fetch booked times for the selected day
    List<String> bookedTimes = await _fetchBookedTimes(selectedDay);
    print("Booked Times for $selectedDay: $bookedTimes");

    // Fetch combined time slots for the selected day
    List<String> combinedTimeSlots =
        _getCombinedTimeSlotsForSelectedDay(selectedDay);
    print("Combined Time Slots for $selectedDay: $combinedTimeSlots");

    for (String slot in combinedTimeSlots) {
      bool isSelected = selectedTimes.contains(slot);
      bool isTimeSlotBooked = bookedTimes.contains(slot);

      currentRowChildren.add(
        GestureDetector(
          onTap: () {
            if (isTimeSlotBooked) {
              // Optionally show a message or feedback when trying to click on a booked slot
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("This time slot is already booked."),
              ));
            } else {
              // Handle selection of the time slot
              setState(() {
                // If you want multiple slots selected, use add() instead of clear()
                selectedTimes.add(slot);
                reservation();
              });
            }
          },
          child: FutureBuilder<Widget>(
            future: _generateTimeSlotWidget(slot, isSelected, isTimeSlotBooked),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return Container(); // Handle error case (show nothing if error)
              } else {
                return snapshot.data ??
                    Container(); // Return the widget or empty container
              }
            },
          ),
        ),
      );

      // Check if we've reached the max slots per row (e.g., 3 per row)
      if (currentRowChildren.length >= 3) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: currentRowChildren,
        ));
        currentRowChildren = []; // Reset for the next row
      }
    }

    // Add any remaining children as the last row if they exist
    if (currentRowChildren.isNotEmpty) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: currentRowChildren,
      ));
    }

    return rows;
  }

  Future<void> getAllBookingDocuments() async {
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      // Reference to the 'booking' collection
      CollectionReference bookingRef =
          FirebaseFirestore.instance.collection("booking");

      // Fetch all documents from the 'booking' collection
      QuerySnapshot bookingSnapshot = await bookingRef.get();

      // Check if any documents were found
      if (bookingSnapshot.docs.isNotEmpty) {
        setState(() {
          playgroundAllData.clear(); // Clear previous data to avoid duplicates
          for (var document in bookingSnapshot.docs) {
            String docId = document.id; // Get the document ID
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;

            AddPlayGroundModel playground =
                AddPlayGroundModel.fromMap(userData);
            playground.id = docId; // Store the document ID in the model

            playgroundAllData.add(playground); // Add playground to the list
            print("Stored document ID in model: ${playground.id}");
          }
        });
      } else {
        print("No booking documents found.");
      }
    } catch (error) {
      print("Error fetching booking documents: $error");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after data is fetched
      });
    }
  }

  void deleteItemAndRelatedDocs(BuildContext context, int index) async {
    bool documentDeleted = false;

    // Ensure the index is valid
    if (index < 0 || index >= playgroundbook.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid item to delete")),
      );
      return;
    }

    // final user = matchedPlaygrounds[index];
    final firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('booking').get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Access nested User and Ground Data

      var groundDataList = data['GroundId'] as List?;

      print('Ground Data List: $groundDataList');
      print('Document dateofBooking: ${data['dateofBooking']}');
      print('Document selectedTimes: ${data['selectedTimes']}');

      if (groundDataList != null) {
        print(
            "matchedPlaygrounds[index].AllUserData![0].UserPhone${matchedPlaygrounds[index].UserPhone}");
        print(
            "NeededGroundData[index].NeededGroundData![0].NeededGroundData${matchedPlaygrounds[index].GroundId}");
        print(
            "dateofBooking[index].dateofBooking![0].dateofBooking${matchedPlaygrounds[index].dateofBooking}");
        print(
            "selectedTimes[index].selectedTimes![0].selectedTimes${matchedPlaygrounds[index].selectedTimes}");
        if (matchedPlaygrounds[index].UserPhone != null &&
            matchedPlaygrounds[index].GroundId != null &&
            matchedPlaygrounds[index].dateofBooking != null &&
            matchedPlaygrounds[index].selectedTimes != null) {
          await firestore.collection('booking').doc(doc.id).delete();
        }
        print("groundDataListgroundDataList$groundDataList");

        return;
      }
    }
  }

  Widget _buildNoInternetUI() {
    // Your UI design when there's no internet connection
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
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


