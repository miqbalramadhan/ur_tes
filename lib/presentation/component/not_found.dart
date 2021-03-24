import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ur_tes/presentation/component/shimmer_box.dart';
import 'package:ur_tes/values/colors.dart';

class NotFound extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String imageLocal;
  final bool scroll;
  final double height;
  final double width;
  NotFound({
    @required this.title, 
    this.description,
    this.imageUrl,
    this.imageLocal,
    this.scroll = false,
    this.height = double.infinity,
    this.width = double.infinity,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: SingleChildScrollView(
        physics: scroll == false ? NeverScrollableScrollPhysics() : BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height/5),
            _contentImage(),
            SizedBox(height: 10,),
            Text(title,style: TextStyle(color:MyColors.indigo,fontSize:14,fontWeight: FontWeight.w600),),
            SizedBox(height: 5,),
            (description == null) ? Container() : Text(description)  
          ],
        ),
      ),
    );
  }
  Widget _contentImage(){
    if(imageUrl != null){
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          height: height / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
            ),
          ),
        ),
        placeholder: (context, url) => ShimmerBox(height:MediaQuery.of(context).size.height/4),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else if(imageLocal != null) {
      return Container(
        margin: EdgeInsets.only(top:20,bottom:20),
        height: height / 3,
        child: Image.asset(imageLocal)
      );
    } else {
      return Container(height: height/3);
    }
  }
}