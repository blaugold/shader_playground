import 'package:flutter/material.dart';

import 'src/widgets/chromatic_aberration.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChromaticAberration(
        aberrationWidth: 4,
        child: DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: Colors.white,
        child: Column(
          children: const [
            Text(
              'Hello World!',
              style: TextStyle(
                fontSize: 100,
                color: Colors.orange,
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox.square(
                  dimension: 300,
                  child: CircularProgressIndicator(
                    strokeWidth: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
