import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/data/partner_dto.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/customer_company_repository.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class CustomerCompanyServiceImpl implements CustomerCompanyService {
  final CustomerCompanyRepository _companyRepository;
  final CompanySettingRepository companySettingRepository;
  final AccountRepository accountService;

  CustomerCompanyServiceImpl(this._companyRepository,
      {required this.companySettingRepository, required this.accountService});

  @override
  Future<Either<Exception, List<Partner>>> fetchCompanies() async {
    try {
      final result = await _companyRepository.getAllCompanies();
      return result.fold(
        (exception) => Left(exception),
        (dtoCompanies) =>
            Right(dtoCompanies.map((dto) => dto.toUiModel()).toList()),
      );
    } catch (e) {
      return Left(Exception('Failed to fetch companies: $e'));
    }
  }

/*  @override
  Future<Either<Exception, String>> saveCompany(Partner company) async {
    try {
      final currentUserResult = await _getCurrentUser();
      if (currentUserResult.isLeft()) {
        return Left((currentUserResult as Left).value);
      }
      final currentUser = (currentUserResult as Right).value;

      final updatedCompany = company.copyWith(
        createdBy:
            company.id.isEmpty ? currentUser.userName : company.createdBy,
        lastUpdatedBy: currentUser.userName,
      );

      final dto = PartnerDto.fromUiModel(updatedCompany);
      final result = company.id.isEmpty
          ? await _companyRepository.addCompany(dto)
          : await _companyRepository.updateCompany(company.id, dto);

      return result;
    } catch (e) {
      return Left(Exception('Failed to save company: $e'));
    }
  }*/

  @override
  Future<Either<Exception, CompanySettingsUi>> fetchCompanySettings() async {
    try {
      return await companySettingRepository.getSettings();
    } catch (e) {
      return Left(Exception('Failed to fetch company settings: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> isCompanyNameUnique(
      String companyName) async {
    try {
      return await _companyRepository.isCompanyNameUnique(companyName);
    } catch (e) {
      return Left(Exception('Failed to check company name uniqueness: $e'));
    }
  }

  @override
  Future<String> addCompany(Partner company) async {
    try {
      final currentUserResult = await _getCurrentUser();
      if (currentUserResult.isLeft()) {
        throw (currentUserResult as Left).value;
      }
      final currentUser = (currentUserResult as Right).value;

      final updatedCompany = company.copyWith(
        createdBy: currentUser.userName,
        lastUpdatedBy: currentUser.userName,
      );

      final dto = PartnerDto.fromUiModel(updatedCompany);
      final id = await _companyRepository.addCompany(dto);
      return id.fold((l)  {
        return l.toString();
      }, (r) {
        return r;
      });
    } catch (e) {
      throw Exception('Failed to add company: $e');
    }
  }

  @override
  Future<void> updateCompany(String id, Partner company) async {
    try {
      final currentUserResult = await _getCurrentUser();
      if (currentUserResult.isLeft()) {
        throw (currentUserResult as Left).value;
      }
      final currentUser = (currentUserResult as Right).value;

      final updatedCompany =
          company.copyWith(lastUpdatedBy: currentUser.userName);
      final dto = PartnerDto.fromUiModel(updatedCompany);
      await _companyRepository.updateCompany(id, dto);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  @override
  Future<Either<Exception, List<Partner>>> getAllCompanies() async {
    try {
      final result = await _companyRepository.getAllCompanies();
      return result.fold(
        (exception) => Left(exception),
        (dtoCompanies) =>
            Right(dtoCompanies.map((dto) => dto.toUiModel()).toList()),
      );
    } catch (e) {
      return Left(Exception('Failed to fetch all companies: $e'));
    }
  }

  @override
  Future<void> deleteCompany(String id) async {
    try {
      final result = await _companyRepository.deleteCompany(id);
      result.fold(
        (exception) => throw exception,
        (_) => null,
      );
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }

  @override
  Future<Either<Exception, CompanySettingsUi>> getSettings() async {
    try {
      return await companySettingRepository.getSettings();
    } catch (e) {
      return Left(Exception('Failed to fetch settings: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateSettings(
      CompanySettingsUi settings) async {
    try {
      return await companySettingRepository.updateSettings(settings);
    } catch (e) {
      return Left(Exception('Failed to update settings: $e'));
    }
  }

  @override
  Future<List<UserInfoDto>> getUsersFromOwnCompany() async {
    try {
      final result = await _companyRepository.getUsersFromOwnCompany();
      return result.fold(
        (exception) => throw exception,
        (dtoUsers) => dtoUsers,
      );
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<Either<Exception, UserInfo>> _getCurrentUser() async {
    try {
      final userInfo = await accountService.getUserInfo();
      if (userInfo == null || userInfo.companyId == null) {
        return Left(Exception('User not associated with any company.'));
      }
      return Right(userInfo);
    } catch (e) {
      return Left(Exception('Failed to fetch current user: $e'));
    }
  }
}
