import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpdesk/core/l10n/app_localizations.dart';
import 'package:helpdesk/core/utils/app_colors.dart';

enum TicketCategory {
  it('IT & Systems', Icons.computer_rounded),
  hr('Human Resources', Icons.people_outline_rounded),
  facilities('Facilities & Office', Icons.apartment_rounded),
  operations('Operations', Icons.settings_suggest_outlined),
  finance('Finance & Payroll', Icons.account_balance_wallet_outlined),
  other('Other Support', Icons.help_outline_rounded);

  final String label;
  final IconData icon;
  const TicketCategory(this.label, this.icon);

  static TicketCategory fromString(String? value) {
    return TicketCategory.values.firstWhere(
      (cat) => cat.name == value?.toLowerCase(),
      orElse: () => TicketCategory.other,
    );
  }

  bool matchesDepartment(String? department) {
    if (department == null || department.isEmpty) return true;
    final dept = department.toLowerCase().trim();
    switch (this) {
      case TicketCategory.it:
        return dept.contains('it') || dept.contains('system') || dept.contains('tech');
      case TicketCategory.hr:
        return dept.contains('hr') || dept.contains('human resource') || dept.contains('personnel');
      case TicketCategory.facilities:
        return dept.contains('facilit') || dept.contains('office');
      case TicketCategory.operations:
        return dept.contains('operation') || dept.contains('ops');
      case TicketCategory.finance:
        return dept.contains('finance') || dept.contains('payroll') || dept.contains('account');
      case TicketCategory.other:
        return true;
    }
  }

  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (this) {
      case TicketCategory.it:
        return l10n.categoryIT;
      case TicketCategory.hr:
        return l10n.categoryHR;
      case TicketCategory.facilities:
        return l10n.categoryFacilities;
      case TicketCategory.operations:
        return l10n.categoryOperations;
      case TicketCategory.finance:
        return l10n.categoryFinance;
      case TicketCategory.other:
        return l10n.categoryOther;
    }
  }
}

enum TicketPriority {
  low('Low', AppColors.priorityLow, AppColors.priorityLowBg),
  medium('Medium', AppColors.priorityMedium, AppColors.priorityMediumBg),
  high('High', AppColors.priorityHigh, AppColors.priorityHighBg),
  urgent('Urgent', Color(0xFFDC2626), Color(0xFFFEE2E2));

  final String label;
  final Color color;
  final Color bgColor;
  const TicketPriority(this.label, this.color, this.bgColor);

  static TicketPriority fromString(String? value) {
    return TicketPriority.values.firstWhere(
      (p) => p.name == value?.toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }

  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (this) {
      case TicketPriority.low:
        return l10n.priorityLow;
      case TicketPriority.medium:
        return l10n.priorityMedium;
      case TicketPriority.high:
        return l10n.priorityHigh;
      case TicketPriority.urgent:
        return l10n.priorityUrgent;
    }
  }
}

enum TicketStatus {
  open('Open', AppColors.statusOpen, AppColors.statusOpenBg),
  inProgress('In Progress', AppColors.statusInProgress, AppColors.statusInProgressBg),
  resolved('Resolved', AppColors.statusResolved, AppColors.statusResolvedBg),
  closed('Closed', AppColors.statusClosed, AppColors.statusClosedBg);

  final String label;
  final Color color;
  final Color bgColor;
  const TicketStatus(this.label, this.color, this.bgColor);

  static TicketStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'open':
      default:
        return TicketStatus.open;
    }
  }

  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (this) {
      case TicketStatus.open:
        return l10n.open;
      case TicketStatus.inProgress:
        return l10n.inProgress;
      case TicketStatus.resolved:
        return l10n.resolved;
      case TicketStatus.closed:
        return l10n.closed;
    }
  }
}

class TicketUserModel {
  final String uid;
  final String name;
  final String email;
  final String? department;
  final bool isVerified;

  const TicketUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.department,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'isVerified': isVerified,
    if (department != null) 'department': department,
  };

  factory TicketUserModel.fromMap(Map<String, dynamic> map) {
    return TicketUserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'],
      isVerified: map['isVerified'] ?? false,
    );
  }
}

class TicketModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final TicketUserModel createdBy;
  final TicketUserModel? assignedTo;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    this.category = TicketCategory.other,
    this.priority = TicketPriority.medium,
    this.status = TicketStatus.open,
    required this.createdBy,
    this.assignedTo,
    this.attachmentUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.closedAt,
  });

  TicketModel copyWith({
    String? id,
    String? ticketNumber,
    String? title,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    TicketUserModel? createdBy,
    TicketUserModel? assignedTo,
    bool clearAssignedTo = false,
    List<String>? attachmentUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'createdBy': createdBy.toMap(),
      'assignedTo': assignedTo?.toMap(),
      'attachmentUrls': attachmentUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    return TicketModel(
      id: id,
      ticketNumber: map['ticketNumber'] ?? 'HD-${id.substring(0, id.length > 5 ? 5 : id.length).toUpperCase()}',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: TicketCategory.fromString(map['category']),
      priority: TicketPriority.fromString(map['priority']),
      status: TicketStatus.fromString(map['status']),
      createdBy: TicketUserModel.fromMap(Map<String, dynamic>.from(map['createdBy'] ?? {})),
      assignedTo: map['assignedTo'] != null
          ? TicketUserModel.fromMap(Map<String, dynamic>.from(map['assignedTo']))
          : null,
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      resolvedAt: (map['resolvedAt'] is Timestamp)
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      closedAt: (map['closedAt'] is Timestamp)
          ? (map['closedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
