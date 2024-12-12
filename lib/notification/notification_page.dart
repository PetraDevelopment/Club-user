
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../Home/Userclass.dart';
import '../../Menu/menu.dart';
import '../../Register/SignInPage.dart';
import '../../my_reservation/my_reservation.dart';
import '../My_group/my_group.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import 'model/send_modelfirebase.dart';

class Notification_page extends StatefulWidget {

  @override
  State<Notification_page> createState() {
    return Notification_pageState();
  }
}

class Notification_pageState extends State<Notification_page> with TickerProviderStateMixin {

  bool isLoading = false;
  String useridddd="";
  late List<User1> user1 = [];
  late List<NotificationModel> notificationlist = [];
  fetchgrounddatabyid(NotificationModel ground) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('AddPlayground').doc(ground.groundid).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;


        if (data != null ) {
          print("grounddaaaaaaaaaaaaata$data");
          return data;

        }
        else {
          print('FCMToken field is missing for this admin.');
        }
      } else {
        print('No document found with ID: $ground');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }
  User? user = FirebaseAuth.instance.currentUser;
  int selectedIndex=3;
  double opacity = 1.0;
  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var playerDoc = querySnapshot.docs.first;
        useridddd = playerDoc.id;
        print("Document ID for the Phoone number: $useridddd");
        await fetchnotificationdatabyid(useridddd);
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
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');
    print("newphoneValue${phoneValue.toString()}");

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
    }
    else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }
  bool isConnected=false;
  final NavigationController navigationController = Get.put(NavigationController());
