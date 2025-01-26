import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/backend.dart';

abstract class BaseRepository {
  final StockBuddyBackend backend;

  BaseRepository(this.backend);

  void handleNoValueResponse(PostgrestResponse response) {
    handleResponse(response, null);
  }

  T handleNeverNullResponse<T>(PostgrestResponse<T> response) {
    const T? nothing = null;
    return handleResponse<T?>(
      response,
      nothing,
    )!;
  }

  T handleResponse<T>(PostgrestResponse<T> response, T defaultValue) {
    return response.data ?? defaultValue;
  }
}
