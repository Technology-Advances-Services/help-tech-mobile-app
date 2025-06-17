import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/consumer.dart';
import '../models/technical.dart';

class ProfileService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token = '';
  dynamic username = '';

  Future<Technical?> profileTechnical() async {

    username = await _storage.read(key: 'username');
    token = await _storage.read(key: 'token');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}informations/'
        'technical-by-id?id=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      dynamic data = json.decode(response.body);

      return Technical(
        id: data['id'],
        specialtyId: data['specialtyId'],
        districtId: data['districtId'],
        profileUrl: data['profileUrl'],
        firstname: data['firstname'],
        lastname: data['lastname'],
        age: data['age'],
        genre: data['genre'],
        phone: data['phone'],
        email: data['email']
      );
    }

    return null;
  }

  Future<Consumer?> profileConsumer() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}informations/'
        'consumer-by-id?id=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      dynamic data = json.decode(response.body);

      return Consumer(
        id: data['id'],
        districtId: data['districtId'],
        profileUrl: data['profileUrl'],
        firstname: data['firstname'],
        lastname: data['lastname'],
        age: data['age'],
        genre: data['genre'],
        phone: data['phone'],
        email: data['email']
      );
    }

    return null;
  }
}