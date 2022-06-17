import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseRepository {
  void handleStorageResponse(StorageResponse response) {
    if (response.hasError) {
      throw response.error!;
    }
  }

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
    if (response.error != null && response.status != 406) {
      throw response.error!;
    } else {
      return response.data ?? defaultValue;
    }
  }
}
