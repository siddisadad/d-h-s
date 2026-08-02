# Deshmukh Hardware & Steel ERP

A high-performance, enterprise-grade ERP system built with Flutter and Spring Boot. Optimized for multi-platform deployment (Web, Mobile, Desktop) with real-time cloud synchronization.

## 🏗️ Architecture

This project follows **Clean Architecture** principles to ensure scalability, testability, and clear separation of concerns. It follows a "Features-First" structure.

### Layers
- **Presentation**: UI components and State Management using **Riverpod 2.6** (Functional and Code-Gen).
- **Domain**: Pure business logic (Entities, Use Cases, Repository Interfaces).
- **Data**: Implementation of repositories and Remote DataSources (**Dio**).

## 🚀 Tech Stack

- **Frontend**: Flutter 3.22+ (Material 3)
- **State Management**: Riverpod (Generator)
- **Networking**: Dio (with Auth & Logging Interceptors)
- **Routing**: GoRouter (Reactive with Auth Guards)
- **Design System**: Customized token-based Industrial Blue theme.
- **Testing**: Integration Test (End-to-End Business Flows)

## 📦 Core Modules

- 📦 **Inventory**: Real-time stock tracking with live cloud fetching.
- 🧾 **Sales**: Professional invoice generation with PDF export.
- 👥 **CRM**: Customer and Supplier directory with transaction ledgers.
- 💰 **Finance**: Real-time cash book and business liquidity tracking.
- 📊 **Analytics**: Profit & Loss reporting and multi-series trend charts.
- 👷 **Employees**: Staff directory and attendance management.

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK `^3.22.0`
- Spring Boot Backend (Running on `localhost:8080`)

### Local Development
1. **Clone the repo**:
   ```bash
   git clone <repo-url>
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate code** (Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the app**:
   ```bash
   flutter run -d chrome  # For Web
   flutter run -d windows # For Desktop
   ```

## 🛡️ Security

The system implements **Role-Based Access Control (RBAC)**:
- **Admin**: Full access to all financial data, staff salaries, and system settings.
- **Manager**: Access to inventory adjustments and transaction approvals.
- **Employee**: Access to sales entry and customer lookups.

## 📝 Reporting

- **PDF**: Automated invoice and statement generation.
- **Excel**: One-tap export of Inventory and Sales reports using the `excel` service.

---
© 2026 Deshmukh Hardware & Steel. All rights reserved.
