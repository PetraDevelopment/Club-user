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
import 'package:popover/popover.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Home/Userclass.dart';
import '../../Menu/menu.dart';
import '../../Register/SignInPage.dart';
import '../../Splach/LoadingScreen.dart';
import '../../my_reservation/my_reservation.dart';
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

class book_playground_pageState extends State<book_playground_page> with TickerProviderStateMixin {

  bool _isLoading = true;
  int PhooneNumberMaxLength = 10;
  Set<String> selectedTimes = {};
  bool isLoading = false;
  late List<AddPlayGroundModel> playgroundAllData = [];
  List<String> dayss = [];
  String date='';
  String date2='';

  List<DateTime> datees = [];
  int _currentIndex = 0; // Add this state variable to track the current page

  late List<AddbookingModel> playgroundbook = [];
  List<AddbookingModel> matchedPlaygrounds = [];
  late List<AddPlayGroundModel> matchedplaygroundAllData = [];
  Future<String> convertmonthtonumber(date,int index) async{
    List<String>months=[ 'January',
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
      'December',];
    for(int k=0;k<months.length;k++){
      if(date.contains(months[k])){
        date=  date.replaceAll(months[k] ,'-${k+1}-');
        print("updated done with ${date}");
        playgroundbook[index].dateofBooking=date;

      }
    }
//loop in date to convert every en number to ar

    date = date.replaceAllMapped(RegExp(r'\d'), (match) { const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    playgroundbook[index].dateofBooking=englishToArabicNumbers[int.parse(match.group(0)!)];
    return englishToArabicNumbers[int.parse(match.group(0)!)];

    });

    print(" date in Arabic : $date");
    playgroundbook[index].dateofBooking = date;

    return date;

  }
  Future<String> convertmonthtonumberforlastwidget(date2,int index) async{
    List<String>months=[ 'January',
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
      'December',];
    for(int k=0;k<months.length;k++){
      if(date2.contains(months[k])){
        date2=  date2.replaceAll(months[k] ,'-${k+1}-');
        print("updated matchedPlaygrounds done with ${date2}");
        // matchedPlaygrounds[index].dateofBooking=date2;
// print("shokaaaa matchedPlaygrounds[index].dateofBooking${ matchedPlaygrounds[index].dateofBooking!}");
      }
    }
//loop in date to convert every en number to ar

    date2 = date2.replaceAllMapped(RegExp(r'\d'), (match) { const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

   englishToArabicNumbers[int.parse(match.group(0)!)];
    return englishToArabicNumbers[int.parse(match.group(0)!)];

    });

    print(" date in Arabic : $date2");
    // matchedPlaygrounds[index].dateofBooking = date2;

    return date2;

  }
  String toArabicNumerals(num number, int i) {
    const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    // Convert the number to a string for processing
    String numberString = number.toString();

    // Replace each digit in the number string with its Arabic equivalent
    String convertedNumber = numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkknum$convertedNumber");
    // If you want to assign the converted number back to the cost
    // playgroundAllData[i].bookTypes![0].cost = convertedNumber; // Assuming cost is a String

    print("number equal $convertedNumber");
    return convertedNumber; // Return the converted number
  }
  late DateTime Day1;
  late DateTime Day2;
  var Phoone = '';
  String PhooneErrorText = '';
  String SelectedTimeErrorText = '';

  List<User> users = [];
  final NavigationController navigationController = Get.put(NavigationController());
  List<bool> _isCheckedList = [false, false, false, false, false];
  List<String> timeSlots = [];
  String startTimeStr = '';  // Define these as state variables

  String endTimeStr = '';
  List<Map<String, DateTime>> selectedDates =[];
  String selectedDayName = '';
  String? storeDate;
// Define tappedIndex at the beginning of your class
  int tappedIndex = 0;
  late AnimationController _animationController;

