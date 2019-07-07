import UIKit.UIImage

class Downloader {
  private static let cache = NSCache<NSString, NSData>()
  
  class func image(for url: URL?, completionHandler: @escaping(UIImage?) -> Void) {
    guard let url = url else {
      completionHandler(nil)
      return
    }
    
    DispatchQueue.global(qos: .background).async {
      let key = url.absoluteString as NSString
      
      if
        let nsData = self.cache.object(forKey: key),
        let cachedImage = UIImage(data: nsData as Data) {
        DispatchQueue.main.async { completionHandler(cachedImage) }
        return
      }
      
      if
        let nsData = NSData(contentsOf: url),
        let newImage = UIImage(data: nsData as Data) {
        self.cache.setObject(nsData, forKey: key)
        DispatchQueue.main.async { completionHandler(newImage) }
        return
      }
      
      DispatchQueue.main.async { completionHandler(nil) }
    }
  }
}
