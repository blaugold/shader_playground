import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ChromaticAberration extends StatelessWidget {
  const ChromaticAberration({
    super.key,
    this.aberrationWidth = 2,
    required this.child,
  });

  final double aberrationWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'assets/shaders/chromatic_aberration.frag',
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, offset, canvas) {
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, offset.dx)
              ..setFloat(3, offset.dy)
              ..setFloat(4, aberrationWidth)
              ..setImageSampler(0, image);
            canvas.drawRect(offset & size, Paint()..shader = shader);
          },
          child: child,
        );
      },
    );
  }
}
