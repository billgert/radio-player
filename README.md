# RadioPlayer

This Swift Package is a native radio player for iOS. Install by going to Xcode -> File -> Swift Packages -> Add Package Dependency and follow the instructions.

## Examples

Here follows some examples on how to use RadioPlayer on different platforms.

#### iOS

Use shared instance `RadioPlayer.shared` if that makes sense for your app.

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
