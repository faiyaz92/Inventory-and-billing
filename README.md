# requirment_gathering_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

- fires tore structure: 
V1
Easy2Solutions (Root Collection)
├── companyDirectory (Document)
│   ├── tenantCompanies (Collection)  // 🔹 Tenant Companies
│   │   ├── {companyId} (Document)
│   │   │   ├── users (Collection)  // 🔥 Tenant Company Users
│   │   │   │   ├── {userId} (Document)
│   │   │   │   │   ├── name: "John Doe"
│   │   │   │   │   ├── email: "john@example.com"
│   │   │   │   │   ├── role: "Admin/User"
│   │   │   │   │   ├── createdAt: "Timestamp"
│   │   │   ├── companies (Collection)  // 🔥 Customer Companies (Linked to Tenant)
│   │   │   │   ├── {customerCompanyId} (Document)
│   │   │   │   │   ├── companyName: "XYZ Pvt Ltd"
│   │   │   │   │   ├── industry: "IT Services"
│   │   │   │   │   ├── createdAt: "Timestamp"
│   │   │   ├── tasks (Collection)  // 🔥 Task Management
│   │   │   │   ├── {taskId} (Document)
│   │   │   │   │   ├── title: "Task Title"
│   │   │   │   │   ├── description: "Task Description"
│   │   │   │   │   ├── assignedTo: "{userId}"  // 🔹 Assigned to a user in same tenant
│   │   │   │   │   ├── createdBy: "{userId}"
│   │   │   │   │   ├── status: "Pending/In Progress/Completed"
│   │   │   │   │   ├── deadline: "ISO Date String"
│   │   │   ├── settings (Collection)  // 🔥 Tenant-Level Settings
│   │   │   │   ├── {settingId} (Document)
│   ├── superAdmins (Collection)  // 🔥 Super Admins (Stored Separately)
│   │   ├── {adminId} (Document)
│   │   │   ├── name: "Super Admin"
│   │   │   ├── email: "admin@example.com"
│   │   │   ├── role: "SUPER_ADMIN"
│   │   │   ├── createdAt: "Timestamp"
│   ├── users (Collection)  // 🔥 Global User Index (Faster Login)
│   │   ├── {userId} (Document)
│   │   │   ├── name: "Common User"
│   │   │   ├── email: "common@example.com"
│   │   │   ├── role: "General"
│   │   │   ├── companyId: "{companyId}"  // 🔥 Fast lookup ke liye
│   │   │   ├── createdAt: "Timestamp"

v2:

Easy2Solutions (Root Collection)
├── companyDirectory (Document)
│   ├── tenantCompanies (Collection)
│   │   ├── {companyId} (Document)
│   │   │   ├── companies (Collection)
│   │   │   │   ├── {customerCompanyId} (Document)
│   │   │   │   │   ├── companyName: "XYZ Pvt Ltd"
│   │   │   │   │   ├── industry: "IT Services"
│   │   │   │   │   ├── createdAt: "Timestamp"
│   │   │   │   │   ├── ledger (Collection)  // 🔥 Account Ledger Data
│   │   │   │   │   │   ├── {ledgerId} (Document)
│   │   │   │   │   │   │   ├── totalOutstanding: 50000
│   │   │   │   │   │   │   ├── transactions (Collection)
│   │   │   │   │   │   │   │   ├── {transactionId} (Document)
│   │   │   │   │   │   │   │   │   ├── type: "Debit" / "Credit"
│   │   │   │   │   │   │   │   │   ├── amount: 25000
│   │   │   │   │   │   │   │   │   ├── billNumber: "INV1234"  // Only for Debit
│   │   │   │   │   │   │   │   │   ├── receivedBy: "{userId}"  // Only for Credit
│   │   │   │   │   │   │   │   │   ├── createdAt: "Timestamp"
│   │   │   │   │   │   │   ├── promiseAmount: 15000  // If customer promises to pay later
│   │   │   │   │   │   │   ├── promiseDate: "ISO Date String"
│   │   │   ├── tasks (Collection)  // 🔥 Task Management
│   │   │   │   ├── {taskId} (Document)
│   │   │   │   │   ├── title: "Follow-up for Pending Payment"
│   │   │   │   │   ├── description: "Reminder to collect ₹15000 from XYZ Pvt Ltd."
│   │   │   │   │   ├── assignedTo: "{adminUserId}"  // 🔹 Company Admin
│   │   │   │   │   ├── createdBy: "{userId}"
│   │   │   │   │   ├── status: "Pending/In Progress/Completed"
│   │   │   │   │   ├── deadline: "Promise Date"
