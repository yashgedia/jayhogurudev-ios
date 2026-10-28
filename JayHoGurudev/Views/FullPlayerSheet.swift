import SwiftUI

public struct FullPlayerSheet: View {
    @ObservedObject var audioManager = SpiritualAudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isDraggingSlider: Bool = false
    @State private var dragValue: Double = 0.0
    @State private var artworkRotation: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.spiritualCreamBg.ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Top Handle & Dismiss
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.spiritualTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text("NOW CHANTING")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color.spiritualSaffronDark)
                    
                    Spacer()
                    
                    Button(action: {
                        audioManager.dismissMiniPlayer()
                        dismiss()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Consecrated Artwork Disc with Slow Divine Spin
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.spiritualGold.opacity(0.35), Color.spiritualSaffron.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 80,
                                endRadius: 160
                            )
                        )
                        .frame(width: 300, height: 300)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 240, height: 240)
                        .overlay(Circle().stroke(Color.spiritualGold, lineWidth: 3))
                        .shadow(color: Color.spiritualSaffron.opacity(0.25), radius: 16, x: 0, y: 8)
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(artworkRotation))
                    
                    Circle()
                        .fill(Color.spiritualSaffronDark)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                }
                .onChange(of: audioManager.isPlaying) { isPlaying in
                    if isPlaying {
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            artworkRotation += 360
                        }
                    }
                }
                
                // Title & Artist
                VStack(spacing: 6) {
                    Text(audioManager.currentTrack?.title ?? "Spiritual Bhajan")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(Color.spiritualTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text(audioManager.currentTrack?.artist ?? "Santvani")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                
                // Progress Slider & Timestamps
                VStack(spacing: 6) {
                    Slider(
                        value: Binding(
                            get: { isDraggingSlider ? dragValue : audioManager.currentTime },
                            set: { dragValue = $0 }
                        ),
                        in: 0...(audioManager.duration > 0 ? audioManager.duration : 1),
                        onEditingChanged: { editing in
                            isDraggingSlider = editing
                            if !editing {
                                audioManager.seek(to: dragValue)
                            }
                        }
                    )
                    .accentColor(Color.spiritualSaffron)
                    
                    HStack {
                        Text(formatTime(isDraggingSlider ? dragValue : audioManager.currentTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                        
                        Spacer()
                        
                        Text(formatTime(audioManager.duration))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                }
                .padding(.horizontal, 32)
                
                // Player Controls (Shuffle, Prev, Play/Pause, Next, Repeat)
                HStack(spacing: 32) {
                    Button(action: { audioManager.toggleShuffle() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18))
                            .foregroundColor(audioManager.isShuffle ? Color.spiritualSaffronDark : Color.spiritualTextSecondary)
                    }
                    
                    Button(action: { audioManager.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.spiritualTextPrimary)
                    }
                    
                    // Consecrated Play / Pause Button
                    Button(action: { audioManager.playOrPause() }) {
                        ZStack {
                            Circle()
                                .fill(SpiritualGradients.saffron)
                                .frame(width: 68, height: 68)
                                .shadow(color: Color.spiritualSaffron.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .offset(x: audioManager.isPlaying ? 0 : 2)
                        }
                    }
                    
                    Button(action: { audioManager.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.spiritualTextPrimary)
                    }
                    
                    Button(action: { audioManager.toggleRepeat() }) {
                        Image(systemName: "repeat")
                            .font(.system(size: 18))
                            .foregroundColor(audioManager.isRepeat ? Color.spiritualSaffronDark : Color.spiritualTextSecondary)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            if audioManager.isPlaying {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    artworkRotation += 360
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && seconds >= 0 else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
