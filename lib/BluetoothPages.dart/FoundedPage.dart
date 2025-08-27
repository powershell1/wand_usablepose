import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wandquest/BluetoothPages.dart/WandQuestData.dart';
import 'package:wandquest/Pages/HomePage.dart';

class FoundedPage extends StatefulWidget {
  FoundedPage({super.key, this.scanResult});
  final ScanResult? scanResult;

  @override
  State<FoundedPage> createState() => _FoundedPageState();
}

class _FoundedPageState extends State<FoundedPage> {
  Map<String, BluetoothCharacteristic?> allBluetooth = {
    "WandQuestWrite": null,
    "WandQuestNotify": null,
  };

  String connectionStatus = "";
  Timer? _timeoutTimer;

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _updateStatus(String status) {
    setState(() {
      connectionStatus = status;
    });
    print(status);
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Connection Timeout"),
        content: const Text("Unable to connect to WandQuest device."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("Go Home"),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  _timeoutTimer = Timer(const Duration(seconds: 22), () {
    Navigator.pop(context); // remove loading
    _showTimeoutDialog();
  });

  try {
    await FlutterBluePlus.stopScan();
    var device = widget.scanResult?.device;
    if (device == null) throw Exception("No device found in scan result.");

    _updateStatus("Connecting to device: ${device.id}");
    var state = await device.connectionState.first;
    if (state != BluetoothConnectionState.connected) {
      await device.connect();
    }

    _updateStatus("Device connected. Discovering services...");
    context.read<WandQuestData>().changeWandQuestDevice(device: device);

    var currentState = await device.connectionState.first;
    if (currentState != BluetoothConnectionState.connected) {
      throw Exception("Device disconnected before discovering services.");
    }

    var services = await device.discoverServices();
    _updateStatus("Services discovered.");

    // Find characteristics by UUID (reliable!)
    for (var s in services) {
      for (var c in s.characteristics) {
        final uuid = c.uuid.toString().toLowerCase();

        if (uuid == "277d7c4b-d4d5-49a0-aa13-06caca57004e") {
          allBluetooth["WandQuestWrite"] = c;
          context.read<WandQuestData>().changeWandQuestWrite(characteristic: c);
        } else if (uuid == "84549f4f-2979-4276-b253-0a8c6d4f55b3") {
          allBluetooth["WandQuestNotify"] = c;
          context.read<WandQuestData>().changeWandQuestNotify(characteristic: c);
        }
      }
    }

    if (allBluetooth["WandQuestWrite"] == null ||
        allBluetooth["WandQuestNotify"] == null) {
      throw Exception("Could not find required WandQuest characteristics.");
    }

    _updateStatus("Connection successful!");
    _timeoutTimer?.cancel();
    Navigator.pop(context); // remove loading

    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(connectionstate: true),
      ),
    );

    // Send startup signal "S"
    await context.read<WandQuestData>().WandQuestWrite?.write(utf8.encode("S"));

    // Enable notifications
    await context.read<WandQuestData>().WandQuestNotify?.setNotifyValue(true);
  } catch (e) {
    _timeoutTimer?.cancel();
    Navigator.pop(context); // remove loading
    _updateStatus("Connection failed: $e");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connection Error"),
        content: const Text("Failed to connect or discover services. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7D22D0),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 250),
                Image.asset('assets/FoundedLogo.png', width: 138),
                const SizedBox(height: 10),
                Text(
                  'Found!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 294),
                GestureDetector(
                  onTap: _connectToDevice,
                  child: Container(
                    width: 356,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Connect',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF7D22D0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom connection status
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                connectionStatus,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD1A1F9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
