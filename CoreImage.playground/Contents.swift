import UIKit
import PlaygroundSupport

//: # Loading Images
let url = Bundle.main.url(forResource: "IMG_5276", withExtension: "HEIC")!
var options = [CIImageOption.applyOrientationProperty: true]
let image = CIImage(contentsOf: url, options: options)!

//: # Filtering Images
let resized = image.transformed(by: CGAffineTransform(scaleX: 0.125, y: 0.125))

let filtered = resized.applyingFilter("CIPhotoEffectNoir")
                      .applyingFilter("CIDotScreen", parameters: [
                        "inputAngle" : 0.5,
                        "inputCenter": CIVector(x: 100, y: 100),
                        "inputSharpness" : 0.2,
                        "inputWidth" : 0.5])

//: # Displaying Images
let uiImage = UIImage(ciImage: filtered)
PlaygroundPage.current.liveView = UIImageView(image: uiImage)



