import 'package:flutter/material.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/widgets/connectivity_checker_wrapper.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_cubit.dart';
import 'package:helpdesk/features/profile/view/profile_view.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view/create_ticket_view.dart';
import 'package:helpdesk/features/tickets/view/ticket_details_view.dart';
import 'package:helpdesk/features/tickets/widgets/ticket_card_widget.dart';

class EmployeePortalView extends StatefulWidget {
  final UserModel currentUser;

  const EmployeePortalView({
    super.key,
    required this.currentUser,
  });

  @override
  State<EmployeePortalView> createState() => _EmployeePortalViewState();
}

class _EmployeePortalViewState extends State<EmployeePortalView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  TicketStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileView(user: widget.currentUser),
      ),
    );
  }

  void _openCreateTicket([TicketCategory? initialCategory]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTicketView(
          currentUser: widget.currentUser,
          initialCategory: initialCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    final user = authCubit.currentUser ?? widget.currentUser;
    final ticketRepo = sl<TicketRepository>();

    return ConnectivityCheckerWrapper(
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // User Avatar
            GestureDetector(
              onTap: () => _openProfile(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${user.department} • Employee',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: const Color(0xFF334155),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF334155)),
            tooltip: 'Profile',
            onPressed: () => _openProfile(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 3,
        highlightElevation: 5,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'New Ticket',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        onPressed: () => _openCreateTicket(),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: ticketRepo.streamTickets(createdByUid: user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load tickets: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFDC2626)),
              ),
            );
          }

          final List<TicketModel> allMyTickets = snapshot.data ?? [];

          // Apply Status Filter
          List<TicketModel> filteredTickets = List.from(allMyTickets);
          if (_selectedStatus != null) {
            filteredTickets = filteredTickets.where((t) => t.status == _selectedStatus).toList();
          }

          // Apply Search Query
          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase().trim();
            filteredTickets = filteredTickets.where((t) {
              return t.title.toLowerCase().contains(q) ||
                  t.ticketNumber.toLowerCase().contains(q) ||
                  t.description.toLowerCase().contains(q);
            }).toList();
          }

          final totalCount = allMyTickets.length;
          final openCount = allMyTickets.where((t) => t.status == TicketStatus.open).length;
          final inProgressCount = allMyTickets.where((t) => t.status == TicketStatus.inProgress).length;
          final resolvedCount = allMyTickets.where((t) => t.status == TicketStatus.resolved).length;
          final closedCount = allMyTickets.where((t) => t.status == TicketStatus.closed).length;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Collapsible Search Bar
                if (_isSearching)
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            hintText: 'Search tickets by title, description or ID...',
                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Top Header Summary & Segmented Tabs Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clean Segmented Filter Chips (All, Open, In Progress, Resolved, Closed)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'All',
                                count: totalCount,
                                isSelected: _selectedStatus == null,
                                onTap: () => setState(() => _selectedStatus = null),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Open',
                                count: openCount,
                                isSelected: _selectedStatus == TicketStatus.open,
                                color: const Color(0xFF2563EB),
                                onTap: () => setState(() {
                                  _selectedStatus = _selectedStatus == TicketStatus.open ? null : TicketStatus.open;
                                }),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'In Progress',
                                count: inProgressCount,
                                isSelected: _selectedStatus == TicketStatus.inProgress,
                                color: const Color(0xFFD97706),
                                onTap: () => setState(() {
                                  _selectedStatus = _selectedStatus == TicketStatus.inProgress ? null : TicketStatus.inProgress;
                                }),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Resolved',
                                count: resolvedCount,
                                isSelected: _selectedStatus == TicketStatus.resolved,
                                color: const Color(0xFF16A34A),
                                onTap: () => setState(() {
                                  _selectedStatus = _selectedStatus == TicketStatus.resolved ? null : TicketStatus.resolved;
                                }),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                label: 'Closed',
                                count: closedCount,
                                isSelected: _selectedStatus == TicketStatus.closed,
                                color: const Color(0xFF64748B),
                                onTap: () => setState(() {
                                  _selectedStatus = _selectedStatus == TicketStatus.closed ? null : TicketStatus.closed;
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section Title and Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Tickets (${filteredTickets.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (_selectedStatus != null || _searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedStatus = null;
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text(
                                  'Clear filter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tickets List / Empty State
                if (filteredTickets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.inbox_outlined, size: 28, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              allMyTickets.isEmpty ? 'No support tickets yet' : 'No matching tickets',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              allMyTickets.isEmpty
                                  ? 'Tap "+ New Ticket" below to submit your first request.'
                                  : 'Try adjusting your search or selected status.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (allMyTickets.isEmpty) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Create Ticket', style: TextStyle(fontWeight: FontWeight.w600)),
                                onPressed: () => _openCreateTicket(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ticket = filteredTickets[index];
                          return TicketCardWidget(
                            ticket: ticket,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TicketDetailsView(
                                    ticketId: ticket.id,
                                    currentUser: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: filteredTickets.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
