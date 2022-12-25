import 'package:flutter/material.dart';

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
      home: MaskedBlur(
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/city.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
