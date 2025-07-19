import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class UserLedgerCubit extends Cubit<AccountLedgerState> {
final IAccountLedgerService _accountLedgerService;
final AccountRepository _accountRepository;
final CustomerCompanyService _companyService;
final UserServices _userService;

UserLedgerCubit(this._accountLedgerService, this._accountRepository, this._companyService, this._userService)
    : super(AccountLedgerInitial());

Future<void> ensureLedger(String? ledgerId, UserType? userType, UserInfo user) async {
if (ledgerId == null || ledgerId.isEmpty) {
emit(AccountLedgerFetching());
try {
if (user.userId == null || user.companyId == null) {
emit(const AccountLedgerError("User ID or Company ID missing"));
return;
}
final newLedger = AccountLedger(
totalOutstanding: 0,
promiseAmount: null,
promiseDate: null,
transactions: [],
entityType: userType ?? UserType.Customer,
);
final newLedgerId = await _accountLedgerService.createLedger(newLedger);
final updatedUserInfo = user.copyWith(accountLedgerId: newLedgerId);
await _userService.updateUser(updatedUserInfo);
await fetchLedger(newLedgerId, userType);
} catch (e) {
emit(AccountLedgerError("Failed to create or update ledger: $e"));
return;
}
} else {
await fetchLedger(ledgerId, userType);
}
}

Future<void> fetchLedger(String? ledgerId, UserType? userType) async {
if (ledgerId == null || ledgerId.isEmpty) {
emit(const AccountLedgerError("Invalid ledger ID"));
return;
}
emit(AccountLedgerFetching());
try {
final ledger = await _accountLedgerService.getLedger(ledgerId);
final sortedTransactions = List<AccountTransactionModel>.from(ledger.transactions ?? [])
..sort((a, b) => b.createdAt!.compareTo(a.createdAt));
emit(AccountLedgerUpdated(ledger.copyWith(transactions: sortedTransactions)));
} catch (e) {
emit(AccountLedgerError("Failed to fetch ledger: $e"));
}
}

Future<void> openTransactionPopup(bool isDebit, Role? userRole) async {
try {
final result = await _companyService.getSettings();
final purposeTypeMap = result.fold<Map<String, List<String>>>(
(error) => {
'Salary': ['Cash'],
'Expenses': ['Cash'],
'Other': ['Cash'],
'Reimbursement': ['Cash'], // Added for Credit transactions
'Material': [],
'Labor': [],
},
(settings) {
final map = Map<String, List<String>>.from(settings.purposeTypeMap);
// Ensure default purposes
map.putIfAbsent('Salary', () => ['Cash']);
map.putIfAbsent('Expenses', () => ['Cash']);
map.putIfAbsent('Other', () => ['Cash']);
map.putIfAbsent('Reimbursement', () => ['Cash']); // Ensure Reimbursement
if (map.isEmpty) {
return {
'Salary': ['Cash'],
'Expenses': ['Cash'],
'Other': ['Cash'],
'Reimbursement': ['Cash'],
'Material': [],
'Labor': [],
};
}
final validatedMap = <String, List<String>>{};
for (var entry in map.entries) {
validatedMap[entry.key] = (entry.value).cast<String>();
}
return validatedMap;
},
);
String? defaultPurpose;
String? defaultType;
if (userRole == Role.SALES_MAN && !isDebit) {
defaultPurpose = null;
defaultType = null;
} else if (userRole == Role.SALES_MAN) {
defaultPurpose = purposeTypeMap.containsKey('Transfer Cash') ? 'Transfer Cash' : 'Other';
defaultType = purposeTypeMap[defaultPurpose]?.isNotEmpty == true ? purposeTypeMap[defaultPurpose]!.first : null;
} else if (!isDebit && (userRole == Role.STORE_ACCOUNTANT || userRole == Role.COMPANY_ACCOUNTANT)) {
defaultPurpose = 'Reimbursement';
defaultType = 'Cash';
} else {
defaultPurpose = purposeTypeMap.isNotEmpty ? purposeTypeMap.keys.first : null;
defaultType = defaultPurpose != null && purposeTypeMap[defaultPurpose]!.isNotEmpty
? purposeTypeMap[defaultPurpose]!.first
    : null;
}
emit(TransactionPopupOpened(
isDebit: isDebit,
companyType: null,
purposeTypeMap: purposeTypeMap,
selectedPurpose: defaultPurpose,
selectedType: defaultType,
isInitialOpen: true,
));
} catch (e) {
emit(TransactionPopupOpened(
isDebit: isDebit,
companyType: null,
purposeTypeMap: {
'Salary': ['Cash'],
'Expenses': ['Cash'],
'Other': ['Cash'],
'Reimbursement': ['Cash'],
'Material': [],
'Labor': [],
},
selectedPurpose: userRole == Role.SALES_MAN && !isDebit
? null
    : (userRole == Role.STORE_ACCOUNTANT || userRole == Role.COMPANY_ACCOUNTANT) && !isDebit
? 'Reimbursement'
    : 'Salary',
selectedType: userRole == Role.SALES_MAN && !isDebit
? null
    : (userRole == Role.STORE_ACCOUNTANT || userRole == Role.COMPANY_ACCOUNTANT) && !isDebit
? 'Cash'
    : 'Cash',
errorMessage: "Failed to load purposes: $e",
isInitialOpen: true,
));
}
}

Future<void> addTransaction({
required String ledgerId,
required double amount,
required String type,
String? billNumber,
String? purpose,
String? typeOfPurpose,
String? remarks,
required UserType? userType,
}) async {
emit(AccountLedgerPosting());
try {
if (amount <= 0) {
emit(const TransactionAddFailed("Amount must be positive"));
return;
}
if (remarks != null && remarks.length > 500) {
emit(const TransactionAddFailed("Remarks cannot exceed 500 characters"));
return;
}
final loggedIn = await _accountRepository.getUserInfo();
final transaction = AccountTransactionModel(
amount: amount,
type: type,
billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
createdAt: DateTime.now(),
receivedBy: loggedIn?.userId ?? '',
purpose: purpose,
typeOfPurpose: typeOfPurpose,
remarks: remarks?.isNotEmpty == true ? remarks : null,
);
final currentLedger = await _accountLedgerService.getLedger(ledgerId);
double updatedDue = currentLedger.currentDue ?? 0.0;
double updatedOutstanding = currentLedger.totalOutstanding;
updatedDue += (type == "Debit" ? amount : -amount);
updatedOutstanding += (type == "Debit" ? amount : -amount);
final updatedLedger = currentLedger.copyWith(
totalOutstanding: updatedOutstanding,
currentDue: updatedDue,
currentPayable: null,
transactions: [...?currentLedger.transactions, transaction],
);
await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
await _accountLedgerService.addTransaction(ledgerId, transaction);
emit(const TransactionSuccess("Transaction added successfully"));
await fetchLedger(ledgerId, userType);
} catch (e) {
emit(TransactionAddFailed("Failed to add transaction: $e"));
}
}

Future<void> addTransactionWithSource({
required String ledgerId,
required String sourceLedgerId,
UserInfo? destinationUserInfo,
UserInfo? sourceUserInfo,
required double amount,
required String type,
String? billNumber,
String? purpose,
String? typeOfPurpose,
String? remarks,
required UserType? userType,
required Role? userRole,
}) async {
emit(AccountLedgerPosting());
try {
if (amount <= 0) {
emit(const TransactionAddFailed("Amount must be positive"));
return;
}
if (remarks != null && remarks.length > 500) {
emit(const TransactionAddFailed("Remarks cannot exceed 500 characters"));
return;
}
final loggedIn = await _accountRepository.getUserInfo();
if (loggedIn?.accountLedgerId == null) {
emit(const TransactionAddFailed("Logged-in user ledger ID not found"));
return;
}

// Allow single entry for accountants' Expenses/Reimbursement when destination is their own ledger
final isAccountant = userRole == Role.STORE_ACCOUNTANT || userRole == Role.COMPANY_ACCOUNTANT;
final isSelfTransaction = ledgerId == loggedIn!.accountLedgerId && isAccountant &&
(purpose == 'Expenses' || purpose == 'Reimbursement');

if (!isSelfTransaction && ledgerId == sourceLedgerId) {
emit(const TransactionAddFailed("Source and destination ledgers cannot be the same"));
return;
}

// Fallback for names
final destinationName = destinationUserInfo?.name ?? destinationUserInfo?.userName ?? 'User';
final sourceName = sourceUserInfo?.name ?? sourceUserInfo?.userName ?? loggedIn?.userName ?? 'User';

// Adjust typeOfPurpose for accountants
final effectiveTypeOfPurpose = (isAccountant && purpose != null && ['Salary', 'Expenses', 'Other', 'Reimbursement'].contains(purpose))
? 'Cash'
    : typeOfPurpose ?? 'Internal';

// Destination ledger transaction
final transaction = AccountTransactionModel(
amount: amount,
type: type,
billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
createdAt: DateTime.now(),
receivedBy: loggedIn?.userId ?? '',
purpose: purpose,
typeOfPurpose: effectiveTypeOfPurpose,
remarks: remarks?.isNotEmpty == true
? remarks
    : 'Transaction for $destinationName ($ledgerId)',
);
final currentLedger = await _accountLedgerService.getLedger(ledgerId);
double updatedDue = currentLedger.currentDue ?? 0.0;
double updatedOutstanding = currentLedger.totalOutstanding;
updatedDue += (type == "Debit" ? amount : -amount);
updatedOutstanding += (type == "Debit" ? amount : -amount);
final updatedLedger = currentLedger.copyWith(
totalOutstanding: updatedOutstanding,
currentDue: updatedDue,
currentPayable: null,
transactions: [...?currentLedger.transactions, transaction],
);
await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
await _accountLedgerService.addTransaction(ledgerId, transaction);

// Source ledger transaction (skip for accountants' Expenses/Other or self-transactions)
if (!isSelfTransaction && (purpose != 'Expenses' && purpose != 'Other' || !isAccountant)) {
final sourceTransaction = AccountTransactionModel(
amount: amount,
type: type == "Debit" ? "Credit" : "Debit",
billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
createdAt: DateTime.now(),
receivedBy: loggedIn?.userId ?? '',
purpose: purpose ?? 'Transaction',
typeOfPurpose: effectiveTypeOfPurpose,
remarks: remarks?.isNotEmpty == true
? 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId): $remarks'
    : 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId) from $sourceName',
);
final sourceLedger = await _accountLedgerService.getLedger(sourceLedgerId);
double sourceUpdatedDue = sourceLedger.currentDue ?? 0.0;
double sourceUpdatedOutstanding = sourceLedger.totalOutstanding;
sourceUpdatedDue += (sourceTransaction.type == "Debit" ? amount : -amount);
sourceUpdatedOutstanding += (sourceTransaction.type == "Debit" ? amount : -amount);
final updatedSourceLedger = sourceLedger.copyWith(
totalOutstanding: sourceUpdatedOutstanding,
currentDue: sourceUpdatedDue,
currentPayable: null,
transactions: [...?sourceLedger.transactions, sourceTransaction],
);
await _accountLedgerService.updateLedger(sourceLedgerId, updatedSourceLedger);
await _accountLedgerService.addTransaction(sourceLedgerId, sourceTransaction);
}

emit(const TransactionSuccess("Transaction added successfully"));
await fetchLedger(ledgerId, userType);
} catch (e) {
emit(TransactionAddFailed("Failed to add transaction: $e"));
}
}

