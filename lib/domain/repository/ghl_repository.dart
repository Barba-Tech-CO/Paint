import '../../model/ghl/ghl_config_model.dart';
import '../../utils/result/result.dart';

abstract class IGhlRepository {
  Future<Result<GhlConfigModel>> getGhlConfig();
  Future<Result<GhlConfigModel>> saveGhlConfig(GhlConfigModel config);
  Future<Result<void>> disconnect();
}
