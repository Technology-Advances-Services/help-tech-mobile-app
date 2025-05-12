import 'dart:convert';

import 'package:helptechmobileapp/Report/models/type_complaint.dart';
import 'package:http/http.dart' as http;

class TypeComplaintService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<List<TypeComplaint>> getTypesComplaints() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}reports/all-types-complaints'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<TypeComplaint> typeComplaints = data.map((parameter) => TypeComplaint(
        id: parameter['id'],
        name: parameter['name']
      )).toList();

      return typeComplaints;
    }

    return [];
  }
}