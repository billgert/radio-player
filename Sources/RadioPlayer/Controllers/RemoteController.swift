import MediaPlayer

protocol RemoteControllerDelegate: class {
  func remoteControllerDidReceivePlayCommand(_ remoteController: RemoteController)
  func remoteControllerDidReceivePauseCommand(_ remoteController: RemoteController)
  func remoteController(_ remoteController: RemoteController, didUpdate nowPlayingInfo: [String: Any]?)
}

class RemoteController {
  weak var delegate: RemoteControllerDelegate?
  
  private let remoteCommandCenter = MPRemoteCommandCenter.shared()
  private let nowPlayingInfoCenter =  MPNowPlayingInfoCenter.default()
  
  private var nowPlayingInfo: [String: Any]? = [:] {
    didSet {
      nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
      notifyListeners()
    }
  }
  
  // MARK: Initialization
  
  init() {
    setupCommandCenter()
  }
  
  // MARK: Private Methods
  
  private func setupCommandCenter() {
    remoteCommandCenter.playCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
      guard let self = self else {
        return .commandFailed
      }
      self.delegate?.remoteControllerDidReceivePlayCommand(self)
      return .success
    }
    
    remoteCommandCenter.pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
      guard let self = self else {
        return .commandFailed
      }
      self.delegate?.remoteControllerDidReceivePauseCommand(self)
      return .success
    }
  }
  
  private func artworkForImage(_ image: UIImage) -> MPMediaItemArtwork {
    return MPMediaItemArtwork(
      boundsSize: image.size,
      requestHandler: { _ in
        return image
    })
  }
  
  private func notifyListeners() {
    delegate?.remoteController(self, didUpdate: nowPlayingInfoCenter.nowPlayingInfo)
  }
  
  // MARK: Public Methods
  
  func clearInfo() {
    nowPlayingInfo = nil
  }
  
  func setTitle(_ title: String) {
    nowPlayingInfo?[MPMediaItemPropertyTitle] = title
  }
  
  func setArtist(_ artist: String) {
    nowPlayingInfo?[MPMediaItemPropertyArtist] = artist
  }
  
  func setImage(_ image: UIImage) {
    nowPlayingInfo?[MPMediaItemPropertyArtwork] = artworkForImage(image)
  }
}
