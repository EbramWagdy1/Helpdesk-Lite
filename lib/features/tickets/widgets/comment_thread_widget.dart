import 'package:flutter/material.dart';
import 'package:helpdesk/core/extensions/localization_extension.dart';
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

  String _localizeMessage(BuildContext context, String rawMessage) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (rawMessage.startsWith('Ticket created:') || rawMessage.startsWith('تم إنشاء التذكرة:')) {
      final prefixLen = rawMessage.startsWith('Ticket created:')
          ? 'Ticket created:'.length
          : 'تم إنشاء التذكرة:'.length;
      final title = rawMessage.substring(prefixLen).trim();
      return isAr ? 'تم إنشاء التذكرة: $title' : 'Ticket created: $title';
    }

    if (rawMessage.startsWith('Assigned ticket to ') || rawMessage.startsWith('تم إسناد التذكرة إلى ')) {
      final prefixLen = rawMessage.startsWith('Assigned ticket to ')
          ? 'Assigned ticket to '.length
          : 'تم إسناد التذكرة إلى '.length;
      final name = rawMessage.substring(prefixLen).trim();
      return isAr ? 'تم إسناد التذكرة إلى $name' : 'Assigned ticket to $name';
    }

    if (rawMessage == 'Unassigned ticket' || rawMessage == 'تم إلغاء إسناد التذكرة') {
      return isAr ? 'تم إلغاء إسناد التذكرة' : 'Unassigned ticket';
    }

    if (rawMessage.startsWith('Status changed to') || rawMessage.startsWith('تم تغيير الحالة إلى')) {
      String statusLabel = rawMessage;
      if (rawMessage.toLowerCase().contains('open') || rawMessage.contains('مفتوح')) {
        statusLabel = context.l10n.open;
      } else if (rawMessage.toLowerCase().contains('progress') || rawMessage.contains('تنفيذ')) {
        statusLabel = context.l10n.inProgress;
      } else if (rawMessage.toLowerCase().contains('resolved') || rawMessage.contains('تم الحل') || rawMessage.contains('محلول')) {
        statusLabel = context.l10n.resolved;
      } else if (rawMessage.toLowerCase().contains('closed') || rawMessage.contains('مغلق')) {
        statusLabel = context.l10n.closed;
      }
      return isAr ? 'تم تغيير الحالة إلى "$statusLabel"' : 'Status changed to "$statusLabel"';
    }

    return rawMessage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${context.l10n.activityAndMessages} (${comments.length})',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Icon(Icons.chat_bubble_outline_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ],
        ),
        const SizedBox(height: 12),

        // Comments Stream
        if (comments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(Icons.mark_chat_unread_outlined, size: 24, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                const SizedBox(height: 6),
                Text(
                  context.l10n.noMessagesYet,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_localizeMessage(context, comment.message)} • ${_formatTime(comment.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          comment.senderName.isNotEmpty
                              ? comment.senderName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? theme.colorScheme.primary : theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                  isMe ? context.l10n.you : comment.senderName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isMe ? Colors.white : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    UserRole.fromString(comment.senderRole).getLocalizedLabel(context),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isMe ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Message
                            Text(
                              _localizeMessage(context, comment.message),
                              style: TextStyle(
                                fontSize: 13,
                                color: isMe ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Time
                            Text(
                              _formatTime(comment.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                        backgroundColor: theme.colorScheme.primary,
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
