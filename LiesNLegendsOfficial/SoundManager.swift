import Foundation
import AVFoundation
import UIKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    // Separate players for background music and sound effects
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    // Published properties for UI control
    @Published var isBackgroundMusicPlaying = false
    @Published var backgroundMusicVolume: Float = 0.5
    @Published var soundEffectsVolume: Float = 1.0
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // Configure audio session for background playback and mixing with other apps
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Add notification observers for audio interruptions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: nil
            )
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio interruption began - pause music
            pauseBackgroundMusic()
        case .ended:
            // Audio interruption ended - resume music if it was playing
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resumeBackgroundMusic()
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable:
            // Audio route changed - ensure music continues playing
            if isBackgroundMusicPlaying {
                resumeBackgroundMusic()
            }
        default:
            break
        }
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(named soundName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Background music file not found: \(soundName).\(fileExtension)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Infinite loop
            backgroundMusicPlayer?.volume = backgroundMusicVolume
            backgroundMusicPlayer?.play()
            isBackgroundMusicPlaying = true
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        isBackgroundMusicPlaying = false
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        isBackgroundMusicPlaying = false
    }
    
    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
        isBackgroundMusicPlaying = true
    }
    
    func setBackgroundMusicVolume(_ volume: Float) {
        backgroundMusicVolume = volume
        backgroundMusicPlayer?.volume = volume
    }
    
    // MARK: - Sound Effects
    func playSound(named soundName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Sound file not found: \(soundName).\(fileExtension)")
            return
        }
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.numberOfLoops = 0 // No loop for sound effects
            soundEffectPlayer?.volume = soundEffectsVolume
            soundEffectPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func setSoundEffectsVolume(_ volume: Float) {
        soundEffectsVolume = volume
        soundEffectPlayer?.volume = volume
    }
    
    // MARK: - Haptics
    func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Cleanup
    func cleanup() {
        // Remove notification observers
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        
        // Stop and cleanup audio players
        backgroundMusicPlayer?.stop()
        soundEffectPlayer?.stop()
        backgroundMusicPlayer = nil
        soundEffectPlayer = nil
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    deinit {
        cleanup()
    }
} 