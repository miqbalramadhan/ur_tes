import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ur_tes/presentation/component/shimmer_box.dart';

class ImageUrl extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final position;
  ImageUrl({
    this.url,
    this.width,
    this.height,
    this.position = Alignment.topLeft,
  });
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: width ?? height,
        height: height ?? width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.contain, alignment: position),
        ),
      ),
      placeholder: (context, url) => ShimmerBox(width: 35, height: 14),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
