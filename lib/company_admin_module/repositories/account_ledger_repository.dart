import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_transcation_dto.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

abstract class IAccountLedgerRepository {
  Future<AccountLedgerDto> getAccountLedger(String companyId, String ledgerId);

  Future<String> createAccountLedger(String companyId, AccountLedgerDto ledgerDto);

  Future<void> updateAccountLedger(String companyId, String ledgerId, AccountLedgerDto ledgerDto);

  Future<void> addTransaction(String companyId, String ledgerId, AccountTransactionDto transactionDto);

  Future<List<AccountTransactionDto>> getTransactions(String companyId, String ledgerId);

  Future<void> deleteTransaction(String companyId, String ledgerId, String transactionId);
}

class AccountLedgerRepositoryImpl implements IAccountLedgerRepository {
  final IFirestorePathProvider _pathProvider;

  AccountLedgerRepositoryImpl(this._pathProvider);

  @override
  Future<AccountLedgerDto> getAccountLedger(String companyId, String ledgerId) async {
    try {
      final doc = await _pathProvider.getAccountLedgerRef(companyId, ledgerId).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception("Ledger not found!");
      }

      final transactionsSnapshot = await _pathProvider.getTransactionsRef(companyId, ledgerId).get();

      List<AccountTransactionDto> transactions = transactionsSnapshot.docs.map((txnDoc) {
        return AccountTransactionDto.fromMap(txnDoc.data() as Map<String, dynamic>, txnDoc.id);
      }).toList();

      return AccountLedgerDto.fromMap(doc.data() as Map<String, dynamic>, doc.id, transactions);
    } catch (e) {
      print("❌ Error fetching ledger: $e");
      throw Exception("Failed to fetch ledger.");
    }
  }

  @override
  Future<String> createAccountLedger(String companyId, AccountLedgerDto ledgerDto) async {
    final docRef = await _pathProvider.getAccountLedger(companyId,).add(ledgerDto.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateAccountLedger(String companyId, String ledgerId, AccountLedgerDto ledgerDto) async {
    await _pathProvider.getAccountLedgerRef(companyId, ledgerId).update(ledgerDto.toMap());
  }

  @override
  Future<void> addTransaction(String companyId, String ledgerId, AccountTransactionDto transactionDto) async {
    await _pathProvider.getTransactionsRef(companyId, ledgerId).add(transactionDto.toMap());
  }


  @override
  Future<List<AccountTransactionDto>> getTransactions(String companyId, String ledgerId) async {
    final snapshot = await _pathProvider.getTransactionsRef(companyId, ledgerId).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?; // ✅ Ensure safe casting
      if (data == null) throw Exception("Transaction data is null");

      return AccountTransactionDto.fromMap(data, doc.id);
    }).toList();
  }
  @override
  Future<void> deleteTransaction(String companyId, String ledgerId, String transactionId) async {
    await _pathProvider.getTransactionsRef(companyId, ledgerId).doc(transactionId).delete();
  }
}
