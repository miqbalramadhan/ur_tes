import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageAsset extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  ImageAsset({
    this.image,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      height: height ?? width,
      width: width ?? height,
    );
  }
}
