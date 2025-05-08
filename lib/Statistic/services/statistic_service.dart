import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/review_statistic.dart';

class StatisticService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<dynamic> generalTechnicalStatistic() async {

    var token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

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

      final List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      if (dataList.isEmpty) return null;

      final Map<String, dynamic> data = dataList.first;

      dynamic generalStatistic = (
        agendasId: data['AgendasId'],
        totalIncome: data['TotalIncome'],
        totalConsumersServed: data['TotalConsumersServed'],
        totalWorkTime: data['TotalWorkTime'],
        totalPendingsJobs: data['TotalPendingsJobs'],
      );

      return generalStatistic;
    }
    else {
      return null;
    }
  }

  Future<dynamic> detailedTechnicalStatistic
      (String typeStatistic) async {

    var token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
          'detailed-technical-statistic?technicalId=$username&'
          'typeStatistic=$typeStatistic'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      final List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      if (dataList.isEmpty) return null;

      final Map<String, dynamic> data = dataList.first;

      dynamic detailedStatistic = (
        agendasId: data['AgendasId'],
        averageIncome: data['AverageIncome'],
        totalIncome: data['TotalIncome'],
        totalConsumersServed: data['TotalConsumersServed'],
        totalWorkTime: data['TotalWorkTime'],
        totalPendingsJobs: data['TotalPendingsJobs'],
        averageScore: data['AverageScore'],
        totalReviews: data['TotalReviews']
      );

      return detailedStatistic;
    }
    else {
      return null;
    }
  }

  Future<List<ReviewStatistic>> reviewStatistic() async {

    var token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
          'review-statistic?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {

      final List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      if (dataList.isEmpty) return [];

      return dataList.map((e) => ReviewStatistic.fromJson(e)).toList();
    }
    else {
      return [];
    }
  }
}