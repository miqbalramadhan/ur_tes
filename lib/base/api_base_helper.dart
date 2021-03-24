import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client, Response;

class ApiBaseHelper {
  Client http = Client();

  Future<Response> get(BuildContext context, url, header) async {
    Response response;
    try {
      response = await http
          .get(url, headers: header)
          .timeout(const Duration(seconds: 30));
    } on SocketException {
      throw Exception("No Internet Connection");
    }
    return response;
  }

  dynamic returnResponse(Response response) {
    if (response.statusCode != null) {
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    } else {
      throw Exception("Error");
    }
  }
}
