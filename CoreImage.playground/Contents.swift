import UIKit
import PlaygroundSupport

//: # Loading Images
let url = Bundle.main.url(forResource: "IMG_5276", withExtension: "HEIC")!
var options = [CIImageOption.applyOrientationProperty: true]
let image = CIImage(contentsOf: url, options: options)!

options = [CIImageOption.auxiliaryPortraitEffectsMatte: true, CIImageOption.applyOrientationProperty: true]
let matte = CIImage(contentsOf: url, options: options)!
let matteResized = matte.transformed(by: CGAffineTransform(scaleX: 0.25, y: 0.25))

//: # Filtering Images
let resized = image.transformed(by: CGAffineTransform(scaleX: 0.125, y: 0.125))

let foreground = resized.applyingFilter("CIVibrance", parameters: ["inputAmount" : 0.7])
let background = resized.applyingFilter("CIVibrance", parameters: ["inputAmount": -0.8])
                        .applyingFilter("CIDiscBlur", parameters: ["inputRadius": 8])
                        .cropped(to: resized.extent)
                        .applyingFilter("CIVignette", parameters: ["inputIntensity" : 0.7, "inputRadius": 20])
let composite = foreground.applyingFilter("CIBlendWithMask",
                                          parameters: ["inputBackgroundImage": background,
                                                       "inputMaskImage": matteResized])


//: # Displaying Images
let uiImage = UIImage(ciImage: composite)
PlaygroundPage.current.liveView = UIImageView(image: uiImage)



