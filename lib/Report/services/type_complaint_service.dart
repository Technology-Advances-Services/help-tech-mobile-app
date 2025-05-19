import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/type_complaint.dart';

class TypeComplaintService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<List<TypeComplaint>> getTypeComplaints() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}reports/all-types-complaints'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((parameter) => TypeComplaint(
        id: parameter['id'],
        name: parameter['name']
      )).toList();
    }

    return [];
  }
}