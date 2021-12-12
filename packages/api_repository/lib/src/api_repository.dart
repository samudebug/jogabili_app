import 'dart:convert';

import 'package:http/http.dart' as http;

class APIError implements Exception {
  const APIError(this.errorCode);
  final int errorCode;
}

class APIRepository {
  const APIRepository();
  Future<dynamic> performGet(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('[API] Request: Get - Response Code: ${response.statusCode}');
        print('[API] Request: Get -  Body: ${response.body}');
        throw APIError(response.statusCode);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
