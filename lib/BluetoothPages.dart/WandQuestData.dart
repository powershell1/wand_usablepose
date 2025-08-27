import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; 

class WandQuestData extends ChangeNotifier {
  BluetoothCharacteristic? WandQuestWrite;
  BluetoothCharacteristic? WandQuestNotify;
  BluetoothDevice? WandQuest;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
  try {
    if (WandQuest != null) {
      await WandQuest!.disconnect();
    }
    _isConnected = false;
  } catch (e) {
    print("Error while disconnecting: $e");
  }

  WandQuestWrite = null;
  WandQuestNotify = null;
  WandQuest = null; // clear device

  notifyListeners();
}

  void changeWanQuestMainDevice({required BluetoothDevice device}) {
    WandQuest = device;

    // Listen to the connection state of VIA2025
    WandQuest?.state.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.connected) {
        // Mark as connected when the device is connected
        isConnected = true;
      } else if (state == BluetoothConnectionState.disconnected) {
        // Mark as disconnected when the device is disconnected
        isConnected = false;
      }
    });

    isConnected = true;

    notifyListeners();
  }

  void changeWandQuestDevice({required BluetoothDevice device}) {
    WandQuest = device;
    _isConnected = true;
    notifyListeners();
  }

  void changeWandQuestWrite({required BluetoothCharacteristic characteristic}) {
    WandQuestWrite = characteristic;
    notifyListeners();
  }

  void changeWandQuestNotify({required BluetoothCharacteristic characteristic}) {
    WandQuestNotify = characteristic;
    notifyListeners();
  }

  // Method to manually update connection status if needed
  void setConnectionStatus(bool status) {
    _isConnected = status;
    notifyListeners();
  }
}