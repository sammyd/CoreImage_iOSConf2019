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

import CoreImage

class CIRgbToYcbcrFilter: CIFilter {
  private lazy var kernel: CIColorKernel = {
    guard
      let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
      let data = try? Data(contentsOf: url) else {
        fatalError("Unable to get metallib")
    }
    
    guard let kernel = try? CIColorKernel(functionName: "rgbToYcbcrFilterKernel", fromMetalLibraryData: data) else {
      fatalError("Unable to create CIColorKernel from rgbToYcbcrFilterKernel")
    }
    
    return kernel
  }()
  
  var inputImage: CIImage?
  
  override var outputImage: CIImage? {
    guard let inputImage = inputImage else { return .none }
    
    return apply(kernel, arguments: [inputImage], options: [kCIApplyOptionExtent: inputImage.extent.toArray])
  }

}
