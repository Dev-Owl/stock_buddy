import 'package:stock_buddy/backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (response.status >= 400 && response.status != 406) {
      throw response.data ?? 'No error information in response';
    } else {
      return response.data ?? defaultValue;
    }
  }
}
