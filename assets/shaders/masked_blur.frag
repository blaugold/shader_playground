#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

layout(location = 0) uniform float imageSizeX;
layout(location = 1) uniform float imageSizeY;
layout(location = 2) uniform float direction;
layout(location = 3) uniform sampler2D image;
layout(location = 4) uniform sampler2D mask;

out vec4 fragColor;

const int blurSize = 33;

float blurWeight(int i) {
  if (i < blurSize / 2) {
    return i;
  } else {
    return blurSize - i;
  }
}

vec4 blur(vec2 uv, vec2 imageSize) {
  vec2 pixelSize = 1.0 / imageSize.xy;
  vec2 directionVector = vec2(sin(direction), cos(direction));
  vec2 center = directionVector * (blurSize / 2.0);

  float weights = 0.0;
  vec4 color = vec4(0.0);

  for (int i = 0; i < blurSize; i++) {
    float weight = blurWeight(i);
    weights += weight;

    vec2 offset = (i * directionVector - center) * pixelSize;
    vec2 p = uv + offset;
    color += weight * texture(image, p);
  }

  color /= weights;

  return color;
}

void main() {
  vec2 imageSize = vec2(imageSizeX, imageSizeY);
  vec2 uv = FlutterFragCoord().xy / imageSize;
  vec4 maskColor = texture(mask, uv);

  if (maskColor.a == 1.0) {
    fragColor = texture(image, uv);
  } else {
    fragColor = blur(uv, imageSize);
  }
}

