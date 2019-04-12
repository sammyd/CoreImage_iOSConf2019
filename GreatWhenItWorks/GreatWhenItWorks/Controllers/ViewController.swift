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

class ViewController: NSViewController {
  
  @IBOutlet weak var beforeImageView: NSImageView!
  @IBOutlet weak var afterImageView: NSImageView!
  
  @IBOutlet weak var kernelSizeSlider: NSSlider!
  @IBOutlet weak var spatialSigmaSlider: NSSlider!
  @IBOutlet weak var rangeSigmaSlider: NSSlider!
  @IBOutlet weak var kernelSizeLabel: NSTextField!
  @IBOutlet weak var spatialSigmaLabel: NSTextField!
  @IBOutlet weak var rangeSigmaLabel: NSTextField!
  
  @IBAction func handleNewImage(_ sender: NSImageView) {
    processImage()
  }
  
  @IBAction func handleSliderMoved(_ sender: Any) {
    imageProcessor.kernelRadius = kernelSizeSlider.integerValue
    imageProcessor.sigmaRange = rangeSigmaSlider.floatValue
    imageProcessor.sigmaSpatial = spatialSigmaSlider.floatValue
    updateLabels()
    processImage()
  }
  
  let imageProcessor = BilateralFilerImageProcessor()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    kernelSizeSlider.integerValue = imageProcessor.kernelRadius
    spatialSigmaSlider.floatValue = imageProcessor.sigmaSpatial
    rangeSigmaSlider.floatValue = imageProcessor.sigmaRange
    updateLabels()
  }
  
  private func updateLabels() {
    kernelSizeLabel.stringValue = "\(kernelSizeSlider.integerValue)"
    spatialSigmaLabel.stringValue = spatialSigmaSlider.stringValue
    rangeSigmaLabel.stringValue = rangeSigmaSlider.stringValue
  }
  
  private func processImage() {
    guard let image = beforeImageView.image else { return }
    
    afterImageView.image = imageProcessor.process(image: image)
  }
}

