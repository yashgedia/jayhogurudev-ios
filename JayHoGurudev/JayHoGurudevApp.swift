import SwiftUI

@main
struct JayHoGurudevApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var audioManager = SpiritualAudioManager.shared
    @StateObject private var broadcastPoller = BroadcastPoller.shared
    
    @State private var isShowingSplash: Bool = true
    
    init() {
        configureSpiritualAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingSplash {
                    SplashView(isPresented: $isShowingSplash)
                        .transition(.opacity)
                } else if authManager.isLoggedIn {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isShowingSplash)
            .animation(.easeInOut(duration: 0.35), value: authManager.isLoggedIn)
            .environmentObject(authManager)
            .environmentObject(audioManager)
            .environmentObject(broadcastPoller)
        }
    }
    
    private func configureSpiritualAppearance() {
        // Configure Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.spiritualCreamBg)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.spiritualTextPrimary),
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.spiritualTextPrimary),
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.spiritualSaffronDark)
    }
}
