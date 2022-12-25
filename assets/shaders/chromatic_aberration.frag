#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

layout(location = 0) uniform float imageSizeX;
layout(location = 1) uniform float imageSizeY;
layout(location = 2) uniform float imageOffsetX;
layout(location = 3) uniform float imageOffsetY;
layout(location = 4) uniform float aberrationWidth;
layout(location = 5) uniform sampler2D image;

out vec4 fragColor;

void main() {
  vec2 imageSize = vec2(imageSizeX, imageSizeY);
  vec2 imageOffset = vec2(imageOffsetX, imageOffsetY);
  vec2 uv = (FlutterFragCoord().xy - imageOffset) / imageSize;
  float pixelWidth = 1.0 / imageSize.x;
  vec2 aberration = vec2(pixelWidth * aberrationWidth, 0.0);

  vec2 left = uv - aberration;
  vec2 right = uv + aberration;

  vec4 color = texture(image, uv);
  vec4 colorLeft = texture(image, left);
  vec4 colorRight = texture(image, right);

  fragColor = vec4(colorLeft.r, color.g, colorRight.b, (colorLeft.a + color.a + colorRight.a) / 3.0);
}
