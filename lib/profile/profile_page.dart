import 'dart:io';

import 'package:club_user/Menu/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import 'package:image_picker/image_picker.dart';
import '../../Register/SignInPage.dart';
import '../../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../Favourite/Favourite_page.dart';
import '../Home/Userclass.dart';
import '../Splach/LoadingScreen.dart';
import '../my_reservation/my_reservation.dart';
import '../notification/notification_page.dart';

class Profilepage extends StatefulWidget {
  @override
  State<Profilepage> createState() {
    return ProfilepageState();
  }
}

class ProfilepageState extends State<Profilepage>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final NavigationController navigationController =
  Get.put(NavigationController());

  bool _isLoading = true;
  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  late List<User1> user1 = [];
  bool _isUploading = false;
  String img_profile = '';
  File? selectedImages;
  String previousName = '';
  String previousPhoneNumber = '';
  String userid='';
  Future<void> takePhoto() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImages = File(pickedFile.path);
      });
    }
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

  Future<void> uploadImagesAndSaveUrls() async {
    File? image = await pickImageFromGallery();
    if (image == null) return;

    setState(() {
      selectedImages = image;
    });

    String downloadUrl = await _uploadImage(image);
    print("downloadUrl$downloadUrl");
    img_profile = downloadUrl;
  }

  Future<File?> pickImageFromGallery() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageRef =
    FirebaseStorage.instance.ref().child('Users/$fileName');
    await storageRef.putFile(image);
    String downloadUrl = await storageRef.getDownloadURL();
    img_profile = downloadUrl;

    return downloadUrl;
  }

  Future<void> _storeImageUrls(String name, String phone,
      String profileImageUrl) async
  {
    CollectionReference usersRef =
    FirebaseFirestore.instance.collection('Users');

    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      String? token = await messaging.getToken();
      print("FCM Token: $token");
      DocumentReference documentRef = usersRef.doc(userid);
      DocumentSnapshot documentSnapshot = await documentRef.get();
      if (documentSnapshot.exists) {

        await documentSnapshot.reference.update({
          'fcm':token,
          'name': name,
          'phone': phone,
          'profile_image': profileImageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حفظ التعديل بنجاح',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF1F8C4B),
          ),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profilepage()),
          );
        print('User  data updated successfully.');
      } else {

        print('users document is not found');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<void> _updateName(String name) async {
    CollectionReference usersRef =
    FirebaseFirestore.instance.collection('Users');

    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      String? token = await messaging.getToken();
      print("FCM Token: $token");
      DocumentReference documentRef = usersRef.doc(userid);
      DocumentSnapshot documentSnapshot = await documentRef.get();

      String existingName = user1[0].name!;
      if (name == existingName) {
        print("Name is already up to date");
      }

      else {
        if (documentSnapshot.exists) {


          await documentSnapshot.reference.update({
            'fcm':token,
            'name': name,
            'phone': _phoneNumberController.text,
            'profile_image': img_profile,
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profilepage()),
          );
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
          setState(() {
            _isLoading = false;
          });
        }

        else {

          print('users document is not found');
        }
      }
    }
    catch (e) {
      print('Error updating user data: $e');
    }
  }

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
        userid= querySnapshot.docs.first.id;
        Map<String, dynamic> userData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        User1 user = User1.fromMap(userData);
        setState(() {
          user1.add(user);
          if (user1.isNotEmpty) {
            _phoneNumberController.text = user1[0].phoneNumber!;
            _nameController.text = user1[0].name!;
            previousName = _nameController.text;
            previousPhoneNumber = _phoneNumberController.text;
            img_profile = user1[0].img!;
          }
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
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _loadUserData();
    _loadData();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: EdgeInsets.only(top: 25.0, right: 8, left: 8),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "الملف الشخصى".tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Map<dynamic, dynamic>? arguments = ModalRoute
                    .of(context)
                    ?.settings
                    .arguments as Map<dynamic, dynamic>?;
                if (arguments != null && arguments['from'] == 'menu_page') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => menupage(),
                    ),
                  );
                }
                else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
              },
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: Color(0xFF62748E),
              ),
            ),
            actions: [
              GestureDetector(
                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Notification_page()),
                  );
                } ,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
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
      body:isConnected? Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
            children: [ SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 13.0, bottom: 13, right: 25, left: 25),
                child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: selectedImages == null
                                ? img_profile == ''
                                ? Container(
                              width: 164,
                              height: 164,
                              child: Image.asset(
                                "assets/images/profile.png",
                              ),
                            )
                                : ClipOval(
                              child: Image(
                                image: NetworkImage(img_profile),
                                width: 164,
                                height: 164,
                                fit: BoxFit.fitWidth,
                              ),
                            )
                                : ClipOval(
                                child: Image.file(
                                  selectedImages!,
                                  height: 164,
                                  width: 164,
                                  fit: BoxFit.cover,
                                ))

                        ),
                      ),
                      Positioned(

                        top: MediaQuery.of(context).size.height/6.2,
                        left: MediaQuery.of(context).size.width/1.8,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),

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
                  SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)),
                          children: [
                            TextSpan(
                              text: 'الأسم ',
                            ),
                          ],
                        ),
                      ),
                      Text("")
                    ],
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

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20.0,left: 5),
                          child: Image.asset(
                            'assets/images/name.png',
                            height: 19,
                            width: 19,
                            color: Color(0xFF495A71),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            cursorColor: Color(0xFF064821),
                            // textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.start,

                            decoration: InputDecoration(
                              hintText: 'الأسم'.tr,
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF495A71),
                              ),
                              border: InputBorder.none,
                            ),

                            // onEditingComplete: () async {
                            //
                            //   FocusScope.of(context).nextFocus();
                            // },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_nameController.text.length > 0 &&
                      _nameController.text.length < 2)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF495A71)),
                          children: [
                            TextSpan(
                              text: 'رقم التليفون ',
                            ),
                          ],
                        ),
                      ),
                      Text(""),
                    ],
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
                        Container(
                          margin: EdgeInsets.only(right: 20.0,left: 5),

                          child: Image.asset(
                            'assets/images/call.png',
                            height: 19,
                            width: 19,
                            color: Color(0xFF495A71),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneNumberController,
                            readOnly: true,
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

                            },
                            onSubmitted: (value) {

                            },
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
                    height: 100,
                  ),


                  GestureDetector(
                    onTap: () async {


                        bool hasChanges = false;

                        if (_nameController.text != previousName ||
                            _phoneNumberController.text !=
                                previousPhoneNumber ||
                            selectedImages != null) {
                          hasChanges = true;
                        }

                        if (hasChanges) {
                          setState(() {
                            _isLoading = true;
                          });

                          await _updateName(_nameController.text);
                          await  getUserByPhone(_phoneNumberController.text);
                          if (selectedImages != null) {
                            String downloadUrl = await _uploadImage(
                                selectedImages!);
                            await _storeImageUrls(_nameController.text,
                                _phoneNumberController.text, downloadUrl);

                            setState(() {
                              img_profile = downloadUrl;
                            });
                          }


                          await getUserByPhone(_phoneNumberController.text);
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'لا يوجد بيانات لحفظها',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Color(0xFF1F8C4B),
                            ),
                          );
                          print('No changes made');
                        }

                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50.0, right: 20, left: 20),
                      child: Container(
                        height: 50,
                        width: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          shape: BoxShape.rectangle,
                          color: Color(
                              0xFF064821),
                        ),
                        child: Center(
                          child: Text(
                            'حفــــــظ'.tr,
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
                  SizedBox(
                    height: 5,
                  ),
                ]),
              ),
            ),
              (_isLoading == true)
                  ? const Positioned(child: Loading())
                  : Container(height: 5,),

            ]
        ),):  _buildNoInternetUI(),
        bottomNavigationBar:_isLoading == false? CurvedNavigationBar(
        height: 60,
        index: 0,

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
              .updateIndex(index);

          switch (index) {
            case 0:

              break;
            case 1:
              Get.to(() => my_reservation())?.then((_) {
                navigationController
                    .updateIndex(1);
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
      ):Loading(),
    );
  }

  Future<bool> handleBackNavigation() async {
    int currentIndex = NavigationController().currentIndex.value;

    if (currentIndex == 3) {
      return true;
    } else {
      NavigationController().updateIndex(3);
      Get.off(HomePage());
      return false;
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'اختر مصدر الصورة', textAlign: TextAlign.center, style: TextStyle(
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
                  child: Icon(
                    Icons.camera_alt_outlined, color: Color(0xFF064821),),
                  onPressed: () {
                    Navigator.of(context).pop();
                    takePhoto();
                  },
                ),
                TextButton(
                  child: Icon(
                      Icons.photo_library_outlined, color: Color(0xFF064821)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    uploadImagesAndSaveUrls();
                  },
                ),
              ],)
          ],
        );
      },
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