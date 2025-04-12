import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDTO {
  final String? id;  // Added id to DTO class
  final String? name; // Optional, can be null
  final String? description; // Optional, can be null

  CategoryDTO({
    this.id,  // Now passing id in DTO as well
    this.name,
    this.description,
  });

  // Convert Firestore DocumentSnapshot to CategoryDTO
  factory CategoryDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryDTO(
      id: doc.id,  // Assigning Firestore document ID
      name: data['name'],
      description: data['description'] ?? '',  // Default to an empty string if description is null
    );
  }

  // Convert Category Model to CategoryDTO (for Firestore write)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,  // Include id in Firestore mapping (nullable)
      'name': name ?? '',  // Provide a default value if null
      'description': description ?? '',  // Provide a default value if null
    };
  }
}
