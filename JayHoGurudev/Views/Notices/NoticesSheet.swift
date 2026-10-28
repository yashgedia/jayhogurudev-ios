import SwiftUI

public struct NoticesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notices: [BroadcastNotice] = []
    @State private var isLoading: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Retrieving temple broadcasts...")
                        .tint(Color.spiritualSaffron)
                } else if notices.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 44))
                            .foregroundColor(Color.spiritualTextSecondary.opacity(0.6))
                        Text("No active announcements")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(notices) { notice in
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.spiritualSaffronLight)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "megaphone.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.spiritualSaffronDark)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(notice.title)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(Color.spiritualTextPrimary)
                                            Spacer()
                                            if let t = notice.createdAt {
                                                Text(t)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color.spiritualTextSecondary)
                                            }
                                        }
                                        
                                        Text(notice.body)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.spiritualTextPrimary.opacity(0.85))
                                            .lineSpacing(4)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .spiritualCard(cornerRadius: 14, elevation: 4)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await loadNotices()
                    }
                }
            }
            .navigationTitle("Temple Broadcasts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.spiritualSaffronDark)
                    .fontWeight(.semibold)
                }
            }
        }
        .task {
            await loadNotices()
        }
    }
    
    private func loadNotices() async {
        isLoading = true
        do {
            self.notices = try await APIService.shared.fetchNotifications(limit: 30)
        } catch {
            print("Failed to fetch notices: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
