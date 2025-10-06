import 'package:requirment_gathering_app/accounting_module/data/TransactionModel.dart';
import 'package:requirment_gathering_app/accounting_module/data/TransactionModelDto.dart';
import 'package:requirment_gathering_app/accounting_module/data/account_model_dto.dart';
import 'package:requirment_gathering_app/accounting_module/repositories/accounting_repositories.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class AccountingRepositoryImpl implements AccountingRepository {
final IFirestorePathProvider _firestorePathProvider;

AccountingRepositoryImpl(this._firestorePathProvider);

@override
Future<void> initFirm(String firmId, String firmName) async {
await _firestorePathProvider.getTenantCompanyRef(firmId).set({
'name': firmName,
'createdAt': DateTime.now().toIso8601String(),
});
await _firestorePathProvider.getAccountingGeneralJournalRef(firmId).set({
'createdAt': DateTime.now().toIso8601String(),
});
await createAccounts(firmId, [
AccountDto(id: 'cash', name: 'Cash', type: 'Real', subtype: 'General', balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'bank', name: 'Bank', type: 'Real', subtype: 'General', balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'capital', name: 'Capital', type: 'Personal', subtype: 'General', balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'retained-earnings', name: 'Retained Earnings', type: 'Personal', subtype: 'General', balance: 0, companyId: firmId, createdAt: DateTime.now()),
]);
}

@override
Future<void> createStore(String firmId, String storeId, String storeName) async {
await _firestorePathProvider.getAccountingStoresCollectionRef(firmId).doc(storeId).set({
'name': storeName,
'createdAt': DateTime.now().toIso8601String(),
});
await _firestorePathProvider.getAccountingStockCollectionRef(firmId, storeId).add({
'createdAt': DateTime.now().toIso8601String(),
});
await _firestorePathProvider.getAccountingTransactionsCollectionRef(firmId, storeId).add({
'createdAt': DateTime.now().toIso8601String(),
});
await _firestorePathProvider.getAccountingJournalRef(firmId, storeId).set({
'createdAt': DateTime.now().toIso8601String(),
});
await createAccounts(firmId, [
AccountDto(id: 'inventory-$storeId', name: 'Inventory-$storeId', type: 'Real', subtype: 'General', storeId: storeId, balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'sales-revenue-$storeId', name: 'Sales Revenue-$storeId', type: 'Nominal', subtype: 'General', storeId: storeId, balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'cogs-$storeId', name: 'COGS-$storeId', type: 'Nominal', subtype: 'General', storeId: storeId, balance: 0, companyId: firmId, createdAt: DateTime.now()),
AccountDto(id: 'general-expense-$storeId', name: 'General Expense-$storeId', type: 'Nominal', subtype: 'General', storeId: storeId, balance: 0, companyId: firmId, createdAt: DateTime.now()),
]);
}

@override
Future<void> createPersonalAccount(String firmId, String name, String? storeId, String type) async {
final accountId = storeId != null ? '$name-$storeId' : name;
await _firestorePathProvider.getAccountingAccountLedgerRef(firmId, accountId).set(AccountDto(
id: accountId,
name: name,
type: 'Personal',
subtype: 'Subsidiary',
storeId: storeId,
balance: 0,
companyId: firmId,
createdAt: DateTime.now(),
).toMap());
}

