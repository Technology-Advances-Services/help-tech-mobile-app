import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../IAM/models/technical.dart';
import '../models/job.dart';

class JobService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token = '';
  dynamic username = '';

  Future<bool> registerRequestJob(Job job) async {

    if (job.agendaId < 1) {
      return false;
    }
    if (job.address.trim().isEmpty) {
      return false;
    }
    if (job.description.trim().isEmpty) {
      return false;
    }

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token.replaceAll('"', '');

    final response = await http.post(
      Uri.parse('${_baseUrl}jobs/register-request-job'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'agendaId': job.agendaId,
        'consumerId': username,
        'address': job.address,
        'description': job.description
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> assignJobDetail(Job job) async {

    if (job.id < 1) {
      return false;
    }
    if (job.workDate == null) {
      return false;
    }
    if (job.time! < 0.0) {
      return false;
    }
    if (job.laborBudget! < 0.0) {
      return false;
    }
    if (job.materialBudget! < 0.0) {
      return false;
    }

    token = await _storage.read(key: 'token');

    token = token.replaceAll('"', '');

    var response = await http.post(
      Uri.parse('${_baseUrl}jobs/assign-job-detail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'id': job.id,
        'workDate': job.workDate?.toIso8601String(),
        'time': job.time,
        'laborBudget': job.laborBudget,
        'materialBudget': job.materialBudget
      })
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      response = await http.post(
        Uri.parse('${_baseUrl}jobs/update-job-state'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'id': job.id,
          'jobState': job.jobState
        })
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    }

    return false;
  }

  Future<bool> completeJob(Job job) async {

    if (job.id < 1) {
      return false;
    }

    token = await _storage.read(key: 'token');

    token = token.replaceAll('"', '');

    final response = await http.post(
      Uri.parse('${_baseUrl}jobs/update-job-state'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'id': job.id,
        'jobState': 'COMPLETADO'
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<int> getAgendaId(String technicalId) async {

    token = await _storage.read(key: 'token');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}agendas/agenda-by-technical?'
        'technicalId=$technicalId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      dynamic data = json.decode(response.body);

      String agendaId = data['id'].toString();

      return int.parse(agendaId);
    }

    return 0;
  }

  Future<List<Job>> jobsByTechnical() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}jobs/'
        'jobs-by-technical?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      final jobsList = List<dynamic>.from(json.decode(response.body));

      final jobs = <Job>[];

      for (var jobJson in jobsList) {

        final consumerJson = jobJson['consumer'];

        DateTime? workDate;

        try {
          workDate = DateTime.parse(jobJson['workDate']);
        }
        catch (e) {
          workDate = null;
        }

        final job = Job(
          id: jobJson['id'],
          agendaId: jobJson['agendaId'],
          registrationDate: DateTime.parse(jobJson['registrationDate']),
          personId: consumerJson['id'],
          firstName: consumerJson['firstname'],
          lastName: consumerJson['lastname'],
          phone: consumerJson['phone'],
          workDate: workDate,
          address: jobJson['address'],
          description: jobJson['description'],
          time: jobJson['time'],
          laborBudget: jobJson['laborBudget'],
          materialBudget: jobJson['materialBudget'],
          amountFinal: jobJson['amountFinal'],
          jobState: jobJson['jobState']
        );

        jobs.add(job);
      }

      jobs.sort((a, b) => b.registrationDate!.compareTo(a.registrationDate!));

      return jobs;
    }

    return [];
  }

  Future<List<Job>> jobsByConsumer() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}jobs/'
        'jobs-by-consumer?consumerId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      final jobsList = List<dynamic>.from(json.decode(response.body));

      final jobs = <Job>[];

      for (var jobJson in jobsList) {

        final technicalJson = jobJson['technical'];

        DateTime? workDate;

        try {
          workDate = DateTime.parse(jobJson['workDate']);
        }
        catch (e) {
          workDate = null;
        }

        final job = Job(
          id: jobJson['id'],
          agendaId: jobJson['agendaId'],
          registrationDate: DateTime.parse(jobJson['registrationDate']),
          personId: technicalJson['id'],
          firstName: technicalJson['firstname'],
          lastName: technicalJson['lastname'],
          phone: technicalJson['phone'],
          workDate: workDate,
          address: jobJson['address'],
          description: jobJson['description'],
          time: jobJson['time'],
          laborBudget: jobJson['laborBudget'],
          materialBudget: jobJson['materialBudget'],
          amountFinal: jobJson['amountFinal'],
          jobState: jobJson['jobState']
        );

        jobs.add(job);
      }

      jobs.sort((a, b) => b.registrationDate!.compareTo(a.registrationDate!));

      return jobs;
    }

    return [];
  }

  Future<List<Technical>> technicalsByAvailability() async {

    token = await _storage.read(key: 'token');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}informations/technicals-by-availability?'
        'availability=DISPONIBLE'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((parameter) => Technical(
        id: parameter['id'],
        specialtyId: parameter['specialtyId'],
        districtId: parameter['districtId'],
        profileUrl: parameter['profileUrl'],
        firstname: parameter['firstname'],
        lastname: parameter['lastname'],
        age: parameter['age'],
        genre: parameter['genre'],
        phone: parameter['phone'],
        email: parameter['email'],
        availability: parameter['availability']
      )).toList();
    }

    return [];
  }
}