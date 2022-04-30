import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluStateProvider with ChangeNotifier {
  BluetoothState? state = BluetoothState.UNKNOWN;
  bool pushSMS = false;

  updateState(BluetoothState? state) {
    this.state = state;

    notifyListeners();
  }

  enableSMS(bool state) {
    pushSMS = state;

    notifyListeners();
  }
}
