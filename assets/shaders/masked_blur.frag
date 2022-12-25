#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

layout(location = 0) uniform vec2 imageSize;
layout(location = 1) uniform vec2 imageOffset;
layout(location = 2) uniform sampler2D image;
layout(location = 3) uniform sampler2D wipeMask;

out vec4 fragColor;

const float blurSize = 15.0;

float blurWeight(float i) {
  if (i < blurSize / 2.0) {
    return i;
  } else {
    return blurSize - i;
  }
}

vec4 blur(vec2 uv) {
  vec2 pixelSize = 1.0 / imageSize.xy;
  vec2 center = vec2(blurSize / 2.0);

  float weights = 0.0;
  vec4 color = vec4(0.0);

  for (float i = 0.0; i < blurSize; i += 1.0) {
    for (float j = 0.0; j < blurSize; j += 1.0) {
      float weight = (blurWeight(i) + blurWeight(j)) / 2.0;
      weights += weight;

      vec2 offset = (vec2(i, j) - center) * pixelSize;
      vec2 p = uv + offset;
      color += weight * texture(image, p);
    }
  }

  color /= weights;

  return color;
}

void main() {
  vec2 uv = (FlutterFragCoord().xy - imageOffset) / imageSize;
  vec4 maskColor = texture(wipeMask, uv);

  if (maskColor.a == 1.0) {
    fragColor = texture(image, uv);
  } else {
    fragColor = blur(uv);
  }
}