  String normalizeText(String text) {
    return text.trim(); // Trims any leading or trailing spaces
  }

  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime); // Parse the start time
    DateTime end = start.add(Duration(hours: 1)); // Add 1 hour for the end time

    // Format the time in Arabic but numbers in English
    String formattedStartTime = DateFormat('h:mm a', 'ar').format(start).replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(int.parse(match.group(0)!));  // Ensure numbers are in English
    });

    String formattedEndTime = DateFormat('h:mm a', 'ar').format(end).replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en').format(int.parse(match.group(0)!));
    });

    return '$formattedStartTime     الي     $formattedEndTime';
  }


  Future<void> getAllPlaygrounds() async {
    try {
      // Reference to the Firestore collection
      CollectionReference playerchat = FirebaseFirestore.instance.collection("booking");

      // Fetch all documents in the 'booking' collection
      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<AddbookingModel> playgrounds = [];

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

          // Check if 'NeededGroundData' and 'GroundData' exist
          var groundDataList = userData['NeededGroundData']?['GroundData'] as List?;
          var userList = userData['AlluserData']?['UserData'] as List?;

          if (groundDataList != null&&userList!=null) {
            // Filter by 'GroundId' within 'GroundData' array
            for (var groundData in groundDataList) {
              if (groundData['GroundId'] == widget.IdData) {

                // If groundID matches, add the document to the list
                playgrounds.add(AddbookingModel.fromMap(userData));
                break; // Stop checking this document if a match is found
              }
            }
          }
        }

        // Update the list and UI inside setState
        setState(() {
          playgroundbook = playgrounds; // Replace list with matched documents
          print("kkkplaygroundbook${playgroundbook.length}");
        });



        // Fetch and print phone number from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? phoneValue = prefs.getString('phonev');
        print("newphoneValue: ${phoneValue.toString()}");

        // Normalize phone number
        String? normalizedPhoneNumber = user?.phoneNumber!.replaceFirst('+20', '0');

        for (int i = 0; i < playgroundbook.length; i++) {
          print("playgroundbook.1${playgroundbook.length}");
          // Check if the current user's phone number matches any user in AllUserData
          if (playgroundbook[i].AllUserData![0].UserPhone == normalizedPhoneNumber) {
            setState(() {
              matchedPlaygrounds.add(playgroundbook[i]);

              print("matchedPlaygrounds.1${matchedPlaygrounds.length}");

              getmaatchedPlaygroundbyname(matchedPlaygrounds[i].NeededGroundData![0].GroundId!);
              print("shimaaaa${matchedPlaygrounds.length}");
              print("shimaaaa dataaaaaa${matchedPlaygrounds[i]}");
              convertmonthtonumberforlastwidget(matchedPlaygrounds[0].dateofBooking!, i);
            });

          }
        }

        if (timeSlots.isNotEmpty) {
          startendtime(timeSlots.first, timeSlots.last);
          print("time for start: ${timeSlots.first} + ${timeSlots.last}");
        } else {
          print("timeSlots is empty.");
        }
      } else {
        print("No playgrounds found.");
      }
    } catch (e) {
      print("Error fetching playgrounds: $e");
    }
  }
  num costboll = 0;

  String?USerID;
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

  int cnt=0;
  List<num> selectedCosts = [];
  List<num> selectedCostsperhour = [];
  Future<void> notifyAdmin(String adminId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('PlayersChat').doc(adminId).get();

      if (docSnapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

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
            String?  bookType = playgroundAllData[0].bookTypes![0].time;

            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");

            // Splitting time into startTime and endTime based on '-'
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];

              print("Start Time: $startTime");
              print("End Time: $endTime");
              String adminId =playgroundAllData[0].adminId! ; // Fetch AdminId directly from userData
              groundPhoneee=playgroundAllData[0].phoneCommunication!;
              groundNamee=playgroundAllData[0].playgroundName!;

              // You can use these times to update the UI or for other logic
              timeSlots.add(startTime); // Add start time to the list
              timeSlots.add(endTime);   // Add end time to the list
              num ttt = 0;
              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              for (var bookType in playgroundAllData[0].bookTypes!) {
                print("hhhselectedDayName$selectedDayName");
                if (bookType.day == selectedDayName) {
                  setState(() {
                    costboll=0;
                    costboll += bookType.cost!;
                    print("coopppppppp$costboll");
                  });
                  print("tessst${bookType.cost!+bookType.costPerHour!}");
                }
              }
              setState(() {
                // Update any UI components with the start and end times
                startTimeStr = startTime; // Assuming you have a state variable to store this
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

            String?  bookType = matchedplaygroundAllData[0].bookTypes![0].time;
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
              String adminId =matchedplaygroundAllData[0].adminId! ; // Fetch AdminId directly from userData

              // You can use these times to update the UI or for other logic
              timeSlots.add(startTime); // Add start time to the list
              timeSlots.add(endTime);   // Add end time to the list

              // You could directly update your UI here or save this data for later
              // For example, show the start and end time in the UI
              setState(() {
                // Update any UI components with the start and end times
                startTimeStr = startTime; // Assuming you have a state variable to store this
                endTimeStr = endTime;     // Assuming you have a state variable to store this
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
  int selectedIndex=3;
  double opacity = 1.0;

  Map<String, Set<String>> alreadySelectedTimesPerDay = {

  };
  Future<void> _fetchData() async {

    final playgrounddata = await FirebaseFirestore.instance.collection('booking')
        .get();

    List<AddbookingModel> bookings = playgrounddata.docs.map((doc) {
      return AddbookingModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Initialize the map to store selected times per day
    Map<String, Set<String>> fetchedSelectedTimesPerDay = {};
    // Loop through each booking and add its selected times to the correct day
    for (var booking in bookings) {
      String day = booking.Day_of_booking ?? ''; // Replace with correct day field
      Set<String> selectedTimes = booking.selectedTimes?.toSet() ?? {};
      // If the day already exists in the map, add the times to the set
      if (fetchedSelectedTimesPerDay.containsKey(day)) {
        fetchedSelectedTimesPerDay[day]!.addAll(selectedTimes);
      } else {
        // Otherwise, create a new entry for that day
        fetchedSelectedTimesPerDay[day] = selectedTimes;
      }
    }

    // Update the state with the fetched data
    setState(() {
      // alreadySelectedTimesPerDay = fetchedSelectedTimesPerDay;
      // print("alreadySelectedTimesPerDay: $alreadySelectedTimesPerDay");
      // print("alllllldata ${playgroundbook.length}");
    });
    setState(() {
      // This triggers a rebuild of the current page with the updated values
    });

  }

  String? groundNamee ;
  String? groundPhoneee;
  Future<void> _sendData(BuildContext context,bool x) async {
    setState(() {
      _isLoading = true; // Set loading to true when starting the operation
    });
    final name =user1[0].name!;
    final phooneNumber =user1[0].phoneNumber!;
     num cooooooooooost=playgroundAllData[0].bookTypes![0].cost!;
    final selectedDay = selectedDayName; // The day the user selects for booking

    // Step 1: Initialize total cost
    num totalCost = 0;

    // Step 2: Calculate the total cost based on the selected day and time
    // Loop through each selected time and match with the costs in playgroundAllData
    for (var selectedTime in selectedTimes) {
      print("shokddddddddda${selectedTime}");
      print("shokddddddddda${selectedDay}");
      sellll=selectedTime;
      for (var bookType in playgroundAllData[0].bookTypes!) {
        if (bookType.day == selectedDay ) {
          totalCost=0;
if(x==true){
  totalCost += bookType.costPerHour!+costboll;
  print("tesssttruee$totalCost");
}else{
  totalCost += bookType.costPerHour!;
  print("tessst$totalCost");
}


        }
      }
    }
    print("Total cost test: $totalCost");


    print("Checking phone number: $phooneNumber");

    // Check for empty fields
    if (name.isNotEmpty && phooneNumber.isNotEmpty && selectedTimes.isNotEmpty) {
      print("Selected date: $storeDate");
      // Query the 'booking' collection for documents that match date, day, and any overlapping times
      final bookingQuery = await FirebaseFirestore.instance
          .collection('booking')
          .where('dateofBooking', isEqualTo: storeDate)          // Check date
          .where('Day_of_booking', isEqualTo: selectedDayName)   // Check day
          .where('selectedTimes', arrayContainsAny: selectedTimes)
      .where('NeededGroundData.GroundData.GroundId', isEqualTo: groundIiid) // Check GroundId wit// Check any overlapping time
          .get();

      if(bookingQuery.docs.isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الحجز موجود بالفعل', // "This booking already exists"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }

     else{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String phoooone = prefs.getString('phone') ?? '';

        // // Fetch the document ID of the player using the phone number
        // CollectionReference playerchat = FirebaseFirestore.instance.collection('PlayersChat');
        // QuerySnapshot playerQuerySnapshot = await playerchat.where('phone', isEqualTo: phoooone).get();
        //
        // String docId = '';
        // if (playerQuerySnapshot.docs.isNotEmpty) {
        //   var playerDoc = playerQuerySnapshot.docs.first;
        //   docId = playerDoc.id; // Get the docId of the matching phone number
        //   print("Document ID for the phone number: $docId");
        // }
        // else {
        //   print("No matching document found for the phone number.");
        //   return; // Handle case where phone number doesn't exist
        // }

        // Create a new UserData entry
        UserData newUserData = UserData(
          UserName: name,
          UserPhone: phooneNumber,
          UserImg: user1[0].img!, // Ensure userImage is set from the previous fetch
        );
        PlayGroundData GroundData = PlayGroundData(
          GroundName: groundNamee,
          GroundId: groundIiid,
          GroundPhone: groundPhoneee, // Ensure userImage is set from the previous fetch
        );

        // Prepare the booking model
        final bookingModel = AddbookingModel(
          Name: name,
          groundImage: playgroundAllData[0].img![0],
           totalcost:totalCost.toInt() ,
          dateofBooking: storeDate,
          Day_of_booking: selectedDayName,
          rentTheBall: _isCheckedList[0],
          selectedTimes: selectedTimes.toList(),
          AdminId: playgroundAllData[0].adminId,
          AllUserData: [newUserData], // Add the user data directly to the model,
          NeededGroundData: [GroundData],
          acceptorcancle: false,
        );

        // Add booking to Firestore
        await FirebaseFirestore.instance.collection('booking').add(bookingModel.toMap());

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
        getAllPlaygrounds();
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

  bool isAlreadySelected = false;

  String formatDate(String dateString) {
    DateTime dateTime = DateFormat('dd MMMM yyyy').parse(dateString);
    return DateFormat('dd-MM-yyyy','ar').format(dateTime);
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


  List<DateTime> getDaysInRange(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (var date = startDate;
    date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
    date = date.add(Duration(days: 1))) {
      days.add(date);
    }
    return days;
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

    while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
      timeSlots.add(timeFormat.format(currentTime));
      currentTime = currentTime.add(Duration(hours: 1));
    }

    for (String slot in timeSlots) {
      print("sl00ot$slot");
    }

    return timeSlots;
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
  void initState() {
    checkInternetConnection();
    _loadUserData();
    getAllPlaygrounds();
    getAllBookingDocuments();
    getPlaygroundbyname(widget.IdData);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }
  //
  @override
  void dispose() {
    _animationController.dispose();
    // PhooneControlller.dispose();
    // NameController.dispose();
    // playgroundAllData;

    super.dispose();
  }

  // Function to check if phone number exists in Firestore and update the name field
  Future<void> checkPhoneNumberInFirestore(String phoneNumber) async {
    // Reference to the Firestore collection where the phone numbers are stored
    var query = await FirebaseFirestore.instance
        .collection('booking') // Adjust collection path
        .where('phoneCommunication', isEqualTo: phoneNumber)
        .limit(1) // Limit to one result for efficiency
        .get();

    if (query.docs.isNotEmpty) {
      // Phone number exists, get the name
      var userData = query.docs.first.data();
      setState(() {
       user1[0].name = userData['Name'] ?? ''; // Update the name field
      });
    } else {
      // Phone number doesn't exist, clear the name field
      setState(() {
        user1[0].name="";
      });
    }
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
      String dayName = DateFormat('EEEE','ar').format(day); // Full day name, e.g., Monday
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
      body:isConnected? Stack(
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
                                viewportFraction: 0.2, // Adjust this value as needed
                                initialPage: _currentIndex, // Start with the center item
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                enlargeCenterPage: true, // Ensure the center item is enlarged
                                onPageChanged: (index, reason) {
                                  setState(() {

                                    _currentIndex = index; // Update the current index on page change
                                    selectedDayName = daysOfWeek[index]['dayName']!; // Update the selected day name
                                    storeDate = daysOfWeek[index]['dayDate'];

                                  });
                                },
                                scrollDirection: Axis.horizontal,
                              ),
                              items: daysOfWeek.map((dayInfo) {
                                int itemIndex = daysOfWeek.indexOf(dayInfo); // Get the index of the item

                                return GestureDetector(
                                  onTap: () {
                                    print("Tapped on ${dayInfo['dayName']} - ${dayInfo['dayDate']}");
                                    storeDate = dayInfo['dayDate'];
                                    setState(() {
                                      _currentIndex = itemIndex; // Update the current index when an item is tapped
                                      selectedDayName = dayInfo['dayName']!; // Save the selected day name
                                      getPlaygroundbyname(widget.IdData);
                                      selectedTimes = {};
                                    });
                                  },
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300), // Add smooth transition for color changes
                                      width: 87,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(17),
                                          bottomLeft: Radius.circular(17),
                                          topRight: Radius.circular(22),
                                          topLeft: Radius.circular(22),
                                        ),
                                        // Highlight with green if it is the center item (current index)
                                        color: _currentIndex == itemIndex ? Colors.green.shade500 : Colors.transparent,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            IntrinsicHeight(
                                              child: Container(
                                                height: 92,
                                                width: 87,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  color: Color(0xFFF0F6FF), // Inner container color
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 2.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center, // Center the content
                                                    children: [
                                                      Text(
                                                        dayInfo['dayName']!, // Display day name
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 10.0,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF334154),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        DateFormat('dd').format(
                                                            DateFormat('dd MMMM yyyy').parse(dayInfo['dayDate']!) // Parse the date
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily: 'Cairo',
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF495A71),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 18.0, left: 12),
                                              child: Container(
                                                height: 2.5, // Height of the green color section
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.circular(22),
                                                    bottomLeft: Radius.circular(22),
                                                  ),
                                                  // Green color for the selected (centered) day
                                                  color: _currentIndex == itemIndex ? Colors.green.shade500 : Colors.transparent,
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
                      child: Center(child: Text("لم يتم اضافة تاريخ بعد "))),

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
                  playgroundAllData.isNotEmpty && playgroundAllData.any((data) => data.bookTypes!.any((bt) => bt.day == selectedDayName))
                      ? playgroundAllData.isNotEmpty
    && playgroundAllData.any((data) => data.bookTypes!.any((bt) => bt.day == selectedDayName))
    ?FutureBuilder<List<Widget>>(
    future: _generateRows(selectedTimes, selectedDayName),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: _isLoading
    ? CircularProgressIndicator(color: Colors.green,) // Show a loading indicator
        : Container(), // Show an empty container or other content
    );
    }
    if (snapshot.hasError) {
    return Center(child: Text("Error: ${snapshot.error}"));
    }
    if (snapshot.hasData) {
    return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: snapshot.data!.map((slotWidget) {
    return GestureDetector(
    onTap: () {
    _handleSlotTap(slotWidget.toString()); // Pass the slot value
    },
    child: slotWidget, // Use the slot widget
    );
    }).toList(),
    );
    }
    return Center(child: Text("No data available"));
    },
    )

                      : Container(
                    height: 99,
                    child: Center(child: Text("لا يوجد حجز متاح لهذا اليوم")),
                  ):Container(
                    height: 99,
                    child: Center(child: Text("لا يوجد حجز متاح لهذا اليوم")),
                  ),
                  playgroundAllData.isNotEmpty && playgroundAllData.any((data) => data.bookTypes!.any((bt) => bt.day == selectedDayName))
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [

                            TextSpan(
                              text: '    تأجير الكره   :', // النص الأساسي
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71), // اللون الأساسي
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            TextSpan(
                              text: '   ${costboll}  '  +'  جنية  ' ,
                              // النص الذي تريد جعله أبهت
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFFB0B0B0), // لون أبهت
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
                        side: MaterialStateBorderSide.resolveWith((states) =>
                        states.contains(MaterialState.selected)
                            ? BorderSide(width: 2, color: Color(0xFF106A35))
                            : BorderSide(
                            width: 2, color: Color(0xFF106A35))),
                        value: _isCheckedList[0],
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isCheckedList[0] = newValue ?? false;
                          });
                        },
                      )
                    ],
                  )
                      :Container(),
                  GestureDetector(

                    onTap: _isLoading ? null : () async {

                    // Step 2: Disable button when loading
                      await _sendData(context,_isCheckedList[0]);
                      await _fetchData();
                      print("addddmin${playgroundAllData[0].adminId!}");
                      await notifyAdmin(playgroundAllData[0].adminId! );

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
                  matchedPlaygrounds.isNotEmpty && matchedplaygroundAllData.isNotEmpty
                      ? IntrinsicHeight(
                    child: Container(
                      child: Wrap(
                        children: List.generate(matchedPlaygrounds.length, (index) {
                          final user = matchedPlaygrounds[index];
                          print("objectmatching${matchedPlaygrounds.length}");
                          return Dismissible(
                            key: Key('${user.AllUserData?[0].UserPhone}_${index}'), // Ensure the key is unique
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) async {
                              await deleteCancelByPhoneAndPlaygroundId(
                                user.AllUserData![0].UserPhone!,
                                user.NeededGroundData![0].GroundId!,
                                user.selectedTimes!.first,
                                user.dateofBooking!,
                              );
                              setState(() {
                                matchedPlaygrounds.removeAt(index); // Use removeAt to remove by index
                               String i=widget.IdData;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => book_playground_page(i)),
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
                                    content: Text('Are you sure you want to delete this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false), // Cancel the delete
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true), // Confirm the delete
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            background: Container(
                              height: 72,
                              color: Colors.red.shade800, // Background color when swiped
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image(
                                      image: AssetImage("assets/images/trush-square.png"),
                                      color: Colors.white,
                                      width: 40.0,
                                      height: 30.0,
                                    ),
                                  ),
                                  Expanded(child: Container()), // Fill space
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              height: 72,
                              color: Colors.red.shade800, // Background color when swiped
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(child: Container()), // Fill space
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image(
                                      image: AssetImage("assets/images/trush-square.png"),
                                      color: Colors.white,
                                      width: 40.0,
                                      height: 30.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 17.0, left: 17, bottom: 9,top: 9),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Color(0xFFF0F6FF),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'ج.م   ',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(0xFF7C90AB),
                                                        fontSize: 21.55,
                                                        fontFamily: 'Cairo',
                                                        fontWeight: FontWeight.w700,
                                                        height: 0,
                                                        letterSpacing: -0.43,
                                                      ),
                                                    ),
                                                    Text(
                                                     " ${toArabicNumerals(matchedPlaygrounds[index].totalcost!,0)}",
                                                      // '${matchedplaygroundAllData[0].bookTypes![0].cost} ',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(0xFF7C90AB),
                                                        fontSize: 21.55,
                                                        fontFamily: 'Cairo',
                                                        fontWeight: FontWeight.w700,
                                                        height: 0,
                                                        letterSpacing: -0.43,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8, left: 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(formatDate(matchedPlaygrounds[index].dateofBooking!),
                                                         textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Color(0xFF324054),
                                                          fontSize: 16,
                                                          fontFamily: 'Cairo',
                                                          fontWeight: FontWeight.w700,
                                                          height: 0,
                                                          letterSpacing: 0.64,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        matchedPlaygrounds[index].Day_of_booking ?? " ",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Color(0xFF334154),
                                                          fontSize: 16,
                                                          fontFamily: 'Cairo',
                                                          fontWeight: FontWeight.w700,
                                                          height: 0,
                                                          letterSpacing: 0.64,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8, left: 8),
                                                  child: Text(
                                                    "التكلفة الاجمالية",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF324054),
                                                      fontSize: 10.77,
                                                      fontFamily: 'Cairo',
                                                      fontWeight: FontWeight.w700,
                                                      height: 0,
                                                      letterSpacing: 0.32,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 14.0,bottom: 10),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        color: Color(0xFF7C90AB),
                                                        fontSize: 12,
                                                        fontFamily: 'Cairo',
                                                        fontWeight: FontWeight.w400,
                                                        height: 0,
                                                        letterSpacing: 0.36,
                                                      ),
                                                      children: [

                                                        for (var i = 0; i < matchedPlaygrounds[index].selectedTimes!.length; i++)
                                                          TextSpan(
                                                            text: getTimeRange(matchedPlaygrounds[index].selectedTimes![0]) , // Add formatted time range
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
                      :Container(),

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
      ):                        _buildNoInternetUI(),
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
    );
  }



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

          String x=  widget.IdData;
            // Navigate to HomePage after successful deletion

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => book_playground_page(x)),
            );
            // await getAllPlaygrounds();
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
  Future<Widget> _generateTimeSlotWidget(
      String slot,
      bool isSelected,
      bool isAlreadySelected,
      )
  async {
    final firestore = FirebaseFirestore.instance;

    // Query documents based on top-level fields `dateofBooking` and `selectedTimes`
    final existingBookingQuery = firestore
        .collection('booking')
        .where('dateofBooking', isEqualTo: storeDate)
        .where('selectedTimes', arrayContainsAny: [slot]);

    final existingBookings = await existingBookingQuery.get();
    bool isTimeSlotBooked = false;

    // Loop through each document to check the nested `groundID` inside `GroundData`
    for (var doc in existingBookings.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Access `GroundData` array within `NeededGroundData`
      var groundDataList = data['NeededGroundData']?['GroundData'] as List?;

      if (groundDataList != null) {
        for (var groundData in groundDataList) {
          // Check if `groundID` matches
          if (groundData['GroundId'] == widget.IdData) {
            isTimeSlotBooked = true;
            break;
          }
        }
      }

      // Break the outer loop if a match is found
      if (isTimeSlotBooked) break;
    }

    // Determine the color based on booking status
    bool _isAlreadySelected = isTimeSlotBooked;
    // Disable interaction if the time slot is booked
    bool isClickable = !_isAlreadySelected;
    if (mounted) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Opacity(
          opacity:isClickable? 1.0 : 0.5,
          child: GestureDetector(
            onTap: () {
              if (isClickable) {
                setState(() {

                  selectedTimes.clear();
                  selectedTimes.add(slot);

                });
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: selectedTimes.contains(slot)
                    ? Color(0xFFC3FFDC)
                    : _isAlreadySelected
                    ? Color(0xFFFFBEC5)
                    : Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  slot.characters.length == 7 ? "$slot   " : slot,
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
    } else {
      return SizedBox.shrink();
    }
  }
  Future<List<String>> _fetchBookedTimes(String selectedDay) async {
    final existingBookingQuery = FirebaseFirestore.instance
        .collection('booking')
        .where('Day_of_booking', isEqualTo: selectedDay)
        .where('dateofBooking', isEqualTo: storeDate)
        .where('groundID', isEqualTo: widget.IdData);

    final existingBookings = await existingBookingQuery.get();
    List<String> bookedTimes = [];

    for (var doc in existingBookings.docs) {
      // Assuming 'selectedTimes' is a field in your document that holds the booked time slots
      List<String> times = List<String>.from(doc['selectedTimes']);
      bookedTimes.addAll(times);
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

      for (DateTime time = start; time.isBefore(end) || time == end; time = time.add(Duration(hours: 1))) {
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
    combinedTimeSlots.sort((a, b) => DateFormat.jm().parse(a).compareTo(DateFormat.jm().parse(b)));

    return combinedTimeSlots;
  }

  Future<List<Widget>> _generateRows(Set<String> selectedTimes, String selectedDay) async {
    List<Widget> rows = [];
    List<Widget> currentRowChildren = [];
    // _getCostAndCostPerHourForTimeSlot(selectedDay,selectedTimes.toString());
    // Fetch booked times first
    List<String> bookedTimes = await _fetchBookedTimes(selectedDay);
    print("Booked Times for $selectedDay: $bookedTimes");

    // Fetch combined time slots for the selected day
    List<String> combinedTimeSlots = _getCombinedTimeSlotsForSelectedDay(selectedDay);
    print("Combined Time Slots for $selectedDay: $combinedTimeSlots");

    for (String slot in combinedTimeSlots) {
      bool isSelected = selectedTimes.contains(slot);
      bool isTimeSlotBooked = bookedTimes.contains(slot);

      currentRowChildren.add(
        GestureDetector(
          onTap: () {
            if (isTimeSlotBooked) {
              // Handle booked time slot
              // showPopover(...);
            } else {
              // Handle selection
              setState(() {
                selectedTimes.clear();
                selectedTimes.add(slot);
                reservation();
              });
            }
          },
          child: FutureBuilder<Widget>(
            future: _generateTimeSlotWidget(slot, isSelected, isTimeSlotBooked),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Container() // Loading indicator
                  : snapshot.data ?? Container(); // Handle error or no data case
            },
          ),
        ),
      );

      // Check if we reached the maximum slots per row
      if (currentRowChildren.length >= 3) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: currentRowChildren,
        ));
        currentRowChildren = [];
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

// Function to filter time slots based on the selected day
  List<String> _getTimeSlotsForSelectedDay(String selectedDay) {
    List<String> filteredTimeSlots = [];

    // Iterate over all time slots and filter by selected day
    for (var bookTypeEntry in playgroundAllData[0].bookTypes!) {
      if (bookTypeEntry.day == selectedDay) {
        String? time = bookTypeEntry.time;
        if (time != null) {
          List<String> times = time.split(' - ');
          if (times.length == 2) {
            filteredTimeSlots.add(times[0]); // Add start time
            filteredTimeSlots.add(times[1]); // Add end time
          }
        }
      }
    }

    return filteredTimeSlots;
  }


  Future<void> getAllBookingDocuments() async {
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      // Reference to the 'booking' collection
      CollectionReference bookingRef = FirebaseFirestore.instance.collection("booking");

      // Fetch all documents from the 'booking' collection
      QuerySnapshot bookingSnapshot = await bookingRef.get();

      // Check if any documents were found
      if (bookingSnapshot.docs.isNotEmpty) {
        setState(() {
          playgroundAllData.clear(); // Clear previous data to avoid duplicates
          for (var document in bookingSnapshot.docs) {
            String docId = document.id; // Get the document ID
            Map<String, dynamic> userData = document.data() as Map<String, dynamic>;

            AddPlayGroundModel playground = AddPlayGroundModel.fromMap(userData);
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
      var userDataList = data['AlluserData']?['UserData'] as List?;
      var groundDataList = data['NeededGroundData']?['GroundData'] as List?;

      print('User Data List for deleting: $userDataList');
      print('Ground Data List: $groundDataList');
      print('Document dateofBooking: ${data['dateofBooking']}');
      print('Document selectedTimes: ${data['selectedTimes']}');

      if (userDataList != null && groundDataList != null) {
        print("matchedPlaygrounds[index].AllUserData![0].UserPhone${matchedPlaygrounds[index].AllUserData![0].UserPhone}");
        print("NeededGroundData[index].NeededGroundData![0].NeededGroundData${matchedPlaygrounds[index].NeededGroundData![0].GroundId}");
        print("dateofBooking[index].dateofBooking![0].dateofBooking${matchedPlaygrounds[index].dateofBooking}");
        print("selectedTimes[index].selectedTimes![0].selectedTimes${matchedPlaygrounds[index].selectedTimes}");
        if(matchedPlaygrounds[index].AllUserData![0].UserPhone!=null&&matchedPlaygrounds[index].NeededGroundData![0].GroundId!=null&&matchedPlaygrounds[index].dateofBooking!=null&&matchedPlaygrounds[index].selectedTimes!=null)
       {
         await firestore.collection('booking').doc(doc.id).delete();
       }
        print("userDataListuserDataList${userDataList}");
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
            height: MediaQuery.of(context).size.height/5,

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


  Future<void> restoreDocument(Map<String, dynamic> docData) async {
    // Assuming you have a way to determine the collection and generate a new document ID
    // Replace 'booking' with your actual collection name
    await FirebaseFirestore.instance.collection('booking').add(docData);
  }



class ListItems extends StatelessWidget {
  // const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      // width: MediaQuery.of(context).size.width*0.9 ,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'محمد أحمد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '012356577841',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    Text(
                      'قام بالحجز: علاء أبراهيم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),

                  ],
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/profile.png"), // Replace with your actual image
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '13-08-2024',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                '4:00 AM - 5:00 AM',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تأجير الكرة: 20 جنية',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 3,),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                '620',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 23,
                  color: Color(0xFF7D90AC),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'المبلغ المدفوع: 500',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Text(
                'التكلفة أجمالية',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Color(0xFF334154),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                'المبلغ المتبقي: 120',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: Color(0xFFB3261E),
              ),

              child: Center(
                child: Text(
                  'ألغاء الحجز',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}