import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home/HomePage.dart';
import '../Home/Userclass.dart';
import '../Splach/LoadingScreen.dart';
import 'OTP.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() {
    return SigninPageState();
  }
}

late AnimationController animationController;
late Animation<double> animation;
final PhoneController = TextEditingController();
final PasswordController = TextEditingController();

var Phone = '';
String PhoneErrorText = '';

class SigninPageState extends State<SigninPage>
    with SingleTickerProviderStateMixin {
  void validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        PhoneErrorText = ' يجب ادخال رقم التليفون *'.tr;

      });
    } else if (value.length < 11) {
      setState(() {
        PhoneErrorText = ' يجب أن يكون رقم الهاتف 11 رقمًا *'.tr;

      });
    } else {
      setState(() {

        PhoneErrorText = '';
      });
    }
  }
  bool isValidPhoneNumber(String phoneNumber) {

    String prefix = phoneNumber.substring(0, 2);
    if (prefix != '01' && prefix != '02' && prefix != '03' && prefix != '04') {
      return false;
    }

    if (phoneNumber.length != 11) {
      return false;
    }

    return true;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم التسجيل بنجاح',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
    }
    else{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2$phone',

        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
            print("Successfully signed in with auto-retrieval.");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.code}");
          if (e.code == 'invalid-phone-number') {
            print("The phone number entered is invalid!");
          }
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
  bool isLoading = false;
  late List<User1> user1 = [];

  Future<void> updatetoken( String tooken) async {
    CollectionReference usersRef = FirebaseFirestore.instance.collection('Users');

    try {
      QuerySnapshot querySnapshot = await usersRef.where('phone', isEqualTo: PhoneController.text).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        String existingfcm = documentSnapshot['fcm'];

        if (tooken == existingfcm) {
          print("Token is already up to date");
        } else {
          await documentSnapshot.reference.update({'fcm': tooken});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حفظ التعديل بنجاح',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xFF1F8C4B),
            ),
          );
          print('User  data updated successfully.');
        }
      } else {

        await usersRef.add({
          'phone': PhoneController.text,
          'fcm': tooken,
        });
        print('User  data added successfully.');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
  bool startsWith015or011(String input) {
    return input.startsWith('015') || input.startsWith('011');
  }

  void validatePhonefirebase(String value) async {
    CollectionReference playerchat = FirebaseFirestore.instance.collection('Users');
    QuerySnapshot querySnapshot = await playerchat.get();

    bool phoneFound = false;

    for (var doc in querySnapshot.docs) {
      if (doc['phone'] == value) {
        phoneFound = true;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('phone', value);
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        print("FCM Token: $token");
await updatetoken(token!);

          await verifyPhone(value);



      }
    }

    if (!phoneFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textAlign: TextAlign.center,
            'رقم الهاتف غير موجود برجاء عمل حساب'.tr,
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
  }
  bool isConnected=false;
  void _initialize() async {
    await checkInternetConnection();
    print("ggggg");
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

  @override
  void initState() {
    _initialize();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    Future.delayed(Duration(seconds: 2), () {});
    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Stack(
        children: [
           (isLoading == true)
              ? const Positioned(top: 0, child: Loading()): SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),

               child:     Column(
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
                                child: Image.asset('assets/images/splach.png'),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),
                    Center(
                      child: Text(
                        "تسجيل دخول".tr,
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
                                color: Colors.red.shade800,
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
                          color: Color(0xFF9AAEC9),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: PhoneController,
                              cursorColor:Color(0xFF064821),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                              ],
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.datetime,
                              textAlign: TextAlign.right,
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
                          color: Colors.red.shade900,
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
                        ),),
                    SizedBox(height: 5,),



                    GestureDetector(
                      onTap: () {
                        String phoneNumber = PhoneController.text;

                        if (phoneNumber.isEmpty ) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textAlign: TextAlign.center,
                                'يجب ادخال بيانات'.tr,
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
                        else if (!isValidPhoneNumber(phoneNumber)) {
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
                          validatePhonefirebase(phoneNumber);
                        }
                      },

                      child: Padding(
                        padding: const EdgeInsets.only(top: 190.0,right: 20,left: 20),
                        child: Container(
                          height: 50,
                          width: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            shape: BoxShape.rectangle,
                            color: Color(0xFF064821),
                          ),
                          child: Center(
                            child: Text(
                              "تسجيل دخول".tr,
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
                    SizedBox(height: 5,),
                    GestureDetector(
                      onTap: () {
                        setState(() {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        });
                      },

                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'إنشــــاء حســــــاب'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF32AE64),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF32AE64),
                            decorationThickness: 1.0,
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


        ],
      ),
    );
  }
}
