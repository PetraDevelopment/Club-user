import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../playground_model/AddPlaygroundModel.dart';


class SportsController extends GetxController {
  // Observable variable for the current selected category
  var selectedCategory = 'كرة قدم'.obs;
  var sportData = <Widget>[].obs; // List of widgets
  late List<AddPlayGroundModel> allplaygrounds = [];

  Future<void> getPlaygroundbyname() async {
    try {
      CollectionReference playerchat = FirebaseFirestore.instance.collection("AddPlayground");

      QuerySnapshot querySnapshot = await playerchat.get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> playgroundData = document.data() as Map<String, dynamic>;
          AddPlayGroundModel playground = AddPlayGroundModel.fromMap(playgroundData);

          allplaygrounds.add(playground);

          print("Playground ID: ${document.id}");
          print("Playground Data: $playground");
        }
      }
    } catch (e) {
      print("Error getting playground: $e");
    }
  }
  @override
  void onInit() {
    super.onInit();
    getPlaygroundbyname();
    fetchSportData('كرة قدم'); // Set initial category
  }

  // Function to update the selected category and fetch data
  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchSportData(category);
  }

  // Function to fetch data based on the selected category
  void fetchSportData(String category) {
    // Clear previous data
    sportData.clear();

    switch (category) {
      case 'كرة قدم':
        if (allplaygrounds.isNotEmpty) {
          sportData.addAll([
            // FootballPlayGround(),
            SizedBox(height: 28,),
            ...allplaygrounds.map((playground) => _buildStadiumCard(playground.img!, playground.playgroundName!)).toList(),
            SizedBox(height: 58,),
          ]);
        } else {
          sportData.add(Text('No playgrounds found'));
        }
        break;
      case 'كرة سله':
        if (allplaygrounds.isNotEmpty) {
          sportData.addAll([
            // BasketBallPlayGround(),
            SizedBox(height: 28,),
            ...allplaygrounds.map((playground) => _buildStadiumCard(playground.img!, playground.playgroundName!)).toList(),
            SizedBox(height: 58,),
          ]);
        } else {
          sportData.add(Text('No playgrounds found'));
        }
        break;
      case 'كرة طايره':
        if (allplaygrounds.isNotEmpty) {
          sportData.addAll([
            // VollyBallPlayGround(),
            SizedBox(height: 28,),
            ...allplaygrounds.map((playground) => _buildStadiumCard(playground.img!, playground.playgroundName!)).toList(),
            SizedBox(height: 58,),
          ]);
        } else {
          sportData.add(Text('No playgrounds found'));
        }
        break;
      case 'تنس':
        if (allplaygrounds.isNotEmpty) {
          sportData.addAll([
            // VollyBallPlayGround(),
            SizedBox(height: 28,),
            ...allplaygrounds.map((playground) => _buildStadiumCard(playground.img!, playground.playgroundName!)).toList(),
            SizedBox(height: 58,),
          ]);
        } else {
          sportData.add(Text('No playgrounds found'));
        }
        break;
      default:
        break;
    }
  }


  Widget _buildStadiumCard(String imagePath, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 22.0, left: 22.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              shape: BoxShape.rectangle,
              color: Color(0xFFF0F6FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6), // Increase opacity for a darker shadow
                  spreadRadius: 0, // No spread; keeps the shadow tight to the edge
                  blurRadius: 4, // Increase blur radius for a more diffused shadow
                  offset: Offset(0, 10), // Positive offset on the y-axis for a shadow only at the bottom
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.0), // Ensure the image has rounded corners
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
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
                  bottomLeft: Radius.circular(28.0),
                  bottomRight: Radius.circular(28.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: 115,
            right: 40,
            left: 55,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}