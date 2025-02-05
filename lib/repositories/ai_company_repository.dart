import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/ai_module/company_response_dto.dart';

abstract class AiCompanyListRepository {
  Future<Either<Exception, List<AiCompanyDto>>> fetchCompanyListFromAPI(
    String country,
    String city,
    String businessType,
    List<String> existingCompanyNames,
    String searchQuery, // New parameter for search
  );
}
