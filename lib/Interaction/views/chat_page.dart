import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';

import '../models/chat.dart';
import '../models/chat_member.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {

  final ChatMember chatMember;
  final String role;

  const ChatPage({super.key, required this.chatMember, required this.role});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  late final IOWebSocketChannel _channel;

  final ChatService _chatService = ChatService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Chat> messages = [];

  bool isSending = false;
  bool isLoading = true;

  Future<void> loadMessages() async {

    final tmpMessages = await _chatService.chatsByChatRoom
      (widget.chatMember.chatRoomId);

    setState(() {
      messages = tmpMessages;
      isLoading = false;
    });

    scrollToBottom();
  }

  Future<void> sendMessage() async {

    final text = _messageController.text;

    if (text.isEmpty) return;

    setState(() => isSending = true);

    await _chatService.sendMessage(Chat(
      chatRoomId: widget.chatMember.chatRoomId,
      technicalId: widget.chatMember.technicalId,
      consumerId: widget.chatMember.consumerId,
      message: text,
    ));

    final payload = json.encode({
      'room': widget.chatMember.chatRoomId,
      'user': widget.role,
      'text': text,
    });

    _channel.sink.add(payload);

    setState(() {
      isSending = false;
      _messageController.clear();
    });
  }

  void connectSocket() {

    final room = widget.chatMember.chatRoomId;

    _channel = IOWebSocketChannel.connect
      ('ws://helptechwebapp.runasp.net/chat?room=$room');

    _channel.stream.listen((event) {

      final data = json.decode(event);

      if (data['room'] == room) {
        final chat = Chat(
          chatRoomId: room,
          technicalId: widget.chatMember.technicalId,
          consumerId: widget.chatMember.consumerId,
          shippingDate: DateTime.now(),
          message: data['text'] ?? '',
          technical: widget.chatMember.technical,
          consumer: widget.chatMember.consumer,
        );

        setState(() => messages.add(chat));

        scrollToBottom();
      }
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((context) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
        );
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    connectSocket();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {

    final isTechnical = widget.role == 'TECNICO';

    final dynamic other = isTechnical ?
    widget.chatMember.consumer! : widget.chatMember.technical!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(other.profileUrl),
            ),
            const SizedBox(width: 10),
            Text('${other.firstname} ${other.lastname}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final chat = messages[index];
                final isMe = (isTechnical && chat.technicalId == widget.chatMember.technicalId) ||
                    (!isTechnical && chat.consumerId == widget.chatMember.consumerId);
                return bubble(chat, isMe);
              },
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (context) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                isSending
                    ? const CircularProgressIndicator()
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bubble(Chat chat, bool isMe) {

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? Colors.teal[50] : Colors.grey[200];

    final radius = isMe ?
    const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12)
    ) :
    const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12)
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[

                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(
                      widget.role == 'TECNICO' ? chat.consumer!.profileUrl :
                      chat.technical!.profileUrl)
                ),
                const SizedBox(width: 8)
              ],
              Flexible(
                child: Container(
                  decoration: BoxDecoration(color: bg, borderRadius: radius),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: align,
                    children: [

                      Text(chat.message),
                      const SizedBox(height: 6),

                      Text(
                        fmt.format(chat.shippingDate!),
                        style: const TextStyle(fontSize: 10,
                            color: Colors.black54)
                      )
                    ]
                  )
                )
              ),
              if (isMe) ...[

                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(
                      widget.role == 'TECNICO' ? chat.technical!.profileUrl :
                      chat.consumer!.profileUrl)
                )
              ]
            ]
          )
        ]
      )
    );
  }
}