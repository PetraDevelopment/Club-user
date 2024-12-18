// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import '../Home/HomePage.dart';
// import '../Splach/LoadingScreen.dart';
//
// class OTP extends StatefulWidget {
//   String verificationId;
//   String phone;
//   String type;
//   String name;
//
//   OTP(this.verificationId, this.phone, this.type, this.name, {super.key});
//
//   @override
//   State<OTP> createState() {
//     return OTPState(phone);
//   }
// }
//
//
//
// Future<void> verifyOtp(String verificationId, String otp, BuildContext context) async {
//   final AuthCredential credential = PhoneAuthProvider.credential(
//     verificationId: verificationId,
//     smsCode: otp,
//   );
//
//
//
//   try {
//     final UserCredential userCredential =
//     await FirebaseAuth.instance.signInWithCredential(credential);
//     final User? user = userCredential.user;
//
//     // Handle successful sign-in
//     print('User signed in: $user');
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'تم تسجيل الدخول بنجاح',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontFamily: 'Cairo',
//             fontSize: 15.0,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         backgroundColor:Color(0xFF1F8C4B),
//       ),
//     );
//
//   } catch (e) {
//     // Handle specific errors
//     print('Error signing in: $e');
//
//     // Example of handling quota exceeded error
//     if (e.toString().contains('quota for this operation has been exceeded')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'تجاوز الحد الأقصى لعدد المحاولات. يرجى المحاولة مرة أخرى لاحقًا.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Cairo',
//               fontSize: 15.0,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           backgroundColor: Color(0xFF1F8C4B),
//         ),
//       );
//     } else {
//       // Handle other errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'خطأ: الرمز غير صحيح. يرجى التأكد من الرمز والمحاولة مرة أخرى.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Cairo',
//               fontSize: 15.0,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
//
//
// String? _verificationId;
//
// class OTPState extends State<OTP>  with SingleTickerProviderStateMixin{
//   TextEditingController controller = TextEditingController(); // Add this line
//   String? otpcode;
//   late int _counter = 60;
//   late Timer _timer;
//   late List<TextEditingController> _controller;
//   String phone;
//   bool isLoading = false;
//
//   OTPState(this.phone);
//
// /////////
//   Future<dynamic> SignUpStudent() async {
//     String? tokenFCM =
//     await FirebaseMessaging.instance.getToken();
//     print("tokenFCM$tokenFCM");
//     // Check internet connectivity
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) {
//       // Not connected to any network
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'لا يوجد اتصال بالإنترنت'.tr,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Cairo',
//               fontSize: 15.0,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           backgroundColor: Color(0xFF1F8C4B),
//         ),
//       );
//       return;
//     }
//   }
//
//   Future<dynamic> LoginStudent() async {
//     // Check internet connectivity
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) {
//       // Not connected to any network
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'لا يوجد اتصال بالإنترنت'.tr,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Cairo',
//               fontSize: 15.0,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           backgroundColor: Color(0xFF1F8C4B),
//         ),
//       );
//       return null;
//     }
//     String? tokenFCM =
//     await FirebaseMessaging.instance.getToken();
//     print("tokenFCM$tokenFCM");
//     // Prepare user data
//   }
//   String phonewithstars='';
//   @override
//   void initState() {
//     String numericPart = widget.phone.replaceAll(RegExp(r'\D'), '');
//
//     // Mask the middle digits
//     String maskedNumber = numericPart.substring(0, 1) + // أول رقم
//         '*******' + // سبع نجوم لإخفاء الأرقام الوسطى
//         numericPart.substring(numericPart.length - 3); // آخر 3 أرقام
//
//     // اجعل الرقم المعروض مضافًا له 2+ كما هو مطلوب
//     phonewithstars = '+2 ' + maskedNumber;
//
//     print("maskedNumber: $maskedNumber"); // Output: 6*******010
//     print("phonewithstars: $phonewithstars"); // Output: 2+ 6*******010
//
//     _controller = List<TextEditingController>.generate(
//       6,
//           (index) => TextEditingController(),
//     );
//
//     _startTimer();
//     super.initState();
//   }
//
//   // @override
//   // void initState() {
//   //   String numericPart = widget.phone.replaceAll(RegExp(r'\D'), '');
//   //
//   //   // Mask the middle digits
//   //   String maskedNumber = numericPart.substring(0, 3) +
//   //       '*******' +
//   //       numericPart.substring(numericPart.length - 1);
//   //
//   //   String reversedNumericPart = maskedNumber.split('').reversed.join('');
//   //   phonewithstars = reversedNumericPart; // Assign the reversed maskedNumber to phonewithstars
//   //   print("maskedNumber$maskedNumber"); // Output: 01*******9
//   //   print("phonewithstars$phonewithstars"); // Output: 9*******10
//   //
//   //   _controller = List<TextEditingController>.generate(
//   //     6,
//   //         (index) => TextEditingController(),
//   //   );
//   //
//   //   _startTimer();
//   //   super.initState();
//   // }
//   void _startTimer() {
//     const oneSecond = Duration(seconds: 1);
//     _timer = Timer.periodic(oneSecond, (timer) {
//       if (!mounted) {
//         timer.cancel(); // Cancel the timer if the widget is no longer in the widget tree
//         return;
//       }
//
//       if (_counter > 0) {
//         setState(() {
//           _counter--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   Future<void> sendOtp(String phoneNumber) async {
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: '+2$phoneNumber', // Ensure correct format
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           print('Auto-signed in with credential');
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           print('Verification failed: ${e.message}');
//           if (e.code == 'invalid-phone-number') {
//             // Handle invalid phone number
//           }
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           print('Code sent: $verificationId');
//
//           // Save verificationId to use in OTP verification
//           // Navigate to OTP page
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           print('Code auto-retrieval timeout: $verificationId');
//         },
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       print('Error sending OTP: $e');
//     }
//   }
//   TextEditingController otpController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: false,
//       body:  Stack(
//           children: [
//             SingleChildScrollView(
//               child: Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.only(top: 65.0),
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         child: Container(
//                           width: 135,
//                           height: 160.72,
//                           child: Image.asset('assets/images/splach.png'),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16,),
//
//                     Center(
//                         child: Text(
//                             'رمز التحقيق'.tr,
//                             style: TextStyle(
//                               color: Color(0xFF1F8C4B),
//                               fontFamily: 'Cairo',
//                               fontSize: 24.0,
//                               fontWeight: FontWeight.w700,
//                             ))),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 48.0,right: 48,left: 48,bottom: 15),
//                       child: Center(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               'لقد أرسلنا الرمز إلى'.tr,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16.15,
//                                 fontFamily: 'Cairo',
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//
//                             Text(
//                               '$phonewithstars' +'   '+ 'الرقم'.tr,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: 'Cairo',
//                                 color:Colors.green.shade600,
//                                 fontSize: 15.0,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20.0),
//                     Directionality(
//                       textDirection: TextDirection.ltr,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 18.0),
//                         child: PinCodeTextField(
//                           controller: otpController,
//                           textStyle: const TextStyle(
//                             fontSize: 20,
//                             fontFamily: 'Inter-SemiBold',
//                           ),
//                           hintCharacter: '0',
//                           hintStyle: const TextStyle(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 24,
//                             fontFamily: 'Inter-SemiBold',
//                             color: Color(0xff8198A5),
//                           ),
//                           appContext: context,
//                           length: 6,
//                           blinkWhenObscuring: true,
//                           animationType: AnimationType.fade,
//                           pinTheme: PinTheme(
//                             shape: PinCodeFieldShape.box,
//                             borderRadius: BorderRadius.circular(15), // Adjust radius here
//                             fieldHeight: 53,
//                             fieldWidth: 53,
//                             borderWidth: 0,
//                             activeFillColor: Colors.grey.shade600,
//                             inactiveColor:  Color(0xFF9AAEC9),
//                             selectedColor: Color(0xFF9AAEC9),
//                             activeColor: Color(0xFF9AAEC9),
//                             selectedFillColor: Colors.grey,
//                           ),
//                           cursorColor: const Color(0xff001D4A),
//                           animationDuration: const Duration(milliseconds: 300),
//                           keyboardType: TextInputType.number,
//                           onCompleted: (String pin) {
//                             otpcode = pin;
//                             // Callback when all the fields are filled
//                             print("Completed: $pin");
//                             // You can add your verification logic here
//                           },
//                           onChanged: (String value) {
//                             // Optional: handle changes in the text field
//                           },
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         padding: EdgeInsets.only(right: 8.0, top: 5.0, bottom: 30),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             _counter != 0
//                                 ? Row(
//                               children: [
//                                 Text(
//                                   '${'ثانية   '.tr}',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontFamily: 'Cairo',
//                                     fontSize: 12.32,
//                                     color: Colors.green.shade600,
//                                     fontWeight: FontWeight.normal,
//                                   ),
//                                 ),
//                                 Text(
//                                   '$_counter',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontFamily: 'Cairo',
//                                     fontSize: 12.32,
//                                     color: Colors.green.shade600,
//                                     fontWeight: FontWeight.normal,
//                                   ),
//                                 )
//                               ],
//                             )
//                                 : GestureDetector(
//                               onTap: () {
//                                 sendOtp(phone);
//                                 // FirebaseAuth.instance.currentUser!
//                                 //     .sendEmailVerification();
//                                 setState(() {
//                                   _counter = 60;
//                                   _startTimer();
//                                   otpController.clear();
//                                 });
//                               },
//                               child: Text(
//                                 '${'اعادة الارسال'.tr}',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'Cairo',
//                                   fontSize: 12.32,
//                                   color: Colors.green.shade600,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               'لم يتبق سوى '.tr,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: 'Cairo',
//                                 fontSize: 12.32,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//
//                           ],
//                         ),
//                       ),
//                     ),
//                     _counter!=0? Padding(
//                       padding: const EdgeInsets.only(
//                           top: 120.0, left: 31.46, right: 31.46),
//                       child: Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Center(
//                           child: Container(
//                             alignment: Alignment.bottomCenter,
//                             child: SizedBox(
//                               width: 300,
//                               height: 66,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 22.0),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30.0),
//                                     ),
//                                     backgroundColor: Color(0xFF064821), // Background color
//                                   ),
//                                   onPressed: () async {
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//
//                                     try {
//                                       // Verify the OTP code
//                                       final credential = PhoneAuthProvider.credential(
//                                         verificationId: widget.verificationId,
//                                         smsCode: otpcode!,
//                                       );
//                                       print('FCM otpcode: $otpcode');
//
//                                       await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
//                                         // Get FCM token
//                                         String? tokenFCM = await FirebaseMessaging.instance.getToken();
//                                         print('FCM Token: $tokenFCM');
//
//                                         // Get SharedPreferences instance
//                                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                                         await prefs.setString("studentphone", phone.toString());
//
//                                         // Show success message
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               "تم تسجيل الدخول بنجاح".tr,
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 fontFamily: 'Cairo',
//                                                 fontSize: 15.0,
//                                                 fontWeight: FontWeight.normal,
//                                               ),
//                                             ),
//                                             backgroundColor: Color(0xFF1F8C4B),
//                                           ),
//
//                                         );
//                                         // await prefs.setString("phoneotp", phone.toString());
//                                         // Call appropriate function based on type
//                                         if (widget.type == "login") {
//                                           LoginStudent();
//                                         } else {
//                                           SignUpStudent();
//                                         }
//
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => HomePage(),
//                                           ),
//                                         );
//
//
//
//                                       }).catchError((error) {
//                                         // Print error details
//                                         print('Error during sign-in: $error');
//
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               'خطأ: الرمز غير صحيح'.tr,
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 fontFamily: 'Cairo',
//                                                 fontSize: 15.0,
//                                                 fontWeight: FontWeight.normal,
//                                               ),
//                                             ),
//                                             backgroundColor: Color(0xFF1F8C4B),
//                                           ),
//                                         );
//                                       });
//                                     } catch (e) {
//                                       // Print error details
//                                       print('Exception: $e');
//
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'حدث خطأ أثناء التحقق من الرمز', // "An error occurred while verifying the code"
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               fontFamily: 'Cairo',
//                                               fontSize: 15.0,
//                                               fontWeight: FontWeight.normal,
//                                             ),
//                                           ),
//                                           backgroundColor: Color(0xFF1F8C4B),
//                                         ),
//                                       );
//                                     } finally {
//                                       setState(() {
//                                         isLoading = false;
//                                       });
//                                     }
//                                   },
//                                   child: Text(
//                                     'تأكيــــــد'.tr,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontFamily: 'Cairo',
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ):Container(),
//                     SizedBox(
//                       height: 35,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             (isLoading == true)
//                 ? const Positioned(top: 0, child: Loading())
//                 : Container(),
//           ]
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Home/HomePage.dart';
import '../Splach/LoadingScreen.dart';

class OTP extends StatefulWidget {
  String verificationId;
  String phone;
  String type;
  String name;

  OTP(this.verificationId, this.phone, this.type, this.name, {super.key});

  @override
  State<OTP> createState() {
    return OTPState(phone);
  }
}



Future<void> verifyOtp(String verificationId, String otp, BuildContext context) async {
  final AuthCredential credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: otp,
  );



  try {
    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    // Handle successful sign-in
    print('User signed in: $user');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تسجيل الدخول بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor:Color(0xFF1F8C4B),
      ),
    );

  } catch (e) {
    // Handle specific errors
    print('Error signing in: $e');

    // Example of handling quota exceeded error
    if (e.toString().contains('quota for this operation has been exceeded')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تجاوز الحد الأقصى لعدد المحاولات. يرجى المحاولة مرة أخرى لاحقًا.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ: الرمز غير صحيح. يرجى التأكد من الرمز والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


String? _verificationId;

class OTPState extends State<OTP>  with SingleTickerProviderStateMixin{
  TextEditingController controller = TextEditingController(); // Add this line
  String? otpcode;
  late int _counter = 60;
  late Timer _timer;
  late List<TextEditingController> _controller;
  String phone;
  bool isLoading = false;

  OTPState(this.phone);

/////////
  Future<dynamic> SignUpStudent() async {
    String? tokenFCM =
    await FirebaseMessaging.instance.getToken();
    print("tokenFCM$tokenFCM");
    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Not connected to any network
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  Future<dynamic> LoginStudent() async {
    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Not connected to any network
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
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
    String? tokenFCM =
    await FirebaseMessaging.instance.getToken();
    print("tokenFCM$tokenFCM");
    // Prepare user data
  }
  String phonewithstars='';
  @override
  void initState() {
    String numericPart = widget.phone.replaceAll(RegExp(r'\D'), '');

    // Mask the middle digits
    String maskedNumber = numericPart.substring(0, 1) + // أول رقم
        '*******' + // سبع نجوم لإخفاء الأرقام الوسطى
        numericPart.substring(numericPart.length - 3); // آخر 3 أرقام

    // اجعل الرقم المعروض مضافًا له 2+ كما هو مطلوب
    phonewithstars = '+2 ' + maskedNumber;

    print("maskedNumber: $maskedNumber"); // Output: 6*******010
    print("phonewithstars: $phonewithstars"); // Output: 2+ 6*******010

    _controller = List<TextEditingController>.generate(
      6,
          (index) => TextEditingController(),
    );

    _startTimer();
    super.initState();
  }

  // @override
  // void initState() {
  //   String numericPart = widget.phone.replaceAll(RegExp(r'\D'), '');
  //
  //   // Mask the middle digits
  //   String maskedNumber = numericPart.substring(0, 3) +
  //       '*******' +
  //       numericPart.substring(numericPart.length - 1);
  //
  //   String reversedNumericPart = maskedNumber.split('').reversed.join('');
  //   phonewithstars = reversedNumericPart; // Assign the reversed maskedNumber to phonewithstars
  //   print("maskedNumber$maskedNumber"); // Output: 01*******9
  //   print("phonewithstars$phonewithstars"); // Output: 9*******10
  //
  //   _controller = List<TextEditingController>.generate(
  //     6,
  //         (index) => TextEditingController(),
  //   );
  //
  //   _startTimer();
  //   super.initState();
  // }
  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (!mounted) {
        timer.cancel(); // Cancel the timer if the widget is no longer in the widget tree
        return;
      }

      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2$phoneNumber', // Ensure correct format
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          print('Auto-signed in with credential');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          if (e.code == 'invalid-phone-number') {
            // Handle invalid phone number
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent: $verificationId');

          // Save verificationId to use in OTP verification
          // Navigate to OTP page
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }
  TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body:  Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 65.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 135,
                          height: 160.72,
                          child: Image.asset('assets/images/splach.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),

                    Center(
                        child: Text(
                            'رمز التحقيق'.tr,
                            style: TextStyle(
                              color: Color(0xFF1F8C4B),
                              fontFamily: 'Cairo',
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0,right: 48,left: 48,bottom: 15),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'لقد أرسلنا الرمز إلى'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.15,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            Text(
                              '$phonewithstars' +'   '+ 'الرقم'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color:Colors.green.shade600,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: PinCodeTextField(
                          controller: otpController,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Inter-SemiBold',
                          ),
                          hintCharacter: '0',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            fontFamily: 'Inter-SemiBold',
                            color: Color(0xff8198A5),
                          ),
                          appContext: context,
                          length: 6,
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(15), // Adjust radius here
                            fieldHeight: 53,
                            fieldWidth: 53,
                            borderWidth: 0,
                            activeFillColor: Colors.grey.shade600,
                            inactiveColor:  Color(0xFF9AAEC9),
                            selectedColor: Color(0xFF9AAEC9),
                            activeColor: Color(0xFF9AAEC9),
                            selectedFillColor: Colors.grey,
                          ),
                          cursorColor: const Color(0xff001D4A),
                          animationDuration: const Duration(milliseconds: 300),
                          keyboardType: TextInputType.number,
                          onCompleted: (String pin) {
                            otpcode = pin;
                            // Callback when all the fields are filled
                            print("Completed: $pin");
                            // You can add your verification logic here
                          },
                          onChanged: (String value) {
                            // Optional: handle changes in the text field
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.only(right: 8.0, top: 5.0, bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _counter != 0
                                ? Row(
                              children: [
                                Text(
                                  '${'ثانية   '.tr}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.32,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '$_counter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.32,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              ],
                            )
                                : GestureDetector(
                              onTap: () {
                                sendOtp(phone);
                                // FirebaseAuth.instance.currentUser!
                                //     .sendEmailVerification();
                                setState(() {
                                  _counter = 60;
                                  _startTimer();
                                  otpController.clear();
                                });
                              },
                              child: Text(
                                '${'اعادة الارسال'.tr}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.32,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              'لم يتبق سوى '.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.32,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    _counter!=0? Padding(
                      padding: const EdgeInsets.only(
                          top: 120.0, left: 31.46, right: 31.46),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Center(
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: 300,
                              height: 66,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 22.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    backgroundColor: Color(0xFF064821), // Background color
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      // Verify the OTP code
                                      final credential = PhoneAuthProvider.credential(
                                        verificationId: widget.verificationId,
                                        smsCode: otpcode!,
                                      );
                                      print('FCM otpcode: $otpcode');

                                      await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                        // Get FCM token
                                        String? tokenFCM = await FirebaseMessaging.instance.getToken();
                                        print('FCM Token: $tokenFCM');

                                        // Get SharedPreferences instance
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        await prefs.setString("studentphone", phone.toString());

                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "تم تسجيل الدخول بنجاح".tr,
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
                                        await prefs.setString("phoneotp", phone.toString());
                                        // Call appropriate function based on type
                                        if (widget.type == "login") {
                                          LoginStudent();
                                        } else {
                                          SignUpStudent();
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                        );



                                      }).catchError((error) {
                                        // Print error details
                                        print('Error during sign-in: $error');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'خطأ: الرمز غير صحيح'.tr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      });
                                    } catch (e) {
                                      // Print error details
                                      print('Exception: $e');

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'حدث خطأ أثناء التحقق من الرمز', // "An error occurred while verifying the code"
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  child: Text(
                                    'تأكيــــــد'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ):Container(),
                    SizedBox(
                      height: 35,
                    ),
                  ],
                ),
              ),
            ),
            (isLoading == true)
                ? const Positioned(child: Loading())
                : Container(height: 5,),
          ]
      ),
    );
  }
}