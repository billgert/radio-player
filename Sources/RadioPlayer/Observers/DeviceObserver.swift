import AVFoundation

protocol DeviceObserverDelegate: class {
  func deviceObserverDidBeginInterruption(_ observer: DeviceObserver)
  func deviceObserver(_ observer: DeviceObserver, didEndInterruptionWithOptions options: AVAudioSession.InterruptionOptions)
  func deviceObserverDidConnectHeadPhones(_ observer: DeviceObserver)
  func deviceObserverDidDisconnectHeadPhones(_ observer: DeviceObserver)
}

class DeviceObserver {
  weak var delegate: DeviceObserverDelegate?

  // MARK: Initialization
  
  init() {
    setupInterruptionObserver()
    setupRouteChangeObserver()
  }
  
  // MARK: Interruptions
  
  private func setupInterruptionObserver() {
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: nil,
      queue: nil) { notification in
        guard let userInfo = notification.userInfo,
          let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
        case .began:
          self.delegate?.deviceObserverDidBeginInterruption(self)
        case .ended:
          if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            self.delegate?.deviceObserver(self, didEndInterruptionWithOptions: options)
          }
        @unknown default:
          fatalError()
        }
    }
  }
  
  // MARK: Route Changes
  
  private func setupRouteChangeObserver() {
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification,
      object: nil,
      queue: nil) { notification in
        guard let userInfo = notification.userInfo,
          let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        switch reason {
        case .newDeviceAvailable:
          self.delegate?.deviceObserverDidConnectHeadPhones(self)
        case .oldDeviceUnavailable:
          self.delegate?.deviceObserverDidDisconnectHeadPhones(self)
        default:
          print("AVAudioSession.routeChangeNotification: \(reason)")
        }
    }
  }
}

