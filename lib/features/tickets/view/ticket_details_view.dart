import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/widgets/custom_snackbar.dart';
import 'package:helpdesk/core/widgets/verified_badge_widget.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_details_cubit.dart';
import 'package:helpdesk/features/tickets/view_model/ticket_details_state.dart';
import 'package:helpdesk/features/tickets/widgets/comment_thread_widget.dart';

class TicketDetailsView extends StatefulWidget {
  final String ticketId;
  final UserModel currentUser;

  const TicketDetailsView({
    super.key,
    required this.ticketId,
    required this.currentUser,
  });

  @override
  State<TicketDetailsView> createState() => _TicketDetailsViewState();
}

class _TicketDetailsViewState extends State<TicketDetailsView> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment(TicketDetailsCubit cubit) {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      cubit.addComment(
        message: text,
        currentUser: widget.currentUser,
      );
      _commentController.clear();
    }
  }

  void _confirmDeleteTicket(BuildContext context, TicketDetailsCubit cubit) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Text('Delete Ticket', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: theme.colorScheme.onSurface)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this ticket and all of its conversation history? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              cubit.deleteTicket();
            },
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(
    BuildContext context,
    TicketDetailsCubit cubit,
    List<UserModel> agents,
    TicketModel ticket,
  ) {
    final theme = Theme.of(context);
    final matchingAgents = agents
        .where((agent) => ticket.category.matchesDepartment(agent.department))
        .toList();
    final otherAgents = agents
        .where((agent) => !ticket.category.matchesDepartment(agent.department))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assign Agent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assign this ${ticket.category.label} ticket to a support specialist:',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),

                  if (agents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No support agents found.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),
                    )
                  else ...[
                    if (matchingAgents.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: const Text(
                          'Department Matching Specialists',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      ...matchingAgents.map((agent) {
                        final isCurrentAssignee = ticket.assignedTo?.uid == agent.uid;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isCurrentAssignee ? theme.colorScheme.primary.withValues(alpha: 0.12) : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrentAssignee ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(agent.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                                ),
                                if (agent.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const VerifiedBadgeWidget(size: 14),
                                ],
                              ],
                            ),
                            subtitle: Text('${agent.department} • ${agent.email}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            trailing: isCurrentAssignee
                                ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20)
                                : null,
                            onTap: () {
                              Navigator.pop(ctx);
                              cubit.assignToAgent(agent: agent, currentUser: widget.currentUser);
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    if (otherAgents.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Other Department Agents',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      ...otherAgents.map((agent) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              child: Text(
                                agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(agent.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                                ),
                                if (agent.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const VerifiedBadgeWidget(size: 14),
                                ],
                              ],
                            ),
                            subtitle: Text('${agent.department} • ${agent.email}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                            onTap: () {
                              Navigator.pop(ctx);
                              cubit.assignToAgent(agent: agent, currentUser: widget.currentUser);
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = widget.currentUser.role != UserRole.employee;
    final isManager = widget.currentUser.role == UserRole.manager;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => TicketDetailsCubit()..init(widget.ticketId),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Ticket Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<TicketDetailsCubit, TicketDetailsState>(
          listener: (context, state) {
            if (state is TicketDetailsErrorState) {
              CustomSnackBar.showError(context, message: state.errorMessage);
            } else if (state is TicketDetailsDeletedState) {
              CustomSnackBar.showSuccess(context, message: 'Ticket deleted successfully');
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is TicketDetailsLoadingState || state is TicketDetailsInitialState) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary));
            }

            if (state is TicketDetailsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                    const SizedBox(height: 12),
                    Text(state.errorMessage, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            if (state is! TicketDetailsLoadedState) {
              return const SizedBox.shrink();
            }

            final loaded = state;
            final ticket = loaded.ticket;
            final cubit = BlocProvider.of<TicketDetailsCubit>(context);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Main Unified Ticket Header Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Meta Row: ID, Priority, Status
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ticket.ticketNumber,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: ticket.status.bgColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: ticket.status.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          ticket.status.label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: ticket.status.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: ticket.priority.bgColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ticket.priority.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: ticket.priority.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Title
                              Text(
                                ticket.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Department & Created Date
                              Row(
                                children: [
                                  Icon(ticket.category.icon, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  const SizedBox(width: 5),
                                  Text(
                                    ticket.category.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('•', style: TextStyle(color: theme.colorScheme.outline)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Opened ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(height: 1, color: theme.dividerColor),
                              const SizedBox(height: 14),

                              // Description
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ticket.description.isNotEmpty ? ticket.description : 'No description provided.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                  height: 1.5,
                                ),
                              ),

                              // Attachments Strip (if any)
                              if (ticket.attachmentUrls.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Attachments',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: ticket.attachmentUrls.map((url) {
                                    return GestureDetector(
                                      onTap: () => _showImagePreview(context, url),
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(9),
                                          child: Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (ctx, child, progress) {
                                              if (progress == null) return child;
                                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Modern Workflow Actions Section (for Agent, Manager, or Ticket Creator)
                        if (isStaff || widget.currentUser.uid == ticket.createdBy.uid) ...[
                          _buildWorkflowSection(
                            context: context,
                            cubit: cubit,
                            ticket: ticket,
                            availableAgents: loaded.availableAgents,
                            isStaff: isStaff,
                            isManager: isManager,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Stakeholders Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              // Requester
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    child: Icon(Icons.person_outline_rounded, size: 18, color: theme.colorScheme.onSurface),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Requested by', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                                        Text(
                                          ticket.createdBy.name,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (ticket.createdBy.department != null)
                                    Text(
                                      ticket.createdBy.department!,
                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                              Divider(height: 18, color: theme.dividerColor),

                              // Assignee
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: ticket.assignedTo != null ? theme.colorScheme.primary.withValues(alpha: 0.15) : const Color(0xFFFEF3C7),
                                    child: Icon(
                                      ticket.assignedTo != null ? Icons.support_agent_rounded : Icons.person_off_outlined,
                                      size: 18,
                                      color: ticket.assignedTo != null ? theme.colorScheme.primary : const Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Assigned Specialist', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                ticket.assignedTo != null ? ticket.assignedTo!.name : 'Unassigned',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: ticket.assignedTo != null ? theme.colorScheme.onSurface : const Color(0xFFD97706),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (ticket.assignedTo != null && ticket.assignedTo!.isVerified) ...[
                                              const SizedBox(width: 4),
                                              const VerifiedBadgeWidget(size: 14),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (ticket.assignedTo != null && ticket.assignedTo!.department != null)
                                    Text(
                                      ticket.assignedTo!.department!,
                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Real-time Conversation & Comments Thread
                        CommentThreadWidget(
                          comments: loaded.comments,
                          currentUser: widget.currentUser,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Docked Chat Input Bar at the Bottom
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 6
                        : 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4))),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Write a response or update...',
                              hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                            ),
                            maxLines: 3,
                            minLines: 1,
                            onSubmitted: (_) => _sendComment(cubit),
                          ),
                        ),
                        IconButton(
                          onPressed: loaded.isSubmittingComment ? null : () => _sendComment(cubit),
                          icon: loaded.isSubmittingComment
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                                )
                              : Icon(Icons.send_rounded, color: theme.colorScheme.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildWorkflowSection({
    required BuildContext context,
    required TicketDetailsCubit cubit,
    required TicketModel ticket,
    required List<UserModel> availableAgents,
    required bool isStaff,
    required bool isManager,
  }) {
    final theme = Theme.of(context);
    final status = ticket.status;

    // Define Pipeline stages
    final stages = [
      {'status': TicketStatus.open, 'label': 'Open'},
      {'status': TicketStatus.inProgress, 'label': 'In Progress'},
      {'status': TicketStatus.resolved, 'label': 'Resolved'},
      {'status': TicketStatus.closed, 'label': 'Closed'},
    ];

    final currentStageIndex = stages.indexWhere((s) => s['status'] == status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Active Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.alt_route_rounded, size: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WORKFLOW PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: status.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lifecycle Stepper Track
          Row(
            children: List.generate(stages.length * 2 - 1, (index) {
              if (index.isOdd) {
                final stageBefore = index ~/ 2;
                final isPassed = stageBefore < currentStageIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                );
              }

              final stageIdx = index ~/ 2;
              final isCompleted = stageIdx < currentStageIndex;
              final isCurrent = stageIdx == currentStageIndex;

              Color stepBg = theme.colorScheme.surfaceContainerHighest;
              Color stepIconColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
              Widget iconWidget = Text(
                '${stageIdx + 1}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: stepIconColor),
              );

              if (isCompleted) {
                stepBg = theme.colorScheme.primary;
                stepIconColor = Colors.white;
                iconWidget = const Icon(Icons.check_rounded, size: 12, color: Colors.white);
              } else if (isCurrent) {
                stepBg = status.color;
                stepIconColor = Colors.white;
                iconWidget = const Icon(Icons.circle, size: 8, color: Colors.white);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stepBg,
                      border: isCurrent
                          ? Border.all(color: status.color.withValues(alpha: 0.3), width: 3)
                          : null,
                    ),
                    child: Center(child: iconWidget),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stages[stageIdx]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 18),

          // Primary Contextual CTA
          _buildPrimaryWorkflowAction(
            context: context,
            cubit: cubit,
            ticket: ticket,
            isStaff: isStaff,
            isCreator: widget.currentUser.uid == ticket.createdBy.uid,
          ),

          // Secondary Quick Actions Row
          const SizedBox(height: 10),
          Row(
            children: [
              // Reassign (for Managers only)
              if (isManager) ...[
                Expanded(
                  child: _buildSecondaryActionButton(
                    context: context,
                    label: 'Reassign',
                    icon: Icons.swap_horiz_rounded,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    borderColor: theme.colorScheme.outline.withValues(alpha: 0.5),
                    onTap: () => _showReassignDialog(context, cubit, availableAgents, ticket),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Creator can cancel/close their own open ticket
              if (widget.currentUser.uid == ticket.createdBy.uid && status == TicketStatus.open) ...[
                Expanded(
                  child: _buildSecondaryActionButton(
                    context: context,
                    label: 'Cancel Request',
                    icon: Icons.close_rounded,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    borderColor: theme.colorScheme.outline.withValues(alpha: 0.5),
                    onTap: () => cubit.updateStatus(
                      newStatus: TicketStatus.closed,
                      currentUser: widget.currentUser,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Delete Ticket
              Expanded(
                child: _buildSecondaryActionButton(
                  context: context,
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: const Color(0xFFFEF2F2).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFFDC2626),
                  borderColor: const Color(0xFFFECACA).withValues(alpha: 0.5),
                  onTap: () => _confirmDeleteTicket(context, cubit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryWorkflowAction({
    required BuildContext context,
    required TicketDetailsCubit cubit,
    required TicketModel ticket,
    required bool isStaff,
    required bool isCreator,
  }) {
    final theme = Theme.of(context);

    // 1. Open and Unassigned (Agent/Manager can claim)
    if (ticket.status == TicketStatus.open && ticket.assignedTo == null && isStaff) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: const Text(
            'Claim & Start Ticket',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          onPressed: () => cubit.claimTicket(widget.currentUser),
        ),
      );
    }

    // 2. Open and Assigned (Staff starts working)
    if (ticket.status == TicketStatus.open && isStaff) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text(
            'Start Working (In Progress)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          onPressed: () => cubit.updateStatus(
            newStatus: TicketStatus.inProgress,
            currentUser: widget.currentUser,
          ),
        ),
      );
    }

    // 3. In Progress (Staff marks as Resolved)
    if (ticket.status == TicketStatus.inProgress && isStaff) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text(
            'Mark as Resolved',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          onPressed: () => cubit.updateStatus(
            newStatus: TicketStatus.resolved,
            currentUser: widget.currentUser,
          ),
        ),
      );
    }

    // 4. Resolved - ONLY the Employee / Creator verifies and closes the ticket
    if (ticket.status == TicketStatus.resolved) {
      if (isCreator) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The support team marked this ticket as resolved. Please test and confirm to close it.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Reopen if still not fixed
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(color: Color(0xFFFCD34D)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text(
                      'Not Fixed',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    onPressed: () => cubit.updateStatus(
                      newStatus: TicketStatus.inProgress,
                      currentUser: widget.currentUser,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Accept & Close
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text(
                      'Approve & Close',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    onPressed: () => cubit.updateStatus(
                      newStatus: TicketStatus.closed,
                      currentUser: widget.currentUser,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        // For Agent / Manager: Inform that it's waiting for Employee confirmation
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, size: 20, color: Color(0xFF16A34A)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resolved • Awaiting employee testing and confirmation to close.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    // 5. Closed - Creator can reopen if needed
    if (ticket.status == TicketStatus.closed) {
      if (isCreator) {
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text(
              'Reopen Ticket',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: () => cubit.updateStatus(
              newStatus: TicketStatus.open,
              currentUser: widget.currentUser,
            ),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This ticket is closed and archived by the employee.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSecondaryActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
