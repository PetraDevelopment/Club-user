import 'package:flutter/material.dart';
import 'package:popover/popover.dart';


class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(

        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width*1.4,
        child: Column(
          children: [

                Text(
                  '620',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 23,
                    color: Color(0xFF7D90AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),


                Text(
                  'التكلفة أجمالية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Color(0xFF334154),
                    fontWeight: FontWeight.bold,
                  ),
                ),

            SizedBox(height: 25),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 25,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.0),
                  color: Color(0xFF106A35),
                ),
                child: Center(
                  child: Text(
                    'حجـــــز',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
