import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/contract.dart';

class ContractService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token;
  dynamic username;
  dynamic role;

  Future<Contract?> getContract() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');
    role = await _storage.read(key: 'role');

    token = token?.replaceAll('"', '');

    String endpoint = role == 'TECNICO'
        ? 'contracts/contract-by-technical?technicalId=$username'
        : 'contracts/contract-by-consumer?consumerId=$username';

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      dynamic data = json.decode(response.body);

      String? personId;

      if (role == 'TECNICO') {
        personId = data['technicalId'];
      }
      else if (role == 'CONSUMIDOR') {
        personId = data['consumerId'];
      }

      return Contract(
        id: data['id'],
        membershipId: data['membershipId'],
        personId: personId!,
        name: data['name'],
        price: data['price'],
        policies: data['policies'],
        startDate: DateTime.parse(data['startDate']),
        finalDate: DateTime.parse(data['finalDate'])
      );
    }

    return null;
  }
}