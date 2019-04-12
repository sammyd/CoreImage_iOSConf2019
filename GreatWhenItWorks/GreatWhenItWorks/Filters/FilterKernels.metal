/*
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>

#define K_R 0.2126
#define K_G 0.7152
#define K_B 0.0722


extern "C" { namespace coreimage {
  
  float4 ycbcrToRgb(float4 pixel) {
    float y  = pixel.r;
    float cb = pixel.g;
    float cr = pixel.b;
    float blue  = 2 * cb * (1 - K_B) + y;
    float red   = 2 * cr * (1 - K_R) + y;
    float green = (y - K_R * red - K_B * blue) / K_G;
    return float4(red, green, blue, pixel.a);
  }
  
  // KERNEL
  float4 bilateralFilterKernel(sampler src, float kernelRadius_f, float sigmaSpatial, float sigmaRange) {
    float4 input = src.sample(src.coord());
    float3 premultipliedRunningSum = 0;
    float weightRunningSum = 0;
    int kernelRadius = int(kernelRadius_f);

    for (int i = -kernelRadius; i <= kernelRadius; i++) {
      for (int j = -kernelRadius; j <= kernelRadius; j++) {
        float4 referenceInput = src.sample(src.coord() + float2(i, j));

        float weight = exp ( - (i * i + j * j) / (2 * sigmaSpatial * sigmaSpatial)
                             - pow((input.r - referenceInput.r), 2.0) / (2 * sigmaRange * sigmaRange));

        weightRunningSum += weight;
        premultipliedRunningSum += weight * referenceInput.rgb;
      }
    }

    return float4(premultipliedRunningSum / weightRunningSum, input.a);
  }
  
  // KERNEL
  float4 ycbcrToRgbFilterKernel(sample_t s) {
    return ycbcrToRgb(s);
  }
  
  
  
  
  
  float intensity(float4 pixel) {
    return K_R * pixel.r + K_G * pixel.g + K_B * pixel.b;
  }
  
  float blueDifference(float4 pixel) {
    return (pixel.b - intensity(pixel)) / (2 * (1 - K_B));
  }
  
  float redDifference(float4 pixel) {
    return (pixel.r - intensity(pixel)) / (2 * (1 - K_R));
  }
  
  // KERNEL
  float4 rgbToYcbcrFilterKernel(sample_t s) {
    float y = intensity(s);
    float cb = blueDifference(s);
    float cr = redDifference(s);
    return float4(y, cb, cr, s.a);
  }
}}

