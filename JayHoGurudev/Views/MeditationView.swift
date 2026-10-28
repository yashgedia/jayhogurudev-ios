import SwiftUI

public enum BreathPhase: Int {
    case inhale = 0
    case hold = 1
    case exhale = 2
    case rest = 3
    
    public var durationSeconds: Int {
        switch self {
        case .inhale: return 4
        case .hold: return 4
        case .exhale: return 4
        case .rest: return 2
        }
    }
    
    public var titleGujarati: String {
        switch self {
        case .inhale: return "શ્વાસ અંદર લો"
        case .hold: return "ધ્યાનસ્થ રહો"
        case .exhale: return "શ્વાસ બહાર કાઢો"
        case .rest: return "શાંતિ અનુભવો"
        }
    }
    
    public var titleEnglish: String {
        switch self {
        case .inhale: return "INHALE DIVINE ENERGY"
        case .hold: return "HOLD INNER PEACE"
        case .exhale: return "EXHALE ALL ANXIETY"
        case .rest: return "REST IN SACRED SILENCE"
        }
    }
    
    public var mantra: String {
        switch self {
        case .inhale: return "ૐ સોઽહમ્"
        case .hold: return "ૐ શાંતિઃ શાંતિઃ શાંતિઃ"
        case .exhale: return "સત નામ સાહેબ"
        case .rest: return "ૐ નમઃ શિવાય"
        }
    }
}

public struct MeditationView: View {
    @ObservedObject var omService = MeditationAudioService.shared
    
    @State private var isRunning: Bool = false
    @State private var currentPhase: BreathPhase = .inhale
    @State private var secondsRemaining: Int = 4
    @State private var cycleCount: Int = 0
    @State private var circleScale: CGFloat = 1.0
    @State private var haloOpacity: Double = 0.3
    
    @State private var timer: Timer?
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header Guidance
                    VStack(spacing: 6) {
                        Text("Pranayama & Dhyan")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(Color.spiritualTextPrimary)
                        
                        Text("4s Inhale • 4s Hold • 4s Exhale • 2s Rest")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.spiritualSaffronDark)
                    }
                    .padding(.top, 10)
                    
                    // Sound & Cycle Bar
                    HStack {
                        // Ambient Om Toggle
                        Button(action: {
                            omService.toggleOm()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: omService.isOmPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                Text(omService.isOmPlaying ? "Om Sound On" : "Om Sound Off")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(omService.isOmPlaying ? Color.spiritualSaffronDark : Color.spiritualTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spiritualDivider, lineWidth: 1))
                        }
                        
                        Spacer()
                        
                        // Cycles Done
                        HStack(spacing: 4) {
                            Text("Cycles:")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color.spiritualTextSecondary)
                            Text("\(cycleCount)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.spiritualSaffronDark)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spiritualDivider, lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Consecrated Breathing Halo Circle
                    ZStack {
                        // Outer Pulsing Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.spiritualGold.opacity(haloOpacity), Color.spiritualSaffron.opacity(haloOpacity * 0.5), Color.clear],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 160
                                )
                            )
                            .frame(width: 320, height: 320)
                            .scaleEffect(circleScale)
                        
                        // Inner Sacred Circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.spiritualSaffron, Color.spiritualSaffronDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 210, height: 210)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.8), lineWidth: 3)
                            )
                            .shadow(color: Color.spiritualSaffron.opacity(0.4), radius: 16, x: 0, y: 8)
                            .scaleEffect(circleScale)
                        
                        // Central Breath Countdown & Mantra
                        VStack(spacing: 6) {
                            Text("\(secondsRemaining)")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(currentPhase.titleGujarati)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color.spiritualGold)
                            
                            Text(currentPhase.mantra)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    // English Phase Subtitle
                    Text(currentPhase.titleEnglish)
                        .font(.system(size: 13, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color.spiritualSaffronDark)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Controls (Start / Pause, Reset)
                    HStack(spacing: 20) {
                        Button(action: resetMeditation) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Restart")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spiritualDivider, lineWidth: 1))
                        }
                        
                        Button(action: toggleRunning) {
                            HStack {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                Text(isRunning ? "Pause" : (cycleCount > 0 ? "Resume" : "Begin Dhyan"))
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(SpiritualGradients.saffron)
                            .cornerRadius(12)
                            .shadow(color: Color.spiritualSaffron.opacity(0.35), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Guided Meditation")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                pauseMeditation()
                omService.stopOm()
            }
        }
    }
    
    private func toggleRunning() {
        if isRunning {
            pauseMeditation()
        } else {
            startMeditation()
        }
    }
    
    private func startMeditation() {
        isRunning = true
        omService.startOm()
        animateCircleForPhase()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick()
        }
    }
    
    private func pauseMeditation() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetMeditation() {
        pauseMeditation()
        currentPhase = .inhale
        secondsRemaining = currentPhase.durationSeconds
        cycleCount = 0
        circleScale = 1.0
        haloOpacity = 0.3
    }
    
    private func tick() {
        if secondsRemaining > 1 {
            secondsRemaining -= 1
        } else {
            // Transition to next phase
            advancePhase()
        }
    }
    
    private func advancePhase() {
        HapticManager.breathPhaseChange()
        
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .rest
        case .rest:
            currentPhase = .inhale
            cycleCount += 1
        }
        
        secondsRemaining = currentPhase.durationSeconds
        animateCircleForPhase()
    }
    
    private func animateCircleForPhase() {
        let duration = Double(currentPhase.durationSeconds)
        switch currentPhase {
        case .inhale:
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = 1.3
                haloOpacity = 0.8
            }
        case .hold:
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = 1.3
                haloOpacity = 0.6
            }
        case .exhale:
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = 1.0
                haloOpacity = 0.25
            }
        case .rest:
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = 1.0
                haloOpacity = 0.2
            }
        }
    }
}
