import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/complaint.dart';

class ComplaintService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token;
  dynamic role;

  Future<bool> registerComplaint(Complaint complaint) async {

    token = await _storage.read(key: 'token');
    role = await _storage.read(key: 'role');

    token = token?.replaceAll('"', '');

    final response = await http.post(
      Uri.parse('${_baseUrl}reports/register-complaint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'typeComplaintId': complaint.typeComplaintId,
        'jobId': complaint.jobId,
        'sender': role,
        'description': complaint.description
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}