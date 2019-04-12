# Core Image
## _great_ when it works

---

## Syntax highlighting



```
$ swift
import CoreImage

// List all the filters
CIFilter.filterNames(inCategories: nil)

// Learn about a filter
CIFilter.localizedDescription(forFilterName: "CIBokehBlur")

// Instantiate it
let f = CIFilter(name: "CIBokehBlur")!

// Interrogate it
f.inputKeys
f.attributes
```

