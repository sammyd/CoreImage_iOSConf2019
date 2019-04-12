# Core Image: Great When it Works

## Part 1: Interrogating filters

Your first snippet:

```
import CoreImage
```

```
// List all the filters
CIFilter.filterNames(inCategories: nil)
```

```
// Learn about a filter
CIFilter.localizedDescription(forFilterName: "CIBokehBlur")
```

```
// Instantiate it
let f = CIFilter(name: "CIBokehBlur")!
```

```
// Interrogate it
f.inputKeys
```

```
f.attributes
```

## Part 2: Using filters

Load an image:

```
let url = Bundle.main.url(forResource: "IMG_5276", withExtension: "HEIC")!
let image = CIImage(contentsOf: url)!
```

Resize it:
```
let resized = image.transformed(by: CGAffineTransform(scaleX: 0.125, y: 0.125))
```

Display a CIImage:

```
let uiImage = UIImage(ciImage: resized)
PlaygroundPage.current.liveView = UIImageView(image: uiImage)
```

Get it to handle auto-rotation:

```
var options = [CIImageOption.applyOrientationProperty: true]
let image = CIImage(contentsOf: url, options: options)!
```

Apply a filter:
```
let filtered = resized.applyingFilter("CIPhotoEffectNoir")
```

with parameters:

```
.applyingFilter("CIDotScreen", parameters: [
                        "inputAngle" : 0.5,
                        "inputCenter": CIVector(x: 100, y: 100),
                        "inputSharpness" : 0.2,
                        "inputWidth" : 0.5])
```


## Part 3: Building the depth filter

Import the depth mask

```
options = [CIImageOption.auxiliaryDepth: true, CIImageOption.applyOrientationProperty: true]
let depth = CIImage(contentsOf: url, options: options )!
```

And the portrait matte

```
options = [CIImageOption.auxiliaryPortraitEffectsMatte: true, CIImageOption.applyOrientationProperty: true]
let matte = CIImage(contentsOf: url, options: options)!
let matteResized = matte.transformed(by: CGAffineTransform(scaleX: 0.25, y: 0.25))
```

Create the foreground
```
let foreground = resized.applyingFilter("CIVibrance", parameters: ["inputAmount" : 0.7])
```

Create the background
```
let background = resized.applyingFilter("CIVibrance", parameters: ["inputAmount": -0.8])
                        .applyingFilter("CIDiscBlur", parameters: ["inputRadius": 8])
                        .cropped(to: resized.extent)
                        .applyingFilter("CIVignette", parameters: ["inputIntensity" : 0.7, "inputRadius": 20])
```

Composite them together
```
let composite = foreground.applyingFilter("CIBlendWithMask",
                                          parameters: ["inputBackgroundImage": background,
                                                       "inputMaskImage": matteResized])
```


## Part 4: Building a colour kernel

A passthrough colour kernel:

```
  // KERNEL
  float4 rgbToYcbcrFilterKernel(sample_t s) {
    return s;
  }
```

Creating the kernel property:

```
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
```

The input image:

```
var inputImage: CIImage?
```

And output image:
```
override var outputImage: CIImage? {
    guard let inputImage = inputImage else { return .none }
    
    return apply(kernel, arguments: [inputImage], options: [kCIApplyOptionExtent: inputImage.extent.toArray])
  }
```

Then use this in my view controller:

```
let filter = CIRgbToYcbcrFilter()
    filter.inputImage = CIImage(nsImage: image)
    
    guard let output = filter.outputImage else { return }
    
    afterImageView.image = NSImage(ciImage: output)
```

Make it show intensity:

```
float y = intensity(s);
    return float4(y, y, y, s.a);
```

And now ycbcr:
```
float y = intensity(s);
    float cb = blueDifference(s);
    float cr = redDifference(s);
    return float4(y, cb, cr, s.a);
```

Check it works by incorporating the inverse:

```
let inverseFilter = CIYcbcrToRgbFilter()
    inverseFilter.inputImage = filter.outputImage
    
    guard let output = inverseFilter.outputImage else { return }
```


## Part 5: Building the bilateral filter

Switch to using the bilateral filter processor in the VC:

```
afterImageView.image = imageProcessor.process(image: image)
```

Add the kernel call to the filter:

```
let sampler = CISampler(image: inputImage)
    
    return apply(kernel, arguments: [sampler, kernelRadius, sigmaSpatial, sigmaRange], options: [kCIApplyOptionExtent: inputImage.extent.toArray])
```

Need to wrap it in a colour space switch:

```
    let ycbcrFilter = CIRgbToYcbcrFilter()
    ycbcrFilter.inputImage = downsized
    
    filter.inputImage = ycbcrFilter.outputImage
    
    let rgbFilter = CIYcbcrToRgbFilter()
    rgbFilter.inputImage = filter.outputImage

    guard let outputImage = rgbFilter.outputImage else { return .none }
```

