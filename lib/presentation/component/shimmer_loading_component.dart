import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ur_tes/presentation/component/shimmer_box.dart';
import 'package:ur_tes/presentation/component/style.dart';


Widget listProductShimmer({total,loadmore = false}){
  return Container(
      padding: loadmore == false ? EdgeInsets.symmetric(horizontal:10,vertical:0) : EdgeInsets.symmetric(horizontal:10),
      child: ListView.builder(
      physics: loadmore == false ? BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()) : NeverScrollableScrollPhysics(),
      shrinkWrap: loadmore,
      itemCount: total,
      itemBuilder: (BuildContext context, int index) {
        return _itemHistoryShimmer();
     }),
  );
}
Widget _itemHistoryShimmer(){
  return Container(
      margin: EdgeInsets.only(bottom:10),
      padding: EdgeInsets.all(10),
      decoration: boxCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width:100,height: 15,),
                    SizedBox(height: 10,),
                    ShimmerBox(width:200,height: 15,),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              ShimmerBox(width:50),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width:100,height: 15,),
              ShimmerBox(width:50,height: 15,),
            ],
          ),
        ],
      ),
    );
}
