import SwiftUI
import AVKit

public struct SplashView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    @State private var player: AVPlayer?
    @State private var showSkipButton: Bool = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            Color.spiritualCreamBg.ignoresSafeArea()
            
            if let p = player {
                VideoPlayer(player: p)
                    .disabled(true)
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Sacred Fallback Aesthetic
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(color: Color.spiritualSaffron.opacity(0.35), radius: 16, x: 0, y: 8)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    VStack(spacing: 8) {
                        Text("Jay Ho Gurudev")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(Color.spiritualTextPrimary)
                        
                        Text("સત નામ સાહેબ 🙏")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.spiritualSaffronDark)
                        
                        Text(AppConfig.appTagline)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                    .opacity(logoOpacity)
                    
                    Spacer()
                }
            }
            
            // Skip Button
            if showSkipButton {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: finishSplash) {
                            HStack(spacing: 6) {
                                Text("Skip")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.55))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 54)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            startSplashVideo()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func startSplashVideo() {
        if let videoURL = Bundle.main.url(forResource: "splashscreen", withExtension: "mp4") {
            let p = AVPlayer(url: videoURL)
            self.player = p
            p.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showSkipButton = true }
            }
            
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: p.currentItem,
                queue: .main
            ) { _ in
                finishSplash()
            }
            
            // Safety timeout after 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                finishSplash()
            }
        } else {
            // Animate fallback lotus / logo
            withAnimation(.easeOut(duration: 1.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                finishSplash()
            }
        }
    }
    
    private func finishSplash() {
        player?.pause()
        withAnimation(.easeInOut(duration: 0.4)) {
            isPresented = false
        }
    }
}
