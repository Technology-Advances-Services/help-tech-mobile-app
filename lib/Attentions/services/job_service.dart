import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/job.dart';

class JobService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<List<Job>> jobsByTechnical() async {

    var token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final jobsUrl = '${_baseUrl}jobs/'
        'jobs-by-technical?technicalId=$username';
    /*final chatsMembersUrl = '${_baseUrl}chatsmembers/'
        'chats-members-by-technical?technicalId=$username';*/

    final jobsResponse = await http.get(
      Uri.parse(jobsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    /*final chatsMembersResponse = await http.get(
      Uri.parse(chatsMembersUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );*/

    if (jobsResponse.statusCode >= 200 &&
        jobsResponse.statusCode < 300) {

      final jobsList = List<dynamic>.from(json.decode(jobsResponse.body));
      //final chatsMembersList = List<dynamic>.from(json.decode(chatsMembersResponse.body));

      final jobResults = <Job>[];

      for (var jobJson in jobsList) {

        final consumerResponse = await http.get(
          Uri.parse('${_baseUrl}informations/'
              'consumer-by-id?id=${jobJson['consumerId']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
        );

        final consumerJson = json.decode(consumerResponse.body);

        DateTime? workDate;

        try {
          workDate = DateTime.parse(jobJson['workDate']);
        }
        catch (e) {
          workDate = null;
        }

        final job = Job(
          id: jobJson['id'],
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
          jobState: jobJson['jobState'],
        );

        /*final chatMember = chatsMembersList
            .firstWhere((chat) => chat['consumerId'] == jobJson['consumerId'],
            orElse: () => null);

        if (chatMember != null) {
          job.chatRoomId = chatMember['chatRoomId'];
        }*/

        jobResults.add(job);
      }

      jobResults.sort((a, b) => b.registrationDate!.compareTo(a.registrationDate!));

      return jobResults;
    }
    else {
      return [];
    }
  }
}