@override
Future<void> addEntry(String firmId, TransactionDto transaction) async {
final journalPath = transaction.storeId != null
? _firestorePathProvider.getAccountingJournalRef(firmId, transaction.storeId!).collection('entries')
    : _firestorePathProvider.getAccountingGeneralJournalRef(firmId).collection('entries');
final entries = [];

if (transaction.type == 'Investment') {
await ensureAccount(firmId, 'cash', 'Real', 'General');
await ensureAccount(firmId, 'capital', 'Personal', 'General');
entries.add({
'debitAccountId': 'cash',
'creditAccountId': 'capital',
'amount': transaction.amount,
'particulars': 'Owner Investment',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
} else if (transaction.type == 'Sale') {
await ensureAccount(firmId, 'sales-revenue-${transaction.storeId}', 'Nominal', 'General', transaction.storeId);
final debitAccountId = transaction.paymentType == 'Cash' ? 'cash' : '${transaction.customerId}-${transaction.storeId}';
if (transaction.paymentType == 'Credit') {
await ensureAccount(firmId, debitAccountId, 'Personal', 'Subsidiary', transaction.storeId);
}
entries.add({
'debitAccountId': debitAccountId,
'creditAccountId': 'sales-revenue-${transaction.storeId}',
'amount': transaction.amount,
'particulars': 'Sale to ${transaction.customerId}',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
if (transaction.items != null) {
final totalCost = transaction.items!.fold(0.0, (sum, item) => sum + item.quantity * item.cost);
await ensureAccount(firmId, 'cogs-${transaction.storeId}', 'Nominal', 'General', transaction.storeId);
await ensureAccount(firmId, 'inventory-${transaction.storeId}', 'Real', 'General', transaction.storeId);
entries.add({
'debitAccountId': 'cogs-${transaction.storeId}',
'creditAccountId': 'inventory-${transaction.storeId}',
'amount': totalCost,
'particulars': 'Cost of Goods Sold',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
await updateStock(firmId, transaction.storeId!, transaction.items!, 'remove');
}
} else if (transaction.type == 'Purchase') {
await ensureAccount(firmId, 'inventory-${transaction.storeId}', 'Real', 'General', transaction.storeId);
final creditAccountId = transaction.paymentType == 'Cash' ? 'cash' : '${transaction.supplierId}-${transaction.storeId}';
if (transaction.paymentType == 'Credit') {
await ensureAccount(firmId, creditAccountId, 'Personal', 'Subsidiary', transaction.storeId);
}
entries.add({
'debitAccountId': 'inventory-${transaction.storeId}',
'creditAccountId': creditAccountId,
'amount': transaction.amount,
'particulars': 'Purchase from ${transaction.supplierId}',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
if (transaction.items != null) {
await updateStock(firmId, transaction.storeId!, transaction.items!, 'add');
}
} else if (transaction.type == 'Expense') {
await ensureAccount(firmId, 'general-expense-${transaction.storeId}', 'Nominal', 'General', transaction.storeId);
final creditAccountId = transaction.paymentType == 'Cash' ? 'cash' : '${transaction.supplierId}-${transaction.storeId}';
if (transaction.paymentType == 'Credit') {
await ensureAccount(firmId, creditAccountId, 'Personal', 'Subsidiary', transaction.storeId);
}
entries.add({
'debitAccountId': 'general-expense-${transaction.storeId}',
'creditAccountId': creditAccountId,
'amount': transaction.amount,
'particulars': 'Expense to ${transaction.supplierId}',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
} else if (transaction.type == 'Withdrawal') {
await ensureAccount(firmId, 'cash', 'Real', 'General');
await ensureAccount(firmId, 'retained-earnings', 'Personal', 'General');
entries.add({
'debitAccountId': 'retained-earnings',
'creditAccountId': 'cash',
'amount': transaction.amount,
'particulars': 'Owner Withdrawal',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
} else if (transaction.type == 'Deposit') {
await ensureAccount(firmId, 'bank', 'Real', 'General');
await ensureAccount(firmId, 'cash', 'Real', 'General');
entries.add({
'debitAccountId': 'bank',
'creditAccountId': 'cash',
'amount': transaction.amount,
'particulars': 'EOD Deposit',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
} else if (transaction.type == 'Profit') {
final revenue = await calculateRevenue(firmId, transaction.storeId, transaction.date);
final expenses = await calculateExpenses(firmId, transaction.storeId, transaction.date);
final profit = revenue - expenses.fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
entries.add({
'debitAccountId': 'sales-revenue-${transaction.storeId}',
'creditAccountId': 'cogs-${transaction.storeId}',
'amount': expenses.firstWhere((e) => e['name'].contains('cogs'))['amount'],
'particulars': 'Profit Transfer',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
entries.add({
'debitAccountId': 'sales-revenue-${transaction.storeId}',
'creditAccountId': 'general-expense-${transaction.storeId}',
'amount': expenses.firstWhere((e) => e['name'].contains('general-expense'))['amount'],
'particulars': 'Profit Transfer',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
entries.add({
'debitAccountId': 'sales-revenue-${transaction.storeId}',
'creditAccountId': 'retained-earnings',
'amount': profit,
'particulars': 'Profit Transfer',
'date': transaction.date.toIso8601String(),
'createdAt': DateTime.now().toIso8601String(),
});
}

for (final entry in entries) {
await journalPath.add(entry);
await updateLedger(firmId, entry['debitAccountId'], entry['amount'], 0, entry['particulars'], entry['date']);
await updateLedger(firmId, entry['creditAccountId'], 0, entry['amount'], entry['particulars'], entry['date']);
}

await _firestorePathProvider.getAccountingTransactionsCollectionRef(firmId, transaction.storeId ?? firmId).add(transaction.toMap());
}

@override
Future<Map<String, dynamic>> getBalanceSheet(String firmId, DateTime start, DateTime end) async {
final accountsSnapshot = await _firestorePathProvider.getAccountingAccountLedger(firmId).get();
final accounts = accountsSnapshot.docs.map((doc) => AccountDto.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
final assets = accounts.where((a) => a.type == 'Real' && a.balance > 0).map((a) => {'name': a.name, 'balance': a.balance}).toList();
final liabilities = accounts.where((a) => a.type == 'Personal' && a.subtype == 'Subsidiary' && a.balance > 0).map((a) => {'name': a.name, 'balance': a.balance}).toList();
final equity = accounts.where((a) => a.type == 'Personal' && a.subtype == 'General').fold(0.0, (sum, a) => sum + a.balance);
return {'assets': assets, 'liabilities': liabilities, 'equity': equity};
}

@override
Future<Map<String, dynamic>> getIncomeStatement(String firmId, DateTime start, DateTime end) async {
final generalJournalSnapshot = await _firestorePathProvider.getAccountingGeneralJournalRef(firmId).collection('entries').get();
final storesSnapshot = await _firestorePathProvider.getAccountingStoresCollectionRef(firmId).get();
final storeJournals = await Future.wait(storesSnapshot.docs.map((store) => _firestorePathProvider.getAccountingJournalRef(firmId, store.id).collection('entries').get()));
final allEntries = [...generalJournalSnapshot.docs, ...storeJournals.expand((s) => s.docs)].map((doc) => doc.data() as Map<String, dynamic>).toList();
final revenue = allEntries.where((e) => e['creditAccountId'].contains('sales-revenue')).fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
final expenses = allEntries
    .where((e) => e['debitAccountId'].contains('cogs') || e['debitAccountId'].contains('general-expense'))
    .map((e) => {'name': e['debitAccountId'], 'amount': (e['amount'] as num).toDouble()})
    .toList();
final profit = revenue - expenses.fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
return {'revenue': revenue, 'expenses': expenses, 'profit': profit};
}

@override
Future<List<Map<String, dynamic>>> getStock(String firmId) async {
final storesSnapshot = await _firestorePathProvider.getAccountingStoresCollectionRef(firmId).get();
final stocks = await Future.wait(storesSnapshot.docs.map((store) async {
final stockSnapshot = await _firestorePathProvider.getAccountingStockCollectionRef(firmId, store.id).get();
return {
'storeId': store.id,
'items': stockSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
};
}));
return stocks;
}

@override
Future<Map<String, dynamic>> getStockOfStore(String firmId, String storeId) async {
final stockSnapshot = await _firestorePathProvider.getAccountingStockCollectionRef(firmId, storeId).get();
return {
'items': stockSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
};
}

@override
Future<Map<String, dynamic>> getAccountBalance(String firmId, String accountId, DateTime start, DateTime end) async {
final transactionsSnapshot = await _firestorePathProvider.getAccountingTransactionsRef(firmId, accountId).get();
final transactions = transactionsSnapshot.docs
    .map((doc) => doc.data() as Map<String, dynamic>)
    .where((t) => DateTime.parse(t['date']).isAfter(start) && DateTime.parse(t['date']).isBefore(end))
    .toList();
final balance = transactions.fold(0.0, (sum, t) => sum + ((t['debit'] ?? 0) as num).toDouble() - ((t['credit'] ?? 0) as num).toDouble());
return {'balance': balance, 'transactions': transactions};
}

Future<void> createAccounts(String firmId, List<AccountDto> accounts) async {
for (final account in accounts) {
await _firestorePathProvider.getAccountingAccountLedgerRef(firmId, account.id).set(account.toMap());
}
}

Future<void> ensureAccount(String firmId, String accountId, String type, String subtype, [String? storeId]) async {
final accountRef = await _firestorePathProvider.getAccountingAccountLedgerRef(firmId, accountId).get();
if (!accountRef.exists) {
await _firestorePathProvider.getAccountingAccountLedgerRef(firmId, accountId).set(AccountDto(
id: accountId,
name: accountId,
type: type,
subtype: subtype,
storeId: storeId,
balance: 0,
companyId: firmId,
createdAt: DateTime.now(),
).toMap());
}
}

Future<void> updateLedger(String firmId, String accountId, double debit, double credit, String particulars, String date) async {
final accountRef = _firestorePathProvider.getAccountingAccountLedgerRef(firmId, accountId);
final accountSnapshot = await accountRef.get();
final currentBalance = (accountSnapshot.data() as Map<String, dynamic>)['balance'] ?? 0;
final newBalance = currentBalance + debit - credit;
await accountRef.update({'balance': newBalance});
await _firestorePathProvider.getAccountingTransactionsRef(firmId, accountId).add({
'date': date,
'particulars': particulars,
'debit': debit,
'credit': credit,
'balance': newBalance,
'createdAt': DateTime.now().toIso8601String(),
});
}

Future<double> calculateRevenue(String firmId, String? storeId, DateTime date) async {
  final journalPath = storeId != null
      ? _firestorePathProvider.getAccountingJournalRef(firmId, storeId).collection('entries')
      : _firestorePathProvider.getAccountingGeneralJournalRef(firmId).collection('entries');
  final snapshot = await journalPath.get();
  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .where((e) => e['creditAccountId'].contains('sales-revenue') && e['date'] == date.toIso8601String())
      .fold(0.0, (sum, e) async=> ( await sum + double.parse(e['amount'].toString())));
}

Future<List<Map<String, dynamic>>> calculateExpenses(String firmId, String? storeId, DateTime date) async {
final journalPath = storeId != null
? _firestorePathProvider.getAccountingJournalRef(firmId, storeId).collection('entries')
    : _firestorePathProvider.getAccountingGeneralJournalRef(firmId).collection('entries');
final snapshot = await journalPath.get();
return snapshot.docs
    .map((doc) => doc.data() as Map<String, dynamic>)
    .where((e) => (e['debitAccountId'].contains('cogs') || e['debitAccountId'].contains('general-expense')) && e['date'] == date.toIso8601String())
    .map((e) => {'name': e['debitAccountId'], 'amount': (e['amount'] as num).toDouble()})
    .toList();
}

Future<void> updateStock(String firmId, String storeId, List<TransactionItem> items, String action) async {
for (final item in items) {
final stockRef = _firestorePathProvider.getAccountingStockCollectionRef(firmId, storeId).doc(item.itemId);
final stockSnapshot = await stockRef.get();
final currentQuantity = stockSnapshot.exists ? (stockSnapshot.data() as Map<String, dynamic>)['quantity'] ?? 0 : 0;
final newQuantity = action == 'add' ? currentQuantity + item.quantity : currentQuantity - item.quantity;
await stockRef.set({
'itemId': item.itemId,
'name': item.name,
'quantity': newQuantity,
'cost': item.cost,
'createdAt': DateTime.now().toIso8601String(),
});
}
}
}
