import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Border? borderOnTap;
  final bool isTapped;

  CustomCard({required this.child, this.borderOnTap, required this.isTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isTapped ? borderOnTap : null,
      ),
      child: Card(
        color: Color(0xFFF0F6FF),
        child: child,
      ),
    );
  }
}