import 'package:book_reader_app/services/api.dart';
import 'package:flutter/material.dart';

class BaseProvider with ChangeNotifier {
  bool busy = false;
  Api api = Api();

  void setBusy(bool status) {
    busy = status;
    notifyListeners();
  }

  bool failed = false;

  void setFailed(bool status) {
    failed = status;
    notifyListeners();
  }

  String? errorMessage;
  void setErrorMessage(String? msg) {
    errorMessage = msg;
    notifyListeners();
  }
}
