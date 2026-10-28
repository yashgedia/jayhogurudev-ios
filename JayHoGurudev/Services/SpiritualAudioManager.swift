import Foundation
import SwiftUI
import AVFoundation
import MediaPlayer

@MainActor
public class SpiritualAudioManager: ObservableObject {
    public static let shared = SpiritualAudioManager()
    
    @Published public var currentTrack: BhajanTrack? = nil
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0.0
    @Published public var duration: Double = 0.0
    @Published public var playlist: [BhajanTrack] = []
    @Published public var isShuffle: Bool = false
    @Published public var isRepeat: Bool = false
    @Published public var isMiniPlayerVisible: Bool = false
    @Published public var showFullPlayer: Bool = false
    @Published public var errorMessage: String? = nil
    
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playerItemContext = 0
    
    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to configure background audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Controls
    public func setPlaylist(_ tracks: [BhajanTrack]) {
        self.playlist = tracks
    }
    
    public func playTrack(_ track: BhajanTrack) {
        guard let url = track.resolvedAudioURL else {
            errorMessage = "Invalid track audio link."
            return
        }
        
        removeTimeObserver()
        currentTrack = track
        isMiniPlayerVisible = true
        errorMessage = nil
        
        let playerItem = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        addTimeObserver()
        player?.play()
        isPlaying = true
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.handleTrackDidEnd()
        }
        
        updateNowPlayingInfo()
    }
    
    public func playOrPause() {
        guard let p = player else { return }
        if isPlaying {
            p.pause()
            isPlaying = false
        } else {
            p.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
    }
    
    public func nextTrack() {
        guard !playlist.isEmpty, let current = currentTrack,
              let currentIndex = playlist.firstIndex(of: current) else { return }
        
        if isShuffle {
            let randomIndex = Int.random(in: 0..<playlist.count)
            playTrack(playlist[randomIndex])
        } else {
            let nextIndex = (currentIndex + 1) % playlist.count
            playTrack(playlist[nextIndex])
        }
    }
    
    public func previousTrack() {
        guard !playlist.isEmpty, let current = currentTrack,
              let currentIndex = playlist.firstIndex(of: current) else { return }
        
        let prevIndex = (currentIndex - 1 + playlist.count) % playlist.count
        playTrack(playlist[prevIndex])
    }
    
    public func seek(to seconds: Double) {
        let cmTime = CMTime(seconds: seconds, preferredTimescale: 1000)
        player?.seek(to: cmTime) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
    }
    
    public func toggleShuffle() {
        isShuffle.toggle()
    }
    
    public func toggleRepeat() {
        isRepeat.toggle()
    }
    
    public func dismissMiniPlayer() {
        player?.pause()
        isPlaying = false
        isMiniPlayerVisible = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func handleTrackDidEnd() {
        if isRepeat, let current = currentTrack {
            seek(to: 0)
            player?.play()
            isPlaying = true
        } else {
            nextTrack()
        }
    }
    
    // MARK: - Periodic Time Observer
    private func addTimeObserver() {
        guard let p = player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: 1000)
        timeObserverToken = p.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if let currentItem = p.currentItem {
                let durationSec = CMTimeGetSeconds(currentItem.duration)
                if !durationSec.isNaN && durationSec > 0 {
                    self.duration = durationSec
                }
            }
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken, let p = player {
            p.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    // MARK: - Lock Screen & Control Center
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = track.title
        info[MPMediaItemPropertyArtist] = track.artist
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let logoImg = UIImage(named: "app_logo") {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: logoImg.size) { _ in logoImg }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.playOrPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }
}
