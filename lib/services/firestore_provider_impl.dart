import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/services/firestore_provider.dart';

class FirestorePathProviderImpl implements FirestorePathProvider {
  final FirebaseFirestore _firestore;

  FirestorePathProviderImpl(this._firestore);

  @override
  DocumentReference get basePath => _firestore.doc('Easy2Solutions/Easy2Solutions');
}
