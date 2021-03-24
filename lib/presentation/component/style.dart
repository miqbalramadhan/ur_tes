import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ur_tes/values/colors.dart';

final boxCard = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(5),
  border: Border.all(width: 0.5, color: MyColors.dark[100].withOpacity(0.3)),
  boxShadow: [
    BoxShadow(
      color: MyColors.dark[100].withOpacity(0.03),
      spreadRadius: 0,
      blurRadius: 3,
      offset: Offset(0, 4),
    ),
  ],
);