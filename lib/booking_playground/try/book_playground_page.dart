import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Menu/menu.dart';
import '../../Splach/LoadingScreen.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../../playground_model/AddPlaygroundModel.dart';
import '../AddbookingModel/AddbookingModel.dart'; // Add this

class book_playground_page extends StatefulWidget {
  String? IdData;
  book_playground_page(this.IdData);
  @override
  State<book_playground_page> createState() {
    return book_playground_pageState();
  }
}

class book_playground_pageState extends State<book_playground_page> with TickerProviderStateMixin {

  TextEditingController phoneController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  // late List<AddPlayGroundModel> addplayground = [];
  int phoneNumberMaxLength = 10; // Default length, can be adjusted
// Map of country codes to phone number lengths
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
  // Helper function to fetch booking details based on the selected slot
  Future<DocumentSnapshot> _fetchBookingDetails(String slot) async {
    // Query your booking collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('Day_of_booking', isEqualTo: selectedDayName)
        .where('selectedTimes', arrayContains: slot)
        .get();

    // Assuming only one booking per slot
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      throw Exception("No booking found for this slot"); // Or return null
    }
  }
  void _showBookingDetailsDialog(String slot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.9,
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '012356577841',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            Text(
                              'قام بالحجز: علاء أبراهيم',
                              style: TextStyle(
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
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '4:00 AM - 5:00 AM',
                        style: TextStyle(
                          fontSize: 16,
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
                          fontSize: 23,
                          color: Color(0xFF7D90AC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'المبلغ المدفوع: 500',
                        style: TextStyle(
                          fontSize: 16,
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
                          color: Color(0xFF334154),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'المبلغ المتبقي: 120',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 50,
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
  bool isLoading = false;
  late List<AddPlayGroundModel> playgrounda = [];
  List<String> dayss = [];
  List<DateTime> datees = [];
  int _currentIndex = 0; // Add this state variable to track the current page

  late List<AddbookingModel> playgroundbook = [];
  String cost = "";
  late DateTime Day1;
  late DateTime Day2;
  // Map to hold already booked times per day
  Map<String, Set<String>> alreadySelectedTimesPerDay = {
    "Saturday": {"12:00 AM", "1:00 AM"}, // Example initial data
    "Monday": {},  // Initialize other days as needed
    "Tuesday": {},
    // Add other days here
  };
// Track times that are already selected and should not be deselected
  var Phone = '';
  String PhoneErrorText = '';
  String SelectedTimeErrorText = '';
  String startTime = '9:00 AM'; // Example start time
  String endTime = '9:00 PM';   // Example end time
  List<User> users = []; // Your user list

// Call startendtime and get the time slots
  final NavigationController navigationController = Get.put(NavigationController());
  List<bool> _isCheckedList = [false, false, false, false, false];
  List<String> timeSlots = [];
  List<Map<String, DateTime>> selectedDates = [];
  String selectedDayName = '';

// Define tappedIndex at the beginning of your class
  int tappedIndex = 0;
  final List<String> _checkboxTexts = ['تأجير الكره:',];
  late AnimationController _animationController;

  String normalizeText(String text) {
    return text.trim(); // Trims any leading or trailing spaces
  }
  /// Function to format time in Arabic (with 'م' for PM or 'ص' for AM)
  String formatNumberInEnglish(int number) {
    return NumberFormat.decimalPattern('en').format(number);  // Formats number in English
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



  //funnnnnnnnnnnnnnnnnnnnnnnnnnnn
//Fetch all playground bookings
  Future<void> getAllPlaygrounds() async {
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

  }
  //Retrieve a playground by name
  Future<void> getPlaygroundbyname() async {
    CollectionReference playerchat = FirebaseFirestore.instance.collection("AddPlayground");
    QuerySnapshot querySnapshot = await playerchat.get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
        playgrounda.add(user);
        // Check if bookTypes is not null and has entries before accessing
        playgrounda.add(user);
        print("PlayGroung Id : ${document.id}"); // Print the latest playground

        print("allplaygrounds[i] : ${playgrounda.last}"); // Print the latest playground

        // Store the document ID in the AddPlayGroundModel object
        // user.id = document.id;
        user.id = document.id;
        print("Docummmmmm${user.id}"); // Print the latest playground
      }

      // Update the UI after loading data
      setState(() {
        if (playgrounda.isNotEmpty && playgrounda[0].bookTypes != null && playgrounda[0].bookTypes!.isNotEmpty) {
          String day1String = playgrounda[0].bookTypes![0].day ?? "No day data";
          cost = playgrounda[0].cost ?? "No cost data";

          // Generate days and dates
          _generateDaysAndDates(day1String);

          // Call startendtime if needed
          startendtime(startTime, endTime);
          _handleTap(0);
        }
      });
    }

  }

  void _generateDaysAndDates(String day1String) {
    DateTime today = DateTime.now();
    DateTime day1 = _getNextDayOfWeek(day1String, today);

    // Assuming day2 is calculated similarly or fetched
    DateTime day2 = day1.add(Duration(days: 6)); // Example; change logic as needed

    // Loop through the days from Day1 to Day2
    for (DateTime day = day1; day.isBefore(day2) || day.isAtSameMomentAs(day2); day = day.add(Duration(days: 1))) {
      String dayName = _getDayName(day);
      dayss.add(dayName);
      datees.add(day);
    }
  }

  void _loadUserData() async {
    await _fetchData();
    setState(() {
      // This triggers a rebuild of the current page with the updated values
    });


  }
//Send booking data to Firestore
  Future<void> _sendData(BuildContext context) async {
    final name = NameController.text;
    final phoneNumber = phoneController.text;

    if (name.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        selectedTimes.isNotEmpty &&
        selectedDates.isNotEmpty) {
      final selectedDate = selectedDates.last['date'];
      if (selectedDate != null && datees.contains(selectedDate)) {


        // Merge selectedTimes into the already selected times for the specific day
        alreadySelectedTimesPerDay[selectedDayName] =
        (alreadySelectedTimesPerDay[selectedDayName] ?? {})
          ..addAll(selectedTimes);
        String formattedDate =
        intl.DateFormat('yyyy-MM-dd').format(selectedDate);

        final bookingModel = AddbookingModel(
          Name: name,
          phoneCommunication: phoneNumber,
          rentTheBall: _isCheckedList[0],
          selectedTimes: selectedTimes.toList(),
          notavailable: alreadySelectedTimesPerDay[selectedDayName]?.toList(),
          dateofBooking: formattedDate,
          Day_of_booking: selectedDayName,
        );

        // Add to Firestore
        await FirebaseFirestore.instance
            .collection('booking')
            .add(bookingModel.toMap());

        await _fetchData();
        // Clear after booking
        selectedTimes.clear();
        NameController.clear();
        phoneController.clear();
        _isCheckedList[0] = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل البيانات بنجاح', // "Data registered successfully"
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
      }
    }
  }
//Fetch booking data and manage the selected times for each day
  Future<void> _fetchData() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('AddPlayground').get();

      List<AddbookingModel> bookings = snapshot.docs.map((doc) {
        return AddbookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Initialize the map to store selected times per day
      Map<String, Set<String>> fetchedSelectedTimesPerDay = {};

      // Loop through each booking and add its selected times to the correct day
      for (var booking in bookings) {
        String day = booking.Day_of_booking ?? 'Unknown'; // Replace with correct day field
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
        alreadySelectedTimesPerDay = fetchedSelectedTimesPerDay;
        print("alreadySelectedTimesPerDay: $alreadySelectedTimesPerDay");
      });
      setState(() {
        // This triggers a rebuild of the current page with the updated values
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }
//end of funnnnnnnnnnnnnnnnnnnnnnn
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

  void _handleTap(int index) {
    // Save the selected day and date to the list
    selectedDates.add({'date': datees[index]});
    selectedDayName = intl.DateFormat.EEEE().format(datees[index]);
    print("Selected Dates: $selectedDates");
    print("Selected Day Name: $selectedDayName");
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

  List<String> startendtime(String startTimeStr, String endTimeStr) {
    List<String> timeSlots = [];

    try {
      DateTime startTime = Jiffy.parse(startTimeStr, pattern: 'h:mm a').dateTime;
      DateTime endTime = Jiffy.parse(endTimeStr, pattern: 'h:mm a').dateTime;

      intl.DateFormat timeFormat = intl.DateFormat.jm();

      DateTime currentTime = startTime;

      while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
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

  void initState() {
    super.initState();
    print(" Get.off(HomePage()); // Navigate to HomePage${widget.IdData}");
    _loadUserData();
    getAllPlaygrounds();
    getPlaygroundbyname();
    initializeDateFormatting('ar', null).then((_) {
      // Now the locale data is ready, and you can safely use DateFormat in Arabic
    });
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
    // String startTime = '9:00 AM'; // Example start time
    // String endTime = '5:00 PM';   // Example end time
    // Get today's date
    DateTime today = DateTime.now();

    // List to store days and their corresponding dates
    List<Map<String, String>> daysOfWeek = [];

    // Loop to get the next 7 days (including today)
    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));

      // Format day name and date
      String dayName = DateFormat('EEEE').format(day); // Full day name, e.g., Monday
      String dayDate = DateFormat('dd').format(day); // Date in day number format, e.g., 21

      // Add to the list as a map
      daysOfWeek.add({'dayName': dayName, 'dayDate': dayDate});
    }
    // Call startendtime and get the time slots
    List<String> timeSlots = startendtime(startTime,endTime);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  playgrounda.isNotEmpty
                      ? LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 125,
                                viewportFraction: 0.27, // Adjust this value as needed
                                initialPage: _currentIndex, // Start with the center item
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index; // Update the current index on page change
                                  });
                                },
                                scrollDirection: Axis.horizontal,
                              ),
                              items: daysOfWeek.map((dayInfo) {
                                int itemIndex = daysOfWeek.indexOf(dayInfo); // Get the index of the item

                                return GestureDetector(
                                  onTap: () {
                                    print("Tapped on ${dayInfo['dayName']} - ${dayInfo['dayDate']}");
                                    setState(() {
                                      _currentIndex = itemIndex; // Update the current index when an item is tapped
                                    });
                                  },
                                  child: Center(
                                    child: IntrinsicHeight(
                                      child: Container(

                                        width: 87,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(17),
                                            bottomLeft: Radius.circular(17),
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),

                                          color: _currentIndex == itemIndex ? Colors.green.shade500 : Colors.transparent, // Highlight with green if selected
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              IntrinsicHeight(
                                                child: Container(
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
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            dayInfo['dayName']!, // Display day name
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: 'Cairo',
                                                              fontSize: 10.0,
                                                              fontWeight: FontWeight.w700,
                                                              color: Color(0xFF334154),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 4,),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            dayInfo['dayDate']!, // Display formatted date
                                                            style: TextStyle(
                                                              fontFamily: 'Cairo',
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.w700,
                                                              color: Color(0xFF495A71),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 18.0,left: 12),
                                                child: Container(
                                                  height: 2.5, // Height of the green color section
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(22),
                                                      bottomLeft: Radius.circular(22),
                                                    ),
                                                    color: _currentIndex == itemIndex ? Colors.green.shade500 : Colors.transparent, // Green color if selected
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                      : Center(child: Text("No Playground added yet ")),


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

                  // Ensure playgrounda is not empty and time1/time2 are available
                  // Conditionally display time slots
                  playgrounda.isNotEmpty && playgrounda[0].bookTypes![0].time!= null
                  //     playgrounda[0].bookTypes![0].time!= null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _generateRows(
                        timeSlots, selectedTimes, alreadySelectedTimesPerDay ,selectedDayName),
                  )
                      : Container(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:'  جنية  ' +' ${cost}'  ,
                              // النص الذي تريد جعله أبهت
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFFB0B0B0), // لون أبهت
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            TextSpan(
                              text: '   : تأجير الكره', // النص الأساسي
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71), // اللون الأساسي
                                fontWeight: FontWeight.w700,
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
                    onTap: () async {
                      // Check if any of the required fields are empty
                      if (NameController.text.isEmpty) {
                        // Show a SnackBar with the error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'برجاء ادخال جميع البيانات',
                              // "Please enter all the data"
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: Color(0xFF1F8C4B),
                          ),
                        );

                        isLoading = false;
                      } else {
                        // Show the loading indicator
                        setState(() {
                          isLoading = true;
                        });

                        // If validation passes, send data to Firebase
                        try {
                          await _sendData(
                              context); // Ensure this function is async and handles Firebase operations
                          // After successful data sending, navigate to the ConfirmInformationPlayGround screen
                          await getAllPlaygrounds();
                          await _fetchData();

                          setState(() {
                            // This triggers a rebuild of the current page with the updated values
                          });

                        } catch (e) {
                          // Show an error SnackBar if data sending fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'حدث خطأ أثناء إرسال البيانات. حاول مرة أخرى.',
                                // "An error occurred while sending data. Please try again."
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          // Hide the loading indicator in both success and error cases
                          setState(() {
                            isLoading = false;
                            _fetchData();
                          });
                        }
                      }
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


                  IntrinsicHeight(
                    child: Container(
                      child: Wrap(
                        children: List.generate(playgroundbook.length, (index) {
                          final user = playgroundbook[index];
                          return Dismissible(
                              key: Key(user.phoneCommunication.toString()), // Ensure the key is unique
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                // Update the list to remove the item
                                setState(() {
                                  playgroundbook.removeAt(index);
                                });

                                // Optionally show a snackbar or perform another action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Item dismissed")),
                                );
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
                                      right: 22.0, left: 22, bottom: 22),
                                  child: Dismissible(
                                      key: Key(user.phoneCommunication.toString()), // Use a unique key for each item
                                      direction: DismissDirection.horizontal,

                                      onDismissed: (direction) {
                                        setState(() {
                                          // Remove the item from the list
                                          users.removeAt(index);  // Remove the dismissed user
                                        });
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
                                                              padding: const EdgeInsets.only(right: 8, left: 8,bottom: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    playgroundbook[index].dateofBooking ?? "No booking date",
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontFamily: 'Cairo',
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Color(0xFF7D90AC),
                                                                    ),
                                                                  ),

                                                                  SizedBox(width: 5,),
                                                                  Text(
                                                                    playgroundbook[index].Day_of_booking ?? "No booking day",
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontFamily: 'Cairo',
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Color(0xFF7D90AC),
                                                                    ),
                                                                  ),

                                                                ],
                                                              )

                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 8, left: 8),
                                                              child: Text(
                                                                "Total cost".tr,
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
                                                              text: TextSpan(
                                                                style: TextStyle(
                                                                  fontFamily: 'Cairo',
                                                                  fontSize: 14.0,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Color(0xFF7D90AC),
                                                                ),
                                                                children: [
                                                                  for (var i = 0; i < playgroundbook[index].selectedTimes!.length; i++)
                                                                    TextSpan(
                                                                      text: getTimeRange(playgroundbook[index].selectedTimes![i]) + '\n', // Add formatted time range
                                                                    ),
                                                                ],
                                                              ),
                                                            )
                                                          ]),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]),

                                      ))));
                        }),
                      ),
                    ),
                  ),



                  ///@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@222
                  // IntrinsicHeight(
                  //   child: Container(
                  //     child: Wrap(
                  //       children: List.generate(playgroundbook.length, (index) {
                  //         final user = playgroundbook[index];
                  //         return Dismissible(
                  //           key: Key(user.phoneCommunication.toString()), // Use a unique key for each item
                  //           direction: DismissDirection.horizontal,
                  //           onDismissed: (direction) {
                  //             // You can handle the dismissal here if needed
                  //           },
                  //           background: Container(
                  //             color: Colors.red, // Background color when swiped
                  //             child: Align(
                  //               alignment: Alignment.centerLeft,
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(16.0),
                  //                 child: Image(
                  //                   image: AssetImage("assets/images/trush-square.png"),
                  //                   width: 40.0,
                  //                   height: 40.0,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           secondaryBackground: Container(
                  //             color: Colors.red, // Background color when swiped
                  //             child: Align(
                  //               alignment: Alignment.centerRight,
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(16.0),
                  //                 child: Image(
                  //                   image: AssetImage("assets/images/trush-square.png"),
                  //                   width: 40.0,
                  //                   height: 40.0,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.only(
                  //                 right: 22.0, left: 22, top: 16, bottom: 1),
                  //             child: Container(
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(20.0),
                  //                 color: Color(0xFFF0F6FF),
                  //                 boxShadow: [
                  //                   BoxShadow(
                  //                     color: Colors.grey.withOpacity(0.5),
                  //                     spreadRadius: 1,
                  //                     blurRadius: 2,
                  //                     offset: Offset(0, 0),
                  //                   ),
                  //                 ],
                  //               ),
                  //               child: Row(
                  //                 children: [
                  //                   ClipRRect(
                  //                     borderRadius: BorderRadius.only(
                  //                       topRight: Directionality.of(context) ==
                  //                           TextDirection.rtl
                  //                           ? Radius.circular(20.0)
                  //                           : Radius.zero,
                  //                       bottomRight: Directionality.of(context) ==
                  //                           TextDirection.rtl
                  //                           ? Radius.circular(20.0)
                  //                           : Radius.zero,
                  //                       topLeft: Directionality.of(context) ==
                  //                           TextDirection.ltr
                  //                           ? Radius.circular(20.0)
                  //                           : Radius.zero,
                  //                       bottomLeft: Directionality.of(context) ==
                  //                           TextDirection.ltr
                  //                           ? Radius.circular(20.0)
                  //                           : Radius.zero,
                  //                     ),
                  //                     child: Container(
                  //                       color: Color(0xFFB3261E),
                  //                       height: 75,
                  //                       width: 44,
                  //                       child: Padding(
                  //                         padding: const EdgeInsets.all(8.0),
                  //                         child: Container(
                  //                           height: 24,
                  //                           child: Image(
                  //                             image: AssetImage(
                  //                                 "assets/images/trush-square.png"),
                  //                             color: Colors.white,
                  //                             width: 24.0,
                  //                             height: 24.0,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: 10,
                  //                   ),
                  //                   Expanded(
                  //                     child: Padding(
                  //                       padding: const EdgeInsets.all(8.0),
                  //                       child: Column(
                  //                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                         children: [
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               user.dateofBooking!.isNotEmpty
                  //                                   ? Text(
                  //                                 (user.Day_of_booking != null &&
                  //                                     user.Day_of_booking!.length > 5)
                  //                                     ? "${user.Day_of_booking!.substring(0, 3)}.. : ${user.dateofBooking}"
                  //                                     : (user.Day_of_booking ?? 'No date'),
                  //                                 style: TextStyle(
                  //                                   fontSize: 16.0,
                  //                                   fontWeight: FontWeight.w700,
                  //                                   color: Color(0xFF7D90AC),
                  //                                 ),
                  //                               )
                  //                                   : Container(),
                  //                               Padding(
                  //                                 padding:
                  //                                 const EdgeInsets.only(right: 8, left: 8),
                  //                                 child: Text(
                  //                                   cost ?? 'No date',
                  //                                   textAlign: TextAlign.center,
                  //                                   style: TextStyle(
                  //                                     fontSize: 21.0,
                  //                                     fontWeight: FontWeight.w700,
                  //                                     color: Color(0xFF7D90AC),
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(
                  //                                 user.selectedTimes!.length > 2
                  //                                     ? '${user.selectedTimes!.first}, ..., ${user.selectedTimes!.last}'
                  //                                     : user.selectedTimes!.join(', '),
                  //                                 style: TextStyle(
                  //                                   fontSize: 12.0,
                  //                                   fontWeight: FontWeight.w400,
                  //                                   color: Color(0xFF7D90AC),
                  //                                 ),
                  //                               ),
                  //                               Padding(
                  //                                 padding:
                  //                                 const EdgeInsets.only(right: 8, left: 8),
                  //                                 child: Text(
                  //                                   "Total cost".tr,
                  //                                   textAlign: TextAlign.center,
                  //                                   style: TextStyle(
                  //                                     fontSize: 10.0,
                  //                                     fontWeight: FontWeight.w700,
                  //                                     color: Color(0xFF7D90AC),
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       }),
                  //     ),
                  //   ),
                  // ),
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
    );
  }
  Future<Widget> _generateTimeSlotWidget(
      String slot,
      bool isSelected,
      bool isAlreadySelected // Change Set<String> to bool
      ) async
  {
    // Check if a document with the same Day_of_booking and selectedTimes already exists
    final existingBookingQuery = FirebaseFirestore.instance
        .collection('booking')
        .where('Day_of_booking', isEqualTo: selectedDayName)
        .where('selectedTimes', arrayContainsAny: [slot]);

    final existingBookings = await existingBookingQuery.get();
    bool isTimeSlotBooked = existingBookings.docs.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
          color: selectedTimes.contains(slot)
              ? Color(0xFFC3FFDC)
              : isTimeSlotBooked
              ? Color(0xFFFFBEC5)
              : Color(0xFFEFF6FF), // Background color based on the condition
          borderRadius: BorderRadius.circular(10.0), // Radius of the corners
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


  List<Widget> _generateRows(
      List<String> timeSlots,
      Set<String> selectedTimes,
      Map<String, Set<String>> alreadySelectedTimesPerDay,
      String selectedDay
      )
  {
    List<Widget> rows = [];
    int index = 0;

    while (index < timeSlots.length) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < 3 && index < timeSlots.length; j++, index++) {
        String slot = timeSlots[index];
        bool isSelected = selectedTimes.contains(slot);

        // Check if the time slot is already booked for the selected day
        bool isAlreadySelected =
            alreadySelectedTimesPerDay[selectedDay]?.contains(slot) ?? false;

        rowChildren.add(
            GestureDetector(
                onTap: () {
                  if (isAlreadySelected) {
                    _showBookingDetailsDialog(slot);
                  } else {
                    setState(() {
                      if (isSelected) {
                        selectedTimes.remove(slot);
                      } else {
                        selectedTimes.add(slot);
                      }
                    });
                  }
                },
                child: FutureBuilder<Widget>(
                  future: _generateTimeSlotWidget(slot, isSelected, isAlreadySelected), // Pass isAlreadySelected as bool
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return Container(); // or some other loading indicator
                    }
                  },
                )
            ));
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

}