import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final bool isInternal;

  const CommentModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.attachmentUrls = const [],
    required this.createdAt,
    this.isInternal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'attachmentUrls': attachmentUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'isInternal': isInternal,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      ticketId: map['ticketId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'Employee',
      message: map['message'] ?? '',
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isInternal: map['isInternal'] ?? false,
    );
  }
}
