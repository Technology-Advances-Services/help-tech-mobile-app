import 'dart:convert';

import '../models/membership.dart';

import 'package:http/http.dart' as http;

class MembershipService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<bool> registerMembership
      (Membership membership, String personId, String role) async {

    String endpoint = role == 'TECNICO' ? 'contracts/create-technical-contract'
        : 'contracts/create-consumer-contract';

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': membership.id,
        if (role == 'TECNICO') 'technicalId': personId,
        if (role == 'CONSUMIDOR') 'consumerId': personId,
        'name': membership.name,
        'price': membership.price,
        'policies': membership.policies,
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}