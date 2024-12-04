import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Controller/NavigationController.dart';
import '../Favourite_model/Favouritemodel.dart';
import '../Menu/menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../PlayGround_Name/PlayGroundName.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../StadiumPlayGround/ReloadData/AppBarandBtnNavigation.dart';
import '../my_reservation/my_reservation.dart';
import '../notification/notification_page.dart';
import '../playground_model/AddPlaygroundModel.dart';
class FavouritePage extends StatefulWidget {
  @override
  State<FavouritePage> createState() {
    return FavouritePageState();
  }
}

class FavouritePageState extends State<FavouritePage> {
  final NavigationController navigationController = Get.put(NavigationController());
  late List<AddPlayGroundModel> allplaygrounds = [];
  String idddddd='';
  bool _isLoading = true;
  List<Favouritemodel>favlist=[];
  User? user = FirebaseAuth.instance.currentUser;
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
  String useridddd="";
  fetchfavofgrounddatabyid(Favouritemodel ground) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('AddPlayground').doc(ground.playground_id).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null ) {
          print("grounddaaaaaaaaaaaaatafav$data");
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
  Future<void> getfavdata(String playgroundid) async {
    try {
      CollectionReference fav =
      FirebaseFirestore.instance.collection("Favourite");

      QuerySnapshot querySnapshot = await fav.where('playground_id',isEqualTo: playgroundid).get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          Favouritemodel favourite = Favouritemodel.fromMap(userData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String Phone011=prefs.getString('phonev')??'';
          print("phone011$Phone011");
          if(Phone011.toString()!=null&&Phone011.isNotEmpty){
            CollectionReference uuuserData = FirebaseFirestore.instance.collection('Users');

            QuerySnapshot adminSnapshot = await uuuserData.where('phone', isEqualTo:Phone011.toString()).get();
            print('shared phooone ${Phone011.toString()}');
            if(adminSnapshot.docs.isNotEmpty){
              var adminDoc = adminSnapshot.docs.first;
              String docId = adminDoc.id;
              print("Matched user docId: $docId");
              useridddd=docId;
              Map<String, dynamic>? user =   await fetchfavofgrounddatabyid(favourite);
              favourite.playground_name=user!['groundName'];
              favourite.img=user['img'][0];
              print("image of rate ${user['img'][0]}");
              if (favourite.userid ==useridddd) {
                if(favlist.contains(playgroundid)){
                  print("this id already added to favourite list");
                }else{
                  favlist.add(favourite);
                  print("Fav Id : ${document.id}");
                  print('Fav list: $favlist');
                  print("allplaygrounds[i]fff : ${favourite.playground_name}");
                  favourite.id = document.id;
                  print("favouriteid${favourite.id}");
                  print("favourite${favourite.playground_id}");
                }

              } else {
                print("this user not have favourite playground");
              }
            }
          }
         else if(user?.phoneNumber!=null){
            print("user${user?.phoneNumber}");
            CollectionReference uuuserData = FirebaseFirestore.instance.collection('Users');
            String? normalizedPhoneNumber = user?.phoneNumber!.replaceFirst('+20', '0');
            QuerySnapshot adminSnapshot = await uuuserData.where('phone', isEqualTo:normalizedPhoneNumber).get();
            print('shared phooone ${normalizedPhoneNumber}');
            if(adminSnapshot.docs.isNotEmpty){
              var adminDoc = adminSnapshot.docs.first;
              String docId = adminDoc.id;
              print("Matched user docId: $docId");
              useridddd=docId;
              Map<String, dynamic>? user =   await fetchfavofgrounddatabyid(favourite);
              favourite.playground_name=user!['groundName'];
              favourite.img=user['img'][0];
              print("image of rate ${user['img'][0]}");
              if (favourite.userid ==useridddd) {
                if(favlist.contains(playgroundid)){
                  print("this id already added to favourite list");
                }else{
                  favlist.add(favourite);
                  print("Fav Id : ${document.id}");
                  print('Fav list: $favlist');
                  print("allplaygrounds[i] : ${favourite}");
                  favourite.id = document.id;
                  print("favouriteid${favourite.id}");
                  print("favourite${favourite.playground_id}");
                }

              } else {
                print("this user not have favourite playground");
              }
            }
          }

        }
        print("All Fav list: $favlist");
      }
    } catch (e) {
      print("Error getting playground: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    getPlaygroundbyname();
  }
  fetchrateofgrounddatabyid(Favouritemodel ground) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot docSnapshot =
      await firestore.collection('AddPlayground').doc(ground.playground_id).get();

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
  Future<void> getPlaygroundbyname() async {
    try {
      CollectionReference playerchat =
      FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
          AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);

          allplaygrounds.add(user);
          print("PlayGroung Id : ${document.id}");

          print("allplaygrounds[i] : ${allplaygrounds.last}");

          user.id = document.id;
          getfavdata(user.id!);

        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: EdgeInsets.only(top: 25.0,right: 8,left: 8),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'المفضلات',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                height: 29.98 / 16,
                letterSpacing: 0.04,
                color:  Color(0xFF334154),
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Get.back();

              },
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios_new_rounded,
                size: 24,
                color:  Color(0xFF62748E),
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
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Image.asset('assets/images/notification.png', height: 24, width: 24,),

                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        index: 3,
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
              Get.to(() => AppBarandNavigationBTN())?.then((_) {
                navigationController.updateIndex(2);
              });
              break;
            case 3:
              break;
          }
        },
      ),

      body:isConnected? _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4AD080),))
          : SingleChildScrollView(
        child: Center(
          child:favlist.isNotEmpty? Column(
            children: [
              SizedBox(height: 10,),
              for (var i = 0; i < favlist.length; i++)
                GestureDetector(
                  onTap: (){
                    print("favlist${favlist[i].playground_id}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaygroundName(favlist[i].playground_id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 23,left: 23,top: 8),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 4,
                        child: Stack(
                          children: [
                            Container(

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                shape: BoxShape.rectangle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child:CachedNetworkImage(
                                  imageUrl:
                                  favlist[i].img!,
                                  height: 163,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 0,
                              left: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0x1F8C4B).withOpacity(0.0),
                                      Color(0x1F8C4B).withOpacity(1.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 113,
                              right: 40,
                              left: 55,
                              child: Text(
                                favlist[i].playground_name!,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.83,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ):Center(
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

                            Opacity(
                              opacity: 0.5,
                              child: Image.asset(
                                "assets/images/bro.png",
                                width: 200,
                                height: 200,
                              ),
                            ),
                            Text(
                              'لم يتم اضافة ملاعب بعد',
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
        ),
      ):                        _buildNoInternetUI()



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