import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandquest/BluetoothPages.dart/FoundedPage.dart';

class FindingPage extends StatefulWidget {
  const FindingPage({super.key});

  @override
  State<FindingPage> createState() => _FindingPageState();
}

class _FindingPageState extends State<FindingPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  bool _navigated = false;
  Timer? _timeoutTimer;

  // ===== CUSTOMIZATION =====
  final int dotCount = 4;
  final double bounceHeight = -15.0;
  final Duration animationDuration = const Duration(milliseconds: 1400);
  final double dotSize = 16;
  final double dotSpacing = 4;
  final Color dotColor = const Color(0xFF6F338C);
  final Duration scanTimeout = const Duration(seconds: 15);
  // ===== END =====

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    )..repeat();

    _animations = _buildDotAnimations(dotCount);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 14));

    FlutterBluePlus.onScanResults.listen((scanResults) {
      for (var result in scanResults) {
        if (!_navigated && result.advertisementData.advName.contains("WandQuest")) {
          _navigated = true;
          _timeoutTimer?.cancel();
          FlutterBluePlus.stopScan();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FoundedPage(scanResult: result),
              ),
            );
          }
          break;
        }
      }
    });

    _timeoutTimer = Timer(scanTimeout, () {
      if (!_navigated && mounted) {
        _showTimeoutDialog();
      }
    });
  }

  List<Animation<double>> _buildDotAnimations(int count) {
    return List.generate(count, (index) {
      final start = index * 0.1;
      final end = start + 0.6;

      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: bounceHeight).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: bounceHeight, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.linear),
        ),
      );
    });
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: dotSpacing),
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildBouncingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _animations.map(_buildDot).toList(),
    );
  }

  Widget _buildLoadingText() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Finding ',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F338C),
            ),
          ),
          TextSpan(
            text: 'WandQuest',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBA4AF4),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Connection Timeout"),
          content: const Text("Cannot find WandQuest device."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Go Home"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) {
                  FlutterBluePlus.startScan(timeout: const Duration(seconds: 14));

                  Navigator.pop(context);
                }
              },
              child: const Text("Try Again"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timeoutTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBouncingDots(),
            const SizedBox(height: 32),
            _buildLoadingText(),
          ],
        ),
      ),
    );
  }
}
