import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/ai_module/company_response_dto.dart';
import 'package:requirment_gathering_app/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/services/provider.dart';

class AiCompanyListRepositoryImpl implements AiCompanyListRepository {
  final DioClientProvider _dioClientProvider;

  AiCompanyListRepositoryImpl(this._dioClientProvider);

  @override
  Future<Either<Exception, List<AiCompanyDto>>> fetchCompanyListFromAPI(
    String country,
    String city,
    String businessType,
    List<String> existingCompanyNames,
    String searchQuery,
  ) async {
    try {
      final response = await _dioClientProvider.post(
        '/gpt-endpoint', // Replace with actual endpoint
        {
          'country': country,
          'city': city,
          'business_type': businessType,
        },
      );

      if (response.statusCode == 200) {
        List<AiCompanyDto> companyList = (response.data['companies'] as List)
            .map((data) => AiCompanyDto.fromMap(data))
            .toList();
        return Right(companyList); // Success
      } else {
        return Left(Exception('Failed to fetch companies'));
      }
    } catch (e) {
      return Left(Exception('API Error: $e'));
    }
  }
}
