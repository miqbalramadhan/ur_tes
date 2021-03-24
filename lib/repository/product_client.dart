import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Response;
import 'package:ur_tes/base/api_base.dart';
import 'package:ur_tes/model/product_response.dart';

class ProductClient extends ApiBase {
  Future<ProductResponse> getAll(BuildContext context) async {
    String url = "https://api-dev.hijiofficial.com/v3/products/GetAll.php";
    Future<Response> response =
        get(context, url, header()).catchError((onError) {});
    return response.then((res) {
      return ProductResponse.fromJson(json.decode(res.body));
    });
  }
}
