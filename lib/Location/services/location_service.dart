import 'dart:convert';

import 'package:helptechmobileapp/Location/models/department.dart';
import 'package:helptechmobileapp/Location/models/district.dart';

import 'package:http/http.dart' as http;

class LocationService {

  final String baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<List<Department>> getDepartments() async {

    final response = await http.get(
      Uri.parse('${baseUrl}locations/all-departments'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<Department> departments = data.map((roomJson) => Department(
        id: roomJson['id'],
        name: roomJson['name'],
      )).toList();

      return departments;
    }
    else {
      return [];
    }
  }

  Future<List<District>> getDistrictsByDepartment(int departmentId) async {

    final response = await http.get(
      Uri.parse('${baseUrl}locations/districts-by-department?departmentId=$departmentId'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<District> districts = data.map((roomJson) => District(
        id: roomJson['id'],
        name: roomJson['name'],
      )).toList();

      return districts;
    }
    else {
      return [];
    }
  }
}