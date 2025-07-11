import AVKit
import AVFoundation
import os.log

@MainActor
class VideoViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var error: VideoError?
    
    private let logger = Logger(subsystem: "com.devassist.app", category: "Video")
    
    func initialize() async {
        await setupVideoPlayer()
    }
    
    private func setupVideoPlayer() async {
        do {
            // Use secure, Apple-approved video URL
            guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
                throw VideoError.invalidURL
            }
            
            // Create player with proper configuration
            let player = AVPlayer(url: url)
            
            // Configure for background audio (Apple guideline compliance)
            player.allowsExternalPlayback = true
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            
            self.player = player
            
            logger.info("Video player initialized successfully")
            
        } catch {
            logger.error("Video player setup failed: \(error.localizedDescription)")
            self.error = error as? VideoError ?? .unknown
        }
    }
    
    func configureAudioSession() {
        do {
            // Configure audio session for video playback (Apple guidelines)
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            
            logger.info("Audio session configured for video playback")
            
        } catch {
            logger.error("Audio session configuration failed: \(error.localizedDescription)")
        }
    }
    
    func pausePlayback() {
        player?.pause()
        isPlaying = false
    }
    
    func resumePlayback() {
        player?.play()
        isPlaying = true
    }
}

enum VideoError: LocalizedError {
    case invalidURL
    case loadingFailed
    case playbackFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid video URL"
        case .loadingFailed:
            return "Failed to load video"
        case .playbackFailed:
            return "Video playback failed"
        case .unknown:
            return "Unknown video error"
        }
    }
}
