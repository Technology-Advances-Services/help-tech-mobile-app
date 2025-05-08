import 'dart:convert';

import 'package:helptechmobileapp/Information/models/department.dart';
import 'package:helptechmobileapp/Information/models/district.dart';
import 'package:helptechmobileapp/Information/models/specialty.dart';

import 'package:http/http.dart' as http;

import '../../Subscription/models/membership.dart';

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
    else {
      return [];
    }
  }

  Future<List<District>> getDistrictsByDepartment(int departmentId) async {

    final response = await http.get(
      Uri.parse('${_baseUrl}locations/districts-by-department?departmentId=$departmentId'),
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
    else {
      return [];
    }
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
    else {
      return [];
    }
  }

  Future<List<Membership>> getMemberships() async {

    final response = await http.get(
      Uri.parse('${_baseUrl}memberships/all-memberships'),
      headers:{
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<Membership> memberships = data.map((parameter) => Membership(
        id: parameter['id'],
        name: parameter['name'],
        price: parameter['price'],
        policies: parameter['policies']
      )).toList();

      return memberships;
    }
    else {
      return [];
    }
  }
}