import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  ShimmerBox({
    this.width, 
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? height,
      height: height ?? width,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: Container(
          color: Colors.grey,
        ),
      ),
    );
  }
}