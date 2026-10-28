import SwiftUI

public struct JapView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var totalJap: Int = 0
    @State private var sessionCount: Int = 0
    @State private var pendingSyncCount: Int = 0
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var showMilestoneToast: Bool = false
    @State private var milestoneMalaNumber: Int = 0
    @State private var syncDebounceTimer: Timer?
    
    private let malaTarget: Int = 108
    private let kLocalJapCount = "JHG_LOCAL_JAP_COUNT"
    
    public init() {}
    
    private var currentMalaBeads: Int {
        totalJap % malaTarget
    }
    
    private var completedMalas: Int {
        totalJap / malaTarget
    }
    
    private var malaProgress: Double {
        Double(currentMalaBeads) / Double(malaTarget)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header Guidance
                    VStack(spacing: 6) {
                        Text("Sacred Jap Mala")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color.spiritualTextPrimary)
                        
                        Text("108 Beads per Mala • સત નામ સાહેબ 🙏")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.spiritualSaffronDark)
                    }
                    .padding(.top, 10)
                    
                    // Stats Summary Bar
                    HStack(spacing: 16) {
                        statPill(title: "Current Mala", value: "\(currentMalaBeads) / \(malaTarget)")
                        statPill(title: "Completed", value: "\(completedMalas) Malas")
                        statPill(title: "Total Chants", value: "\(totalJap)")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Consecrated Interactive Chanting Circle
                    ZStack {
                        // Background Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.spiritualGold.opacity(0.35), Color.spiritualSaffron.opacity(0.1), Color.clear],
                                    center: .center,
                                    startRadius: 80,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 340, height: 340)
                        
                        // Circular Progress Track (Mala 108 Beads)
                        Circle()
                            .stroke(Color.spiritualDivider, lineWidth: 12)
                            .frame(width: 260, height: 260)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(malaProgress))
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color.spiritualGold, Color.spiritualSaffron, Color.spiritualSaffronDark]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 260, height: 260)
                            .animation(.easeOut(duration: 0.25), value: malaProgress)
                        
                        // Inner Sacred Touch Disk
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "FFF8EE")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 220, height: 220)
                            .shadow(color: Color.spiritualSaffron.opacity(0.2), radius: 14, x: 0, y: 6)
                            .scaleEffect(pulseScale)
                        
                        // Bead Counter in Divine Typography
                        VStack(spacing: 6) {
                            Text("TAP TO CHANT")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2)
                                .foregroundColor(Color.spiritualSaffronDark)
                            
                            Text("\(currentMalaBeads)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(Color.spiritualTextPrimary)
                            
                            Text("Bead #\(currentMalaBeads == 0 ? 108 : currentMalaBeads)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                    }
                    .contentShape(Circle())
                    .onTapGesture {
                        incrementBead()
                    }
                    
                    Spacer()
                    
                    // Reset Button & Session Summary
                    HStack {
                        Button(action: resetCounter) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Counter")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spiritualDivider, lineWidth: 1))
                        }
                        
                        Spacer()
                        
                        Text("This Session: +\(sessionCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.spiritualSaffronDark)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .top) {
                if showMilestoneToast {
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color.spiritualGold)
                            Text("Mala \(milestoneMalaNumber) Completed! પાવન ૧૦૮ મણકા પૂર્ણ 🙏")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.spiritualSaffronDark)
                        .cornerRadius(25)
                        .shadow(radius: 8)
                        .padding(.top, 40)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .task {
            loadInitialStats()
        }
        .onDisappear {
            syncPendingCounts()
        }
    }
    
    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.spiritualTextSecondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.spiritualTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
    }
    
    private func incrementBead() {
        totalJap += 1
        sessionCount += 1
        pendingSyncCount += 1
        
        // Touch animation pulse
        withAnimation(.easeOut(duration: 0.1)) {
            pulseScale = 0.95
        }
        withAnimation(.easeOut(duration: 0.15).delay(0.1)) {
            pulseScale = 1.0
        }
        
        // Check 108 milestone
        if totalJap % malaTarget == 0 {
            HapticManager.malaCompleted()
            milestoneMalaNumber = completedMalas
            withAnimation { showMilestoneToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { showMilestoneToast = false }
            }
        } else {
            HapticManager.beadTap()
        }
        
        UserDefaults.standard.set(totalJap, forKey: kLocalJapCount)
        
        // Debounce sync after 1.2s of inactivity
        syncDebounceTimer?.invalidate()
        syncDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            syncPendingCounts()
        }
    }
    
    private func resetCounter() {
        HapticManager.beadTap()
        totalJap = 0
        sessionCount = 0
        pendingSyncCount = 0
        UserDefaults.standard.set(0, forKey: kLocalJapCount)
    }
    
    private func loadInitialStats() {
        let localCount = UserDefaults.standard.integer(forKey: kLocalJapCount)
        if localCount > 0 {
            self.totalJap = localCount
        }
        
        guard let userId = authManager.currentUser?.id else { return }
        Task {
            do {
                let stats = try await APIService.shared.fetchJapStats(userId: userId)
                if stats.totalJap > totalJap {
                    totalJap = stats.totalJap
                    UserDefaults.standard.set(totalJap, forKey: kLocalJapCount)
                }
            } catch {
                print("Jap stats load error: \(error.localizedDescription)")
            }
        }
    }
    
    private func syncPendingCounts() {
        guard pendingSyncCount > 0, let userId = authManager.currentUser?.id else { return }
        let countToSync = pendingSyncCount
        pendingSyncCount = 0
        
        Task {
            _ = try? await APIService.shared.logJapCount(userId: userId, count: countToSync)
        }
    }
}
