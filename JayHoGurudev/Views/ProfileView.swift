import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var japStats: JapStats? = nil
    @State private var showChangePasswordSheet: Bool = false
    @State private var selectedPolicyTab: PolicyTab = .privacy
    @State private var showPolicySheet: Bool = false
    @State private var showLogoutConfirm: Bool = false
    @State private var notificationsEnabled: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Devotee Profile Header Card
                        profileHeaderCard
                        
                        // Jap Chanting Stats Card
                        statsCard
                        
                        // Settings Group
                        settingsGroup
                        
                        // Legal & Compliance Group
                        legalGroup
                        
                        // Trust & Developer Credits
                        creditsSection
                        
                        // Logout Button
                        logoutButton
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Devotee Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showChangePasswordSheet) {
                ChangePasswordSheet()
            }
            .sheet(isPresented: $showPolicySheet) {
                PolicyViewSheet(initialTab: selectedPolicyTab)
            }
            .alert("Confirm Logout", isPresented: $showLogoutConfirm) {
                Button("Logout", role: .destructive) {
                    authManager.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out of your devotee profile?")
            }
        }
        .task {
            await loadStats()
        }
    }
    
    // MARK: - Header Card
    private var profileHeaderCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(SpiritualGradients.saffron)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.spiritualSaffron.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(initialLetter)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(authManager.currentUser?.fullName ?? "Jay Ho Gurudev Devotee")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.spiritualTextPrimary)
                
                if let uName = authManager.currentUser?.username, !uName.isEmpty {
                    Text("@\(uName)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                
                if let email = authManager.currentUser?.email, !email.isEmpty {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundColor(Color.spiritualTextSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color.spiritualGold)
                        .font(.system(size: 12))
                    Text("સત નામ સાહેબ • Consecrated Devotee")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .spiritualCard(cornerRadius: 18, elevation: 5)
    }
    
    // MARK: - Chanting Stats Card
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Chanting Devotion Records")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.spiritualTextPrimary)
            
            HStack(spacing: 12) {
                statTile(
                    title: "Total Chants",
                    value: "\(japStats?.totalJap ?? UserDefaults.standard.integer(forKey: "JHG_LOCAL_JAP_COUNT"))",
                    icon: "hands.sparkles.fill",
                    color: Color.spiritualSaffron
                )
                
                statTile(
                    title: "Day Streak",
                    value: "\(japStats?.currentStreak ?? 1) Days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                statTile(
                    title: "Spiritual Rank",
                    value: japStats?.rank ?? "ભક્ત",
                    icon: "crown.fill",
                    color: Color.spiritualGold
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    private func statTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.spiritualTextPrimary)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.spiritualTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.spiritualCreamBg)
        .cornerRadius(12)
    }
    
    // MARK: - Settings Group
    private var settingsGroup: some View {
        VStack(spacing: 0) {
            Button(action: { showChangePasswordSheet = true }) {
                rowItem(title: "Change Password", icon: "key.fill")
            }
            
            Divider().padding(.horizontal, 16)
            
            Toggle(isOn: $notificationsEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color.spiritualSaffron)
                        .frame(width: 24)
                    Text("Spiritual Notifications")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.spiritualTextPrimary)
                }
            }
            .tint(Color.spiritualSaffron)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    // MARK: - Legal Group
    private var legalGroup: some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedPolicyTab = .privacy
                showPolicySheet = true
            }) {
                rowItem(title: "Privacy Policy", icon: "shield.lefthalf.filled")
            }
            
            Divider().padding(.horizontal, 16)
            
            Button(action: {
                selectedPolicyTab = .terms
                showPolicySheet = true
            }) {
                rowItem(title: "Terms of Service", icon: "doc.text.fill")
            }
            
            Divider().padding(.horizontal, 16)
            
            Button(action: {
                selectedPolicyTab = .cookies
                showPolicySheet = true
            }) {
                rowItem(title: "Cookie Policy", icon: "lock.shield.fill")
            }
        }
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    private func rowItem(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.spiritualSaffron)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.spiritualTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.spiritualTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Credits
    private var creditsSection: some View {
        VStack(spacing: 6) {
            Text("આવૃત્તિ: v\(AppConfig.appVersion) (Build \(AppConfig.buildNumber))")
                .font(.system(size: 12))
                .foregroundColor(Color.spiritualTextSecondary)
            
            Link(destination: URL(string: AppConfig.developerURL)!) {
                HStack(spacing: 4) {
                    Text("Crafted with Devotion by")
                        .foregroundColor(Color.spiritualTextSecondary)
                    Text("Webnova Technologies")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                .font(.system(size: 12))
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { showLogoutConfirm = true }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out Devotee Profile")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 8)
    }
    
    private var initialLetter: String {
        guard let name = authManager.currentUser?.fullName, !name.isEmpty else { return "J" }
        return String(name.prefix(1)).uppercased()
    }
    
    private func loadStats() async {
        guard let uid = authManager.currentUser?.id else { return }
        do {
            self.japStats = try await APIService.shared.fetchJapStats(userId: uid)
        } catch {
            print("Stats load error: \(error.localizedDescription)")
        }
    }
}
