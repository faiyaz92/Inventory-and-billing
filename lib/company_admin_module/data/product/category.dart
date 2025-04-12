import 'package:requirment_gathering_app/company_admin_module/data/product/categoryDto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';

class Category {
  final String? id;
  final String? name;
  final String? description;
  List<Subcategory> subcategories;  // Added subcategories list

  Category({
    this.id,
    this.name,
    this.description,
    this.subcategories = const [],  // Initialize with an empty list
  });

  factory Category.fromDTO(CategoryDTO dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      subcategories: [], // Initialize subcategories as empty
    );
  }

  CategoryDTO toDTO() {
    return CategoryDTO(
      id: id,
      name: name ?? '',
      description: description ?? '',
    );
  }
}
