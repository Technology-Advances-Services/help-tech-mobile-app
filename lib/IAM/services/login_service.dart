import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginService {

  final String baseUrl = 'http://helptechservice.runasp.net/api/';

  final storage = const FlutterSecureStorage();

  Future<bool> accessToApp(String username, String password, String role) async{

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
      return true;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> logout() async{
    await storage.delete(key: 'token');
  }

  Future<bool> isAuthenticated() async{

    final token = await storage.read(key: 'token');

    return token == null? false: true;
  }
}