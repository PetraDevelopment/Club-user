import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../Controller/NavigationController.dart';
import '../../Favourite/Favourite_page.dart';
import '../../Home/HomePage.dart';
import '../../Menu/menu.dart';
import '../../Splach/LoadingScreen.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../AddbookingModel/AddbookingModel.dart';
import '../widgets_for_popover_cancel_and_add/reservation.dart';
import 'AddPlaygroundModel.dart';

class book_playground_page extends StatefulWidget {
  @override
  State<book_playground_page> createState() {
    return book_playground_pageState();
  }
}

class book_playground_pageState extends State<book_playground_page>
    with TickerProviderStateMixin {
  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  late List<AddPlayGroundModel> addplayground = [];
  String phoneCont="01141238563";
  int phoneNumberMaxLength = 10; // Default length, can be adjusted
// Map of country codes to phone number lengths
  Future<void> getAllPlaygrounds() async {
    try {
      // Reference to the Firestore collection
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("booking");

      // Fetch all documents from the collection
      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Process each document
        List<AddbookingModel> playgrounds = querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return AddbookingModel.fromMap(userData);
        }).toList();

        // Update the list and UI inside setState
        setState(() {
          playgroundbook = playgrounds; // Replacing the list with all documents
        });

        // Print playground data
        playgroundbook.forEach((playground) {
          print("Playground Name: ${playground.Name}");
        });
        print("All User Data: ${playgroundbook}");

        // Ensure time1 and time2 are not null before using them
        startendtime(startTime,endTime);
      } else {
        print("No playgrounds found.");
        // Optionally clear preferences or handle empty state
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } catch (e) {
      print("Error getting playgrounds: $e");
    }
  }

  final Map<String, int> countryPhoneNumberLengths = {
    'AF': 9, // Afghanistan
    'AL': 8, // Albania
    'DZ': 9, // Algeria
    'AS': 7, // American Samoa
    'AD': 6, // Andorra
    'AO': 9, // Angola
    'AI': 7, // Anguilla
    'AG': 7, // Antigua and Barbuda
    'AR': 10, // Argentina
    'AM': 8, // Armenia
    'AW': 7, // Aruba
    'AU': 9, // Australia
    'AT': 4, // Austria
    'AZ': 9, // Azerbaijan
    'BS': 7, // Bahamas
    'BH': 8, // Bahrain
    'BD': 11, // Bangladesh
    'BB': 7, // Barbados
    'BY': 9, // Belarus
    'BE': 8, // Belgium
    'BZ': 7, // Belize
    'BJ': 8, // Benin
    'BT': 8, // Bhutan
    'BO': 8, // Bolivia
    'BA': 8, // Bosnia and Herzegovina
    'BW': 7, // Botswana
    'BR': 11, // Brazil
    'BN': 7, // Brunei
    'BG': 7, // Bulgaria
    'BF': 8, // Burkina Faso
    'BI': 8, // Burundi
    'KH': 9, // Cambodia
    'CM': 9, // Cameroon
    'CA': 10, // Canada
    'CV': 7, // Cape Verde
    'KY': 7, // Cayman Islands
    'CF': 7, // Central African Republic
    'TD': 8, // Chad
    'CL': 9, // Chile
    'CN': 11, // China
    'CO': 10, // Colombia
    'KM': 7, // Comoros
    'CG': 7, // Congo
    'CD': 9, // Congo, Democratic Republic of the
    'CK': 7, // Cook Islands
    'CR': 8, // Costa Rica
    'CI': 8, // Côte d'Ivoire
    'HR': 9, // Croatia
    'CU': 8, // Cuba
    'CW': 7, // Curaçao
    'CY': 8, // Cyprus
    'CZ': 9, // Czech Republic
    'DK': 8, // Denmark
    'DJ': 7, // Djibouti
    'DM': 7, // Dominica
    'DO': 10, // Dominican Republic
    'EC': 9, // Ecuador
    'EG': 11, // Egypt
    'SV': 8, // El Salvador
    'GQ': 9, // Equatorial Guinea
    'ER': 7, // Eritrea
    'EE': 7, // Estonia
    'ET': 10, // Ethiopia
    'FJ': 7, // Fiji
    'FI': 5, // Finland
    'FR': 9, // France
    'GF': 9, // French Guiana
    'PF': 6, // French Polynesia
    'GA': 7, // Gabon
    'GM': 7, // Gambia
    'GE': 9, // Georgia
    'DE': 11, // Germany
    'GH': 10, // Ghana
    'GI': 8, // Gibraltar
    'GR': 10, // Greece
    'GL': 6, // Greenland
    'GD': 7, // Grenada
    'GP': 9, // Guadeloupe
    'GU': 10, // Guam
    'GT': 8, // Guatemala
    'GN': 9, // Guinea
    'GW': 9, // Guinea-Bissau
    'GY': 7, // Guyana
    'HT': 8, // Haiti
    'HN': 8, // Honduras
    'HK': 8, // Hong Kong
    'HU': 9, // Hungary
    'IS': 7, // Iceland
    'IN': 10, // India
    'ID': 10, // Indonesia
    'IR': 11, // Iran
    'IQ': 10, // Iraq
    'IE': 7, // Ireland
    'IL': 9, // Israel
    'IT': 10, // Italy
    'JE': 5, // Jersey
    'JM': 7, // Jamaica
    'JP': 11, // Japan
    'JO': 9, // Jordan
    'KZ': 10, // Kazakhstan
    'KE': 9, // Kenya
    'KI': 7, // Kiribati
    'KP': 8, // Korea, North
    'KR': 11, // Korea, South
    'KW': 8, // Kuwait
    'KG': 9, // Kyrgyzstan
    'LA': 8, // Laos
    'LV': 8, // Latvia
    'LB': 8, // Lebanon
    'LS': 8, // Lesotho
    'LR': 7, // Liberia
    'LY': 9, // Libya
    'LI': 7, // Liechtenstein
    'LT': 8, // Lithuania
    'LU': 6, // Luxembourg
    'MO': 8, // Macau
    'MG': 8, // Madagascar
    'MW': 9, // Malawi
    'MY': 10, // Malaysia
    'MV': 7, // Maldives
    'ML': 8, // Mali
    'MT': 8, // Malta
    'MH': 7, // Marshall Islands
    'MR': 8, // Mauritania
    'MU': 10, // Mauritius
    'YT': 7, // Mayotte
    'MX': 10, // Mexico
    'FM': 7, // Micronesia
    'MD': 8, // Moldova
    'MC': 7, // Monaco
    'MN': 8, // Mongolia
    'ME': 8, // Montenegro
    'MS': 7, // Montserrat
    'MA': 10, // Morocco
    'MZ': 9, // Mozambique
    'MM': 8, // Myanmar
    'NA': 9, // Namibia
    'NR': 7, // Nauru
    'NP': 10, // Nepal
    'NL': 10, // Netherlands
    'NC': 6, // New Caledonia
    'NZ': 9, // New Zealand
    'NI': 8, // Nicaragua
    'NE': 8, // Niger
    'NG': 11, // Nigeria
    'NU': 7, // Niue
    'NF': 7, // Norfolk Island
    'MP': 10, // Northern Mariana Islands
    'NO': 8, // Norway
    'OM': 8, // Oman
    'PK': 11, // Pakistan
    'PW': 7, // Palau
    'PA': 8, // Panama
    'PG': 7, // Papua New Guinea
    'PY': 9, // Paraguay
    'PE': 9, // Peru
    'PH': 10, // Philippines
    'PL': 9, // Poland
    'PT': 9, // Portugal
    'PR': 10, // Puerto Rico
    'QA': 8, // Qatar
    'RE': 9, // Réunion
    'RO': 10, // Romania
    'RU': 11, // Russia
    'RW': 9, // Rwanda
    'WS': 7, // Samoa
    'SM': 7, // San Marino
    'ST': 6, // São Tomé and Príncipe
    'SA': 9, // Saudi Arabia
    'SN': 9, // Senegal
    'RS': 8, // Serbia
    'SC': 7, // Seychelles
    'SL': 7, // Sierra Leone
    'SG': 8, // Singapore
    'SX': 7, // Sint Maarten
    'SK': 8, // Slovakia
    'SI': 8, // Slovenia
    'SB': 7, // Solomon Islands
    'SO': 7, // Somalia
    'ZA': 10, // South Africa
    'SS': 9, // South Sudan
    'ES': 9, // Spain
    'LK': 10, // Sri Lanka
    'SD': 10, // Sudan
    'SR': 7, // Suriname
    'SZ': 8, // Swaziland
    'SE': 10, // Sweden
    'CH': 9, // Switzerland
    'SY': 9, // Syria
    'TW': 10, // Taiwan
    'TJ': 9, // Tajikistan
    'TZ': 10, // Tanzania
    'TH': 10, // Thailand
    'TL': 9, // Timor-Leste
    'TG': 8, // Togo
    'TK': 7, // Tokelau
    'TO': 7, // Tonga
    'TT': 10, // Trinidad and Tobago
    'TN': 8, // Tunisia
    'TR': 10, // Turkey
    'TV': 7, // Tuvalu
    'UG': 9, // Uganda
    'UA': 9, // Ukraine
    'AE': 9, // United Arab Emirates
    'GB': 10, // United Kingdom
    'US': 10, // United States
    'UY': 8, // Uruguay
    'UZ': 9, // Uzbekistan
    'VU': 7, // Vanuatu
    'VA': 6, // Vatican City
    'VE': 11, // Venezuela
    'VN': 10, // Vietnam
    'WF': 7, // Wallis and Futuna
    'EH': 6, // Western Sahara
    'YE': 9, // Yemen
    'ZM': 9, // Zambia
    'ZW': 9, // Zimbabwe
  };
  Set<String> selectedTimes = {};

  bool isLoading = false;
  late List<AddPlayGroundModel> playgrounda = [];
  List<String> dayss = [];
  List<DateTime> datees = [];

  late List<AddbookingModel> playgroundbook = [];

  String normalizeText(String text) {
    return text.trim(); // Trims any leading or trailing spaces
  }

  Future<void> getPlaygroundbyname(String playground) async {
    try {
      String normalizedplaygroundname = normalizeText(playground);

      CollectionReference playerchat =
          FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat
          .where('groundName', isEqualTo: normalizedplaygroundname)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

        setState(() {
          playgrounda.add(user);
        });

        print("Object Playground Name: ${playgrounda[0].playgroundName}");
        print("User Data: $userData");

        String day1String = playgrounda[0].day!;
        String day2String = playgrounda[0].day2!;

        print("Day1 String: $day1String");
        print("Day2 String: $day2String");

        // Convert day names to DateTime
        DateTime today = DateTime.now();
        DateTime day1 = _getNextDayOfWeek(day1String, today);
        DateTime day2 = _getNextDayOfWeek(day2String, today);

        // If day2 is before day1, it means it is in the next week
        if (day2.isBefore(day1)) {
          day2 = day2.add(Duration(days: 7));
        }

        print("Start Day: $day1");
        print("End Day: $day2");

        // Loop through the days from Day1 to Day2
        for (DateTime day = day1;
            day.isBefore(day2) || day.isAtSameMomentAs(day2);
            day = day.add(Duration(days: 1))) {
          String dayName = _getDayName(day);
          dayss.add(dayName);
          datees.add(day);

          // Print the current state of lists
          print("Loop Day: $dayName");
          print("Days List Length: ${dayss.length}");
          print("Dates List Length: ${datees.length}");
          print("Day Name Added: $dayName");
          print("Date Added: $day");
        }

        startendtime(startTime, endTime);
      } else {
        print("Playground not found with this name: $playground");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }

// Helper function to get the next occurrence of a weekday
  DateTime _getNextDayOfWeek(String dayName, DateTime today) {
    List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    int dayIndex = daysOfWeek.indexOf(dayName);
    if (dayIndex == -1) throw ArgumentError('Invalid day name: $dayName');

    int currentDayIndex =
        today.weekday % 7; // Sunday is 0, Monday is 1, ..., Saturday is 6
    int daysToAdd = (dayIndex - currentDayIndex + 7) % 7;

    return today.add(Duration(days: daysToAdd));
  }

// Helper function to get the name of the day from a DateTime object
  String _getDayName(DateTime date) {
    List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return daysOfWeek[date.weekday % 7];
  }


  void _loadUserData() async {
    await getPlaygroundbyname('وادى دجله');
  }

  Future<void> _sendData(BuildContext context) async {
    final name = NameController.text;
    final phoneNumber = phoneController.text;

    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phonecomunication', phoneNumber);
        String v_phone = prefs.getString('phonecomunication') ?? '';
        print("v_phone: $v_phone");

        // Get the selected date index
        // Get the selected date
        DateTime? selectedDate = selectedDates.last['date'];
        // Format the selected date
        // Find the index of the selected date in the datees list
        int selectedIndex = datees.indexOf(selectedDate!);
        print("selected date $selectedIndex");
// Format the selected date
        String formattedDate =
            intl.DateFormat('yyyy-MM-dd').format(datees[selectedIndex]);
        final bookingModel = AddbookingModel(
          Name: name,
          phoneCommunication: phoneNumber,
          rentTheBall: _isCheckedList[0],
          selectedTimes: selectedTimes.toList(),
          notavailable: alreadySelectedTimes.toList(),
          dateofBooking: formattedDate,
          // Add other fields as needed
        );

        // Use the instance method `toMap()` on the model
        await FirebaseFirestore.instance
            .collection('booking')
            .add(bookingModel.toMap());
        await _fetchData();
        getAllPlaygrounds();
        // Clear the controllers after successful submission
        NameController.clear();
        phoneController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل البيانات بنجاح', // "Data registered successfully"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
      } catch (e) {
        print('Error adding data to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر ارسال البيانات', // "Failed to send data"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب حدث به خطا', // "There was an error with this account"
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('booking').get();

      List<AddbookingModel> bookings = snapshot.docs.map((doc) {
        return AddbookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Combine all selected times from the bookings
      Set<String> fetchedSelectedTimes = bookings
          .expand((booking) => booking.selectedTimes ?? [])
          .cast<String>() // Cast to Set<String>
          .toSet();

      // Update the state with the fetched data
      setState(() {
        alreadySelectedTimes = fetchedSelectedTimes;
        print("alreadySelectedTimes$alreadySelectedTimes");
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  late DateTime Day1;
  late DateTime Day2;
  Set<String> alreadySelectedTimes =
      {}; // Track times that are already selected and should not be deselected
  var Phone = '';
  String PhoneErrorText = '';
  final NavigationController navigationController =
      Get.put(NavigationController());

  // List<bool> _isCheckedList = List.generate(6, (index) => false);
  List<bool> _isCheckedList = [false, false, false, false, false];
  List<String> timeSlots = [];
  List<String> playTypes = [];
  List<Map<String, DateTime>> selectedDates = [];

  void validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        PhoneErrorText = ' يجب ادخال رقم التليفون *'.tr;
        // isLoading=false;
      });
    } else if (value.length < 11) {
      setState(() {
        PhoneErrorText = ' يجب أن يكون رقم الهاتف كاملا *'.tr;
        // isLoading=false;
      });
    } else {
      setState(() {
        // isLoading=false;
        PhoneErrorText = ''; // No error message for 3-letter names
      });
    }
  }

  void _handleTap(int index) {
    // Save the selected day and date to the list
    selectedDates.add({'day': datees[index], 'date': datees[index]});
    print("Selected Dates: $selectedDates");
    // You can add any other logic here, like navigating to another screen
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

  String startTime = '9:00 AM'; // Example start time
  String endTime = '5:00 PM'; // Example end time

  List<String> startendtime(String startTimeStr, String endTimeStr) {
    List<String> timeSlots = [];

    try {
      DateTime startTime =
          Jiffy.parse(startTimeStr, pattern: 'h:mm a').dateTime;
      DateTime endTime = Jiffy.parse(endTimeStr, pattern: 'h:mm a').dateTime;

      intl.DateFormat timeFormat = intl.DateFormat.jm();

      DateTime currentTime = startTime;

      while (currentTime.isBefore(endTime) ||
          currentTime.isAtSameMomentAs(endTime)) {
        timeSlots.add(timeFormat.format(currentTime));
        currentTime = currentTime.add(Duration(hours: 1));
      }

      for (String slot in timeSlots) {
        print(slot);
      }
    } catch (e) {
      print("Error parsing time: $e");
    }

    return timeSlots;
  }

  // String _getDayName(int index) {
  //   List<String> dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  //   return dayNames[index % 7]; // Cycle through day names
  // }

  String _getDate(int index) {
    int currentDate = 12; // Current date (you can replace with any date)
    return (currentDate + index).toString(); // Increment date for each item
  }

  bool showDropdown = false;
  final List<String> _checkboxTexts = [
    'تأجير الكره:',
  ];
  late AnimationController _animationController;

  void initState() {
    super.initState();
    _loadUserData();
    _fetchData();
    getAllPlaygrounds();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    print("njbjbhbbb");

    // Call setState to rebuild the widget tree
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String startTime = '9:00 AM'; // Example start time
    String endTime = '5:00 PM'; // Example end time

    // Call startendtime and get the time slots
    List<String> timeSlots = startendtime(startTime, endTime);

    return Scaffold(
      backgroundColor: Colors.white,
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
              Get.to(() => FavouritePage())?.then((_) {
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, bottom: 12, right: 12, left: 12),
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
                Get.off(HomePage());
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 25.0, left: 25, top: 15, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
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

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 125,
                                viewportFraction: 0.2,
                                // Adjust this value as needed
                                initialPage: 2,
                                // Start with the center item
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {},
                                scrollDirection: Axis.horizontal,
                              ),
                              items: [
                                for (int i = 0; i < 7; i++)
                                  GestureDetector(
                                    onTap: () {
                                      // _handleTap(index);
                                      print("iiiiiii"); // Correct usage
                                    },
                                    child: Center(
                                      child: Container(
                                        width: 80,
                                        child: Card(
                                          color: Color(0xFFF0F6FF),
                                          child: IntrinsicHeight(
                                            child: SingleChildScrollView(
                                              // Wrap your Column with SingleChildScrollView
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "dayss",
                                                      // Function to get day name
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Cairo',
                                                        color:
                                                            Color(0xFF334154),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      '21',
                                                      // Display formatted date
                                                      // Function to get date
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontFamily: 'Cairo',
                                                        color:
                                                            Color(0xFF7D90AC),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                  // Ensure playgrounda is not empty and time1/time2 are available
                  // Conditionally display time slots
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _generateRows(
                            timeSlots, selectedTimes, alreadySelectedTimes),
                      )),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _checkboxTexts[0], // النص الأساسي
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71), // اللون الأساسي
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' 20 جنية', // النص الذي تريد جعله أبهت
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFFB0B0B0), // لون أبهت
                                fontWeight: FontWeight.w400,
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
                  ),
                  GestureDetector(
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

                  IntrinsicHeight(
                    child: Container(
                      // height: MediaQuery.of(context).size.height / 1.5,
                      child: Wrap(
                        children: List.generate(1, (index) {
                          // final user = playgroundbook[0];
                          return Dismissible(
                            key: Key(phoneCont.toString()), // Use a unique key for each item
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              // Handle item dismissal if needed

                            },
                            background: Container(
                              color: Colors.red, // Background color when swiped
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image(
                                      image: AssetImage("assets/images/trush-square.png"),
                                      width: 40.0,
                                      height: 40.0,
                                    ),
                                  ),
                                  Expanded(child: Container()), // Fill space
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red, // Background color when swiped
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(child: Container()), // Fill space
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image(
                                      image: AssetImage("assets/images/trush-square.png"),
                                      width: 40.0,
                                      height: 40.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child:Padding(
                              padding: const EdgeInsets.only(
                                  right: 22.0, left: 22, bottom: 1),
                              child: Dismissible(
                                key: Key("user.phoneCommunication.toString()"), // Use a unique key for each item
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {

                                  // Handle item dismissal if needed
                                },
                                background: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.red,),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image(
                                          image: AssetImage("assets/images/trush-square.png"),
                                          width: 40.0,
                                          height: 40.0,
                                        ),
                                      ),
                                      Expanded(child: Container()), // Fill space
                                    ],
                                  ),
                                ),
                                secondaryBackground: Container(
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.red,),
                                  // Background color when swiped
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(child: Container()), // Fill space
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image(
                                          image: AssetImage("assets/images/trush-square.png"),
                                          width: 40.0,
                                          height: 40.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Container(
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
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // user.dateofBooking!.isNotEmpty
                                                  //     ? Text(
                                                  //     (user.Day_of_booking != null &&
                                                  //         user.Day_of_booking!.length > 5)
                                                  //         ? "${user.Day_of_booking!.substring(0, 3)}.. : ${user.dateofBooking}"
                                                  //         : (user.Day_of_booking ??
                                                        Padding(
                                                          padding: const EdgeInsets.all(6.0),
                                                          child: Text(  '620',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily: 'Cairo',
                                                              fontWeight: FontWeight.w700,
                                                              color: Color(0xFF7D90AC),
                                                            ),
                                                          ),
                                                        ),
                                                      // : Container(),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8, left: 8),
                                                    child: Text(
                                                       'الأربعاء 28-08-2024',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Cairo',
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF7D90AC),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                  // Text(
                                                  //   user.selectedTimes!.length > 2
                                                  //       ? '${user.selectedTimes!.first}, ..., ${user.selectedTimes!.last}'
                                                  //       : user.selectedTimes!.join(', '),
                                                  //   style: TextStyle(
                                                  //     fontSize: 12.0,
                                                  //     fontWeight: FontWeight.w400,
                                                  //     color: Color(0xFF7D90AC),
                                                  //   ),
                                                  // ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 8, left: 8),
                                                    child: Text(
                                                      "التكلفة"+"  "+  "أجمالية".tr,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 10.0,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF7D90AC),
                                                      ),
                                                    ),
                                                  ),
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
                  ),
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
      ),

    );
  }

  // List<Widget> _generateRows(List<String> timeSlots, Set<String> selectedTimes) {
  //   List<Widget> rows = [];
  //   int index = 0;
  //   while (index < timeSlots.length) {
  //     List<Widget> rowChildren = [];
  //     for (int j = 0; j < 4 && index < timeSlots.length; j++, index++) {
  //       String slot = timeSlots[index];
  //       bool isSelected = selectedTimes.contains(slot);
  //       bool isAlreadySelected = alreadySelectedTimes.contains(slot);
  //
  //       rowChildren.add(
  //         GestureDetector(
  //           onTap: () {
  //             if (!isAlreadySelected) {
  //               setState(() {
  //                 if (isSelected) {
  //                   // Do nothing if it's already selected
  //                 } else {
  //                   selectedTimes.add(slot);
  //                   alreadySelectedTimes.add(
  //                       slot); // Mark this time slot as permanently selected
  //                 }
  //               });
  //
  //             }
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               slot,
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 fontFamily: 'Cairo',
  //                 color: isSelected ? Colors.red : Color(0xFF495A71),
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //     rows.add(
  //     Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: rowChildren,
  //     ),
  //   );
  // }
  // return rows;
  //
  // }

  Widget _generateTimeSlotWidget(
      String slot, bool isSelected, Set<String> alreadySelectedTimes) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
          color: selectedTimes.contains(slot)
              ? Color(0xFFC3FFDC)
              : alreadySelectedTimes.contains(slot)
                  ? Color(0xFFFFBEC5)
                  : Color(
                      0xFFEFF6FF), // Background color based on the condition
          // Background color
          borderRadius: BorderRadius.circular(8.0), // Radius of the corners
          // border: Border.all(
          //   color: Colors.grey, // Optional: Border color
          //   width: 1.0, // Optional: Border width
          // ),
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
    );
  }

  List<Widget> _generateRows(List<String> timeSlots, Set<String> selectedTimes,
      Set<String> alreadySelectedTimes) {
    List<Widget> rows = [];
    int index = 0;
    while (index < timeSlots.length) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < 3 && index < timeSlots.length; j++, index++) {
        String slot = timeSlots[index];
        bool isSelected = selectedTimes.contains(slot);

        rowChildren.add(
          GestureDetector(
            onTap: () {
              if (!alreadySelectedTimes.contains(slot)) {
                // _showBookingDetailsDialog(slot);
                setState(() {
                  if (!isSelected) {
                    selectedTimes.add(slot);
                    reservation();
                  } else {
                    selectedTimes.remove(slot);
                  }
                });
              }
            },
            child:
                _generateTimeSlotWidget(slot, isSelected, alreadySelectedTimes),
          ),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowChildren,
        ),
      );
    }
    return rows;
  }

  List<Widget> generatedWidgets = List.generate(5, (index) {
    return Padding(
      padding: const EdgeInsets.only(right: 22.0, left: 22, top: 16, bottom: 1),
      child: Container(
        height: 75,
        // width: 308,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 18, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.red.shade900,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outlined,
                        color: Colors.red.shade900,
                        size: 15,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "user1[0].name!",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334154),
                          ),
                        ),
                        // user1.isNotEmpty && user1[0].phoneNumber!.isNotEmpty
                        //     ?
                        Text(
                          'user1[0].phoneNumber!',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7D90AC),
                          ),
                        )
                        // : Container(),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Image.asset(
                    "assets/images/profile.png",
                    height: 60,
                    width: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}

class Playground {
  String? day;
  String? day2;

  Playground({this.day, this.day2});
}
