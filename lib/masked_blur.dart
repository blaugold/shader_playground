import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/widgets/masked_blur.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaintedBlurMask(
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/city.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              const Center(
                child: _TimeCode(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCode extends StatefulWidget {
  const _TimeCode();

  @override
  State<_TimeCode> createState() => _TimeCodeState();
}

class _TimeCodeState extends State<_TimeCode> {
  late Timer _timer;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _time = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      [
        _zeroPadInt(_time.hour),
        _zeroPadInt(_time.minute),
        _zeroPadInt(_time.second),
      ].join(':'),
      style: GoogleFonts.robotoMono(
        fontSize: 160,
        color: Colors.white,
        fontWeight: FontWeight.w100,
      ),
      // softWrap: false,
      maxLines: 1,
    );
  }

  static String _zeroPadInt(int value, {int width = 2}) {
    return value.toString().padLeft(width, '0');
  }
}
