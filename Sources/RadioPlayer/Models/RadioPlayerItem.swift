import Foundation

public struct RadioPlayerItem {
  let name: String
  let description: String
  let streamingUrl: URL
  let imageUrl: URL?
  
  public init(name: String,
              description: String,
              streamingUrl: URL,
              imageUrl: URL? = nil) {
    self.name = name
    self.description = description
    self.streamingUrl = streamingUrl
    self.imageUrl = imageUrl
  }
}
