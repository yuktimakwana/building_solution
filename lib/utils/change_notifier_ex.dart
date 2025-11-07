import 'package:flutter/cupertino.dart';

class ChangeNotifierEx with ChangeNotifier {
  bool isChecked = false;

  void setChecked() {
    isChecked = true;
    notifyListeners();
  }
}

class ErrorValidation with ChangeNotifier {
  String isErrorText = '';

  void setValue(String errorText) {
    isErrorText = errorText;
    notifyListeners();
  }
}

class ScrollToUpOnKb with ChangeNotifier {
  bool isReverse = false;

  void setValue(reverse) {
    isReverse = reverse;
    notifyListeners();
  }
}
