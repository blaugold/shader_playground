import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class MaskedBlur extends StatefulWidget {
  const MaskedBlur({
    super.key,
    this.blurSize = 15,
    required this.child,
  });

  final double blurSize;
  final Widget child;

  @override
  State<MaskedBlur> createState() => _MaskedBlurState();
}

class _MaskedBlurState extends State<MaskedBlur> {
  ui.Image? _mask;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // Initialize the mask after the widget has been laid out since
      // we need its size. Probably better to do manage the mask in a
      // RenderObject after layout.
      _updateMask((canvas) {});
    });
  }

  void _updateMask(void Function(Canvas canvas) paint) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    // Paint onto the previous mask.

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final wipeMask = _mask;
    if (wipeMask != null) {
      canvas.drawImageRect(
        wipeMask,
        Offset.zero &
            Size(wipeMask.width.toDouble(), wipeMask.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
      wipeMask.dispose();
    }

    paint(canvas);
    final picture = pictureRecorder.endRecording();

    // Create an image of the mask.

    final sceneBuilder = ui.SceneBuilder();
    final transform =
        Matrix4.diagonal3Values(devicePixelRatio, devicePixelRatio, 1);
    sceneBuilder.pushTransform(transform.storage);
    sceneBuilder.addPicture(Offset.zero, picture);
    final scene = sceneBuilder.build();

    final image = scene.toImageSync(
      (size.width * devicePixelRatio).ceil(),
      (size.height * devicePixelRatio).ceil(),
    );

    setState(() {
      _mask = image;
    });
  }

  @override
  void dispose() {
    _mask?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'assets/shaders/masked_blur.frag',
      (context, shader, _) {
        final mask = _mask;
        if (mask == null) {
          return const SizedBox.expand();
        }

        return GestureDetector(
          onPanUpdate: (details) {
            _updateMask((canvas) {
              // On every pan update, draw a circle at the current position to
              // mark the area.
              canvas.drawCircle(
                details.localPosition,
                50,
                Paint()..color = Colors.white,
              );
            });
          },
          child: AnimatedSampler(
            (image, size, offset, canvas) {
              shader
                ..setFloat(0, size.width)
                ..setFloat(1, size.height)
                ..setFloat(2, offset.dx)
                ..setFloat(3, offset.dy)
                ..setImageSampler(0, image)
                ..setImageSampler(1, mask);
              canvas.drawRect(offset & size, Paint()..shader = shader);
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}
