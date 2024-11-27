import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home/Userclass.dart';
import 'package:get_storage/get_storage.dart';
import '../Register/SignInPage.dart';
class NavigationController extends GetxController {
  RxInt currentIndex = 3.obs;
  User? user = FirebaseAuth.instance.currentUser;
  final RxList<User1> user1 = <User1>[].obs;
String docid='';
  Future<void> getUserByPhone(String phoneNumber) async {
    try {
      String normalizedPhoneNumber = phoneNumber.replaceFirst('+20', '0');
      CollectionReference playerchat = FirebaseFirestore.instance.collection('Users');

      QuerySnapshot querySnapshot = await playerchat
          .where('phone', isEqualTo: normalizedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        User1 user = User1.fromMap(userData);
        docid=querySnapshot.docs.first.id;
        user1.add(user);
        print("User data: $userData");
      } else {
        print("User not found with phone number $phoneNumber");
        await GetStorage().erase();
        Get.offAll(SigninPage());
      }
    } catch (e) {
      print("Error getting user: $e");
    }
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneValue = prefs.getString('phonev');

    if (phoneValue != null && phoneValue.isNotEmpty) {
      await getUserByPhone(phoneValue);
    } else if (user?.phoneNumber != null) {
      await getUserByPhone(user!.phoneNumber.toString());
    } else {
      print("No phone number available.");
    }
  }

  @override
  void onInit() {
    _loadUserData();
    super.onInit();
  }

  // Method to update the current index
  void updateIndex(int index) {
    currentIndex.value = index;
  }
}
