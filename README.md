# RadioPlayer

This package is a native RadioPlayer for iOS and coming soon to iPadOS, watchOS, tvOS and macOS.

Todo:
- How to use it
- Any platform restrictions (platform specific API's such as UIKit (iOS) or AppKit (macOS))
- Information about licensing

## Examples

Here follows some examples on how to use RadioPlayer on different platforms.

#### iOS

Use shared instance: `RadioPlayer.shared` if that makes sense for your app.

```swift
import UIKit
import RadioPlayer

class ViewController: UIViewController {
  let radioPlayer = RadioPlayer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    let playerItemImage = RadioPlayerItem.Image(placeholder: UIImage(named: "LOCAL_IMAGE_NAME_STRING")!,
                                                url: URL(string: "REMOTE_IMAGE_URL"))
    
    let item = RadioPlayerItem(name: "NAME_STRING",
                               description: "DESCRIPTION_STRING",
                               streamingUrl: URL(string: "REMOTE_URL")!,
                               image: playerItemImage)
    
    radioPlayer.load(item)
  }
}
```