int first =0;
  Future<void> fetchnotificationdatabyid(String userid) async {

      CollectionReference notificationdata =
      FirebaseFirestore.instance.collection("notification");

      QuerySnapshot anotificationdataSnapshot = await notificationdata
          .where('userid', isEqualTo: userid)
          .get();

      if (anotificationdataSnapshot.docs.isNotEmpty) {
        print('anotificationdataSnapshot.docs${anotificationdataSnapshot.docs.length}');
        for (int i = 0; i < anotificationdataSnapshot.docs.length; i++) {
          var docData = anotificationdataSnapshot.docs[i].data() as Map<String, dynamic>;
          String docId = anotificationdataSnapshot.docs[i].id;
          NotificationModel notification = NotificationModel.fromMap(docData);
if(notification.adminreply==true){
  Map<String, dynamic>? Grounddata =   await fetchgrounddatabyid(notification);
  notification.groundname = Grounddata!['groundName'];
  notificationlist.add(notification);

  print("Notification data: ${docData}");
  notification.idd=docId;
  print("Document ID: $docId");
}

        }
      } else {
        first++;
        print('No notifications found for this userid.');
      }

  }
  Future<void> _updateclick( String docid) async {
    CollectionReference usersRef = FirebaseFirestore.instance.collection('notification');

    try {
      DocumentReference documentRef = usersRef.doc(docid);
      DocumentSnapshot documentSnapshot = await documentRef.get();

      if (documentSnapshot.exists) {
        print("hhhhhhhhclcik${documentSnapshot['click']}");
        if(documentSnapshot['click']==true){
          print('User data already clicked successfully.');
        }
      else{
          await documentRef.update({
            'click': true,
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Notification_page()),
          );
          print('User data update clicked successfully.');
        }


      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
  String convertTo12HourFormat(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
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
  void initState() {
    checkInternetConnection();
    _loadUserData();

    super.initState();

  }
int x=0;
  @override
  Widget build(BuildContext context) {
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
              "الأشعارات".tr,
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
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset(
                    'assets/images/notification.png', height: 28, width: 28,),
                ),
              ),
            ],
          ),
        ),
      ),
    body:notificationlist.isNotEmpty?SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15,),
            for(int x=0;x<notificationlist.length;x++)
            GestureDetector(
              onTap: (){
                print("objectnotificationlist[x].idd!${notificationlist[x].idd!}");
                _updateclick(notificationlist[x].idd!);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 25.0, left: 25),
                child:

                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                       notificationlist[x].click==false?  Visibility(
                            child: Padding(
                              padding:  EdgeInsets.only(left: 5,right: 5),
                              child: Container(

                                child: ClipOval(
                                  child: Icon(
                                    Icons.circle,
                                    size: 15,
                                    color: Color(0xFFEB5757),
                                  ),
                                ),
                              ),
                            ),
                          ):Container(),
                       notificationlist[x].notificationType==1?
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                  Text('تم اضافة حجز ${ notificationlist[x].groundname!.length<7? notificationlist[x].groundname: notificationlist[x].groundname?.substring(0,7)} يوم ${ notificationlist[x].day} ${notificationlist[x].bookingtime.toString().substring(0,4)}', style: TextStyle(


                               fontSize: 14,
                               fontFamily: 'Cairo',
                               fontWeight:notificationlist[x].click==false? FontWeight.w700:FontWeight.w400,
                               color: Color(0xFF091C3F)
                           ),),
                           SizedBox(width: 12,),
                           Image.asset(
                             'assets/images/notification-bing.png.png',
                             height: 18,
                             width: 18,
                             fit: BoxFit.cover,
                           ),
                           SizedBox(width: 6,)
                         ],
                       ):
                       notificationlist[x].notificationType==2?
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [

                           Text('تم الغاء حجز '+'${ notificationlist[x].groundname!.length<7? notificationlist[x].groundname: notificationlist[x].groundname?.substring(0,7)}'+' '+'يوم'+' ' +'${ notificationlist[x].day}'+' '+'${notificationlist[x].bookingtime.substring(0,4)}', style: TextStyle(
                               fontSize: 14,
                               fontFamily: 'Cairo',
                               fontWeight:notificationlist[x].click==false? FontWeight.w700:FontWeight.w400,
                               color: Color(0xFF091C3F)
                           ),),
                           SizedBox(width: 12,),
                           Image.asset(
                             'assets/images/notification-bing.png.png',
                             height: 18,
                             width: 18,
                             fit: BoxFit.cover,
                           ),
                           SizedBox(width: 6,)
                         ],
                       ): notificationlist[x].notificationType==3?
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                  Text('تم تأكيد حجز '+'${ notificationlist[x].groundname!.length<7? notificationlist[x].groundname: notificationlist[x].groundname?.substring(0,7)}'+' '+'يوم'+' ' +'${ notificationlist[x].day}'+' '+'${notificationlist[x].bookingtime.substring(0,4)}', style: TextStyle(


                               fontSize: 14,
                               fontFamily: 'Cairo',
                               fontWeight:notificationlist[x].click==false? FontWeight.w700:FontWeight.w400,
                               color: Color(0xFF091C3F)
                           ),),
                           SizedBox(width: 12,),
                           Image.asset(
                             'assets/images/notification-bing.png.png',
                             height: 18,
                             width: 18,
                             fit: BoxFit.cover,
                           ),
                           SizedBox(width: 6,)
                         ],
                       ): notificationlist[x].notificationType==4?
                       GestureDetector(
                         onTap: (){
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => PlaygroundName(notificationlist[x].groundid),
                               settings: RouteSettings(arguments: {
                                 'from': 'notification'
                               }),
                             ),
                           );
                         },
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [

                             Text('تم اضافة ملعب '+'${ notificationlist[x].groundname!.length<5? notificationlist[x].groundname: notificationlist[x].groundname?.substring(0,5)}'+' '+'يوم'+' ' +'${ notificationlist[x].day}', style: TextStyle(

                             fontSize: 14,
                                 fontFamily: 'Cairo',
                                 fontWeight:notificationlist[x].click==false? FontWeight.w700:FontWeight.w400,
                                 color: Color(0xFF091C3F)
                             ),),
                             SizedBox(width: 12,),
                             Image.asset(
                               'assets/images/notification-bing.png.png',
                               height: 18,
                               width: 18,
                               fit: BoxFit.cover,
                             ),
                             SizedBox(width: 6,)
                           ],
                         ),
                       ): notificationlist[x].notificationType==5?
                       GestureDetector(
                         onTap: (){
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => My_group(),
                             ),
                           );
                         },
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [

                             Text('تم اضافتك فى مجموعه ', style: TextStyle(
                                 fontSize: 14,
                                 fontFamily: 'Cairo',
                                 fontWeight:notificationlist[x].click==false? FontWeight.w700:FontWeight.w400,
                                 color: Color(0xFF091C3F)
                             ),),
                             SizedBox(width: 12,),
                             Image.asset(
                               'assets/images/notification-bing.png.png',
                               height: 18,
                               width: 18,
                               fit: BoxFit.cover,
                             ),
                             SizedBox(width: 6,)
                           ],
                         ),
                       ):Container(),

                        ],
                      )
                      ),
                      Padding(
                        padding:  EdgeInsets.only(right: 34.0,top: 5),
                        child: Text('${notificationlist[x].time}'+'  '+'${notificationlist[x].date}', style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 0),
                        child: Divider(

                          color: Colors.grey.shade300,

                          thickness:
                          1,
                        ),
                      ),
                    ]
                            ),
                        ),
            )
          ],
        ),
      )
        :first>0?Center(
    child: SizedBox(
    height: MediaQuery.of(context).size.height/4,
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
    "assets/images/notification_zero.png",
    width: 156.96,
    height: 134.16,
    ),
    ),
    Text(
    'لا يوجد أشعارات حتى الان',
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
    ):Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height/4,
        child: Stack(
          children: [
            Center(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          "assets/images/notification_zero.png",
                          width: 156.96,
                          height: 134.16,
                        ),
                      ),
                      Opacity(
                        opacity: 0.2,
                        child: Text(
                          'لا يوجد أشعارات حتى الان',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.62,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF181A20),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: CurvedNavigationBar(
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
      ),
    );
  }



}

