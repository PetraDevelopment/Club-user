import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../PlayGround_Name/PlayGroundName.dart';
import '../../playground_model/AddPlaygroundModel.dart';
class SportsController extends GetxController {
  // Observable variable for the current selected category
  RxString selectedCategory = 'كرة قدم'.obs; // Initialize with "كرة قدم"

  var sportData = <Widget>[].obs; // List of widgets
  late List<AddPlayGroundModel> allplaygrounds = [];
  late List<AddPlayGroundModel> volybool = [];
  late List<AddPlayGroundModel> basketball = [];
  late List<AddPlayGroundModel> football = [];
  late List<AddPlayGroundModel> tennis = [];
  final _isLoading = true.obs; // observable boolean flag

  Future<void> _loadData() async {
    // load data here
    await Future.delayed(Duration(seconds: 2)); // simulate data loading
    _isLoading.value = false; // set flag to false when data is loaded
  }
  @override
  void onInit() {
    super.onInit();
    _loadData();
    selectedCategory.value = "كرة قدم"; // Set the initial category
    fetchSportData("كرة قدم"); // Fetch data for the initial category
    getPlaygroundbyname();

  }

  // Function to update the selected category and fetch data
  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchSportData(category);
  }

  // Function to fetch data based on the selected category
  // Future<void> getPlaygroundbyname() async {
  //   try {
  //     CollectionReference playerchat =
  //     FirebaseFirestore.instance.collection("AddPlayground");
  //
  //     QuerySnapshot querySnapshot = await playerchat.get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       for (QueryDocumentSnapshot document in querySnapshot.docs) {
  //         Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
  //         AddPlayGroundModel user = AddPlayGroundModel.fromMap(userData);
  //
  //         allplaygrounds.add(user);
  //         print("PlayGroung Id : ${document.id}"); // Print the latest playground
  //
  //         print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground
  //         fetchSportData("كرة قدم"); // Set initial category
  //         // Normalize playType before comparing
  //         String playType = user.playType!.trim();
  //
  //         if (playType == "كرة طايره") {
  //           volybool.add(user);
  //         } else if (playType == "كرة قدم") {
  //           football.add(user);
  //         } else if (playType == "كرة تنس") {
  //           tennis.add(user);
  //         } else if (playType == "كرة سلة") {
  //           basketball.add(user);
  //         }
  //
  //       }
  //     }
  //   } catch (e) {
  //     print("Error getting playground: $e");
  //   }
  // }
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
          print("PlayGroung Id : ${document.id}"); // Print the latest playground

          print("allplaygrounds[i] : ${allplaygrounds.last}"); // Print the latest playground
          fetchSportData("كرة قدم"); // Set initial category
          // Normalize playType before comparing
          String playType = user.playType!.trim();

          if (playType == "كرة طايره") {
            volybool.add(user);
          } else if (playType == "كرة قدم") {
            football.add(user);
          } else if (playType == "كرة تنس") {
            tennis.add(user);
          } else if (playType == "كرة سلة") {
            basketball.add(user);
          }

          // Store the document ID in the AddPlayGroundModel object
          user.id = document.id;
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  void fetchSportData(String category) {
    // Clear previous data
    sportData.clear();
    // Loop through the list of all playgrounds
    for (var i = 0; i < allplaygrounds.length; i++) {
      if (i < volybool.length && volybool[i].playType == category) {
        sportData.addAll([
          SizedBox(height: 28),
          _buildStadiumCard(
            volybool[i].img![0], // Image, fallback if null
            '${volybool[i].playgroundName}',volybool[i].id! // Name and type
          ),
          SizedBox(height: 22),
        ]);
      }
      if (i < football.length && football[i].playType == category) {
        sportData.addAll([
          SizedBox(height: 28),
          _buildStadiumCard(
            football[i].img![0], // Image, fallback if null
            '${football[i].playgroundName}',football[i].id! // Name and type
          ),
          SizedBox(height: 22),
        ]);

      }
      if (i < basketball.length && basketball[i].playType == category) {
        sportData.addAll([
          SizedBox(height: 28),
          _buildStadiumCard(
            basketball[i].img![0], // Image, fallback if null
            '${basketball[i].playgroundName}',basketball[i].id!,  // Name and type
          ),
          SizedBox(height: 22),
        ]);
      }
      if (i < tennis.length && tennis[i].playType == category) {
        sportData.addAll([
          SizedBox(height: 28),
          _buildStadiumCard(
            tennis[i].img![0], // Image, fallback if null
            '${tennis[i].playgroundName}', tennis[i].id!, // Name and type
          ),
          SizedBox(height: 22),
        ]);
      }
    }

    // Add a bottom space for better UI
    sportData.add(SizedBox(height: 58));
  }

  Widget _buildStadiumCard(String? imagePath, String title,String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use MediaQuery to determine the available width
          final width = constraints.maxWidth;
          // final height = 160; // Adjust height based on width for responsiveness

          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaygroundName(id),
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
                            "assets/images/newground.png", // Fallback image asset
                            fit: BoxFit.cover,
                          ),),
                      ), // shimmer effect child
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
                          "assets/images/newground.png", // Fallback image asset
                          fit: BoxFit.cover,
                        ),),
                    ) // data loaded successfully, show data here
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
                  bottom: 40, // Adjusted for better visibility
                  right: 20,
                  left: 20,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16, // Increased font size for better readability
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