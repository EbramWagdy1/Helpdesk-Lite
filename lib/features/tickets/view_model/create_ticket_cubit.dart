import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/errors/error_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/core/services/storage_service.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';
import 'package:helpdesk/features/tickets/model/ticket_model.dart';
import 'package:helpdesk/features/tickets/view_model/create_ticket_state.dart';

class AttachmentItem {
  final String name;
  final Uint8List bytes;
  final String contentType;

  AttachmentItem({
    required this.name,
    required this.bytes,
    required this.contentType,
  });
}

class CreateTicketCubit extends Cubit<CreateTicketState> {
  final TicketRepository _ticketRepository;
  final StorageService _storageService;
  final ImagePicker _picker = ImagePicker();

  CreateTicketCubit({
    TicketRepository? ticketRepository,
    StorageService? storageService,
  })  : _ticketRepository = ticketRepository ?? sl<TicketRepository>(),
        _storageService = storageService ?? sl<StorageService>(),
        super(CreateTicketInitialState());

  TicketCategory selectedCategory = TicketCategory.it;
  TicketPriority selectedPriority = TicketPriority.medium;
  final List<AttachmentItem> attachments = [];

  void setCategory(TicketCategory category) {
    selectedCategory = category;
    emit(CreateTicketCategoryChangedState(category));
  }

  void setPriority(TicketPriority priority) {
    selectedPriority = priority;
    emit(CreateTicketPriorityChangedState(priority));
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        attachments.add(
          AttachmentItem(
            name: file.name,
            bytes: bytes,
            contentType: file.mimeType ?? 'image/jpeg',
          ),
        );
        emit(CreateTicketAttachmentsChangedState(attachments.length));
      }
    } catch (e) {
      emit(CreateTicketErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
      emit(CreateTicketAttachmentsChangedState(attachments.length));
    }
  }

  Future<void> submitTicket({
    required String title,
    required String description,
    required UserModel currentUser,
  }) async {
    if (title.trim().isEmpty) {
      emit(CreateTicketErrorState('Please enter a ticket title.'));
      return;
    }

    emit(CreateTicketLoadingState());

    try {
      // 1. Upload attachments if any
      final List<String> attachmentUrls = [];
      for (int i = 0; i < attachments.length; i++) {
        final item = attachments[i];
        final path = 'tickets/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_${item.name}';
        final url = await _storageService.uploadAttachment(
          path: path,
          bytes: item.bytes,
          contentType: item.contentType,
        );
        attachmentUrls.add(url);
      }

      // 2. Create ticket document in Firestore
      final ticket = await _ticketRepository.createTicket(
        title: title,
        description: description,
        category: selectedCategory,
        priority: selectedPriority,
        createdBy: TicketUserModel(
          uid: currentUser.uid,
          name: currentUser.name,
          email: currentUser.email,
          department: currentUser.department,
        ),
        attachmentUrls: attachmentUrls,
      );

      emit(CreateTicketSuccessState(ticket));
    } catch (e) {
      emit(CreateTicketErrorState(ErrorHandler.getErrorMessage(e)));
    }
  }
}
