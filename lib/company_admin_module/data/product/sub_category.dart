import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category_dto.dart';

class Subcategory {
  final String? id;
  final String? name;
  final String? categoryId; // Reference to the parent category

  Subcategory({
    this.id,
    this.name,
    this.categoryId,  // Added categoryId to establish the relationship
  });

  factory Subcategory.fromDTO(SubcategoryDTO dto) {
    return Subcategory(
      id: dto.id,
      name: dto.name,
      categoryId: dto.categoryId,  // Mapping categoryId from DTO
    );
  }

  SubcategoryDTO toDTO() {
    return SubcategoryDTO(
      id: id,
      name: name ?? '',
      categoryId: categoryId ?? '',  // Passing categoryId in DTO
    );
  }
}
