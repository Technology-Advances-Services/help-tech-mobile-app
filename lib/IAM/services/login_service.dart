import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginService {

  final String baseUrl = 'http://helptechservice.runasp.net/api/';

  final storage = const FlutterSecureStorage();

  Future<bool> accessToApp(String username, String password, String role) async {

    final response = await http.post(
      Uri.parse('${baseUrl}access/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
        'role': role
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      String token = response.body;

      await storage.write(key: 'token', value: token);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      String role = decodedToken
      ['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
          .toString();

      String username =decodedToken
      ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']
          .toString();

      await storage.write(key: 'role', value: role);
      await storage.write(key: 'username', value: username);

      return true;
    }
    else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> logout() async{
    await storage.delete(key: 'token');
    await storage.delete(key: 'role');
    await storage.delete(key: 'username');
  }
}