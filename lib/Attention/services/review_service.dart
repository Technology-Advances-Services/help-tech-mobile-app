import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/review.dart';

class ReviewService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token;
  dynamic username;

  Future<bool> addReviewToJob(Review review) async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token?.replaceAll('"', '');

    final response = await http.post(
      Uri.parse('${_baseUrl}reviews/add-review-to-job'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'technicalId': review.technicalId,
        'consumerId': username,
        'score': review.score,
        'opinion': review.opinion
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<Review>> reviewsByTechnical(String technicalId) async {

    token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}reviews/reviews-by-technical?'
        'technicalId=$technicalId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((parameter) => Review(
        score: parameter['score'],
        opinion: parameter['opinion']
      )).toList();
    }

    return [];
  }
}