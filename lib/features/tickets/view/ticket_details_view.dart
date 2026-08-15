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
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Ticket', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete this ticket and all of its conversation history? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
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
    final matchingAgents = agents
        .where((agent) => ticket.category.matchesDepartment(agent.department))
        .toList();
    final otherAgents = agents
        .where((agent) => !ticket.category.matchesDepartment(agent.department))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                      const Text(
                        'Assign Agent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assign this ${ticket.category.label} ticket to a support specialist:',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  if (agents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No support agents found.')),
                    )
                  else ...[
                    if (matchingAgents.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${ticket.category.label} Agents (${matchingAgents.length})',
                          style: const TextStyle(
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
                            color: isCurrentAssignee ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrentAssignee ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF0F172A),
                              child: Text(
                                agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(agent.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ),
                                if (agent.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const VerifiedBadgeWidget(size: 14),
                                ],
                              ],
                            ),
                            subtitle: Text('${agent.department} • ${agent.email}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            trailing: isCurrentAssignee
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Other Department Agents',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      ...otherAgents.map((agent) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF64748B),
                              child: Text(
                                agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(agent.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ),
                                if (agent.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const VerifiedBadgeWidget(size: 14),
                                ],
                              ],
                            ),
                            subtitle: Text('${agent.department} • ${agent.email}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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

    return BlocProvider(
      create: (context) => TicketDetailsCubit()..init(widget.ticketId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Ticket Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
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
              return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)));
            }

            if (state is TicketDetailsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                    const SizedBox(height: 12),
                    Text(state.errorMessage, style: const TextStyle(color: Color(0xFF64748B))),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ticket.ticketNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF475569),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Department & Created Date
                              Row(
                                children: [
                                  Icon(ticket.category.icon, size: 14, color: const Color(0xFF64748B)),
                                  const SizedBox(width: 5),
                                  Text(
                                    ticket.category.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Opened ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 14),

                              // Description
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ticket.description.isNotEmpty ? ticket.description : 'No description provided.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF334155),
                                  height: 1.5,
                                ),
                              ),

                              // Attachments Strip (if any)
                              if (ticket.attachmentUrls.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Attachments',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
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
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
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

                        // Workflow Actions Strip (for Agent / Manager)
                        if (isStaff || widget.currentUser.uid == ticket.createdBy.uid) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WORKFLOW ACTIONS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // Claim Ticket
                                    if (isStaff && ticket.assignedTo == null)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                        label: const Text('Claim Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        onPressed: () => cubit.claimTicket(widget.currentUser),
                                      ),

                                    // Reassign (Manager)
                                    if (isManager)
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF475569),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                                        label: const Text('Reassign', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        onPressed: () => _showReassignDialog(context, cubit, loaded.availableAgents, ticket),
                                      ),

                                    // Move to In Progress
                                    if (isStaff && ticket.status == TicketStatus.open)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD97706),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                        label: const Text('Start Working', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        onPressed: () => cubit.updateStatus(
                                          newStatus: TicketStatus.inProgress,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),

                                    // Mark as Resolved
                                    if (isStaff && ticket.status == TicketStatus.inProgress)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF16A34A),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                        label: const Text('Mark Resolved', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        onPressed: () => cubit.updateStatus(
                                          newStatus: TicketStatus.resolved,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),

                                    // Close Ticket
                                    if (ticket.status != TicketStatus.closed)
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF64748B),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        icon: const Icon(Icons.lock_outline_rounded, size: 16),
                                        label: const Text('Close Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        onPressed: () => cubit.updateStatus(
                                          newStatus: TicketStatus.closed,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),

                                    // Delete Ticket
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFDC2626),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                      label: const Text('Delete Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      onPressed: () => _confirmDeleteTicket(context, cubit),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Stakeholders Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              // Requester
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Requested by', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                        Text(
                                          ticket.createdBy.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (ticket.createdBy.department != null)
                                    Text(
                                      ticket.createdBy.department!,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                              const Divider(height: 18, color: Color(0xFFF1F5F9)),

                              // Assignee
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: ticket.assignedTo != null ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7),
                                    child: Icon(
                                      ticket.assignedTo != null ? Icons.support_agent_rounded : Icons.person_off_outlined,
                                      size: 18,
                                      color: ticket.assignedTo != null ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Assigned Specialist', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                ticket.assignedTo != null ? ticket.assignedTo!.name : 'Unassigned',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: ticket.assignedTo != null ? const Color(0xFF0F172A) : const Color(0xFFD97706),
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
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              hintText: 'Write a response or update...',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                            ),
                            maxLines: 3,
                            minLines: 1,
                            onSubmitted: (_) => _sendComment(cubit),
                          ),
                        ),
                        IconButton(
                          onPressed: loaded.isSubmittingComment ? null : () => _sendComment(cubit),
                          icon: loaded.isSubmittingComment
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                                )
                              : const Icon(Icons.send_rounded, color: Color(0xFF2563EB), size: 20),
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
}
