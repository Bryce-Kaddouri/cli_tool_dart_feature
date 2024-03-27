import '../../business/repository/feature_name_repository.dart';
import '../datasource/feature_name_datasource.dart';

class FeatureNameRepositoryImpl implements FeatureNameRepository {
  final FeatureNameDataSource dataSource;

  FeatureNameRepositoryImpl({required this.dataSource});
}
