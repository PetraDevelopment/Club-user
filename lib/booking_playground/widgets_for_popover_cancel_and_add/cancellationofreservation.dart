import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class cancellationofreservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('cancellationofreservation Example')),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Button(),
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: GestureDetector(
        child: const Center(child: Text('Click Me')),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const ListItems(),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.top,
            width: MediaQuery.of(context).size.width / 1.3,

            height: 350,
            arrowHeight: 15,
            arrowWidth: 30,
           radius: 18,
          );
        },
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(

        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width*0.9 ,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'محمد أحمد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '012356577841',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      Text(
                        'قام بالحجز: علاء أبراهيم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),

                    ],
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/images/profile.png"), // Replace with your actual image
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '13-08-2024',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '4:00 AM - 5:00 AM',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'تأجير الكرة: 20 جنية',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 3,),
                Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'المبلغ المدفوع: 500',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Text(
                  'التكلفة أجمالية',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    color: Color(0xFF334154),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  'المبلغ المتبقي: 120',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.0),
                  color: Color(0xFFB3261E),
                ),

                child: Center(
                  child: Text(
                    'ألغاء الحجز',
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
