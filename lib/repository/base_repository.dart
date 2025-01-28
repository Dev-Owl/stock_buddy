import 'package:postgrest/postgrest.dart';
import 'package:stock_buddy/backend.dart';

abstract class BaseRepository {
  final StockBuddyBackend backend;

  BaseRepository(this.backend);

  Future<String> getCurrentRevById(String id) async {
    return backend.head("stockbuddy/$id").then((value) {
      return value.headers.value("ETag")!.replaceAll('"', "");
    });
  }

  Future<bool> delete(String id, String rev) async {
    return backend.requestWithConverter(
        backend.delete("stockbuddy/$id", queryParameters: {"rev": rev}),
        (data) {
      return true;
    });
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
    return response.data ?? defaultValue;
  }
}
