import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home/HomePage.dart';
import '../Splach/LoadingScreen.dart';
import 'OTP.dart';
import 'SignInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() {
    return SignUpPageState();
  }
}

late AnimationController animationController;
late Animation<double> animation;
//save data to firebase
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneNumberController = TextEditingController();
bool _isNavigating = false; // Flag to prevent multiple navigation calls


// Function to check if a phone number is valid
bool isValidPhoneNumber(String phoneNumber) {
  // Check if the phone number starts with a valid prefix (e.g., 01, 02, etc.)
  String prefix = phoneNumber.substring(0, 2);
  if (prefix != '01' && prefix != '02' && prefix != '03' && prefix != '04') {
    return false;
  }

  // Check if the phone number has a valid length (e.g., 11 digits)
  if (phoneNumber.length != 11) {
    return false;
  }

  return true;
}
var Phone = '';

class SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  //send data to firebase

  bool isLoading = false;

  String NameErrorTxT ='';

  void validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        PhoneErrorText = ' يجب ادخال رقم التليفون *'.tr;
        // isLoading=false;
      });
    } else if (value.length < 11) {
      setState(() {
        PhoneErrorText = ' يجب أن يكون رقم الهاتف 11 رقمًا *'.tr;
        // isLoading=false;
      });
    } else {
      setState(() {
        // isLoading=false;
        PhoneErrorText = ''; // No error message for 3-letter names
      });
    }
  }
  Future<void> verifyPhone(String phone) async {
    print('verificationIddd  ' + '+2$phone');
    if(phone.startsWith("011")||phone.startsWith("015")){
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('phonev','+2$phone');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
    else{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2$phone',

        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
            print("Successfully signed in with auto-retrieval.");
            // You might want to navigate directly to the home page or similar
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.code}");
          if (e.code == 'invalid-phone-number') {
            print("The phone number entered is invalid!");
          }
          // Handle error
        },
        codeSent: (String verificationId, int? forceResendingToken) async {
          print('Verification code sent to $phone');
          isLoading=true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTP(verificationId, phone, '', ''),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          print("Auto retrieval timeout for verification ID: $verificationID");
        },
        timeout: const Duration(seconds: 60),
      );

    }
    setState(() {
      isLoading=true;
    });
  }
  Future<void> validatePhonefirebase(String value, BuildContext context) async {
    CollectionReference playerChat = FirebaseFirestore.instance.collection('Users');

    QuerySnapshot querySnapshot = await playerChat.where('phone', isEqualTo: value).get();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phone', value);
    print('shared phone ${prefs.getString('phone') ?? ''}');

    // Check if the phone number was found
    if (querySnapshot.docs.isNotEmpty) {
      // Phone number exists, navigate to the Sign-in page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذا الحساب موجود بالفعل برجاء تسجيل الدخول', // "This account already exists. Please sign in."
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
      print('Phone number exists, navigating to Sign-in page');
    } else {
      // Phone number does not exist, proceed to send data and call verifyPhone
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'برجاء الانتظار', // "Successfully registered"
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );

      _sendData(); // Function to send data to Firestore

      // Call verifyPhone to initiate OTP verification
      await verifyPhone(value.trim());  // Pass context here
    }
  }

  void _sendData() async {
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;

    final connectivityResult = await Connectivity().checkConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
      return; // No need to return null; just return to exit the method.
    }
    final storageRef = FirebaseStorage.instance.ref();
    final profileImageRef = storageRef.child('profile_images/$phoneNumber.png');

    // Load the image from the assets folder
    final bytes = await rootBundle.load('assets/images/profile.png');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/profile.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    // Upload the image to Firebase Storage
    await profileImageRef.putFile(file);

    // Get the download URL
    final downloadUrl = await profileImageRef.getDownloadURL();


    if (name.isNotEmpty && phoneNumber.isNotEmpty ) {
      // Add data to Firestore and get the document reference
      DocumentReference docRef = await FirebaseFirestore.instance.collection('Users').add({
        'name': name,
        'phone': phoneNumber,
        'profile_image':downloadUrl,
      });

      // Get the document ID of phone number
      String docId = docRef.id;
      print("Document ID: $docId");
      // prefs.setString('AdminId', docId);

      // Clear the text fields
      _nameController.clear();
      _phoneNumberController.clear();

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

  @override
  void initState() {
    // Define animation controller
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    );
    Future.delayed(Duration(seconds: 2), () {});

    // Define animation
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    // confirmPasswordController.dispose();
    // _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 65.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 135,
                          height: 160.72,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: animation.value,
                                child: Image.asset('assets/images/registerphoto.png'),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),
                    Center(
                      child: Text(
                        'إنشــــاء حســــــاب'.tr,
                        style: TextStyle(
                          color: Color(0xFF1F8C4B),
                          fontFamily: 'Cairo',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF495A71)
                        ),
                        children: [
                          WidgetSpan(
                            child: Text(
                              '  *  ',
                              style: TextStyle(
                                color: Colors.red.shade800, // Red color for the asterisk
                              ),
                            ),
                          ),
                          TextSpan(
                            text: 'الأسم ',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        shape: BoxShape.rectangle,
                        color: Colors.white70,
                        border: Border.all(
                          color: Color(0xFF9AAEC9), // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child:TextField(
                              controller: _nameController,
                              cursorColor: Color(0xFF064821),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.right, // Align text to the right
                              decoration: InputDecoration(
                                hintText: 'الأسم'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),

                              onEditingComplete: () async {
                                // Move focus to the next text field
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Image.asset(
                              'assets/images/name.png',
                              height: 19,
                              width: 19,
                              color: Color(0xFF495A71),
                            ),

                          ),
                        ],
                      ),
                    ),
                    if (_nameController.text.length >0 && _nameController.text.length <2)
                      Text(
                        // textAlign: TextAlign.end,
                        "برجاء ادخال الاسم",
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    //passssssssssssssssssssword
                    SizedBox(
                      height: 12,
                    ),
                    RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF495A71)
                        ),
                        children: [
                          WidgetSpan(
                            child: Text(
                              '  *  ',
                              style: TextStyle(
                                color: Colors.red.shade800, // Red color for the asterisk
                              ),
                            ),
                          ),
                          TextSpan(
                            text: 'رقم التليفون ',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        shape: BoxShape.rectangle,
                        color: Colors.white70,
                        border: Border.all(
                          color: Color(0xFF9AAEC9), // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneNumberController,
                              cursorColor: Color(0xFF064821),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                              ],
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.datetime, // Updated keyboard type for phone input
                              textAlign: TextAlign.right, // Align text to the right
                              decoration: InputDecoration(
                                hintText: 'رقم التليفون'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                Phone = value;
                                print("phoneeee" + " " + Phone);
                                setState(() {
                                  validatePhone(value);
                                });
                              },
                              onSubmitted: (value) {
                                // Move focus to the next text field
                                // FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Image.asset(
                              'assets/images/call.png',
                              height: 19,
                              width: 19,
                              color: Color(0xFF495A71),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (PhoneErrorText.isNotEmpty)
                      Text(
                        PhoneErrorText,
                        style: TextStyle(
                          color: Colors.red.shade900, // Error message color
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),
                      ),


                    //passssssssssssssssssssword
                    SizedBox(
                      height: 50,
                    ),


                    GestureDetector(
                      onTap: () async {
                        // Check if any field is empty or if the passwords do not match
                        if (_nameController.text.isEmpty ||
                            _phoneNumberController.text.isEmpty ) {
                          setState(() {
                            // Show a SnackBar with the error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'برجاء ادخال جميع البيانات', // "Please enter all the data"
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Color(0xFF1F8C4B),
                              ),
                            );
                            // Ensure `isLoading` is set to false when there's a validation error
                            isLoading = false;
                          });
                        }
                        else if (!isValidPhoneNumber(_phoneNumberController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textAlign: TextAlign.center,
                                'رقم الهاتف غير صحيح'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: Color(0xFF1F8C4B),
                            ),
                          );
                        }

                        else {
                          setState(() {
                            // Clear any existing error message

                            isLoading = true;  // Set loading to true since we're starting an operation
                          });

                          // Prevent multiple navigation attempts
                          if (!_isNavigating) {
                            _isNavigating = true; // Set the flag to true

                            // Validate phone number in Firestore
                            await validatePhonefirebase(_phoneNumberController.text.trim(), context);

                            // Reset the flag after operation completes
                            _isNavigating = false;
                          }

                          setState(() {
                            isLoading = true;  // Set loading to false after the operation completes
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0, right: 20, left: 20),
                        child: Container(
                          height: 50,
                          width: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            shape: BoxShape.rectangle,
                            color: Color(0xFF064821), // Background color of the container
                          ),
                          child: Center(
                            child: Text(
                              'إنشــــاء حســــــاب'.tr,
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
                    SizedBox(height: 5,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SigninPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center, // Center the text within the container
                        child: Text(
                          "تسجيل دخول".tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF32AE64), // Text color
                            decoration: TextDecoration.underline, // Adds the underline
                            decorationColor: Color(0xFF32AE64), // Underline color to match text color
                            decorationThickness: 1.0, // Optional: Thickness of the underline
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                  ]
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
}