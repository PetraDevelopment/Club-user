import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class reservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('reservation Example')),
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
            width: MediaQuery.of(context).size.width / 2.4,


            height: 150,
            arrowHeight: 20,
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
