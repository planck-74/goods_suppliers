import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, voice }

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String senderId;
  final String? text;
  final String? fileUrl;
  final String? fileName;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToId;
  final bool isEdited;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.text,
    this.fileUrl,
    this.fileName,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.isEdited = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['sender'] ?? '',
      text: data['text'],
      fileUrl: data['file'],
      fileName: data['fileName'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${data['status'] ?? 'sent'}',
        orElse: () => MessageStatus.sent,
      ),
      replyToId: data['replyToId'],
      isEdited: data['isEdited'] ?? false,
    );
  }
}
