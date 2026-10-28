import Foundation
import UserNotifications
import SwiftUI

@MainActor
public class BroadcastPoller: ObservableObject {
    public static let shared = BroadcastPoller()
    
    @Published public var unreadCount: Int = 0
    @Published public var latestNotice: BroadcastNotice? = nil
    
    private let kLastSeenBroadcastId = "JHG_LAST_SEEN_BROADCAST_ID"
    private var timer: Timer?
    
    private init() {
        requestNotificationPermission()
    }
    
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification authorization granted")
            }
        }
    }
    
    public func startPolling() {
        pollLatestBroadcast()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 35, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollLatestBroadcast()
            }
        }
    }
    
    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public func pollLatestBroadcast() {
        Task {
            do {
                let notices = try await APIService.shared.fetchNotifications(limit: 5)
                guard let newest = notices.first else { return }
                
                let defaults = UserDefaults.standard
                let lastSeenId = defaults.integer(forKey: kLastSeenBroadcastId)
                
                if newest.id > lastSeenId && lastSeenId > 0 {
                    defaults.set(newest.id, forKey: kLastSeenBroadcastId)
                    self.latestNotice = newest
                    self.unreadCount += 1
                    dispatchLocalNotification(title: newest.title, body: newest.body)
                } else if lastSeenId == 0 {
                    defaults.set(newest.id, forKey: kLastSeenBroadcastId)
                }
            } catch {
                // Silently handle offline/network blips
            }
        }
    }
    
    public func markAllAsRead() {
        unreadCount = 0
    }
    
    private func dispatchLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "📢 " + title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
