import '../../IAM/models/consumer.dart';
import '../../IAM/models/technical.dart';

class ChatMember {

  int chatRoomId;
  String? technicalId;
  String? consumerId;

  Technical? technical;
  Consumer? consumer;

  ChatMember({
    this.chatRoomId = 0,
    this.technicalId,
    this.consumerId,
    this.technical,
    this.consumer
  });
}