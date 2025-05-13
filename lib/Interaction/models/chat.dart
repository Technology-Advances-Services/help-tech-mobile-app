import '../../IAM/models/consumer.dart';
import '../../IAM/models/technical.dart';

class Chat {

  int chatRoomId;
  String? technicalId;
  String? consumerId;
  DateTime? shippingDate;
  String message;

  Technical? technical;
  Consumer? consumer;

  Chat({
    this.chatRoomId = 0,
    this.technicalId,
    this.consumerId,
    this.shippingDate,
    this.message = '',
    this.technical,
    this.consumer
  });
}