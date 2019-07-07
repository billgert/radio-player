import AVFoundation

protocol PlaybackObserverDelegate: class {
  func playbackObserver(_ observer: PlaybackObserver, isPlayable playerItem: AVPlayerItem)
  func playbackObserver(_ observer: PlaybackObserver, didFail playerItem: AVPlayerItem, error: Error)
  func playbackObserver(_ observer: PlaybackObserver, notReady playerItem: AVPlayerItem)
  func playbackObserver(_ observer: PlaybackObserver, didStartBuffering playerItem: AVPlayerItem)
  func playbackObserver(_ observer: PlaybackObserver, didFinishBuffering playerItem: AVPlayerItem)
  func playbackObserver(_ observer: PlaybackObserver, didUpdate metaDataItem: [AVMetadataItem])
}

class PlaybackObserver: NSObject {
  weak var delegate: PlaybackObserverDelegate?
  
  private static var context = 0
  
  private var playerItem: AVPlayerItem?
  
  // MARK: Public Methods
  
  func observePlayerItem(_ item: AVPlayerItem) {
    if let playerItem = playerItem {
      removeObserversForPlayerItem(playerItem)
    }
    addObserversForPlayerItem(item)
    playerItem = item
  }
  
  // MARK: Observers
  
  private func removeObserversForPlayerItem(_ item: AVPlayerItem) {
    item.removeObserver(self, forKeyPath: "status", context: &PlaybackObserver.context)
    item.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: &PlaybackObserver.context)
    item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: &PlaybackObserver.context)
    item.removeObserver(self, forKeyPath: "timedMetadata", context: &PlaybackObserver.context)
  }
  
  private func addObserversForPlayerItem(_ item: AVPlayerItem) {
    item.addObserver(self, forKeyPath: "status", options: .new, context: &PlaybackObserver.context)
    item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: &PlaybackObserver.context)
    item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: &PlaybackObserver.context)
    item.addObserver(self, forKeyPath: "timedMetadata", options: [.initial, .new, .old], context: &PlaybackObserver.context)
  }
  
  // MARK: KVO
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    guard context == &PlaybackObserver.context else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }
    
    guard let playerItem = self.playerItem else {
      return
    }

    if keyPath == "status" {
      guard
        let statusNumber = change?[NSKeyValueChangeKey.newKey] as? Int,
        let status = AVPlayerItem.Status(rawValue: statusNumber) else { return }
      
      switch status {
      case .readyToPlay:
        delegate?.playbackObserver(self, isPlayable: playerItem)
      case .failed:
        guard let error = playerItem.error else { return }
        delegate?.playbackObserver(self, didFail: playerItem, error: error)
      case .unknown:
        delegate?.playbackObserver(self, notReady: playerItem)
      @unknown default:
        fatalError()
      }
    }
    
    if keyPath == "playbackBufferEmpty" {
      delegate?.playbackObserver(self, didStartBuffering: playerItem)
    }
    
    if keyPath == "playbackLikelyToKeepUp" {
      delegate?.playbackObserver(self, didFinishBuffering: playerItem)
    }

    if keyPath == "timedMetadata" {
      guard let timedMetaData = playerItem.timedMetadata else { return }
      delegate?.playbackObserver(self, didUpdate: timedMetaData)
    }
  }
}
