import 'package:cloud_firestore/cloud_firestore.dart';

class SubcategoryDTO {
  final String? id;
  final String? name;
  final String? categoryId; // Reference to the parent category in the DTO

  SubcategoryDTO({
    this.id,
    this.name,
    this.categoryId,
  });

  // Convert Firestore DocumentSnapshot to SubcategoryDTO
  factory SubcategoryDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubcategoryDTO(
      id: doc.id,
      name: data['name'],
      categoryId: data['categoryId'],  // Mapping categoryId from Firestore
    );
  }

  // Convert Subcategory Model to SubcategoryDTO (for Firestore write)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name ?? '',
      'categoryId': categoryId ?? '',  // Include categoryId in Firestore
    };
  }
}
