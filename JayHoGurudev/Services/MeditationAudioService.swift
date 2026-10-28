import Foundation
import AVFoundation

@MainActor
public class MeditationAudioService: ObservableObject {
    public static let shared = MeditationAudioService()
    
    @Published public var isOmPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        prepareOmAudio()
    }
    
    private func prepareOmAudio() {
        guard let url = Bundle.main.url(forResource: "om_chant", withExtension: "wav") else {
            print("om_chant.wav not found in main bundle")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = 0.75
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to initialize meditation Om audio: \(error.localizedDescription)")
        }
    }
    
    public func startOm() {
        if audioPlayer == nil {
            prepareOmAudio()
        }
        audioPlayer?.play()
        isOmPlaying = true
    }
    
    public func pauseOm() {
        audioPlayer?.pause()
        isOmPlaying = false
    }
    
    public func stopOm() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isOmPlaying = false
    }
    
    public func toggleOm() {
        if isOmPlaying {
            pauseOm()
        } else {
            startOm()
        }
    }
}
