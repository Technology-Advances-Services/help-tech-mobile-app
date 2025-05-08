import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<bool> accessToApp(String username, String password, String role) async {

    final response = await http.post(
      Uri.parse('${_baseUrl}access/login'),
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

      await _storage.write(key: 'token', value: token);

      final decodedToken = JwtDecoder.decode(token);

      String role = decodedToken
      ['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
          .toString();

      String username =decodedToken
      ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid']
          .toString();

      await _storage.write(key: 'role', value: role);
      await _storage.write(key: 'username', value: username);

      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> isAuthenticated() async {

    final token = await _storage.read(key: 'token');

    return token == null? false: true;
  }

  Future<void> logout() async {

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'username');
  }
}