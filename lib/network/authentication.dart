import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../utils/multilang_strings.dart';
import '../screens/login_screen.dart';
import '../models/user_model.dart';
import '../database_helper/shared_preferences.dart';
import '../screens/events_selection_screen.dart';
import '../utils/constants.dart';
import 'dart:convert';
import 'headers.dart';
import 'keys.dart';
import 'messages_service.dart';
import 'network_status_service.dart';

class AuthService {
  _passwordEncryption(String password) {
    final digest = utf8.encode(password);
    Digest encryptedPassword = sha1.convert(digest);
    return encryptedPassword;
  }

  Future _loginRequest(String username, String password) async {
    try {
      Map<String, String> body = {
        Keys.username: username,
        Keys.password: password,
        Keys.phoneLanguage: Values.apiLang,
      };

      print('Username: $username');
      print('Password: $password');
      print('body: $body');

      http.Response response = await http.post(Keys.baseUrl + Keys.loginPath,
          headers: Headers.headers, body: jsonEncode(body));
      print("Login status: ${response.statusCode}");

      return jsonDecode(response.body);
    } on TimeoutException catch (e) {
      print(e);
      ShowToast.showToast(MultiLang.currentLanguage.requestTimeOut);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> login(
      String username, String password, BuildContext context) async {
    String errorMessage = MultiLang.currentLanguage.invalidUserOrPass;
    String offlineMessage = MultiLang.currentLanguage.noInternet;

    NetworkStatus networkStatus = await NetworkStatusService.getNetworkStatus();
    if (networkStatus != null && networkStatus == NetworkStatus.Offline) {
      OnError.onError(offlineMessage, context);
      return false;
    }
    String pass = _passwordEncryption(password).toString();
    final user = await _loginRequest(username, pass);
    print("Email: $username, Encrypted Password: $pass, Password: $password");
    print("User: $user");
    if (!user['GrandAccess']) {
      OnError.onError(errorMessage, context);
      return true;
    }
    await DataCache.preferences.setString(DataCache.username, username);
    await DataCache.preferences.setString(DataCache.password, password);
    Values.user = User.mapToUser(user);
    print("User: $user");
    Values.selectedEventId =
        DataCache.preferences.getString(DataCache.selectedEventId) ?? '';
    print("Selected event Id: ${Values.selectedEventId}");
    if (Values.selectedEventId.isNotEmpty)
      Values.event = Values.user.eventData.firstWhere(
          (element) => element.eventId == Values.selectedEventId,
          orElse: null);
    await MessagesService().storeMessages();
    await InitData.initializeData();
    Navigator.pushReplacementNamed(context, EventsSelectionScreen.id);
    return false;
  }

  static Future<void> logout(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.id, (Route<dynamic> route) => false);
    await DataCache.preferences.remove(DataCache.username);
    await DataCache.preferences.remove(DataCache.password);
  }
}
