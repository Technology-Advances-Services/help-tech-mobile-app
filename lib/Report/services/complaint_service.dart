import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helptechmobileapp/Report/models/complaint.dart';
import 'package:http/http.dart' as http;

class ComplaintService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<bool> registerComplaint(Complaint complaint) async {

    var token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    var role = await _storage.read(key: 'role');

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
      }),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}