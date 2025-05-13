import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../IAM/models/consumer.dart';
import '../../IAM/models/technical.dart';
import '../models/chat_member.dart';

class ChatMemberService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<ChatMember?> chatsMembersByTechnical(String consumerId) async {

    var token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    final username = await _storage.read(key: 'username');

    final response = await http.get(
      Uri.parse('${_baseUrl}chatsmembers/'
        'chats-members-by-technical?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      final chatsMembersList = List<dynamic>.from(json.decode(response.body));

      final matched = chatsMembersList.firstWhere(
              (chat) => chat['consumerId'] == consumerId, orElse: () => null);

      if (matched == null) return null;

      final technicalJson = matched['technical'];
      final consumerJson = matched['consumer'];

      return ChatMember(
        chatRoomId: matched['chatRoomId'],
        technicalId: matched['technicalId'],
        consumerId: matched['consumerId'],
        technical: technicalJson != null ?
        Technical(
          id: technicalJson['id'],
          profileUrl: technicalJson['profileUrl'],
          firstname: technicalJson['firstname'],
          lastname: technicalJson['lastname'],
        ) : null,
        consumer: consumerJson != null ?
        Consumer(
          id: consumerJson['id'],
          profileUrl: consumerJson['profileUrl'],
          firstname: consumerJson['firstname'],
          lastname: consumerJson['lastname']
        ) : null
      );
    }

    return null;
  }

  Future<ChatMember?> chatsMembersByConsumer(String technicalId) async {

    var token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    final username = await _storage.read(key: 'username');

    final response = await http.get(
      Uri.parse('${_baseUrl}chatsmembers/'
        'chats-members-by-consumer?consumerId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      final chatsMembersList = List<dynamic>.from(json.decode(response.body));

      final matched = chatsMembersList.firstWhere(
              (chat) => chat['technicalId'] == technicalId, orElse: () => null);

      if (matched == null) return null;

      final technicalJson = matched['technical'];
      final consumerJson = matched['consumer'];

      return ChatMember(
        chatRoomId: matched['chatRoomId'],
        technicalId: matched['technicalId'],
        consumerId: matched['consumerId'],
        technical: technicalJson != null ?
        Technical(
          id: technicalJson['id'],
          profileUrl: technicalJson['profileUrl'],
          firstname: technicalJson['firstname'],
          lastname: technicalJson['lastname'],
        ) : null,
        consumer: consumerJson != null ?
        Consumer(
          id: consumerJson['id'],
          profileUrl: consumerJson['profileUrl'],
          firstname: consumerJson['firstname'],
          lastname: consumerJson['lastname']
        ) : null
      );
    }

    return null;
  }
}