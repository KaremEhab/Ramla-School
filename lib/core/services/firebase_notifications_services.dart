import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static Future<String> getAccessToken() async {
    // حمّل JSON من assets
    final serviceAccountJson = await rootBundle.loadString(
      'assets/service_account.json',
    );
    final serviceAccount = json.decode(serviceAccountJson);

    final accountCredentials = ServiceAccountCredentials.fromJson(
      serviceAccount,
    );

    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);

    return client.credentials.accessToken.data;
  }
}
