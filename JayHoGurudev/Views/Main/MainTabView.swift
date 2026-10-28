import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var audioManager = SpiritualAudioManager.shared
    @ObservedObject var broadcastPoller = BroadcastPoller.shared
    
    @State private var selectedTab: Int = 0
    @State private var showMeditationSheet: Bool = false
    @State private var showBhajansSheet: Bool = false
    @State private var showGallerySheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.spiritualCreamBg.ignoresSafeArea()
            
            // Tab Views Container
            Group {
                switch selectedTab {
                case 0:
                    HomeView(
                        onNavigateToTab: { tab in
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        },
                        onOpenMeditation: { showMeditationSheet = true },
                        onOpenBhajans: { showBhajansSheet = true },
                        onOpenGallery: { showGallerySheet = true }
                    )
                case 1:
                    FeedView()
                case 2:
                    JapView()
                case 3:
                    EventsView()
                case 4:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Navigation Overlay
            VStack(spacing: 8) {
                // Docked Mini Bhajan Player Bar (if active)
                MiniPlayerBarView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                
                // Consecrated Custom Bottom Tab Bar with Elevated Center Jap FAB
                customBottomBar
            }
        }
        .sheet(isPresented: $showMeditationSheet) {
            MeditationView()
        }
        .sheet(isPresented: $showBhajansSheet) {
            BhajansView()
        }
        .sheet(isPresented: $showGallerySheet) {
            GalleryView()
        }
        .sheet(isPresented: $audioManager.showFullPlayer) {
            FullPlayerSheet()
        }
        .onAppear {
            broadcastPoller.startPolling()
        }
        .onDisappear {
            broadcastPoller.stopPolling()
        }
    }
    
    // MARK: - Custom Bottom Bar with Elevated Center Jap Button
    private var customBottomBar: some View {
        HStack(spacing: 0) {
            // Tab 0: Home
            tabButton(index: 0, title: "Home", systemImage: "house.fill")
            
            // Tab 1: Feed
            tabButton(index: 1, title: "Feed", systemImage: "quote.bubble.fill")
            
            // Tab 2: Elevated Center Jap FAB
            centerElevatedJapButton
                .offset(y: -16)
            
            // Tab 3: Events
            tabButton(index: 3, title: "Events", systemImage: "calendar.badge.clock")
            
            // Tab 4: Profile
            tabButton(index: 4, title: "Profile", systemImage: "person.crop.circle.fill")
        }
        .frame(height: 64)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
    
    private func tabButton(index: Int, title: String, systemImage: String) -> some View {
        Button(action: {
            HapticManager.selection()
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == index ? Color.spiritualSaffronDark : Color.spiritualTextSecondary)
                
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == index ? .bold : .medium))
                    .foregroundColor(selectedTab == index ? Color.spiritualSaffronDark : Color.spiritualTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Consecrated Raised Saffron Mala Button
    private var centerElevatedJapButton: some View {
        Button(action: {
            HapticManager.beadTap()
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = 2
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.spiritualSaffron.opacity(0.35), radius: 8, x: 0, y: 3)
                
                Circle()
                    .fill(SpiritualGradients.saffron)
                    .frame(width: 54, height: 54)
                
                VStack(spacing: 2) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("JAP")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
