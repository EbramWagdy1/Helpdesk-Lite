import 'package:flutter/material.dart';
import 'package:helpdesk/app/helpdesk_lite.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/errors/error_handler.dart';
import 'package:helpdesk/core/services/firebase_service.dart';
import 'package:helpdesk/core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 0. Initialize Global App Error Handling
  ErrorHandler.initGlobalErrorHandling();

  // 1. Initialize Cache Helper
  await CacheHelper.init();

  // 2. Initialize Firebase BaaS
  await FirebaseService.init();

  // 3. Register Dependency Injection
  setupServiceLocator();

  runApp(const HelpDeskLiteApp());
}
