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

    final tmpMessages = await _chatService
        .chatsByChatRoom(widget.chatMember.chatRoomId);

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
      'room': widget.chatMember.chatRoomId.toString(),
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

    _channel = IOWebSocketChannel.connect(
      Uri.parse('ws://helptechwebapp.runasp.net/chat?room=$room'),
    );

    _channel.stream.listen((event) {

      final data = json.decode(event);
      final isSenderTechnical = data['user'] == 'TECNICO';

      if (data['room'].toString() == room.toString()) {

        final chat = Chat(
          chatRoomId: room,
          technicalId: isSenderTechnical ? widget.chatMember.technicalId : null,
          consumerId: !isSenderTechnical ? widget.chatMember.consumerId : null,
          shippingDate: DateTime.now(),
          message: data['text'] ?? '',
          technical: widget.chatMember.technical,
          consumer: widget.chatMember.consumer
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

    final dynamic other = isTechnical
        ? widget.chatMember.consumer!
        : widget.chatMember.technical!;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE8B782),
                Color(0xFFAD745D)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            )
          )
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [

                CircleAvatar(
                  backgroundImage: NetworkImage(other.profileUrl)
                ),
                const SizedBox(width: 10),

                Text('${other.firstname}')
              ]
            )
          ),
          body: Column(
            children: [
              Expanded(
                child: isLoading ?
                const Center(child: CircularProgressIndicator()) :
                ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {

                    final chat = messages[index];

                    final isMe = (isTechnical && chat.technicalId ==
                        widget.chatMember.technicalId) ||
                        (!isTechnical && chat.consumerId ==
                            widget.chatMember.consumerId);

                    return bubble(chat, isMe);
                  }
                )
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2)
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (context) => sendMessage()
                      )
                    ),
                    const SizedBox(width: 8),
                    isSending ?
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ) :
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: sendMessage
                      )
                    )
                  ]
                )
              )
            ]
          )
        )
      ]
    );
  }

  Widget bubble(Chat chat, bool isMe) {

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? Colors.tealAccent.shade100 : Colors.blue.shade100;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 0),
      bottomRight: Radius.circular(isMe ? 0 : 18)
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [

              if (!isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.role == 'TECNICO'
                        ? chat.consumer!.profileUrl
                        : chat.technical!.profileUrl
                  )
                ),
              if (!isMe)
                const SizedBox(width: 8),

              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: radius,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)
                      )
                    ]
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: align,
                    children: [

                      Text(
                        chat.message,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 6),

                      Text(
                        fmt.format(chat.shippingDate!),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)
                      )
                    ]
                  )
                )
              ),
              if (isMe)
                const SizedBox(width: 8),

              if (isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.role == 'TECNICO'
                        ? chat.technical!.profileUrl
                        : chat.consumer!.profileUrl
                  )
                )
            ]
          )
        ]
      )
    );
  }
}