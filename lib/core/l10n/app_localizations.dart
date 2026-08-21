import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'HelpDesk Lite'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your daily tasks efficiently'**
  String get splashTagline;

  /// No description provided for @smartWorkplaceHub.
  ///
  /// In en, this message translates to:
  /// **'Smart Workplace & Support Hub'**
  String get smartWorkplaceHub;

  /// No description provided for @enterpriseGradeSecurity.
  ///
  /// In en, this message translates to:
  /// **'Enterprise-Grade • Secure Workspace'**
  String get enterpriseGradeSecurity;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue managing your workspace'**
  String get loginSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us and boost your productivity'**
  String get registerSubtitle;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @workspaceRole.
  ///
  /// In en, this message translates to:
  /// **'Workspace Role'**
  String get workspaceRole;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select Department'**
  String get selectDepartment;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +1 234 567 8900'**
  String get phoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @signOutPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from the workspace?'**
  String get signOutPrompt;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters with letters and numbers'**
  String get invalidPassword;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @roleAgent.
  ///
  /// In en, this message translates to:
  /// **'Support Agent'**
  String get roleAgent;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Operations Manager'**
  String get roleManager;

  /// No description provided for @operationsManagerExecutive.
  ///
  /// In en, this message translates to:
  /// **'Operations Manager • Executive'**
  String get operationsManagerExecutive;

  /// No description provided for @supportAgentOnDuty.
  ///
  /// In en, this message translates to:
  /// **'Support Agent • On-Duty'**
  String get supportAgentOnDuty;

  /// No description provided for @verifiedSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Verified Specialist'**
  String get verifiedSpecialist;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @totalAgents.
  ///
  /// In en, this message translates to:
  /// **'Total Agents'**
  String get totalAgents;

  /// No description provided for @activeTickets.
  ///
  /// In en, this message translates to:
  /// **'Active Tickets'**
  String get activeTickets;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @deptQueue.
  ///
  /// In en, this message translates to:
  /// **'Dept Queue'**
  String get deptQueue;

  /// No description provided for @assignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to Me'**
  String get assignedToMe;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openPending.
  ///
  /// In en, this message translates to:
  /// **'Open / Pending'**
  String get openPending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @categoryIT.
  ///
  /// In en, this message translates to:
  /// **'IT & Systems'**
  String get categoryIT;

  /// No description provided for @categoryHR.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get categoryHR;

  /// No description provided for @categoryFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities & Office'**
  String get categoryFacilities;

  /// No description provided for @categoryOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get categoryOperations;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance & Payroll'**
  String get categoryFinance;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other Support'**
  String get categoryOther;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @newTicket.
  ///
  /// In en, this message translates to:
  /// **'New Ticket'**
  String get newTicket;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @filterTickets.
  ///
  /// In en, this message translates to:
  /// **'Filter Tickets'**
  String get filterTickets;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @searchTicketsHint.
  ///
  /// In en, this message translates to:
  /// **'Search tickets across company...'**
  String get searchTicketsHint;

  /// No description provided for @searchDepartmentTicketsHint.
  ///
  /// In en, this message translates to:
  /// **'Search department tickets, ID, requester...'**
  String get searchDepartmentTicketsHint;

  /// No description provided for @searchAgentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search support specialists...'**
  String get searchAgentsHint;

  /// No description provided for @writeResponseHint.
  ///
  /// In en, this message translates to:
  /// **'Write a response or update...'**
  String get writeResponseHint;

  /// No description provided for @activityAndMessages.
  ///
  /// In en, this message translates to:
  /// **'Activity & Messages'**
  String get activityAndMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Send a note below.'**
  String get noMessagesYet;

  /// No description provided for @workflowProgress.
  ///
  /// In en, this message translates to:
  /// **'WORKFLOW PROGRESS'**
  String get workflowProgress;

  /// No description provided for @claimAndStartTicket.
  ///
  /// In en, this message translates to:
  /// **'Claim & Start Ticket'**
  String get claimAndStartTicket;

  /// No description provided for @startWorking.
  ///
  /// In en, this message translates to:
  /// **'Start Working (In Progress)'**
  String get startWorking;

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Resolved'**
  String get markAsResolved;

  /// No description provided for @approveAndClose.
  ///
  /// In en, this message translates to:
  /// **'Approve & Close'**
  String get approveAndClose;

  /// No description provided for @notFixed.
  ///
  /// In en, this message translates to:
  /// **'Not Fixed'**
  String get notFixed;

  /// No description provided for @reopenTicket.
  ///
  /// In en, this message translates to:
  /// **'Reopen Ticket'**
  String get reopenTicket;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @deleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Delete Ticket'**
  String get deleteTicket;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @assignAgent.
  ///
  /// In en, this message translates to:
  /// **'Assign Agent'**
  String get assignAgent;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @addFileOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add File/Photo'**
  String get addFileOrPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @assignedSpecialistTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned Specialist'**
  String get assignedSpecialistTitle;

  /// No description provided for @teamAnalyticsAndWorkload.
  ///
  /// In en, this message translates to:
  /// **'Team Analytics & Workload'**
  String get teamAnalyticsAndWorkload;

  /// No description provided for @ticketsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Tickets by Category'**
  String get ticketsByCategory;

  /// No description provided for @ticketsByDepartment.
  ///
  /// In en, this message translates to:
  /// **'Tickets by Department'**
  String get ticketsByDepartment;

  /// No description provided for @priorityDistribution.
  ///
  /// In en, this message translates to:
  /// **'Priority Distribution'**
  String get priorityDistribution;

  /// No description provided for @activeWorkloadPerAgent.
  ///
  /// In en, this message translates to:
  /// **'Active Workload per Agent'**
  String get activeWorkloadPerAgent;

  /// No description provided for @totalTickets.
  ///
  /// In en, this message translates to:
  /// **'Total Tickets'**
  String get totalTickets;

  /// No description provided for @resolutionRate.
  ///
  /// In en, this message translates to:
  /// **'Resolution Rate'**
  String get resolutionRate;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'Support Team'**
  String get supportTeam;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light mode enabled'**
  String get lightModeEnabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @phoneNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get phoneNotProvided;

  /// No description provided for @settingsAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS & SECURITY'**
  String get settingsAndSecurity;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @openedOn.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get openedOn;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescriptionProvided;

  /// No description provided for @otherDepartmentAgents.
  ///
  /// In en, this message translates to:
  /// **'Other Department Agents'**
  String get otherDepartmentAgents;

  /// No description provided for @deleteTicketConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this ticket and all of its conversation history? This action cannot be undone.'**
  String get deleteTicketConfirmMessage;

  /// No description provided for @resolvedAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'The support team marked this ticket as resolved. Please test and confirm to close it.'**
  String get resolvedAwaitingConfirmation;

  /// No description provided for @resolvedAwaitingEmployee.
  ///
  /// In en, this message translates to:
  /// **'Resolved • Awaiting employee testing and confirmation to close.'**
  String get resolvedAwaitingEmployee;

  /// No description provided for @ticketClosedArchived.
  ///
  /// In en, this message translates to:
  /// **'This ticket is closed and archived by the employee.'**
  String get ticketClosedArchived;

  /// No description provided for @showOnlyOwnedRequests.
  ///
  /// In en, this message translates to:
  /// **'Show requests currently owned by you'**
  String get showOnlyOwnedRequests;

  /// No description provided for @noSupportTicketsYet.
  ///
  /// In en, this message translates to:
  /// **'No support tickets yet'**
  String get noSupportTicketsYet;

  /// No description provided for @noMatchingTickets.
  ///
  /// In en, this message translates to:
  /// **'No matching tickets'**
  String get noMatchingTickets;

  /// No description provided for @createFirstTicketHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"+ New Ticket\" below to submit your first request.'**
  String get createFirstTicketHint;

  /// No description provided for @adjustSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or selected status.'**
  String get adjustSearchHint;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Brief summary of the issue or request'**
  String get titleHint;

  /// No description provided for @enterTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a ticket title'**
  String get enterTicketTitle;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe details, steps to reproduce, or requirements...'**
  String get descriptionHint;

  /// No description provided for @noAgentsFound.
  ///
  /// In en, this message translates to:
  /// **'No support agents found'**
  String get noAgentsFound;

  /// No description provided for @workspaceDetails.
  ///
  /// In en, this message translates to:
  /// **'WORKSPACE DETAILS'**
  String get workspaceDetails;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language / اللغة'**
  String get languageTitle;

  /// No description provided for @editProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Details'**
  String get editProfileDetails;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @areYouSureSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from your HelpDesk account?'**
  String get areYouSureSignOut;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored! You are back online.'**
  String get connectionRestored;

  /// No description provided for @stillOffline.
  ///
  /// In en, this message translates to:
  /// **'Still offline. Please check your network connection.'**
  String get stillOffline;

  /// No description provided for @noConnectionStatus.
  ///
  /// In en, this message translates to:
  /// **'HTTP 404 • NO CONNECTION'**
  String get noConnectionStatus;

  /// No description provided for @checkInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Check Your Internet'**
  String get checkInternetTitle;

  /// No description provided for @checkInternetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t connect to the server. Please verify your Wi-Fi router or cellular data connection.'**
  String get checkInternetSubtitle;

  /// No description provided for @troubleshootingTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Troubleshooting Tips:'**
  String get troubleshootingTips;

  /// No description provided for @tipWifi.
  ///
  /// In en, this message translates to:
  /// **'Verify Wi-Fi network is active'**
  String get tipWifi;

  /// No description provided for @tipCellular.
  ///
  /// In en, this message translates to:
  /// **'Check mobile cellular data signal'**
  String get tipCellular;

  /// No description provided for @tipAirplane.
  ///
  /// In en, this message translates to:
  /// **'Ensure Airplane mode is turned off'**
  String get tipAirplane;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get reconnecting;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @assignTicketInstruction.
  ///
  /// In en, this message translates to:
  /// **'Assign this ticket to a support specialist:'**
  String get assignTicketInstruction;

  /// No description provided for @deptMatchingSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Department Matching Specialists'**
  String get deptMatchingSpecialists;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your registered email.'**
  String get passwordResetSent;

  /// No description provided for @onDuty.
  ///
  /// In en, this message translates to:
  /// **'On-Duty'**
  String get onDuty;

  /// No description provided for @noTicketsAssignedRightNow.
  ///
  /// In en, this message translates to:
  /// **'No tickets assigned to you right now'**
  String get noTicketsAssignedRightNow;

  /// No description provided for @queueIsClean.
  ///
  /// In en, this message translates to:
  /// **'Queue is clean!'**
  String get queueIsClean;

  /// No description provided for @checkDeptQueueHint.
  ///
  /// In en, this message translates to:
  /// **'Check the \"Dept Queue\" tab to claim incoming support tickets.'**
  String get checkDeptQueueHint;

  /// No description provided for @allDeptTicketsHandledHint.
  ///
  /// In en, this message translates to:
  /// **'All tickets for your department have been handled or assigned.'**
  String get allDeptTicketsHandledHint;

  /// No description provided for @deptIT.
  ///
  /// In en, this message translates to:
  /// **'IT & Systems'**
  String get deptIT;

  /// No description provided for @deptHR.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get deptHR;

  /// No description provided for @deptOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get deptOperations;

  /// No description provided for @deptFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance & Payroll'**
  String get deptFinance;

  /// No description provided for @deptSales.
  ///
  /// In en, this message translates to:
  /// **'Sales & Marketing'**
  String get deptSales;

  /// No description provided for @deptCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get deptCustomerSupport;

  /// No description provided for @deptFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get deptFacilities;

  /// No description provided for @deptGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get deptGeneral;

  /// No description provided for @promoteToAgent.
  ///
  /// In en, this message translates to:
  /// **'Promote to Support Agent'**
  String get promoteToAgent;

  /// No description provided for @promote.
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @manageUserRole.
  ///
  /// In en, this message translates to:
  /// **'Manage User Role'**
  String get manageUserRole;

  /// No description provided for @promoteUserPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a new role and department for this user:'**
  String get promoteUserPrompt;

  /// No description provided for @demoteToEmployee.
  ///
  /// In en, this message translates to:
  /// **'Change to Employee'**
  String get demoteToEmployee;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All Members'**
  String get allUsers;

  /// No description provided for @roleUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User role updated successfully!'**
  String get roleUpdatedSuccess;

  /// No description provided for @sla.
  ///
  /// In en, this message translates to:
  /// **'SLA'**
  String get sla;

  /// No description provided for @slaTarget.
  ///
  /// In en, this message translates to:
  /// **'SLA Target'**
  String get slaTarget;

  /// No description provided for @slaCompliance.
  ///
  /// In en, this message translates to:
  /// **'SLA Compliance'**
  String get slaCompliance;

  /// No description provided for @slaBreached.
  ///
  /// In en, this message translates to:
  /// **'SLA Breached'**
  String get slaBreached;

  /// No description provided for @slaAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get slaAtRisk;

  /// No description provided for @slaOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get slaOnTrack;

  /// No description provided for @slaAchieved.
  ///
  /// In en, this message translates to:
  /// **'SLA Met'**
  String get slaAchieved;

  /// No description provided for @slaEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get slaEscalated;

  /// No description provided for @slaRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get slaRemaining;

  /// No description provided for @slaOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get slaOverdue;

  /// No description provided for @slaTracking.
  ///
  /// In en, this message translates to:
  /// **'SLA TIMELINE & ESCALATION'**
  String get slaTracking;

  /// No description provided for @slaAutoEscalationNote.
  ///
  /// In en, this message translates to:
  /// **'Automatic priority escalation enabled based on SLA policy'**
  String get slaAutoEscalationNote;

  /// No description provided for @slaFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All SLA'**
  String get slaFilterAll;

  /// No description provided for @slaHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours}h left'**
  String slaHoursLeft(Object hours);

  /// No description provided for @slaMinutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m left'**
  String slaMinutesLeft(Object minutes);

  /// No description provided for @slaHoursOverdue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h overdue'**
  String slaHoursOverdue(Object hours);

  /// No description provided for @slaMinutesOverdue.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m overdue'**
  String slaMinutesOverdue(Object minutes);

  /// No description provided for @slaBreaches.
  ///
  /// In en, this message translates to:
  /// **'SLA Breaches'**
  String get slaBreaches;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
