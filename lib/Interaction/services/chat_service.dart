import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../IAM/models/consumer.dart';
import '../../IAM/models/technical.dart';
import '../models/chat.dart';

class ChatService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  Future<bool> sendMessage(Chat chat) async {

    var token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    var username = await _storage.read(key: 'username');
    var role = await _storage.read(key: 'role');

    final response = await http.post(
      Uri.parse('${_baseUrl}chats/send-message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'chatRoomId': chat.chatRoomId,
        'personId': username,
        'sender': role,
        'message': chat.message
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<Chat>> chatsByChatRoom(int chatRoomId) async {

    var token = await _storage.read(key: 'token');

    token = token?.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}chats/chats-by-chat-room?chatRoomId=$chatRoomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      List<Chat> chats = data.map((item) {

        final technicalJson = item['technical'];
        final consumerJson = item['consumer'];

        return Chat(
          chatRoomId: item['chatRoomId'],
          technicalId: item['technicalId'] ?? '',
          consumerId: item['consumerId'] ?? '',
          shippingDate: item['shippingDate'] != null
              ? DateTime.parse(item['shippingDate'])
              : null,
          message: item['message'] ?? '',
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
          ) : null,
        );
      }).toList();

      return chats;
    }

    return [];
  }
}