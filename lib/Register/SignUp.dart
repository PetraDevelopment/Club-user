
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() {
    return SignUpPageState();
  }
}

late AnimationController animationController;
late Animation<double> animation;
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneNumberController = TextEditingController();
bool _isNavigating = false;

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
var Phone = '';

class SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {

  bool isLoading = false;
  File? selectedImages;
  String img_profile = "";

  String NameErrorTxT ='';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد اتصال بالانترنت',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
      setState(() {
        isConnected = false;
        print("bvbbvbvbb$isConnected");
      });
    }else{
      isConnected = true;

    }
    print("bvbbvbvbb$isConnected");

  }
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  String errorrr='';
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
      var connectivityResult = await (Connectivity().checkConnectivity());
      print("connectivityResult$connectivityResult");
      print("connectivityResult${ConnectivityResult.none}");
      if (connectivityResult[0] == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يوجد اتصال بالانترنت',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
        print("لا يوجد اتصال بالانترنت");
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
            isLoading = false; // Stop the loading state immediately
            if (e.code == 'invalid-phone-number') {
              errorrr = 'invalid-phone-number';
              _showErrorSnackbar('The phone number entered is invalid.');
            } else if (e.code == 'billing-not-enabled') {
              errorrr = 'billing-not-enabled';
              _showErrorSnackbar('Billing is not enabled for this project.');
            } else {
              errorrr = 'unknown-error';
              _showErrorSnackbar('${e.message}');

            }
            setState(() {}); // Update UI to reflect the stopped loading state
          },

          codeSent: (String verificationId, int? forceResendingToken) async {
            if (errorrr.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTP(verificationId, phone, '', ''),
                ),
              );
            } else {
              isLoading = false; // Stop loading if there's an error
              _showErrorSnackbar('Cannot proceed due to billing error.');
            }
            setState(() {}); // Update the UI
          },
          codeAutoRetrievalTimeout: (String verificationID) {
            print("Auto retrieval timeout for verification ID: $verificationID");
          },
          timeout: const Duration(seconds: 60),
        );
      }


    }

  }
  Future<void> validatePhonefirebase(String value, BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("connectivityResult$connectivityResult");
    print("connectivityResult${ConnectivityResult.none}");
    if (connectivityResult[0] == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يوجد اتصال بالانترنت',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
      print("لا يوجد اتصال بالانترنت");
    }else{
      CollectionReference playerChat = FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerChat.where('phone', isEqualTo: value).get();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('phone', value);
      print('shared phone ${prefs.getString('phone') ?? ''}');
      if (querySnapshot.docs.isNotEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'هذا الحساب موجود بالفعل برجاء تسجيل الدخول',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
        _nameController.clear();
        _phoneNumberController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SigninPage()),
        );
        print('Phone number exists, navigating to Sign-in page');
      }
      else {


      if(x>0)  {
        _sendData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'برجاء الانتظار',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );


        await verifyPhone(value.trim());
      }


      }
    }
  }
  Future<void> takePhoto() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImages = File(pickedFile.path);
        print("selectedImagesselectedImagesselectedImages${selectedImages}");
        img_profile = pickedFile.path;
print('img_profileimg_profile$img_profile');
        setState(() {

        });
      });
    }
  }
