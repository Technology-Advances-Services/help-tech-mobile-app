import 'dart:convert';

import 'package:helptechmobileapp/Location/models/department.dart';
import 'package:helptechmobileapp/Location/models/district.dart';
import 'package:helptechmobileapp/Location/models/specialty.dart';

import 'package:http/http.dart' as http;

class InformationService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<List<Department>> getDepartments() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}locations/all-departments'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<Department> departments = data.map((parameter) => Department(
        id: parameter['id'],
        name: parameter['name'],
      )).toList();

      return departments;
    }

    return [];
  }

  Future<List<District>> getDistrictsByDepartment(int departmentId) async {

    final response = await http.get(
      Uri.parse('${_baseUrl}locations/districts-by-department?'
        'departmentId=$departmentId'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<District> districts = data.map((parameter) => District(
        id: parameter['id'],
        name: parameter['name'],
      )).toList();

      return districts;
    }

    return [];
  }

  Future<List<Specialty>> getSpecialties() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}specialties/all-specialties'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<Specialty> specialties = data.map((parameter) => Specialty(
        id: parameter['id'],
        name: parameter['name'],
      )).toList();

      return specialties;
    }

    return [];
  }
}