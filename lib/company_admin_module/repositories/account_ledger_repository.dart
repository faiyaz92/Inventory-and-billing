import 'package:requirment_gathering_app/company_admin_module/data/account_ledger_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/transcation_dto.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

abstract class IAccountLedgerRepository {
  /// 🔹 Fetch the account ledger for a customer company.
  Future<AccountLedgerDto> getAccountLedger(String companyId, String ledgerId);

  /// 🔹 Add a new account ledger.
  Future<void> createAccountLedger(
      String companyId, AccountLedgerDto ledgerDto);

  /// 🔹 Update an existing account ledger.
  Future<void> updateAccountLedger(
      String companyId, String ledgerId, AccountLedgerDto ledgerDto);

  /// 🔹 Add a transaction to the account ledger.
  Future<void> addTransaction(
      String companyId, String ledgerId, TransactionDto transactionDto);

  /// 🔹 Fetch all transactions for a given ledger.
  Future<List<TransactionDto>> getTransactions(
      String companyId, String ledgerId);
}

class AccountLedgerRepositoryImpl implements IAccountLedgerRepository {
  final IFirestorePathProvider _pathProvider;

  AccountLedgerRepositoryImpl(this._pathProvider);

  /// 🔹 Fetch account ledger details
  Future<AccountLedgerDto> getAccountLedger(
      String companyId, String ledgerId) async {
    try {
      final doc = await _pathProvider
          .getAccountLedgerRef(companyId, ledgerId) // 🔹 Get Ledger Reference
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception("Ledger not found!");
      }

      // 🔥 Fetch transactions separately
      final transactionsSnapshot = await _pathProvider
          .getTransactionsRef(
              companyId, ledgerId) // 🔹 Get Transactions Reference
          .get();

      List<TransactionDto> transactions =
          transactionsSnapshot.docs.map((txnDoc) {
        return TransactionDto.fromMap(
            txnDoc.data() as Map<String, dynamic>, txnDoc.id);
      }).toList();

      return AccountLedgerDto.fromMap(
          doc.data() as Map<String, dynamic>, doc.id, transactions);
    } catch (e) {
      print("❌ Error fetching ledger: $e");
      throw Exception("Failed to fetch ledger.");
    }
  }

  /// 🔹 Create a new account ledger
  @override
  Future<void> createAccountLedger(
      String companyId, AccountLedgerDto ledgerDto) async {
    await _pathProvider
        .getTenantCompanyRef(companyId)
        .collection('accountLedgers')
        .add(ledgerDto.toMap());
  }

  /// 🔹 Update account ledger details
  @override
  Future<void> updateAccountLedger(
      String companyId, String ledgerId, AccountLedgerDto ledgerDto) async {
    await _pathProvider
        .getTenantCompanyRef(companyId)
        .collection('accountLedgers')
        .doc(ledgerId)
        .update(ledgerDto.toMap());
  }

  /// 🔹 Add a transaction to the account ledger
  @override
  Future<void> addTransaction(
      String companyId, String ledgerId, TransactionDto transactionDto) async {
    await _pathProvider
        .getTenantCompanyRef(companyId)
        .collection('accountLedgers')
        .doc(ledgerId)
        .collection('transactions')
        .add(transactionDto.toMap());
  }

  /// 🔹 Fetch all transactions from a ledger
  @override
  Future<List<TransactionDto>> getTransactions(
      String companyId, String ledgerId) async {
    final snapshot = await _pathProvider
        .getTenantCompanyRef(companyId)
        .collection('accountLedgers')
        .doc(ledgerId)
        .collection('transactions')
        .get();

    return snapshot.docs
        .map((doc) =>
            TransactionDto.fromMap(doc.data(), doc.id))
        .toList();
  }
}
