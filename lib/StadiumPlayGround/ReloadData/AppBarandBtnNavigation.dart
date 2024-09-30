import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../Controller/NavigationController.dart';
import '../../Favourite/Favourite_page.dart';
import '../../Home/HomePage.dart';
import 'GetxController.dart';

class AppBarandNavigationBTN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SportsController controller = Get.put(SportsController());
    final size = MediaQuery.of(context).size;
    final NavigationController navigationController = Get.put(NavigationController());
//to make back btn of android not working

    return WillPopScope(
      onWillPop: () async {
        Get.off(HomePage()); // Navigate to HomePage
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0), // Set the height of the AppBar
          child: Padding(
            padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8), // Add padding to the top of the title
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'المــلاعب',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  height: 29.98 / 16,
                  letterSpacing: 0.04,
                  color:  Color(0xFF334154), // Add this line
                ),
              ),
              centerTitle: true, // Center the title horizontally
              leading: IconButton(
                onPressed: () {
                  // Get.back();
                  Get.off(HomePage());
                  // Navigator.of(context).pop(true); // Navigate back to the previous page
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
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Image.asset('assets/images/notification.png', height: 28, width: 28,),

                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Obx(() => Padding(
              padding: const EdgeInsets.only(right: 22.0,left: 8,top: 22,bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        controller.selectCategory('تنس');
                        // Reset the "كرة قدم" container color
                        controller.selectedCategory.value = 'تنس';
                      },
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: controller.selectedCategory.value == 'تنس'
                              ? Color(0xFF106A35)
                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            "تنس",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: controller.selectedCategory.value == 'تنس'
                                  ? Colors.white
                                  : Color(0xFF334154)
                              ,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    GestureDetector(
                      onTap: () => controller.selectCategory('كرة طائرة'),
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color:controller.selectedCategory.value == 'كرة طائرة' ? Color(0xFF106A35)
                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            "كرة طائرة",
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:controller.selectedCategory.value == 'كرة طائرة' ?
                                Colors.white : Color(0xFF334154)

                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    GestureDetector(
                      onTap: () => controller.selectCategory('كرة سلة'),
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color:controller.selectedCategory.value == 'كرة سلة' ? Color(0xFF106A35)
                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            "كرة سلة",
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:controller.selectedCategory.value == 'كرة سلة' ?
                                Colors.white : Color(0xFF334154)

                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    GestureDetector(
                      onTap: () => controller.selectCategory('كرة قدم'),
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: controller.selectedCategory.value == 'كرة قدم'
                              ? Color(0xFF106A35)

                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            'كرة قدم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: controller.selectedCategory.value == 'كرة قدم'
                                  ? Colors.white
                                  : Color(0xFF334154)
                              ,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            )),
            Expanded(
              child: Obx(() {
                if (controller.sportData == null || controller.sportData.isEmpty) {
                  return Center(child: Text(" data Will add Soon"));
                }
                return ListView.builder(

                  itemCount: controller.sportData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return controller.sportData[index]; // Use the widgets stored in sportData
                  },
                );
              }),
            ),
          ],
        ),

        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 2,
          // Use the dynamic index
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
                .updateIndex(index); // Update the index dynamically
            // Handle navigation based on index
            switch (index) {
            case 0:
              Get.to(() => FavouritePage())?.then((_) {
                navigationController
                    .updateIndex(0); // Update index when navigating back
              });
              break;
              case 1:
                Get.to(() => FavouritePage())?.then((_) {
                  navigationController
                      .updateIndex(1); // Update index when navigating back
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


      ),
    );

  }
  // Function to handle back navigation logic
  Future<bool> handleBackNavigation() async {
    int currentIndex = NavigationController().currentIndex.value;

    if (currentIndex == 3) {
      // If already on Home page, simply pop the route
      return true;
    } else {
      // Update index and navigate back correctly
      NavigationController().updateIndex(3); // Set index to Home
      Get.off(HomePage()); // Navigate to HomePage manually
      return false; // Prevent default pop behavior
    }
  }
}