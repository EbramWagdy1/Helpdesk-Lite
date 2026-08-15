import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpdesk/core/services/firebase_service.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/services/storage_service.dart';
import 'package:helpdesk/features/tickets/model/comment_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';

class TicketRepository {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  CollectionReference<Map<String, dynamic>> get _ticketsCollection =>
      _firestore.collection('tickets');

  /// Streams tickets with optional filters
  Stream<List<TicketModel>> streamTickets({
    String? createdByUid,
    String? assignedToUid,
    TicketStatus? statusFilter,
  }) {
    Query<Map<String, dynamic>> query = _ticketsCollection;

    if (createdByUid != null && createdByUid.isNotEmpty) {
      query = query.where('createdBy.uid', isEqualTo: createdByUid);
    }

    if (assignedToUid != null && assignedToUid.isNotEmpty) {
      query = query.where('assignedTo.uid', isEqualTo: assignedToUid);
    }

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.name);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory by createdAt descending
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Streams a single ticket by its ID
  Stream<TicketModel?> streamTicketById(String ticketId) {
    return _ticketsCollection.doc(ticketId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return TicketModel.fromMap(doc.data()!, doc.id);
    });
  }

  /// Generates a friendly unique ticket number like HD-1042
  String _generateTicketNumber() {
    final randomSuffix = 1000 + Random().nextInt(9000);
    return 'HD-$randomSuffix';
  }

  /// Creates a new support ticket
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required TicketUserModel createdBy,
    List<String> attachmentUrls = const [],
  }) async {
    final docRef = _ticketsCollection.doc();
    final now = DateTime.now();
    final ticketNumber = _generateTicketNumber();

    final ticket = TicketModel(
      id: docRef.id,
      ticketNumber: ticketNumber,
      title: title.trim(),
      description: description.trim(),
      category: category,
      priority: priority,
      status: TicketStatus.open,
      createdBy: createdBy,
      attachmentUrls: attachmentUrls,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(ticket.toMap());

    // Add initial activity/comment
    await addComment(
      ticketId: docRef.id,
      senderId: createdBy.uid,
      senderName: createdBy.name,
      senderRole: 'Employee',
      message: 'Ticket created: $title',
    );

    return ticket;
  }

  /// Updates ticket status (e.g. In Progress, Resolved, Closed)
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus newStatus,
    required String performedByName,
    required String performedByRole,
  }) async {
    final now = DateTime.now();
    final Map<String, dynamic> updates = {
      'status': newStatus.name,
      'updatedAt': Timestamp.fromDate(now),
    };

    if (newStatus == TicketStatus.resolved) {
      updates['resolvedAt'] = Timestamp.fromDate(now);
    } else if (newStatus == TicketStatus.closed) {
      updates['closedAt'] = Timestamp.fromDate(now);
    }

    await _ticketsCollection.doc(ticketId).update(updates);

    // Record activity in comments
    await addComment(
      ticketId: ticketId,
      senderId: 'system',
      senderName: performedByName,
      senderRole: performedByRole,
      message: 'Status changed to "${newStatus.label}"',
      isInternal: false,
    );
  }

  /// Assigns a ticket to a support agent
  Future<void> assignTicket({
    required String ticketId,
    required TicketUserModel? agent,
    required String performedByName,
    required String performedByRole,
  }) async {
    final now = DateTime.now();
    final Map<String, dynamic> updates = {
      'assignedTo': agent?.toMap(),
      'updatedAt': Timestamp.fromDate(now),
    };

    // If previously open and now assigned, move to In Progress automatically
    if (agent != null) {
      updates['status'] = TicketStatus.inProgress.name;
    }

    await _ticketsCollection.doc(ticketId).update(updates);

    final actionMsg = agent != null
        ? 'Assigned ticket to ${agent.name}'
        : 'Unassigned ticket';

    await addComment(
      ticketId: ticketId,
      senderId: 'system',
      senderName: performedByName,
      senderRole: performedByRole,
      message: actionMsg,
      isInternal: false,
    );
  }

  /// Streams comments in chronological order for a ticket
  Stream<List<CommentModel>> streamComments(String ticketId) {
    return _ticketsCollection
        .doc(ticketId)
        .collection('comments')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Adds a comment or activity note
  Future<void> addComment({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    List<String> attachmentUrls = const [],
    bool isInternal = false,
  }) async {
    final commentDoc = _ticketsCollection.doc(ticketId).collection('comments').doc();
    final now = DateTime.now();

    final comment = CommentModel(
      id: commentDoc.id,
      ticketId: ticketId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message.trim(),
      attachmentUrls: attachmentUrls,
      createdAt: now,
      isInternal: isInternal,
    );

    await commentDoc.set(comment.toMap());

    // Bump updatedAt on parent ticket
    await _ticketsCollection.doc(ticketId).update({
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Delete a ticket and all associated data
  Future<void> deleteTicket(String ticketId, [List<String>? attachmentUrls]) async {
    try {
      // 1. Delete comments subcollection
      final commentsSnapshot = await _ticketsCollection.doc(ticketId).collection('comments').get();
      for (final doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete attachments from Storage if available
      if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
        try {
          final storage = sl<StorageService>();
          for (final url in attachmentUrls) {
            await storage.deleteFile(url);
          }
        } catch (_) {}
      }

      // 3. Delete parent ticket document
      await _ticketsCollection.doc(ticketId).delete();
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }
}
