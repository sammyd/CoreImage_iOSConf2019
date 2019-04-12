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

import Cocoa

class BilateralFilerImageProcessor {
  private let filter = BilateralFilter()
  
  var kernelRadius: Int = 5{
    didSet {
      filter.kernelRadius = kernelRadius
    }
  }
  
  var sigmaSpatial: Float = 15 {
    didSet {
      filter.sigmaSpatial = sigmaSpatial
    }
  }
  
  var sigmaRange: Float = 0.01 {
    didSet {
      filter.sigmaRange = sigmaRange
    }
  }
  
  func process(image: NSImage) -> NSImage? {
    guard let ciimage = CIImage(nsImage: image) else { return .none }
    
    let scaleFactor = 600 / max(ciimage.extent.width, ciimage.extent.height);
    let downsized = ciimage.transformed(by: CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor))
    
    let ycbcrFilter = CIRgbToYcbcrFilter()
    ycbcrFilter.inputImage = downsized
    
    filter.inputImage = ycbcrFilter.outputImage
    
    let rgbFilter = CIYcbcrToRgbFilter()
    rgbFilter.inputImage = filter.outputImage

    guard let outputImage = rgbFilter.outputImage else { return .none }

    return NSImage(ciImage: outputImage)
  }

}

fileprivate class BilateralFilter: CIFilter {
  private lazy var kernel: CIKernel = {
    guard
      let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
      let data = try? Data(contentsOf: url) else {
        fatalError("Unable to get metallib")
    }
    
    guard let kernel = try? CIKernel(functionName: "bilateralFilterKernel", fromMetalLibraryData: data) else {
      fatalError("Unable to create CIKernel from bilateralFilterKernel")
    }
    
    return kernel
  }()
  
  var inputImage: CIImage?
  var kernelRadius: Int = 11
  var sigmaSpatial: Float = 0.01
  var sigmaRange: Float = 15
  
  override var outputImage: CIImage? {
    guard let inputImage = inputImage else { return .none }
    
    let sampler = CISampler(image: inputImage)
    
    return apply(kernel, arguments: [sampler, kernelRadius, sigmaSpatial, sigmaRange], options: [kCIApplyOptionExtent: inputImage.extent.toArray])
  }
}
