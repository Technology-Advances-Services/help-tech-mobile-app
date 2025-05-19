import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/review_statistic.dart';

class StatisticService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token;
  dynamic username;

  Future<dynamic> generalTechnicalStatistic() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
        'general-technical-statistic?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> dataList = jsonDecode(response.body);

      if (dataList.isEmpty) return null;

      final data = dataList.first;

      return (
        agendasId: data['AgendasId'],
        totalIncome: data['TotalIncome'],
        totalConsumersServed: data['TotalConsumersServed'],
        totalWorkTime: data['TotalWorkTime'],
        totalPendingsJobs: data['TotalPendingsJobs']
      );
    }

    return null;
  }

  Future<dynamic> detailedTechnicalStatistic
      (String typeStatistic) async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
          'detailed-technical-statistic?technicalId=$username&'
          'typeStatistic=$typeStatistic'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> dataList = jsonDecode(response.body);

      if (dataList.isEmpty) return null;

      final data = dataList.first;

      return (
        agendasId: data['AgendasId'],
        averageIncome: data['AverageIncome'],
        totalIncome: data['TotalIncome'],
        totalConsumersServed: data['TotalConsumersServed'],
        totalWorkTime: data['TotalWorkTime'],
        totalPendingsJobs: data['TotalPendingsJobs'],
        averageScore: data['AverageScore'],
        totalReviews: data['TotalReviews']
      );
    }

    return null;
  }

  Future<List<ReviewStatistic>> reviewStatistic() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
        'review-statistic?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode == 200) {

      final dataList = List<Map<String, dynamic>>
          .from(jsonDecode(response.body));

      if (dataList.isEmpty) return [];

      return dataList.map((e) => ReviewStatistic.fromJson(e)).toList();
    }

    return [];
  }
}