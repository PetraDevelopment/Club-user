import 'package:club_user/Menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../Controller/NavigationController.dart';
import '../../Home/HomePage.dart';
import '../../my_reservation/my_reservation.dart';
import 'GetxController.dart';

class AppBarandNavigationBTN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SportsController controller = Get.put(SportsController());
    final NavigationController navigationController = Get.put(NavigationController());


    return WillPopScope(
      onWillPop: () async {
        Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
            ?.settings
            .arguments as Map<dynamic, dynamic>?;
        if (arguments != null && arguments['from'] == 'home') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => menupage(),
            ),
          );
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Padding(
            padding: EdgeInsets.only(top: 25.0,bottom: 12,right: 8,left: 8),
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
                  color:  Color(0xFF334154),
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {

                    Map<dynamic, dynamic>? arguments = ModalRoute.of(context)
                        ?.settings
                        .arguments as Map<dynamic, dynamic>?;
                    if (arguments != null && arguments['from'] == 'home') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => menupage(),
                        ),
                      );
                    }

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
        body:controller.isConnected.value==true ?  Column(
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
                        controller.selectCategory("كرة تنس");
                        controller.selectedCategory.value = "كرة تنس";
                      },
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: controller.selectedCategory.value == "كرة تنس"
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
                              color: controller.selectedCategory.value == "كرة تنس"
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
                      onTap: () => controller.selectCategory("كرة طائرة"),
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color:controller.selectedCategory.value == "كرة طائرة" ? Color(0xFF106A35)
                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            "كرة طائرة",
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:controller.selectedCategory.value == "كرة طائرة" ?
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
                      onTap: () => controller.selectCategory("كرة قدم"),
                      child: Container(
                        height: 27,
                        width: 86,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: controller.selectedCategory.value == "كرة قدم"
                              ? Color(0xFF106A35)

                              : Color(0xFFE4EFFF),
                        ),
                        child: Center(
                          child: Text(
                            "كرة قدم",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: controller.selectedCategory.value == "كرة قدم"
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
                  return Center(
                child: SizedBox(
                height: MediaQuery.of(context).size.height/2.9,
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
                );
                }
                return controller.isConnected.value==true ?ListView.builder(

                  itemCount: controller.sportData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return controller.sportData[index];
                  },
                ):_buildNoInternetUI();
              }),
            ),
          ],
        ):_buildNoInternetUI(),

        bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 2,

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
  Widget _buildNoInternetUI() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

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
}