import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var broadcastPoller = BroadcastPoller.shared
    
    // Quick navigation triggers to tabs or sub-views
    var onNavigateToTab: ((Int) -> Void)?
    var onOpenMeditation: (() -> Void)?
    var onOpenBhajans: (() -> Void)?
    var onOpenGallery: (() -> Void)?
    
    @State private var todaySaakhi: Saakhi? = nil
    @State private var dailyQuote: String? = nil
    @State private var streakDays: Int = 1
    @State private var streakRank: String = "ભક્ત"
    @State private var isReacting: Bool = false
    @State private var upcomingEvent: SpiritualEvent? = nil
    @State private var leaderboard: [LeaderboardDevotee] = []
    
    @State private var isLoading: Bool = true
    @State private var showNoticesSheet: Bool = false
    @State private var showSaakhiBookSheet: Bool = false
    
    public init(
        onNavigateToTab: ((Int) -> Void)? = nil,
        onOpenMeditation: (() -> Void)? = nil,
        onOpenBhajans: (() -> Void)? = nil,
        onOpenGallery: (() -> Void)? = nil
    ) {
        self.onNavigateToTab = onNavigateToTab
        self.onOpenMeditation = onOpenMeditation
        self.onOpenBhajans = onOpenBhajans
        self.onOpenGallery = onOpenGallery
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Header Bar
                        headerBarView
                        
                        // Devotee Streak Bar
                        streakBarView
                        
                        // Sacred Daily Saakhi Card
                        saakhiCardView
                        
                        // Quick Action Spiritual Tiles
                        quickTilesSection
                        
                        // Upcoming Event Banner
                        if let event = upcomingEvent {
                            upcomingEventBannerView(event: event)
                        }
                        
                        // Top Devotees Jap Leaderboard
                        leaderboardSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .refreshable {
                    await loadHomeData()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNoticesSheet) {
                NoticesSheet()
            }
            .sheet(isPresented: $showSaakhiBookSheet) {
                SaakhiBookSheet()
            }
        }
        .task {
            await loadHomeData()
        }
    }
    
    // MARK: - Header Bar
    private var headerBarView: some View {
        HStack(spacing: 12) {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.spiritualGold, lineWidth: 1.5))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Jay Ho Gurudev")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(Color.spiritualTextPrimary)
                
                Text("સત નામ સાહેબ 🙏")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.spiritualSaffronDark)
            }
            
            Spacer()
            
            // Notification Bell with Badge
            Button(action: {
                broadcastPoller.markAllAsRead()
                showNoticesSheet = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.spiritualTextPrimary)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                    
                    if broadcastPoller.unreadCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Devotee Streak Bar
    private var streakBarView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.spiritualSaffronLight)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("\(streakDays) Days Streak")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.spiritualTextPrimary)
                    
                    Text("•")
                        .foregroundColor(Color.spiritualTextSecondary)
                    
                    Text(streakRank)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                
                Text("Chant daily to keep your divine connection alive")
                    .font(.system(size: 12))
                    .foregroundColor(Color.spiritualTextSecondary)
            }
            
            Spacer()
            
            Button(action: {
                onNavigateToTab?(2) // Go to Jap tab
            }) {
                Text("Chant")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(SpiritualGradients.saffron)
                    .clipShape(Capsule())
                    .shadow(color: Color.spiritualSaffron.opacity(0.35), radius: 6, x: 0, y: 3)
            }
        }
        .padding(12)
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    // MARK: - Daily Saakhi Card
    private var saakhiCardView: some View {
        VStack(spacing: 16) {
            // Card Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(Color.spiritualGold)
                        .font(.system(size: 13))
                    Text(todaySaakhi?.formattedDate ?? todaySaakhi?.date ?? "Daily Divine Saakhi")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.spiritualSaffronLight)
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: {
                    showSaakhiBookSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 11))
                        Text("Sakhi Book")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color.spiritualSaffronDark)
                }
            }
            
            // Saakhi Quote Text
            Text("\"\(todaySaakhi?.content ?? "સત નામ સાહેબ • ગુરુ કૃપા હી કેવલમ્")\"")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color.spiritualTextPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 8)
            
            if let quote = dailyQuote, !quote.isEmpty {
                Text(quote)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.spiritualTextSecondary)
                    .italic()
                    .multilineTextAlignment(.center)
            }
            
            Divider().background(Color.spiritualDivider)
            
            // Card Action Buttons (Jay Ho Reaction & Share)
            HStack(spacing: 16) {
                // Jay Ho Reaction Button
                Button(action: handleReaction) {
                    HStack(spacing: 8) {
                        Image(systemName: (todaySaakhi?.isReacted == true) ? "heart.fill" : "heart")
                            .foregroundColor((todaySaakhi?.isReacted == true) ? .red : Color.spiritualSaffronDark)
                            .font(.system(size: 16))
                        
                        Text("જય હો (\(todaySaakhi?.reactionsCount ?? 0))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.spiritualTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.spiritualSaffronLight)
                    .cornerRadius(10)
                }
                .disabled(isReacting)
                
                // Devotee Share Button
                Button(action: shareSaakhi) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                        Text("Share")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color.spiritualTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.spiritualCreamBg)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .spiritualCard(cornerRadius: 18, elevation: 6)
    }
    
    // MARK: - Quick Action Spiritual Tiles
    private var quickTilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sacred Pathways")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.spiritualTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                tileButton(
                    title: "Mala Jap",
                    subtitle: "Digital Counter",
                    iconName: "hands.sparkles.fill",
                    color: Color.spiritualSaffron
                ) {
                    onNavigateToTab?(2)
                }
                
                tileButton(
                    title: "Meditation",
                    subtitle: "Pranayama & Om",
                    iconName: "wind",
                    color: Color(hex: "27AE60")
                ) {
                    onOpenMeditation?()
                }
                
                tileButton(
                    title: "Divine Bhajans",
                    subtitle: "Sacred Melodies",
                    iconName: "music.note",
                    color: Color(hex: "8E44AD")
                ) {
                    onOpenBhajans?()
                }
                
                tileButton(
                    title: "Sacred Darshan",
                    subtitle: "Temple Gallery",
                    iconName: "photo.stack.fill",
                    color: Color(hex: "E67E22")
                ) {
                    onOpenGallery?()
                }
            }
        }
    }
    
    private func tileButton(title: String, subtitle: String, iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.spiritualTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color.spiritualTextSecondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .spiritualCard(cornerRadius: 14, elevation: 3)
        }
    }
    
    // MARK: - Upcoming Event Banner
    private func upcomingEventBannerView(event: SpiritualEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("UPCOMING SATSANG")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Color.spiritualSaffronDark)
                Spacer()
                if let d = event.date {
                    Text(d)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.spiritualTextSecondary)
                }
            }
            
            Text(event.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.spiritualTextPrimary)
            
            if let loc = event.location {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Color.spiritualSaffron)
                        .font(.system(size: 13))
                    Text(loc)
                        .font(.system(size: 13))
                        .foregroundColor(Color.spiritualTextSecondary)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.white, Color.spiritualSaffronLight.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .spiritualCard(cornerRadius: 16, elevation: 4)
        .onTapGesture {
            onNavigateToTab?(3) // Go to Events tab
        }
    }
    
    // MARK: - Top Devotees Leaderboard
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Devotees Chanting")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.spiritualTextPrimary)
                Spacer()
                Text("Global Satsang")
                    .font(.system(size: 12))
                    .foregroundColor(Color.spiritualTextSecondary)
            }
            
            if leaderboard.isEmpty {
                Text("Leaderboard updating...")
                    .font(.system(size: 13))
                    .foregroundColor(Color.spiritualTextSecondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(leaderboard.prefix(5)) { devotee in
                        HStack(spacing: 12) {
                            Text("#\(devotee.rank)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(devotee.rank == 1 ? Color.spiritualGold : Color.spiritualSaffronDark)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(devotee.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.spiritualTextPrimary)
                                Text("@\(devotee.username)")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.spiritualTextSecondary)
                            }
                            
                            Spacer()
                            
                            Text("\(devotee.count) chants")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.spiritualSaffronDark)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        
                        if devotee.rank < 5 {
                            Divider().background(Color.spiritualDivider)
                        }
                    }
                }
                .padding(12)
                .background(Color.white)
                .spiritualCard(cornerRadius: 14, elevation: 3)
            }
        }
    }
    
    // MARK: - Actions
    private func loadHomeData() async {
        isLoading = true
        let userId = authManager.currentUser?.id
        
        do {
            let res = try await APIService.shared.fetchTodaySaakhi(userId: userId)
            self.todaySaakhi = res.saakhi
            self.dailyQuote = res.quote
            self.streakDays = res.saakhi.streakDays
            self.streakRank = res.saakhi.streakRank
        } catch {
            print("Today Saakhi error: \(error.localizedDescription)")
        }
        
        // Fetch upcoming events
        do {
            let evs = try await APIService.shared.fetchEvents(userId: userId)
            self.upcomingEvent = evs.first
        } catch {
            print("Events error: \(error.localizedDescription)")
        }
        
        // Fetch Leaderboard
        do {
            self.leaderboard = try await APIService.shared.fetchJapLeaderboard()
        } catch {
            print("Leaderboard error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func handleReaction() {
        guard let saakhi = todaySaakhi else { return }
        let userId = authManager.currentUser?.id ?? 1
        isReacting = true
        HapticManager.beadTap()
        
        Task {
            do {
                let updatedReactions = try await APIService.shared.reactToSaakhi(saakhiId: saakhi.id, userId: userId)
                todaySaakhi?.reactionsCount = updatedReactions
                todaySaakhi?.isReacted = true
            } catch {
                print("Reaction failed: \(error.localizedDescription)")
            }
            isReacting = false
        }
    }
    
    private func shareSaakhi() {
        guard let saakhi = todaySaakhi else { return }
        let shareText = """
        જય હો ગુરુદેવ - આજ ની પાવન સાખી 🙏
        
        "\(saakhi.content)"
        
        દૈનિક સાખી અને ભક્તિ સત્સંગ:
        \(AppConfig.baseURL)
        """
        ShareSheetHelper.shareTextAndImage(text: shareText, image: nil)
    }
}
