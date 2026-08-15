import 'package:flutter/material.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/comment_model.dart';

class CommentThreadWidget extends StatelessWidget {
  final List<CommentModel> comments;
  final UserModel currentUser;

  const CommentThreadWidget({
    super.key,
    required this.comments,
    required this.currentUser,
  });

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity & Messages (${comments.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF64748B)),
          ],
        ),
        const SizedBox(height: 12),

        // Comments Stream
        if (comments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(Icons.mark_chat_unread_outlined, size: 24, color: Color(0xFF94A3B8)),
                SizedBox(height: 6),
                Text(
                  'No messages yet. Send a note below.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final isMe = comment.senderId == currentUser.uid;
              final isSystem = comment.senderId == 'system';

              if (isSystem) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${comment.message} • ${_formatTime(comment.createdAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              // User Comment Bubble
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(
                          comment.senderName.isNotEmpty
                              ? comment.senderName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Sender info
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isMe ? 'You' : comment.senderName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isMe ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    comment.senderRole,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isMe ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Message
                            Text(
                              comment.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: isMe ? Colors.white : const Color(0xFF334155),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Time
                            Text(
                              _formatTime(comment.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          currentUser.name.isNotEmpty
                              ? currentUser.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