Future<void> deleteTransaction(String ledgerId, AccountTransactionModel transaction, UserType? userType) async {
emit(AccountLedgerPosting());
try {
final currentLedger = await _accountLedgerService.getLedger(ledgerId);
double updatedDue = currentLedger.currentDue ?? 0.0;
double updatedOutstanding = currentLedger.totalOutstanding;
updatedDue -= (transaction.type == "Debit" ? transaction.amount : -transaction.amount);
updatedOutstanding -= (transaction.type == "Debit" ? transaction.amount : -transaction.amount);
final updatedLedger = currentLedger.copyWith(
totalOutstanding: updatedOutstanding,
currentDue: updatedDue,
currentPayable: null,
transactions: currentLedger.transactions?.where((txn) => txn.transactionId != transaction.transactionId).toList(),
);
await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
await _accountLedgerService.deleteTransaction(ledgerId, transaction.transactionId!);
emit(const AccountLedgerSuccess("Transaction deleted successfully"));
await fetchLedger(ledgerId, userType);
} catch (e) {
emit(AccountLedgerError("Failed to delete transaction: $e"));
}
}

void updatePurposeSelection(String? purpose) {
final currentState = state;
if (currentState is TransactionPopupOpened) {
final purposeTypeMap = currentState.purposeTypeMap;
final newType = purpose != null && purposeTypeMap[purpose]?.isNotEmpty == true ? purposeTypeMap[purpose]!.first : null;
emit(currentState.copyWith(
selectedPurpose: purpose,
selectedType: newType,
isInitialOpen: false,
));
}
}

void updateTypeSelection(String? type) {
final currentState = state;
if (currentState is TransactionPopupOpened) {
emit(currentState.copyWith(
selectedType: type,
isInitialOpen: false,
));
}
}
}
