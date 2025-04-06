import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  set isBusy(bool isBusy) {
    if (_isBusy != isBusy) {
      _isBusy = isBusy;
      notifyListeners();
    }
  }
}
