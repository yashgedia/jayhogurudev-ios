import SwiftUI

public struct MiniPlayerBarView: View {
    @ObservedObject var audioManager = SpiritualAudioManager.shared
    
    public init() {}
    
    public var body: some View {
        if audioManager.isMiniPlayerVisible, let track = audioManager.currentTrack {
            HStack(spacing: 12) {
                // Disc / Icon with rotation
                ZStack {
                    Circle()
                        .fill(Color.spiritualSaffronLight)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                .padding(.leading, 8)
                
                // Track Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.spiritualTextPrimary)
                        .lineLimit(1)
                    
                    Text(track.artist)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.spiritualTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Play/Pause Button
                Button(action: {
                    audioManager.playOrPause()
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.spiritualSaffronDark)
                        .frame(width: 36, height: 36)
                }
                
                // Dismiss Button
                Button(action: {
                    audioManager.dismissMiniPlayer()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.spiritualTextSecondary)
                        .frame(width: 30, height: 30)
                }
                .padding(.trailing, 8)
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.spiritualDivider, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                audioManager.showFullPlayer = true
            }
        }
    }
}