int x=0;
  Future<File?> pickImageFromGallery() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<void> uploadImagesAndSaveUrls() async {
    setState(() {
      x=0;
    });
    File? image = await pickImageFromGallery();
    if (image == null) return;
    setState(() {
      selectedImages = image;
      img_profile = "";
    });

    try {
      String downloadUrl = await _uploadImage(image);
      setState(() {
        img_profile = downloadUrl;
        x++;
        print("prinnnnt$x");
      });

      print("Image uploaded successfully: $downloadUrl");
    } catch (e) {
      print("Failed to upload image: $e");

    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('Users/$fileName');

    await storageRef.putFile(image);
    String downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl;
  }
  void _sendData() async {


    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    print("FCM Token: $token");
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {

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
      return;
    }
    else if(name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب ادخال الاسم',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      isLoading=false;
    }
    else if( phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب ادخال رقم التليفون',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      isLoading=false;

    }
    else if(selectedImages == null
        && img_profile == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب ادخال الصورة',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      isLoading=false;

    }
    else if(token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ فى ارسال الtoken',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFF1F8C4B),
        ),
      );
      isLoading=false;

    }
   else{

      DocumentReference docRef = await FirebaseFirestore.instance.collection('Users').add({
        'name': name,
        'phone': phoneNumber,
        'profile_image': img_profile,
        'fcm':token
      });

      String docId = docRef.id;
      print("Document ID: $docId");
      _nameController.clear();
      _phoneNumberController.clear();
      selectedImages=null;
      img_profile="";
   }


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
      body: Stack(
        children: [
          (isLoading == true)
              ? const Positioned(top: 0,bottom: 0, child: Loading()):   SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15,right: 22,left: 22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
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
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: (){
                            _showImageSourceDialog();
                          },
                          child: Container(
                            width: 140,
                            height: 160.72,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Align(
                                      alignment: Alignment.topCenter,
                                      child: selectedImages == null
                                          ? img_profile == ""
                                          ? ClipOval(
                                            child: Container(
                                                                                    width: 200,
                                                                                    height: 164,
                                                                                    color: Color(0xFFDCDCDC),
                                                                                    
                                                                                    child: Image.asset('assets/images/profile.png',width: 100,height: 102,),
                                                                                  ),
                                          )
                                          : Container(
                                        width: 200,
                                        height: 164,
                                        color: Color(0xFFDCDCDC),
                                            child: ClipOval(
                                              child: Image(
                                            image: NetworkImage(img_profile),
                                            width: 200,
                                            height: 164,
                                            fit: BoxFit.fitWidth,
                                                                                    ),
                                                                                  ),
                                          )
                                          : ClipOval(
                                          child: Image.file(
                                            selectedImages!,
                                            height: 200,
                                            width: 164,
                                            fit: BoxFit.cover,
                                          ))
                                  ),
                                ),
                                Positioned(
                                  top: 108,
                                  left: 110,
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      shape: BoxShape.rectangle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),

                                          spreadRadius: 0,

                                          blurRadius: 5,

                                          offset: Offset(0,
                                              0),
                                        ),
                                      ],
                                    ),
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        _showImageSourceDialog();

                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                      backgroundColor: Color(0xFF064821),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30),
                                      ),

                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),

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
                          color: Color(0xFF9AAEC9),
                          width: 1.0,
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
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'الأسم'.tr,
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF495A71),
                                ),
                                border: InputBorder.none,
                              ),

                              onEditingComplete: () async {

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
                        "برجاء ادخال الاسم",
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12.0,
                          fontFamily: 'Cairo',
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
                              controller: _phoneNumberController,
                              cursorColor: Color(0xFF064821),
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
                        ),
                      ),
                    SizedBox(
                      height: 50,
                    ),


                    GestureDetector(
                      onTap: () async {
                        var connectivityResult = await (Connectivity().checkConnectivity());
                        print("connectivityResult$connectivityResult");
                        print("connectivityResult${ConnectivityResult.none}");
                        if ( connectivityResult[0]== ConnectivityResult.none) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'لا يوجد اتصال بالانترنت',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Color(0xFF1F8C4B),
                            ),
                          );
                          print("لا يوجد اتصال بالانترنت");
                        }
                        else if(_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يجب ادخال الاسم',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          isLoading=false;
                        }
                        else if(_phoneNumberController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يجب ادخال رقم التليفون',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          isLoading=false;

                        }
                        else if(selectedImages == null
                            && img_profile == "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يجب ادخال الصورة',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          isLoading=false;

                        }
                     else{
                          if (_nameController.text.isEmpty &&
                              _phoneNumberController.text.isEmpty &&img_profile==""&&selectedImages==null) {
                            setState(() {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'برجاء ادخال جميع البيانات',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Color(0xFF1F8C4B),
                                ),
                              );

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
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          else {
                            setState(() {

                              isLoading = true;
                            });
                            if (!_isNavigating) {
                              _isNavigating = true;

                              await validatePhonefirebase(_phoneNumberController.text.trim(), context);

                              _isNavigating = false;
                            }

                            setState(() {

                              isLoading = true;
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 120.0, right: 20, left: 20),
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
                              'إنشــــاء حســــــاب'.tr,
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SigninPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "تسجيل دخول".tr,
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر مصدر الصورة',textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Icon(Icons.camera_alt_outlined,color: Color(0xFF064821),),
                  onPressed: () {
                    Navigator.of(context).pop();
                    takePhoto();
                  },
                ),
                TextButton(
                  child:  Icon(Icons.photo_library_outlined,color:Color(0xFF064821)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                   await uploadImagesAndSaveUrls();
                  },
                ),
              ],)
          ],
        );
      },
    );
  }
}