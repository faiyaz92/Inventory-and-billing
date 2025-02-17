import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/data/company_response_dto.dart';

abstract class AiCompanyListRepository {
  Future<Either<Exception, List<AiCompanyDto>>> fetchCompanyListFromAPI(
    String country,
    String city,
    String businessType,
    List<String> existingCompanyNames,
    String searchQuery, // New parameter for search
  );
}
