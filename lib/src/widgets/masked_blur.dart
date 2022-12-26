import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

typedef CreateBlurMask = ui.Image Function(Size size);

class MaskedBlur extends StatelessWidget {
  const MaskedBlur({
    super.key,
    required this.createMask,
    required this.child,
  });

  final CreateBlurMask createMask;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return ShaderBuilder(
      assetKey: 'assets/shaders/masked_blur.frag',
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, offset, canvas) {
            final mask = createMask(size);
            final blurredImage =
                _blurImage(shader, image, mask, devicePixelRatio);

            canvas.drawImageRect(
              blurredImage,
              Offset.zero &
                  Size(
                    blurredImage.width.toDouble(),
                    blurredImage.height.toDouble(),
                  ),
              offset & size,
              Paint(),
            );

            blurredImage.dispose();
          },
          child: child,
        );
      },
    );
  }

  ui.Image _blurImage(
    ui.FragmentShader shader,
    ui.Image image,
    ui.Image mask,
    double devicePixelRatio,
  ) {
    // Horizontal blur pass.
    final firstPass = _blurPass(shader, image, mask, devicePixelRatio, pi * .0);

    // Vertical blur pass.
    final secondPass =
        _blurPass(shader, firstPass, mask, devicePixelRatio, pi * .5);
    firstPass.dispose();

    return secondPass;
  }

  ui.Image _blurPass(
    ui.FragmentShader shader,
    ui.Image image,
    ui.Image mask,
    double devicePixelRatio,
    double direction,
  ) {
    const offset = Offset.zero;
    final size = Size(image.width.toDouble(), image.height.toDouble()) /
        devicePixelRatio;

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, direction)
      ..setImageSampler(0, image)
      ..setImageSampler(1, mask);

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawRect(offset & size, Paint()..shader = shader);
    final picture = pictureRecorder.endRecording();

    final sceneBuilder = ui.SceneBuilder();
    final transform =
        Matrix4.diagonal3Values(devicePixelRatio, devicePixelRatio, 1);
    sceneBuilder.pushTransform(transform.storage);
    sceneBuilder.addPicture(offset, picture);
    final scene = sceneBuilder.build();

    return scene.toImageSync(image.width, image.height);
  }
}

typedef UpdateBlurMask = void Function(
  Canvas canvas,
  Size size,
  ui.Image? currentMask,
);

class BlurMask extends StatefulWidget {
  const BlurMask({
    super.key,
    required this.createMask,
    required this.child,
  });

  final UpdateBlurMask createMask;
  final Widget child;

  @override
  State<BlurMask> createState() => BlurMaskState();
}

class BlurMaskState extends State<BlurMask> {
  Size? _size;
  ui.Image? _mask;

  @override
  void dispose() {
    _mask?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaskedBlur(
      createMask: _createMask,
      child: widget.child,
    );
  }

  void updateMask(UpdateBlurMask update) {
    setState(() {
      _updateMask(update);
    });
  }

  void _updateMask(UpdateBlurMask update) {
    final size = _size;
    if (size == null) {
      return;
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Create the new mask.
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    update(canvas, size, _mask);
    final picture = pictureRecorder.endRecording();

    _mask?.dispose();

    // Create an image of the mask.
    final sceneBuilder = ui.SceneBuilder();
    final transform =
        Matrix4.diagonal3Values(devicePixelRatio, devicePixelRatio, 1);
    sceneBuilder.pushTransform(transform.storage);
    sceneBuilder.addPicture(Offset.zero, picture);
    final scene = sceneBuilder.build();
    _mask = scene.toImageSync(
      (size.width * devicePixelRatio).ceil(),
      (size.height * devicePixelRatio).ceil(),
    );
  }

  ui.Image _createMask(Size size) {
    if (_size != size) {
      _mask?.dispose();
      _mask = null;
    }
    _size = size;

    if (_mask == null) {
      _updateMask(widget.createMask);
    }

    return _mask!;
  }
}

class PaintedBlurMask extends StatefulWidget {
  const PaintedBlurMask({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PaintedBlurMask> createState() => _PaintedBlurMaskState();
}

class _PaintedBlurMaskState extends State<PaintedBlurMask> {
  final _blurMaskKey = GlobalKey<BlurMaskState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        _blurMaskKey.currentState!.updateMask((canvas, size, currentMask) {
          canvas.drawImageRect(
            currentMask!,
            Offset.zero &
                Size(
                  currentMask.width.toDouble(),
                  currentMask.height.toDouble(),
                ),
            Offset.zero & size,
            Paint(),
          );

          // On every pan update, draw a circle at the current position to
          // mark the area.
          canvas.drawCircle(
            details.localPosition,
            50,
            Paint()..color = Colors.white,
          );
        });
      },
      child: BlurMask(
        key: _blurMaskKey,
        createMask: _createMask,
        child: widget.child,
      ),
    );
  }

  void _createMask(ui.Canvas canvas, Size size, ui.Image? currentMask) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.transparent,
    );
  }
}
