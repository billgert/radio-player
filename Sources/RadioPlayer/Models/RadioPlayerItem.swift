import Foundation
import UIKit.UIImage

public struct RadioPlayerItem {
  let name: String
  let description: String
  let streamingUrl: URL
  let image: Image
  
  public init(name: String,
              description: String,
              streamingUrl: URL,
              image: Image) {
    self.name = name
    self.description = description
    self.streamingUrl = streamingUrl
    self.image = image
  }
}

// MARK: - Image

extension RadioPlayerItem {
  public struct Image {
    let placeholder: UIImage
    let url: URL?
    
    public init(placeholder: UIImage, url: URL? = nil) {
      self.placeholder = placeholder
      self.url = url
    }
  }
}
