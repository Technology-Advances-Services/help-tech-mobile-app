import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/detailed_technical_statistic.dart';
import '../models/general_technical_statistic.dart';
import '../models/review_statistic.dart';

class StatisticService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<GeneralTechnicalStatistic?> generalTechnicalStatistic() async {

    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
          'general-technical-statistic?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      Map<String, dynamic> data = json.decode(response.body);

      GeneralTechnicalStatistic generalStatistic = GeneralTechnicalStatistic(
        agendasId: data['id'],
        totalIncome: data['totalIncome'],
        totalConsumersServed: data['totalConsumersServed'],
        totalWorkTime: data['totalWorkTime'],
        totalPendingsJobs: data['totalPendingsJobs'],
      );

      return generalStatistic;
    }
    else {
      return null;
    }
  }

  Future<DetailedTechnicalStatistic?> detailedTechnicalStatistic(String typeStatistic) async {

    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

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

      Map<String, dynamic> data = json.decode(response.body);

      DetailedTechnicalStatistic generalStatistic = DetailedTechnicalStatistic(
        agendasId: data['id'],
        averageIncome: data['averageIncome'],
        totalIncome: data['totalIncome'],
        totalConsumersServed: data['totalConsumersServed'],
        totalWorkTime: data['totalWorkTime'],
        totalPendingsJobs: data['totalPendingsJobs'],
        averageScore: data['averageScore'],
        totalReviews: data['totalReviews']
      );

      return generalStatistic;
    }
    else {
      return null;
    }
  }

  Future<List<dynamic>> reviewStatistic() async {

    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');

    final response = await http.get(
      Uri.parse('${_baseUrl}statistics/'
          'review-statistic?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {

      List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => ReviewStatistic.fromJson(e)).toList();
    }
    else {
      return [];
    }
  }
}