import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true; // flag to control shimmer effect
  String groundIid = '';

  Future<void> _loadData() async {
    // Simulate data loading
    await Future.delayed(Duration(seconds: 2));

    // Check if the state is still mounted before calling setState
    if (mounted) {
      setState(() {
        _isLoading = false; // set flag to false when data is loaded
      });
    }
  }
  String toArabicNumerals(num number, int i) {
    const englishToArabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    // Convert the number to a string for processing
    String numberString = number.toString();

    // Replace each digit in the number string with its Arabic equivalent
    String convertedNumber = numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkk$convertedNumber");
    // If you want to assign the converted number back to the cost
    // playgroundAllData[i].bookTypes![0].cost = convertedNumber; // Assuming cost is a String

    print("number equal $convertedNumber");
    return convertedNumber; // Return the converted number
  }
  late List<User1> user1 = [];


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

    // print("groundId${widget.groundId}");
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
      // Query the collection where user_phone matches the provided phone number
      final querySnapshot = await firestore
          .collection('cancel_book')
          .where('user_phone', isEqualTo: userPhone)
          .get();

      // Check if any documents are returned
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate over each document returned by the query
        querySnapshot.docs.forEach((doc) {
          // Get the document data
          Map<String, dynamic> data = doc.data();
          int numberOfCancel = data['numberofcancel'] ?? 0;

          // Do something with the retrieved data
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

  // Future<String> convertmonthtonumber(date,int index) async{
  //   List<String>months=[ 'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December',];
  //   for(int k=0;k<months.length;k++){
  //     if(date.contains(months[k])){
  //       date=  date.replaceAll(months[k] ,'-${k+1}-');
  //       print("updated done with ${date}");
  //       playgroundbook[index].dateofBooking=date;
  //     }
  //   }
  //   return date;
  //
  // }
  Future<void> getAccepted_bookDataByPhone(String userPhone) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print("uuuuusershimaaa: ${userPhone}");
      // Query the collection where user_phone matches the provided phone number
      final querySnapshot = await firestore
          .collection('accepted')
          .where('phone_number', isEqualTo: userPhone)
          .get();

      // Check if any documents are returned
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate over each document returned by the query
        querySnapshot.docs.forEach((doc) {
          // Get the document data
          Map<String, dynamic> data = doc.data();
          int numberOfaccepted = data['accepted_number'] ?? 0;

          // Do something with the retrieved data
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
        wait = playgroundbook.length - numberaccepted;
        print("wait${wait}");
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  // Future<void> fetchBookingData() async {
  //   try {
  //     CollectionReference bookingCollection = FirebaseFirestore.instance.collection("booking");
  //
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? phoneValue = prefs.getString('phonev');
  //     print("newphoneValue${phoneValue.toString()}");
  //
  //     if (phoneValue != null && phoneValue.isNotEmpty) {
  //       String normalizedPhoneNumber = phoneValue.replaceFirst('+20', '0');
  //
  //       // QuerySnapshot querySnapshot = await bookingCollection.where('phoneCommunication', isEqualTo: normalizedPhoneNumber).get();
  //       QuerySnapshot querySnapshot = await bookingCollection.get();
  //       for (var doc in querySnapshot.docs) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //         // Check if the document has the expected structure
  //         var userDataList = data['AlluserData']?['UserData'] as List?;
  //
  //         if (userDataList != null) {
  //           for (var userData in userDataList) {
  //             if (userData['UserPhone'] == normalizedPhoneNumber) {
  //               List<AddbookingModel> bookings = querySnapshot.docs.map((doc) {
  //                 Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit casting
  //                 return AddbookingModel.fromMap(data);
  //               }).toList();
  //               // Update the playgroundbook list with fetched bookings
  //               playgroundbook = bookings;
  //               break;  // Stop checking once a match is found
  //             }
  //           }
  //         }
  //       }
  //       if (querySnapshot.docs.isNotEmpty) {
  //         List<AddbookingModel> bookings = querySnapshot.docs.map((doc) {
  //           Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit casting
  //           return AddbookingModel.fromMap(data);
  //         }).toList();
  //         // Update the playgroundbook list with fetched bookings
  //         playgroundbook = bookings;
  //         // Print and access specific fields for each booking
  //         for (int g=0;g<playgroundbook.length;g++){
  //           formatDate(playgroundbook[g].dateofBooking!);
  //
  //           print('AdminId: ${playgroundbook[g].AdminId}');
  //           print('Day_of_booking: ${playgroundbook[g].Day_of_booking}');
  //           print('Name: ${playgroundbook[g].Name}');
  //           print('Rent_the_ball: ${playgroundbook[g].rentTheBall}');
  //           print('phoneshoka: ${playgroundbook[g]
  //               .AllUserData![g].UserPhone!}');
  //
  //         }
  //
  //
  //       }
  //       else {
  //         print('No documents found in the "booking" collection.');
  //       }
  //     }
  //     else if (user?.phoneNumber != null) {
  //       String? normalizedPhoneNumber = user?.phoneNumber!.replaceFirst('+20', '0');
  //       // QuerySnapshot querySnapshot = await bookingCollection.where('phoneCommunication', isEqualTo: normalizedPhoneNumber).get();
  //       QuerySnapshot querySnapshot = await bookingCollection.get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         for (var doc in querySnapshot.docs) {
  //           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //           // Check if the document has the expected structure
  //           var userDataList = data['AlluserData']?['UserData'] as List?;
  //
  //           if (userDataList != null) {
  //             for (var userData in userDataList) {
  //               if (userData['UserPhone'] == normalizedPhoneNumber) {
  //                 List<AddbookingModel> bookings = querySnapshot.docs.map((doc) {
  //                   Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit casting
  //                   return AddbookingModel.fromMap(data);
  //                 }).toList();
  //                 // Update the playgroundbook list with fetched bookings
  //                 playgroundbook = bookings;
  //
  //
  //               }
  //             }
  //           }
  //         }
  //         List<AddbookingModel> bookings = querySnapshot.docs.map((doc) {
  //           Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit casting
  //           return AddbookingModel.fromMap(data);
  //         }).toList();
  //         // Update the playgroundbook list with fetched bookings
  //         playgroundbook = bookings;
  //         // Print and access specific fields for each booking
  //         for(int r=0;r<playgroundbook.length;r++) {
  //           print('AdminId: ${playgroundbook[r].AdminId}');
  //           formatDate(playgroundbook[r].dateofBooking!);
  //           print('Day_of_booking: ${playgroundbook[r].Day_of_booking}');
  //           print('Name: ${playgroundbook[r].Name}');
  //           print('Rent_the_ball: ${playgroundbook[r].rentTheBall}');
  //           print('phoneshoka: ${playgroundbook[r]
  //               .AllUserData![r].UserPhone!}');
  //           getPlaygroundbyname(playgroundbook[r]
  //               .NeededGroundData![r].GroundId!);
  //           // Access other fields as needed
  //         }
  //
  //       }
  //       else {
  //         print('No documents found in the "booking" collection.');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching booking data: $e');
  //   }
  // }
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
              MaterialPageRoute(builder: (context) => my_reservation()),
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

  // Future<void> updateCancelCount(String userPhone) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final query = await firestore
  //       .collection('cancel_book')
  //       .where('user_phone', isEqualTo: userPhone)
  //       .get();
  //
  //   if (query.docs.isNotEmpty) {
  //     // Document exists, increment the numberofcancel field
  //     final doc = query.docs.first;
  //     final currentCount = doc['numberofcancel'] ?? 0;
  //
  //     await firestore
  //         .collection('cancel_book')
  //         .doc(doc.id)
  //         .update({'numberofcancel': currentCount + 1});
  //   } else {
  //     // Document does not exist, create a new one with numberofcancel set to 1
  //     await firestore.collection('cancel_book').add({
  //       'user_phone': userPhone,
  //       'numberofcancel': 1,
  //     });
  //   }
  // }
  Future<void> updateCancelCount(String userPhone, String idAdmin,
      String idGround)
  async {
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
      print("dooooc$doc");
    } else {
      // Document does not exist, create a new one with numberofcancel set to 1
      await firestore.collection('cancel_book').add({
        'user_phone': userPhone,
        'numberofcancel': 1,
        'playgroundId': idGround,
        'adminid': idAdmin,
      });
    }
  }

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
              .arguments as Map<dynamic, dynamic>?; // Explicit casting
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
          preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
          child: Padding(
            padding: EdgeInsets.only(top: 25.0, right: 8, left: 8),
            // Add padding to the top of the title
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
              // Center the title horizontally
              leading: IconButton(
                onPressed: () {
                  Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
                      ?.settings
                      .arguments as Map<dynamic, dynamic>?; // Explicit casting
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
                      // SizedBox(
                      //   width: 12,
                      // ),
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
                              .black, // This color will be visible at the bottom
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF), // Inner container color
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
                              .shade200, // This color will be visible at the bottom
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF), // Inner container color
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
                              .shade400, // This color will be visible at the bottom
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 92,
                              width: 87,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(
                                    0xFFF0F6FF), // Inner container color
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
              for (var i = 0; i < playgroundAllData.length; i++) // Repeat the container 5 times
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
                            // Increase opacity for a darker shadow
                            spreadRadius: 0,
                            // Increase spread to make the shadow larger
                            blurRadius: 2,
                            // Increase blur radius for a more diffused shadow
                            offset: Offset(0,
                                0), // Increase offset for a more pronounced shadow effect
                          ),
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
                              // Aligns the content to the right
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${playgroundbook[i].NeededGroundData![0].GroundName!}",
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
                                          // textDirection: TextDirection.RTL,  // Ensures the text direction is RTL

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
                                          "${playgroundbook[i].AllUserData?[0].UserPhone}",
                                          // textDirection: TextDirection.RTL,  // Ensures the text direction is RTL

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
                                // Adds space between the text and the image
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
                                    // SizedBox(width: 5,),


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
                                                .selectedTimes![0]), // Add formatted time range
                                      ):TextSpan(
                            text:"", // Add formatted time range
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
                                    print("phooonefff${playgroundbook[i]
                                        .AllUserData![0].UserPhone!}");
                                    updateCancelCount(
                                        playgroundbook[i].AllUserData![0].UserPhone!,
                                        playgroundbook[i].AdminId!,
                                        playgroundbook[i].NeededGroundData![0].GroundId!);
                                    deleteCancelByPhoneAndPlaygroundId(
                                        playgroundbook[i].AllUserData![0].UserPhone!,
                                        playgroundbook[i].NeededGroundData![0].GroundId!,
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
                                          0xFFB3261E), // Background color of the container
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
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white, // Text color
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
                                          0xFF064821), // Background color of the container
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
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white, // Text color
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
                                      // color: Color(
                                      //     0xFFB3261E), // Background color of the container
                                      // border: Border.all(
                                      //   width: 1.0, // Border width
                                      //   color: Colors.black
                                      // ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white, // Text color
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
                                      // shape: BoxShape.rectangle,
                                      // color: Color(
                                      //     0xFF064821), // Background color of the container
                                      // border: Border.all(
                                      //   width: 1.0, // Border width
                                      //   color: Colors.black
                                      // ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "".tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.0,
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
              // Adds space between the text and the image
            ],
          ),
        ):_buildNoInternetUI(),
        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 1,
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
              // Get.to(() => FavouritePage())?.then((_) {
              //   navigationController
              //       .updateIndex(1); // Update index when navigating back
              // });
              // break;
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