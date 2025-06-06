import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/membership.dart';

class MembershipService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<bool> registerMembership
      (Membership membership, String personId, String role) async {

    if (membership.id < 0) {
      return false;
    }
    if (membership.name.trim().isEmpty) {
      return false;
    }
    if (membership.price < 0.0) {
      return false;
    }
    if (membership.policies.trim().isEmpty) {
      return false;
    }
    if (personId.trim().isEmpty) {
      return false;
    }
    if (role.trim().isEmpty) {
      return false;
    }

    String endpoint = role == 'TECNICO' ? 'contracts/create-technical-contract'
      : 'contracts/create-consumer-contract';

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': membership.id,
        if (role == 'TECNICO') 'technicalId': personId,
        if (role == 'CONSUMIDOR') 'consumerId': personId,
        'name': membership.name,
        'price': membership.price,
        'policies': membership.policies
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<Membership>> getMemberships() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}memberships/all-memberships'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((parameter) => Membership(
        id: parameter['id'],
        name: parameter['name'],
        price: parameter['price'],
        policies: parameter['policies']
      )).toList();
    }

    return [];
  }
}