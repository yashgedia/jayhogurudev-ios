import SwiftUI

public struct EventsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var events: [SpiritualEvent] = []
    @State private var isLoading: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Retrieving upcoming spiritual events...")
                        .tint(Color.spiritualSaffron)
                } else if events.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 44))
                            .foregroundColor(Color.spiritualTextSecondary.opacity(0.5))
                        Text("No upcoming satsangs scheduled")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(events) { event in
                                eventCardView(event: event)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .refreshable {
                        await loadEvents()
                    }
                }
            }
            .navigationTitle("Upcoming Satsangs")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadEvents()
        }
    }
    
    private func eventCardView(event: SpiritualEvent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Event Header Row with Date Badge
            HStack(alignment: .top, spacing: 14) {
                // Calendar Date Badge
                VStack(spacing: 2) {
                    Text(formatMonth(event.date))
                        .font(.system(size: 11, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                        .background(Color.spiritualSaffronDark)
                    
                    Text(formatDay(event.date))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.spiritualTextPrimary)
                        .padding(.vertical, 4)
                }
                .frame(width: 54)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.spiritualTextPrimary)
                    
                    if let loc = event.location, !loc.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.spiritualSaffron)
                            Text(loc)
                                .font(.system(size: 13))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Description
            if let desc = event.description, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(Color.spiritualTextPrimary.opacity(0.85))
                    .lineSpacing(4)
            }
            
            // Event Image Banner (if available)
            if let img = event.imageUrl, !img.isEmpty {
                let resolvedURL = img.starts(with: "http") ? URL(string: img) : URL(string: "\(AppConfig.baseURL)/\(img)")
                if let url = resolvedURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.spiritualSaffronLight)
                                .frame(height: 160)
                                .overlay(ProgressView().tint(Color.spiritualSaffron))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(12)
                }
            }
            
            Divider().background(Color.spiritualDivider)
            
            // Action Bar (RSVP / Attending & Share)
            HStack {
                Button(action: { toggleRSVP(event: event) }) {
                    HStack(spacing: 6) {
                        Image(systemName: event.isAttending ? "checkmark.circle.fill" : "person.badge.plus")
                            .foregroundColor(event.isAttending ? Color.spiritualEmerald : Color.spiritualSaffronDark)
                        Text(event.isAttending ? "Attending (\(event.reactionsCount))" : "I'm Going (\(event.reactionsCount))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(event.isAttending ? Color.spiritualEmerald : Color.spiritualTextPrimary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(event.isAttending ? Color.spiritualEmerald.opacity(0.12) : Color.spiritualSaffronLight)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: {
                    let shareMsg = "પાવન સત્સંગ નિમંત્રણ: \(event.title)\nતારીખ: \(event.date ?? "")\nસ્થળ: \(event.location ?? "")\n\(AppConfig.baseURL)"
                    ShareSheetHelper.shareTextAndImage(text: shareMsg, image: nil)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.spiritualTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.spiritualCreamBg)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spiritualDivider, lineWidth: 1))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    private func loadEvents() async {
        isLoading = true
        let userId = authManager.currentUser?.id
        do {
            self.events = try await APIService.shared.fetchEvents(userId: userId)
        } catch {
            print("Events error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func toggleRSVP(event: SpiritualEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        HapticManager.beadTap()
        
        let willAttend = !events[index].isAttending
        events[index].isAttending = willAttend
        events[index].reactionsCount += (willAttend ? 1 : -1)
        
        let userId = authManager.currentUser?.id ?? 1
        Task {
            _ = try? await APIService.shared.toggleEventReaction(eventId: event.id, userId: userId)
        }
    }
    
    private func formatMonth(_ dateStr: String?) -> String {
        guard let str = dateStr, !str.isEmpty else { return "SATSANG" }
        return String(str.prefix(3))
    }
    
    private func formatDay(_ dateStr: String?) -> String {
        guard let str = dateStr, !str.isEmpty else { return "15" }
        let numbers = str.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        return numbers.first ?? "01"
    }
}
