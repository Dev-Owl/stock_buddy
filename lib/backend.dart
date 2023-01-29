import 'package:flutter/material.dart';
import 'package:stock_buddy/utils/model_converter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String debugUrl = "http://localhost:3000";

class StockBuddyBackend {
  static StockBuddyBackend? _instance;

  static StockBuddyBackend getInstance({String? url}) {
    _instance ??= StockBuddyBackend(url ?? debugUrl);
    return _instance!;
  }

  late final PostgrestClient client;
  DateTime? tokenEndOfLife;
  String? userName;
  String? userPassword;

  StockBuddyBackend(
    String baseUrl, {
    this.userName,
    this.userPassword,
  }) {
    client = PostgrestClient(baseUrl);
  }

  bool get hasLoginDetails => userName != null && userPassword != null;

  void removeSessionInfos() {
    userName = null;
    userPassword = null;
    tokenEndOfLife = null;
    client.headers.remove("Authorization");
  }

  Future<String> generateNewAuthToken() async {
    if (tokenEndOfLife == null ||
        tokenEndOfLife!.isBefore(DateTime.now().toUtc())) {
      // Auth needed
      if (userName == null || userPassword == null) {
        throw "User name or password is missing";
      }
      // Remove the old JWT
      client.headers.remove("Authorization");

      final token = await client.rpc("authenticate", params: {
        "username": userName,
        "password": userPassword,
      }).withConverter((data) => ModelConverter.first<String>(
          data, (singleElement) => singleElement['token']));
      tokenEndOfLife = DateTime.now().toUtc().add(
            const Duration(
              minutes: 4,
            ),
          );
      client.auth(token);
      return token;
    }
    return client.headers["Authorization"]!.substring(7);
  }

  Future<PostgrestClient> getAuthenticatedClient() async {
    await generateNewAuthToken();
    return client;
  }

  Future<T> runAuthenticatedRequest<T>(
      Future<T> Function(PostgrestClient client) action) async {
    try {
      return action(await getAuthenticatedClient());
    } catch (ex) {
      debugPrint(ex.toString());
      rethrow;
    }
  }
}
