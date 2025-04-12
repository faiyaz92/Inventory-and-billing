import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/categoryDto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/category_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/category_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

class CategoryServiceImpl implements CategoryService {
  final CategoryRepository categoryRepository;
  final AccountRepository accountRepository;

  CategoryServiceImpl({
    required this.categoryRepository,
    required this.accountRepository,
  });

  // Helper function to get the companyId
  Future<String> _getCompanyId() async {
    final userInfo = await accountRepository.getUserInfo();
    return userInfo?.companyId ?? ''; // Defaulting to empty string if companyId is null
  }

  @override
  Future<void> addCategory(Category category) async {
    final companyId = await _getCompanyId();

    final categoryDTO = CategoryDTO(
      name: category.name,
      description: category.description,
    );
    await categoryRepository.addCategory(companyId, categoryDTO);
  }

  @override
  Future<void> updateCategory(String id, Category category) async {
    final companyId = await _getCompanyId();

    final categoryDTO = CategoryDTO(
      name: category.name,
      description: category.description,
    );
    await categoryRepository.updateCategory(companyId, id, categoryDTO);
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final companyId = await _getCompanyId();

    final dtoList = await categoryRepository.getCategories(companyId);
    return dtoList.map((dto) => Category.fromDTO(dto)).toList();
  }

  @override
  Future<void> addSubcategory(String categoryId, Subcategory subcategory) async {
    final companyId = await _getCompanyId();
    final subcategoryDTO = subcategory.toDTO();

    await categoryRepository.addSubcategory(companyId, categoryId, subcategoryDTO);
  }

  @override
  Future<void> deleteSubcategory(String categoryId, String subcategoryId) async {
    final companyId = await _getCompanyId();

    await categoryRepository.deleteSubcategory(companyId, categoryId, subcategoryId);
  }

  @override
  Future<void> updateSubcategory(String categoryId, String subcategoryId, Subcategory subcategory) async {
    final companyId = await _getCompanyId();
    final subcategoryDTO = subcategory.toDTO();

    await categoryRepository.updateSubcategory(companyId, categoryId, subcategoryId, subcategoryDTO);
  }

  @override
  Future<List<Subcategory>> fetchSubcategories(String categoryId) async {
    final companyId = await _getCompanyId();

    final subcategoryDTOList = await categoryRepository.getSubcategories(companyId, categoryId);
    return subcategoryDTOList.map((dto) => Subcategory.fromDTO(dto)).toList();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final companyId = await _getCompanyId();

    await categoryRepository.deleteCategory(companyId, categoryId);
  }
}
