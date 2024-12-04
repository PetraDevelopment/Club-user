import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import '../../notification/notification_page.dart';
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
  int _currentIndex = 0;
  bool isSlotSelected = false;
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
       }
    }

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

    String numberString = number.toString();

    String convertedNumber =
        numberString.replaceAllMapped(RegExp(r'\d'), (match) {
      return englishToArabicNumbers[int.parse(match.group(0)!)];
    });
    print("kkkkkkknum$convertedNumber");
    print("number equal $convertedNumber");
    return convertedNumber;
  }

  late DateTime Day1;
  late DateTime Day2;
  var Phoone = '';
  String PhooneErrorText = '';
  String SelectedTimeErrorText = '';
  int dissmiss=0;
  List<User> users = [];
  final NavigationController navigationController = Get.put(NavigationController());
  List<bool> _isCheckedList = [false, false, false, false, false];
  List<String> timeSlots = [];
  String startTimeStr = '';

  String endTimeStr = '';
  List<Map<String, DateTime>> selectedDates = [];
  String selectedDayName = '';
  String? storeDate;
  int tappedIndex = 0;
  late AnimationController _animationController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  String normalizeText(String text) {
    return text.trim();
  }

  String getTimeRange(String startTime) {
    DateTime start = DateFormat.jm().parse(startTime);
    DateTime end = start.add(Duration(hours: 1));
    String formattedStartTime = DateFormat('h:mm a', 'ar')
        .format(start)
        .replaceAllMapped(RegExp(r'\d+'), (match) {
      return NumberFormat('en')
          .format(int.parse(match.group(0)!));
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
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          return data;

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
        QuerySnapshot adminSnapshot = await uuuserData
            .where('phone', isEqualTo: normalizedPhoneNumber)
            .get();
        print('shared phooone $normalizedPhoneNumber');
        if (adminSnapshot.docs.isNotEmpty) {
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc
              .id;
          print("Matched user docId: $docId");
          useridddd = docId;
        }
        QuerySnapshot bookingSnapshot = await bookingdataa
            .where('GroundId', isEqualTo: widget.IdData)
            .where('userID', isEqualTo: useridddd)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          playgroundbook = [];
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
            playgroundbook.add(bookingData);
          }
          setState(() {});
        }

        if (playgroundbook.isNotEmpty) {
          for (int i = 0; i < playgroundbook.length; i++) {

            print('AdminId: ${playgroundbook[i].AdminId}');
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('timeeofbooking: ${playgroundbook[i].Day_of_booking}');


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
        QuerySnapshot adminSnapshot = await uuuserData
            .where('phone', isEqualTo: normalizedPhoneNumber)
            .get();
        print('shared phooone $normalizedPhoneNumber');
        if (adminSnapshot.docs.isNotEmpty) {
          var adminDoc = adminSnapshot.docs.first;
          String docId = adminDoc
              .id;
          print("Matched user docId: $docId");
          useridddd = docId;
        }
        QuerySnapshot bookingSnapshot = await bookingdataa
            .where('GroundId', isEqualTo: widget.IdData)
            .where('userID', isEqualTo: useridddd)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          playgroundbook = [];
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
            playgroundbook.add(bookingData);
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
            print('Day_of_booking: ${playgroundbook[i].Day_of_booking}');
            print('Rent_the_ball: ${playgroundbook[i].rentTheBall}');
            print('phoneshoka: ${playgroundbook[i].UserPhone!}');
            getPlaygroundbyname(playgroundbook[i].GroundId!);
          }
          if (timeSlots.isNotEmpty) {

            startendtime(timeSlots.first+timeSlots.last);
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
  Future<void> updateCancelCount(String userid)
  async {
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('cancel_book')
        .where('userid', isEqualTo: useridddd)

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
        'userid': useridddd,
        'numberofcancel': 1,

      });
    }
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
  late var availableData=[];
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
            availableData = playgroundAllData.isNotEmpty
                ? playgroundAllData
                .where((data) =>
                data.bookTypes!.any((bt) => bt.day == selectedDayName))
                .toList()
                : [];
            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];

              print("Start Time: $startTime");
              print("End Time: $endTime");
              groundPhoneee = playgroundAllData[0].phoneCommunication!;
              groundNamee = playgroundAllData[0].playgroundName!;
              timeSlots.add(startTime);
              timeSlots.add(endTime);
              for (var bookType in playgroundAllData[0].bookTypes!) {
                print("hhhselectedDayName$selectedDayName");
                if (bookType.day == selectedDayName) {
                  setState(() {
                    costboll = 0;
                    costboll += bookType.cost!;
                    print("coopppppppp$costboll");
                    costpeerhour=bookType.costPerHour!.toDouble();
                    print('costpeerhour${costpeerhour=bookType.costPerHour!.toDouble()}');
                  });
                  print("tessst${bookType.cost! + bookType.costPerHour!}");

                }
              }
              setState(() {
                startTimeStr = startTime;
                endTimeStr = endTime;
              });

              print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }
            print("PlayGroungboook Iiid : ${document.id}");
            groundIiid = document.id;
            print("Docummmmmmbook$groundIiid");
          }
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

            String timeofAddedPlayground = bookType ?? '';
            print("timeofAddedPlayground: $timeofAddedPlayground");
            List<String> times = timeofAddedPlayground.split(' - ');
            if (times.length == 2) {
              String startTime = times[0];
              String endTime = times[1];

              print("Start Time: $startTime");
              print("End Time: $endTime");

              timeSlots.add(startTime);
              timeSlots.add(endTime);

              setState(() {
                startTimeStr =
                    startTime;
                endTimeStr =
                    endTime;
              });

              print("Time slots: ${timeSlots}");
            } else {
              print("Invalid time format: $timeofAddedPlayground");
            }

            print(
                "PlayGroungboook Iiid : ${document.id}");
            groundIiid2 = document.id;
            print("Docummmmmmbook$groundIiid2");

          }
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
    for (var booking in bookings) {
      String day =
          booking.Day_of_booking ?? '';
      Set<String> selectedTimes = booking.selectedTimes?.toSet() ?? {};
      Set<String> formattedTimes = selectedTimes.map((time) {
        return time
            .trim();
      }).toSet();
      if (fetchedSelectedTimesPerDay.containsKey(day)) {
        fetchedSelectedTimesPerDay[day]!.addAll(formattedTimes);
        print("fetchbooking${formattedTimes}");
      } else {
        fetchedSelectedTimesPerDay[day] = formattedTimes;
        print("fetchbooking${formattedTimes}");
      }
    }
    print("Fetched times per day: $fetchedSelectedTimesPerDay");
    setState(() {
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
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          print("PlayersChat data is $data");
          return data;
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
      click:false,
      adminreply:false,
      time: time,
      date: daaate,
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

  Future<void> _sendData(BuildContext context, bool x) async {
    setState(() {
      _isLoading = true;
    });
    final name = user1[0].name!;
    final phooneNumber = user1[0].phoneNumber!;

    final selectedDay = selectedDayName;
    num totalCost = 0;
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
    if (name.isNotEmpty &&
        phooneNumber.isNotEmpty &&
        selectedTimes.isNotEmpty) {
      print("Selected date: $storeDate");
       final bookingQuery = await FirebaseFirestore.instance
          .collection('booking')
          .where('GroundId', isEqualTo: widget.IdData)
          .where('dateofBooking', isEqualTo: storeDate)
          .where('Day_of_booking', isEqualTo: selectedDayName)
          .where('selectedTimes', arrayContainsAny: selectedTimes)
          .get();

      if (bookingQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الحجز موجود بالفعل',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      } else {

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
        await FirebaseFirestore.instance.collection('booking').add(bookingModel.toMap());
        Map<String, dynamic>? user =
            await fetchadmindatabyid(playgroundAllData[0].adminId!);
        String ms = "تم اضافة حجز جديد";
        String title = "حجز جديد";
        String token = user!['FCMToken'];

        print("toooooooooook$token");
        String idwidget=widget.IdData;
        print("jjjjjjjjjjjjjjjjjjjjjj$idwidget");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => book_playground_page(idwidget)),
        );
        await _sendnotificationtofirebase(1,groundIiid,selectedDayName,selectedTimes);
        await sp(ms, title, token);
        // await fetchBookingData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل البيانات بنجاح',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
        selectedTimes.clear();

        _isCheckedList[0] = false;
        setState(() {
          matchedPlaygrounds.clear();
        });
        fetchBookingData();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء جميع البيانات',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
    setState(() {
      _isLoading = false;
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

  // }

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
        SelectedTimeErrorText = '';
      });
    }
  }
  double costpeerhour=0;

  List<String> startendtime(String timeRange) {
    // Split the input string into start and end times
    List<String> times = timeRange.split(' - ');
    String startTimeStr = times[0].trim();
    String endTimeStr = times[1].trim();

    DateTime startTime = Jiffy.parse(startTimeStr, pattern: 'h:mm a').dateTime;
    DateTime endTime = Jiffy.parse(endTimeStr, pattern: 'h:mm a').dateTime;

    // If the end time is before the start time, it means it goes to the next day
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(Duration(days: 1));
    }

    print("Start Time: $startTime");
    print("End Time: $endTime");

    // Prepare to format the time
    List<String> timeSlots = [];

    // Generate time slots
    DateTime currentTime = startTime;
    while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
      // Add the hour to the list (in 12-hour format)
      timeSlots.add(intl.DateFormat('h').format(currentTime));
      currentTime = currentTime.add(Duration(hours: 1));
    }

    // Print the generated time slots
    for (String slot in timeSlots) {
      print("Slot: $slot");
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
            await sp(ms, title, adminoooken);
          }else{
            String ms=" "+"تم إلغاء حجز ملعب "+" $g_name "+"يوم"+ " ${dayName} "+" ${selectedTime.substring(0,4)} "+"ص";
            print("message of delete is $ms");
            String title = "الغاء حجز ";
            await sp(ms, title, adminoooken);
            await _sendnotificationtofirebase(2,playgroundId,dayName,selectedTime);
          }

          print('Document with phone $userid, playgroundId $playgroundId, dayName $dayName, and selectedTime $selectedTime deleted successfully.');
          documentDeleted = true;
