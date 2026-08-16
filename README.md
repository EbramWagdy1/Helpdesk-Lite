# 🎫 HelpDesk Lite — Internal Support Ticketing Workspace

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![State Management](https://img.shields.io/badge/State_Management-Bloc%20%2F%20Cubit-blueviolet?style=for-the-badge)](https://bloclibrary.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

> A modern, lightweight, role-based internal helpdesk workspace engineered to streamline support requests, eliminate duplicate communications, ensure task accountability, and provide management with real-time operational visibility.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Key Features by Role](#-key-features-by-role)
  - [👤 Employee Portal](#-employee-portal)
  - [🎧 Support Agent Workspace](#-support-agent-workspace)
  - [📊 Manager Executive Dashboard](#-manager-executive-dashboard)
- [Tech Stack & Architecture](#-tech-stack--architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Setup](#installation--setup)
  - [Firebase Configuration](#firebase-configuration)
- [Security & Database Rules](#-security--database-rules)
- [Roadmap](#-roadmap)
- [License](#-license)

---

## 🚀 Overview

In modern workplaces, support requests often get scattered across emails, chat channels, and informal conversations. This leads to lost requests, ambiguous ownership, delayed follow-ups, and a lack of executive visibility.

**HelpDesk Lite** centralizes all internal requests (IT, HR, Facilities, Operations, Finance) into a unified, transparent, and structured ticketing pipeline.

### Core Objectives:
* **Centralization**: One single portal for all internal operational support.
* **Accountability**: Every ticket has clear ownership, priority, and progress tracking.
* **Visibility**: Real-time workload metrics and status visibility for all stakeholders.
* **Simplicity**: Fast, intuitive, and clean user experience with minimal cognitive overhead.

---

## 🌟 Key Features by Role

### 👤 Employee Portal
* **Intuitive Ticket Creation**: Submit support requests with title, description, category, and priority.
* **File & Image Attachments**: Attach photos, error screenshots, and documents directly to tickets.
* **Real-time Status Tracking**: Monitor ticket progress through stages: `Open` ➔ `In Progress` ➔ `Resolved` ➔ `Closed`.
* **Collaborative Timeline & Comments**: Real-time communication and updates directly within the ticket detail view.
* **Personal Request Hub**: Easily filter, search, and manage your submitted requests.

### 🎧 Support Agent Workspace
* **Triage & Queue Management**: Filter tickets by category/department (`IT`, `HR`, `Facilities`, `Operations`, `Finance`).
* **Ticket Assignment & Ownership**: Claim unassigned tickets or assign them across the support team.
* **Status Lifecycle Management**: Transition tickets seamlessly with resolution notes and timestamps.
* **Audit & History Logs**: Full visibility into ticket updates, status changes, and collaborator interactions.

### 📊 Manager Executive Dashboard
* **Workload & Queue Analytics**: Interactive charts and breakdown of active vs. resolved tickets powered by Syncfusion.
* **Department Performance**: High-level visibility into team workloads, departmental distribution, and pending bottlenecks.
* **User & Agent Verification**: Manage permissions and oversee agent assignments.
* **Executive Summary**: Comprehensive metrics on resolution time, SLA health, and overall request volume.

---

## 🛠 Tech Stack & Architecture

### Core Technologies
* **Framework**: [Flutter](https://flutter.dev/) (SDK `^3.10.7` / Dart 3.x)
* **Design System**: Material 3 Design with custom typography, gradients, and micro-animations
* **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLoC / Cubit Pattern)
* **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) (Service Locator)
* **Routing**: [go_router](https://pub.dev/packages/go_router) (Declarative deep-linking)
* **Backend & Cloud**:
  * **Authentication**: [firebase_auth](https://pub.dev/packages/firebase_auth) (Email/Password & RBAC)
  * **Database**: [cloud_firestore](https://pub.dev/packages/cloud_firestore) (Real-time NoSQL storage)
  * **Storage**: [firebase_storage](https://pub.dev/packages/firebase_storage) (Secure media and attachment uploads)
* **Visualization & UI Components**:
  * [syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts) for executive data visualization
  * [lottie](https://pub.dev/packages/lottie) & [flutter_svg](https://pub.dev/packages/flutter_svg) for animations and vector assets
  * [qr_flutter](https://pub.dev/packages/qr_flutter) for ticket QR codes and quick sharing
  * [image_picker](https://pub.dev/packages/image_picker) for ticket attachment uploads

### Architectural Pattern
HelpDesk Lite utilizes a **Feature-First / Clean Architecture** pattern:
```text
lib/
├── app/                  # Application root & app-level configurations
├── core/                 # Shared domain logic, services, routing, and theme
│   ├── database/         # Local / remote database helpers
│   ├── errors/           # Failure & exception models
│   ├── routing/          # GoRouter definitions & route guards
│   ├── services/         # Firebase service, storage service, service locator (GetIt)
│   ├── theme/            # Color palettes, typography, and themes
│   ├── utils/            # Constants, date formatters, and validators
│   └── widgets/          # Reusable UI components & buttons
└── features/             # Business modules grouped by domain
    ├── agent_dashboard/  # Agent queue management & ticket triage
    ├── auth/             # Authentication (Login, Sign-up, User models)
    ├── employee_portal/  # Employee portal & personal ticket list
    ├── manager_dashboard/# Manager metrics, charts & executive overview
    ├── profile/          # User settings & profile management
    ├── splash/           # Splash screen & initial auth routing
    └── tickets/          # Ticket creation, details, comments, and state cubits
```

---

## 📂 Project Structure

```bash
helpdesk/
├── assets/
│   ├── images/              # App images and branding logos
│   ├── lottie/              # Lottie animation files
│   └── svgs/                # Vector SVG icons
├── lib/
│   ├── app/
│   ├── core/
│   │   ├── database/
│   │   ├── errors/
│   │   ├── routing/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── agent_dashboard/
│   │   ├── auth/
│   │   ├── employee_portal/
│   │   ├── manager_dashboard/
│   │   ├── profile/
│   │   ├── splash/
│   │   └── tickets/
│   ├── firebase_options.dart
│   └── main.dart
├── firestore.rules          # Firestore security rules
├── storage.rules            # Cloud Storage security rules
├── pubspec.yaml             # Project dependencies and asset definitions
└── README.md
```

---

## ⚡ Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>=3.10.7`)
* [Dart SDK](https://dart.dev/get-dart)
* [Firebase CLI](https://firebase.google.com/docs/cli) installed and configured
* Android Studio / Xcode / VS Code with Flutter extension

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/EbramWagdy1/Helpdesk-Lite.git
   cd Helpdesk-Lite
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   * Ensure your Firebase project is set up on the [Firebase Console](https://console.firebase.google.com/).
   * Run FlutterFire CLI to configure platform credentials:
     ```bash
     flutterfire configure
     ```

4. **Run the Application**:
   ```bash
   # Run on connected device / emulator
   flutter run
   ```

---

## 🔒 Security & Database Rules

The project includes pre-configured security rules for both Firestore and Firebase Storage:

* **Firestore Security (`firestore.rules`)**:
  * Authenticated access required for ticket creation and comments.
  * Role-based checks ensuring only assigned agents and managers can modify ticket assignment and resolution states.
* **Storage Security (`storage.rules`)**:
  * Secure uploads for ticket attachments restricted to authenticated users.

Deploy rules using the Firebase CLI:
```bash
firebase deploy --only firestore:rules,storage:rules
```

---

## 🗺 Roadmap

- [x] Role-Based Authentication (`Employee`, `Agent`, `Manager`)
- [x] Ticket Creation with attachments and priority tagging
- [x] Departmental triage (`IT`, `HR`, `Facilities`, `Finance`, `Operations`)
- [x] Interactive Comments & Status Timeline
- [x] Manager Executive Analytics with visual chart summaries
- [ ] Push Notifications for ticket status updates (FCM)
- [ ] Offline caching & sync
- [ ] Automated email-to-ticket ingestion (V2)
- [ ] Multi-tenant organization support (V2)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
