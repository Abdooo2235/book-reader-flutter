// import 'dart:convert';

import 'package:book_reader_app/providers/base_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  uninitialized,
  unauthenticated,
  authenticated,
  authenticating,
}

class AuthProvider extends BaseProvider {
  AuthStatus status = AuthStatus.uninitialized;
  String? token;

  Future<void> initAuthProvider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tempToken = prefs.getString("token");

    if (tempToken != null) {
      status = AuthStatus.authenticated;
      token = tempToken;
      if (kDebugMode) {
        print("TOKEN : $tempToken");
      }

      setBusy(false);
    } else {
      status = AuthStatus.unauthenticated;
      token = null;

      setBusy(false);
    }
  }

  // Future<List> login(Map body) async {
  //   setBusy(true);
  //   // final response = await api.post("/vendor/login", body);
  //   // if (response.statusCode == 200) {
  //   //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   //   prefs.setString("token", json.decode(response.body)['token']);

  //   //   setFailed(false);
  //   //   setBusy(false);
  //   //   return [true, "User Loged Successfully"];
  //   // } else {
  //   //   setFailed(true);
  //   //   setBusy(false);
  //   //   return [false, json.decode(response.body)['message']];
  //   // }
  // }

  Future<void> getWallet() async {
    setBusy(true);

  
  }

//   Future<List> logout() async {
//     setBusy(true);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
 

//     setFailed(false);
//     setBusy(false);
//     return [true, "User Loged Successfully"];
//   }
}
