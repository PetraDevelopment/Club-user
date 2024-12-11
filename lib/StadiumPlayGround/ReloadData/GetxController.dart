import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../PlayGround_Name/PlayGroundName.dart';
import '../../playground_model/AddPlaygroundModel.dart';
class SportsController extends GetxController {
  RxString selectedCategory = "كرة قدم".obs;
  RxBool isConnected = true.obs;
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    print("connectivityResult: $connectivityResult");

    if (connectivityResult[0] == ConnectivityResult.none) {
      isConnected.value = false;
    } else {
      isConnected.value = true;
    }

    print("Internet connection status: ${isConnected.value}");
  }
  var sportData = <Widget>[].obs;
  late List<AddPlayGroundModel> allplaygrounds = [];
  late List<AddPlayGroundModel> volybool = [];
  late List<AddPlayGroundModel> basketball = [];
  late List<AddPlayGroundModel> football = [];
  late List<AddPlayGroundModel> tennis = [];
  final _isLoading = true.obs;

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    _isLoading.value = false;
  }
  @override
  void onInit() {
    super.onInit();
    checkInternetConnection();
    _loadData();
    selectedCategory.value = "كرة قدم";
    fetchSportData("كرة قدم");
    getPlaygroundbyname();

  }
int first=0;
  void selectCategory(String category) {
    selectedCategory.value = category;
    checkInternetConnection();
    fetchSportData(category);
  }

  Future<void> getPlaygroundbyname() async {
    try {
      checkInternetConnection();
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
    fetchSportData("كرة قدم");

    String playType = user.playType!.trim();

    if (playType == "كرة طائرة") {
      volybool.add(user);
    } else if (playType == "كرة قدم") {
      football.add(user);
    } else if (playType == "كرة تنس") {
      tennis.add(user);
    } else if (playType == "كرة سلة") {
      basketball.add(user);
    }

    user.id = document.id;
  }

      }else{
  first++;
}
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  void fetchSportData(String category) {
    sportData.clear();
    for (var i = 0; i < allplaygrounds.length; i++) {
      if (i < volybool.length && volybool[i].playType == category) {
        sportData.addAll([

          _buildStadiumCard(
            volybool[i].img![0],
            '${volybool[i].playgroundName}',volybool[i].id!
          ),

        ]);
      }
      if (i < football.length && football[i].playType == category) {
        sportData.addAll([

          _buildStadiumCard(
            football[i].img![0],
            '${football[i].playgroundName}',football[i].id!
          ),

        ]);

      }
      if (i < basketball.length && basketball[i].playType == category) {
        sportData.addAll([

          _buildStadiumCard(
            basketball[i].img![0],
            '${basketball[i].playgroundName}',basketball[i].id!,
          ),
        ]);
      }
      if (i < tennis.length && tennis[i].playType == category) {
        sportData.addAll([

          _buildStadiumCard(
            tennis[i].img![0],
            '${tennis[i].playgroundName}', tennis[i].id!,
          ),

        ]);
      }
    }

  }

  Widget _buildStadiumCard(String? imagePath, String title,String id) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0,bottom: 5,right: 20,left: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {

          final width = constraints.maxWidth;
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  PlaygroundName(id),
                  settings: RouteSettings(arguments: {
                    'from': 'playground'
                  }),
                ),
              );

              print("Document ID: $id");
            },
            child: Stack(
              children: [
                Obx(
                        () => _isLoading.value
                        ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: width,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28.0),
                          color: Color(0xFFF0F6FF),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child:ClipRRect(
                          borderRadius: BorderRadius.circular(28.0),
                          child: imagePath != null
                              ? Image.network(
                            imagePath,
                            width: width,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            "assets/images/newground.png",
                            fit: BoxFit.cover,
                          ),),
                      ),
                    )
                        :Container(
                      width: width,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.0),
                        color: Color(0xFFF0F6FF),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: imagePath != null
                            ? Image.network(
                          imagePath,
                          width: width,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          "assets/images/newground.png",
                          fit: BoxFit.cover,
                        ),),
                    )
                ),
                Positioned(
                  top: 0,
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
                        bottomLeft: Radius.circular(28.0),
                        bottomRight: Radius.circular(28.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 20,
                  left: 20,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}