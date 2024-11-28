import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class ShimmerLoadingbig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 90,
              height: 10,
              color: Colors.grey[300], // Placeholder color
              margin: EdgeInsets.only(bottom: 9),
            ),
          ),
          SizedBox(height: 15),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 90,
              height: 10,
              color: Colors.grey[300],
              margin: EdgeInsets.only(bottom: 9),
            ),
          ),

        ],
      ),
    );
  }
}