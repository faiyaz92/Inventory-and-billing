import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/product_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;
  final IFirestorePathProvider firestorePathProvider;

  ProductRepositoryImpl(
      {required this.firestore, required this.firestorePathProvider});

  @override
  Future<List<ProductDTO>> getProducts(String companyId) async {
    final snapshot =
        await firestorePathProvider.getProductCollectionRef(companyId).get();
    return snapshot.docs.map((doc) => ProductDTO.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addProduct(String companyId, ProductDTO product) {
    return firestorePathProvider
        .getProductCollectionRef(companyId)
        .doc(product.name)  //product inital name would be id and id never change
        .set(product.toFirestore());
  }

  @override
  Future<void> updateProduct(String companyId, ProductDTO product) {
    return firestorePathProvider
        .getProductCollectionRef(companyId)
        .doc(product.id)
        .update(product.toFirestore());
  }

  @override
  Future<void> deleteProduct(String companyId, String productId) {
    return firestorePathProvider
        .getProductCollectionRef(companyId)
        .doc(productId)
        .delete();
  }
}
