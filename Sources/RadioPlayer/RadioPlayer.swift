import AVFoundation
import UIKit.UIImage

public extension Notification.Name {
  static let PlayerDidPlayNotification = Notification.Name("playerDidPlayNotification")
  static let PlayerDidPauseNotification = Notification.Name("playerDidPauseNotification")
  static let PlayerDidStopNotification = Notification.Name("playerDidStopNotification")
  static let PlayerDidUpdateInfoNotification = Notification.Name("playerDidUpdateInfoNotification")
  static let PlayerDidBeginBufferingNotification = Notification.Name("playerDidBeginBufferingNotification")
  static let PlayerDidEndBufferingNotification = Notification.Name("playerDidEndBufferingNotification")
  static let PlayerDidFailNotification = Notification.Name("playerDidFailNotification")
}

public class RadioPlayer {
  static let shared = RadioPlayer()
  
  var isPlaying: Bool {
    return player.timeControlStatus == .playing
  }
  
  var isPaused: Bool {
    return player.timeControlStatus == .paused
  }
  
  var item: RadioPlayerItem?
  
  private var isBuffering = false
  private var isInterrupted = false
  private var isConnectedToInternet = true
  
  private let player = AVPlayer()
  
  private let playbackObserver = PlaybackObserver()
  private let deviceObserver = DeviceObserver()
  private let remoteController = RemoteController()
  
  // MARK: Initialization
  
  public init() {
    playbackObserver.delegate = self
    deviceObserver.delegate = self
    remoteController.delegate = self
    
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback)
    } catch {
      print("AVAudioSession.sharedInstance(): \(error.localizedDescription)")
    }
  }
  
  // MARK: Actions
  
  public func load(_ item: RadioPlayerItem) {
    self.item = item
    let playerItem = AVPlayerItem(url: item.streamingUrl)
    playbackObserver.observePlayerItem(playerItem)
    player.replaceCurrentItem(with: playerItem)
  }
  
  public func stop() {
    item = nil
    player.pause()
    player.replaceCurrentItem(with: nil)
    remoteController.clearInfo()
    NotificationCenter.default.post(name: .PlayerDidStopNotification,
                                    object: self)
  }
  
  public func play() {
    player.play()
    NotificationCenter.default.post(name: .PlayerDidPlayNotification,
                                    object: self)
  }
  
  public func pause() {
    player.pause()
    NotificationCenter.default.post(name: .PlayerDidPauseNotification,
                                    object: self)
  }
}

// MARK: - PlaybackObserverDelegate

extension RadioPlayer: PlaybackObserverDelegate {
  func playbackObserver(_ observer: PlaybackObserver, isPlayable playerItem: AVPlayerItem) {
    if !isPlaying && !isPaused {
      play()
    }
  }
  
  func playbackObserver(_ observer: PlaybackObserver, didFail playerItem: AVPlayerItem, error: Error) {
    NotificationCenter.default.post(name: .PlayerDidFailNotification,
                                    object: self,
                                    userInfo: ["error": error])
    stop()
  }
  
  func playbackObserver(_ observer: PlaybackObserver, notReady playerItem: AVPlayerItem) {
    print("playbackObserver: playerItemNotReady")
  }
  
  func playbackObserver(_ observer: PlaybackObserver, didStartBuffering playerItem: AVPlayerItem) {
    NotificationCenter.default.post(name: .PlayerDidBeginBufferingNotification,
                                    object: self)
    if playerItem.isPlaybackBufferEmpty {
      guard let item = self.item else { return }
      load(item)
    }
    isBuffering = true
  }
  
  func playbackObserver(_ observer: PlaybackObserver, didFinishBuffering playerItem: AVPlayerItem) {
    NotificationCenter.default.post(name: .PlayerDidEndBufferingNotification,
                                    object: self)
    if isPaused && isBuffering {
      play()
      guard let item = self.item else { return }
      remoteController.setTitle(item.name)
      remoteController.setArtist(item.description)
      Downloader.image(for: item.image.url) { image in
        let image = image ?? item.image.placeholder
        self.remoteController.setImage(image)
      }
    }
    isBuffering = false
  }
  
  func playbackObserver(_ observer: PlaybackObserver, didUpdate metaDataItem: [AVMetadataItem]) {
    if let title = metaDataItem.first?.stringValue {
      self.remoteController.setTitle(title)
    }
  }
}

// MARK: - DeviceObserverDelegate

extension RadioPlayer: DeviceObserverDelegate {
  func deviceObserverDidBeginInterruption(_ observer: DeviceObserver) {
    isInterrupted = true
  }
  
  func deviceObserver(_ observer: DeviceObserver, didEndInterruptionWithOptions options: AVAudioSession.InterruptionOptions) {
    if isInterrupted {
      play()
    }
    isInterrupted = false
  }
  
  func deviceObserverDidConnectHeadPhones(_ observer: DeviceObserver) {
    print("deviceObserverDidConnectHeadPhones")
  }
  
  func deviceObserverDidDisconnectHeadPhones(_ observer: DeviceObserver) {
    if isPlaying {
      pause()
    }
  }
}

// MARK: - RemoteControllerDelegate

extension RadioPlayer: RemoteControllerDelegate {
  func remoteControllerDidReceivePlayCommand(_ remoteController: RemoteController) {
    play()
  }
  
  func remoteControllerDidReceivePauseCommand(_ remoteController: RemoteController) {
    pause()
  }
  
  func remoteController(_ remoteController: RemoteController, didUpdate nowPlayingInfo: [String : Any]?) {
    NotificationCenter.default.post(name: .PlayerDidUpdateInfoNotification,
                                    object: self,
                                    userInfo: nowPlayingInfo)
  }
}