String iddd=widget.IdData;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => book_playground_page(iddd)),
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
  void initState() {
    checkInternetConnection();
    _loadUserData();
    fetchBookingData();
    print("initistatedone");
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
    DateTime today = DateTime.now();
    List<Map<String, String>> daysOfWeek = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));
      String dayName =
          DateFormat('EEEE', 'ar').format(day);
      String dayDate = DateFormat('dd MMMM yyyy').format(day);
      daysOfWeek.add({'dayName': dayName, 'dayDate': dayDate});

      selectedDates.add({dayName: day});

    }
    // fetchBookingData();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, right: 12, left: 12),
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

            leading: IconButton(
              onPressed: () {
                Get.back();
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
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Notification_page()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Image.asset(
                    'assets/images/notification.png',
                    height: 28,
                    width: 28,
                  ),
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
                              color: Color(0xFF495A71),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                                            initialPage: _currentIndex,
                                            enableInfiniteScroll: false,
                                            autoPlay: false,
                                            enlargeCenterPage: true,

                                            onPageChanged: (index, reason) {

                                              _currentIndexNotifier.value = index;
                                                selectedDayName = daysOfWeek[index]['dayName']!;
                                                storeDate = daysOfWeek[index]['dayDate'];

                                            },
                                            scrollDirection: Axis.horizontal,
                                          ),
                                          items: daysOfWeek.map((dayInfo) {
                                            int itemIndex = daysOfWeek.indexOf(
                                                dayInfo);

                                            return ValueListenableBuilder(
                                              valueListenable: _currentIndexNotifier,
                                                builder: (context, currentIndex, child) {
                                              return GestureDetector(
                                                onTap: () {
                                                  print(
                                                      "Tapped on ${dayInfo['dayName']} - ${dayInfo['dayDate']}");
                                                  storeDate = dayInfo['dayDate'];
                                                  print("objectstoreDate$storeDate");

                                                  _currentIndex = itemIndex;
                                                  selectedDayName = dayInfo['dayName']!;
                                                  print("objectselectedDayName$selectedDayName");
                                                  getPlaygroundbyname(widget.IdData);
                                                  selectedTimes = {};
                                                  setState(() {

                                                  });
                                                },
                                                child: Center(
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 300),
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
                                                                    0xFFF0F6FF),
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
                                                                  children: [
                                                                    Text(
                                                                      dayInfo[
                                                                          'dayName']!,
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
                                                                              DateFormat('dd MMMM yyyy').parse(dayInfo['dayDate']!)
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
                                              );}
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
                              color: Color(0xFF495A71),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        availableData.isNotEmpty
                                ? FutureBuilder<List<Widget>>(
                                    future: _generateRows(
                                        selectedTimes, selectedDayName),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                        child:  Column(
                                          children: [
                                            CircularProgressIndicator(
                                                      color: Colors.green,),
                                            SizedBox(height: 40,)
                                          ],
                                        ));

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
                                            return slotWidget;
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
                                  ),

                        availableData.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '    تأجير الكره   :',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Cairo',
                                            color: Color(
                                                0xFF495A71),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   ${costboll}  ' + '  جنية  ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Cairo',
                                            color:
                                                Color(0xFFB0B0B0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    activeColor: Color(0xFF106A35),
                                    checkColor: Color(0xFF106A35),

                                    focusColor: Color(0xFF106A35),
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => Colors.white),
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
                                      _isCheckedList[0] = newValue ?? false;
                                      setState(() {

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
                                    0xFF064821),
                              ),
                              child: Center(
                                child: Text(
                                  'حجز الموعد'.tr,
                                  textAlign: TextAlign.center,
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

                        //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@222
                        matchedPlaygrounds.isNotEmpty
                            ? IntrinsicHeight(
                                child: Container(
                                  child: Wrap(
                                    children: List.generate(
                                        matchedPlaygrounds.length, (index) {
                                      final user = matchedPlaygrounds[index];
                                      print("objectmatching${matchedPlaygrounds.length}");

                                   return   Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 17.0,
                                                left: 17,
                                                bottom: 9,
                                                top: 9),
                                            child: Container(
                                              height: 84,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade800,
                                                borderRadius: BorderRadius.circular(20.0),

                                              ),

                                            ),
                                          ),

                                            Dismissible(
                                        key: Key(user.userID!),

                                              direction: DismissDirection.horizontal,
                                      onDismissed: (direction) async {
                                       setState(() {
                                         dissmiss=1;
                                       });
                                        updateCancelCount(user.userID!,);

                                        deleteCancelByPhoneAndPlaygroundId(
                                            user.userID!,
                                            user.AdminId!,
                                            user.groundName!,
                                            user.GroundId!,
                                            user.selectedTimes!.first,
                                            user.dateofBooking!);

                                          // String i = widget.IdData;
                                          // Navigator.pushAndRemoveUntil(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           book_playground_page(i)),
                                          //       (Route<dynamic> route) => false,
                                          // );

                                      },
                                      confirmDismiss: (direction) async {
                                      return await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                      return  AlertDialog(
                                        title: Center(
                                            child: Text("تاكيد الحذف".tr,
                                                style: TextStyle(
                                                  color: Color(0xFF374957),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  fontFamily: 'Cairo',
                                                ))),
                                        content: Text(
                                            "هل تريد التأكيد على الغاء الحجز".tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF374957),
                                              fontFamily: 'Cairo',
                                            )),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [

                                              ElevatedButton(
                                                onPressed: () async {

                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  Color(0xFFFFBEC5),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 20,
                                                  ),
                                                ),
                                                child: Text(
                                                  "حذف".tr,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                              ),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  Color(0xFF064821),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 20,
                                                  ),
                                                ),
                                                child: Text(
                                                  "إلغاء".tr,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                      },
                                      );
                                      },
                                      background: Container(
                                      height: 84,
                                      decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                      Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image(
                                      image: AssetImage(
                                      "assets/images/trush-square.png"),
                                      color: Colors.white,
                                      width: 40.0,
                                      height: 40.0,
                                      ),
                                      ),
                                      Expanded(child: Container()),
                                      ],
                                      ),
                                      ),
                                      secondaryBackground: Container(
                                      height: 84,
                                      decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      ),

                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                      Expanded(child: Container()),
                                      Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image(
                                      image: AssetImage(
                                      "assets/images/trush-square.png"),
                                      color: Colors.white,
                                      width: 40.0,
                                      height: 40.0,
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
                                      height: 84,
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
                                      child: Row(
                                      children: [
                                      Expanded(
                                      child: Padding(
                                      padding: const EdgeInsets.only(right: 10.0,left: 10),
                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [

                                      Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(width: MediaQuery.of(context).size.width/35,),
                                      Text(
                                      'ج.م',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                      color: Color(0xFF7C90AB),
                                      fontSize: 21.55,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                     letterSpacing: -0.43,
                                      ),
                                      ),
                                    //  SizedBox(width: 8),
                                      Text(
                                      "  ${toArabicNumerals(matchedPlaygrounds[index].totalcost!,0)}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                      color: Color(0xFF7C90AB),
                                      fontSize: 21.55,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                      letterSpacing: -0.43,
                                      ),
                                      ),
                                      Spacer(),
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      children: [
                                      Text(
                                      formatDate(matchedPlaygrounds[index].dateofBooking!),
                                      style: TextStyle(
                                      color: Color(0xFF324054),
                                      fontSize: 16,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                      letterSpacing: 0.64,
                                      ),
                                      ),
                                      Padding(
                                      padding: const EdgeInsets
                                          .only(right: 12.0,left: 4),
                                      child: Text(
                                        matchedPlaygrounds[index].Day_of_booking ?? " ",
                                      style: TextStyle(
                                      color: Color(
                                      0xFF324054),
                                      fontSize: 16,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight
                                          .w700,
                                      height: 0,
                                      letterSpacing: 0.64,
                                      ),
                                      ),
                                      ),
                                      ],
                                      ),
                                      ],
                                      ),
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Padding(
                                      padding: const EdgeInsets
                                          .only(right: 8, left: 8,bottom: 16),
                                      child: Text(
                                      "التكلفة الاجمالية",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                      color: Color(0xFF324054),
                                      fontSize: 10.77,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight
                                          .w700,
                                      height: 0,
                                      letterSpacing: 0.32,
                                      ),
                                      ),
                                      ),
                                      Padding(
                                      padding: const EdgeInsets
                                          .only(right: 14.0),
                                      child: RichText(
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
                                      for (var i = 0; i <
                                          matchedPlaygrounds[index]
                                          .selectedTimes!
                                          .length; i++)
                                      TextSpan(
                                      text: getTimeRange(
                                          matchedPlaygrounds[index]
                                          .selectedTimes![i]) +
                                      '\n',
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
                                      ),
                                      ],
                                      ),
                                      ),
                                      ),
                                      )
                                        ],
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
            opacity = 0.5;
          });
          switch (index) {
            case 0:
              Get.to(() => menupage())?.then((_) {
                navigationController
                    .updateIndex(0);
              });
              break;

            case 1:
              Get.to(() => my_reservation())?.then((_) {
                navigationController
                    .updateIndex(1);
              });
              break;
            case 2:
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

// Function to show the dialog
  void _showDialog(BuildContext context) {
  showDialog(
  context: context,
  builder: (BuildContext context) {
  return AlertDialog(
  title: Center(
  child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Text(
  "ج.م".tr,
  style: TextStyle(
  color: Color(0xFF374957),
  fontWeight: FontWeight.w700,
  fontSize: 15,
  fontFamily: 'Cairo',
  ),
  ),
  Text(
    '$costpeerhour',
  style: TextStyle(
  color: Color(0xFF374957),
  fontWeight: FontWeight.w700,
  fontSize: 15,
  fontFamily: 'Cairo',
  ),
  ),
  ],
  ),
  ),
  content: Text(
  "التكلفة أجمالية".tr,
  textAlign: TextAlign.center,
  style: TextStyle(
  color: Color(0xFF374957),
  fontFamily: 'Cairo',
  ),
  ),
  actions: [
  Center(
  child: ElevatedButton(
  onPressed: () async {
  // Your onPressed functionality here
  Navigator.of(context).pop(); // Close the dialog
  },
  style: ElevatedButton.styleFrom(
  backgroundColor: Color(0xFF064821),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
  ),
  padding: EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 20,
  ),
  ),
  child: Text(
  "حجز".tr,
  style: TextStyle(
  color: Colors.white,
  fontFamily: 'Cairo',
  ),
  ),
  ),
  ),
  ],
  );
  },
  );
  }
  Future<Widget> _generateTimeSlotWidget(
    String slot,
    bool isSelected,
    bool isAlreadySelected,
  )
  async {
    String currentDay =
        selectedDayName;
    bool isSlotBooked =
        fetchedSelectedTimesPerDay[currentDay]?.contains(slot) ?? false;
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
                selectedTimes.add(slot);

                print(("done in reservation"));
              });
              _showDialog(context);
            }

          },
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: selectedTimes.contains(slot)
                      ? Color(0xFFC3FFDC)
                      : isSlotBooked
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
    //           selectedTimes.length!=0?   Dialog(
    //   shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(20.0),
    // ),
    // child: IntrinsicHeight(
    // child: Container(
    // padding: EdgeInsets.all(16),
    // width: MediaQuery.of(context).size.width / 1.5,
    // child: Column(
    // mainAxisSize: MainAxisSize.min,
    // children: [
    // Text(
    // '620',
    // style: TextStyle(
    // fontFamily: 'Cairo',
    // fontSize: 23,
    // color: Color(0xFF7D90AC),
    // fontWeight: FontWeight.bold,
    // ),
    // ),
    // Text(
    // 'التكلفة أجمالية',
    // style: TextStyle(
    // fontFamily: 'Cairo',
    // fontSize: 16,
    // color: Color(0xFF334154),
    // fontWeight: FontWeight.bold,
    // ),
    // ),
    // SizedBox(height: 25),
    // GestureDetector(
    // onTap: () {
    // // Handle booking action here
    // Navigator.pop(context); // Close the dialog
    // },
    // child: Container(
    // height: 45,
    // decoration: BoxDecoration(
    // borderRadius: BorderRadius.circular(40.0),
    // color: Color(0xFF106A35),
    // ),
    // child: Center(
    // child: Text(
    // 'حجـــــز',
    // style: TextStyle(
    // fontSize: 16.0,
    // fontFamily: 'Cairo',
    // fontWeight: FontWeight.w500,
    // color: Colors.white,
    // ),
    // ),
    // ),
    // ),
    // ),
    // ],
    // ),
    // ),
    // ),
    // ):Container()
            ],
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
          combinedTimeSlots.addAll(_getHoursBetween(time));
        }
      }
    }
    combinedTimeSlots = combinedTimeSlots.toSet().toList();
    combinedTimeSlots.sort(
        (a, b) => DateFormat.jm().parse(a).compareTo(DateFormat.jm().parse(b)));

    return combinedTimeSlots;
  }
  void showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width / 1.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    'التكلفة أجمالية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: Color(0xFF334154),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      // Handle booking action here
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color: Color(0xFF106A35),
                      ),
                      child: Center(
                        child: Text(
                          'حجـــــز',
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
            ),
          ),
        );
      },
    );
  }

  Future<List<Widget>> _generateRows(Set<String> selectedTimes, String selectedDay) async {

    List<Widget> rows = [];
    List<Widget> currentRowChildren = [];

    print("selectedddddddddddday: $selectedDay");
    List<String> bookedTimes = await _fetchBookedTimes(selectedDay);
    print("Booked Times for $selectedDay: $bookedTimes");
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("This time slot is already booked."),
              ));
            } else {
              setState(() {
                selectedTimes.add(slot);
print("slotttttttttttttttttt$slot");
              });
            }
          },
          child: Stack(
            children: [
              FutureBuilder<Widget>(
                future: _generateTimeSlotWidget(slot, isSelected, isTimeSlotBooked),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Container();
                  } else {
                    return snapshot.data ??
                        Container();
                  }
                },
              ),


            ],
          ),
        ),
      );
      if (currentRowChildren.length >= 3) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: currentRowChildren,
        ));
        currentRowChildren = [];
      }
    }
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
      _isLoading = true;
    });

    try {
      CollectionReference bookingRef =
          FirebaseFirestore.instance.collection("booking");
      QuerySnapshot bookingSnapshot = await bookingRef.get();
      if (bookingSnapshot.docs.isNotEmpty) {
        setState(() {
          playgroundAllData.clear();
          for (var document in bookingSnapshot.docs) {
            String docId = document.id;
            Map<String, dynamic> userData =
                document.data() as Map<String, dynamic>;

            AddPlayGroundModel playground =
                AddPlayGroundModel.fromMap(userData);
            playground.id = docId;

            playgroundAllData.add(playground);

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
        _isLoading = false;
      });
    }
  }


  Widget _buildNoInternetUI() {
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
