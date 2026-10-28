import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case serverError(String)
    case decodingError
    case unauthorized
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server endpoint URL."
        case .serverError(let message): return message
        case .decodingError: return "Failed to process divine server response."
        case .unauthorized: return "Devotee session expired. Please sign in again."
        case .unknown: return "An unexpected error occurred. Please try again."
        }
    }
}

public class APIService {
    public static let shared = APIService()
    private init() {}
    
    private func createRequest(urlString: String, method: String = "GET", body: [String: Any]? = nil) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return request
    }
    
    // MARK: - Daily Saakhi
    public func fetchTodaySaakhi(userId: Int? = nil) async throws -> (saakhi: Saakhi, quote: String?) {
        var urlStr = "\(AppConfig.baseURL)/api/v1/saakhi.php?action=today&api_key=\(AppConfig.apiKey)"
        if let uid = userId, uid > 0 {
            urlStr += "&user_id=\(uid)"
        }
        let request = try createRequest(urlString: urlStr)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Could not fetch today's Saakhi.")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingError
        }
        
        if let sObj = json["saakhi"] as? [String: Any] {
            let id = sObj["id"] as? Int ?? 1
            let text = sObj["text"] as? String ?? "સત નામ સાહેબ 🙏"
            let date = sObj["date"] as? String
            let formattedDate = sObj["formatted_date"] as? String
            let reactions = sObj["reactions"] as? Int ?? (json["reactions"] as? Int ?? 0)
            let isReacted = sObj["is_reacted"] as? Bool ?? (json["is_reacted"] as? Bool ?? false)
            let streakDays = json["streak_days"] as? Int ?? 1
            let streakRank = json["streak_rank"] as? String ?? "ભક્ત"
            
            let saakhi = Saakhi(
                id: id,
                content: text,
                date: date,
                formattedDate: formattedDate,
                reactionsCount: reactions,
                isReacted: isReacted,
                streakDays: streakDays,
                streakRank: streakRank
            )
            let quote = json["quote"] as? String
            return (saakhi, quote)
        }
        
        throw APIError.serverError(json["message"] as? String ?? "No Saakhi available")
    }
    
    public func reactToSaakhi(saakhiId: Int, userId: Int) async throws -> Int {
        let urlStr = "\(AppConfig.baseURL)/api/v1/saakhi.php?action=react&api_key=\(AppConfig.apiKey)"
        let body: [String: Any] = ["saakhi_id": saakhiId, "user_id": userId]
        let request = try createRequest(urlString: urlStr, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingError
        }
        return json["reactions"] as? Int ?? 0
    }
    
    public func fetchRecentSaakhis() async throws -> [Saakhi] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/saakhi.php?action=recent&api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["saakhis"] as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int, let text = obj["text"] as? String else { return nil }
            return Saakhi(
                id: id,
                content: text,
                date: obj["date"] as? String,
                formattedDate: obj["formatted_date"] as? String,
                reactionsCount: obj["reactions"] as? Int ?? 0,
                isReacted: false,
                streakDays: 0,
                streakRank: ""
            )
        }
    }
    
    // MARK: - Jap Chanting Stats & Sync
    public func fetchJapStats(userId: Int) async throws -> JapStats {
        let urlStr = "\(AppConfig.baseURL)/api/v1/jap.php?action=stats&user_id=\(userId)&api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingError
        }
        
        let total = json["total_jap"] as? Int ?? 0
        let today = json["today_jap"] as? Int ?? 0
        let currentStreak = json["current_streak"] as? Int ?? 1
        let longestStreak = json["longest_streak"] as? Int ?? 1
        let rank = json["rank"] as? String ?? "ભક્ત"
        
        return JapStats(totalJap: total, todayJap: today, currentStreak: currentStreak, longestStreak: longestStreak, rank: rank)
    }
    
    public func logJapCount(userId: Int, count: Int) async throws -> Int {
        let urlStr = "\(AppConfig.baseURL)/api/v1/jap.php?action=log&api_key=\(AppConfig.apiKey)"
        let body: [String: Any] = ["user_id": userId, "count": count]
        let request = try createRequest(urlString: urlStr, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingError
        }
        return json["total_jap"] as? Int ?? 0
    }
    
    public func fetchJapLeaderboard() async throws -> [LeaderboardDevotee] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/jap.php?action=leaderboard&api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["leaderboard"] as? [[String: Any]] else {
            return []
        }
        
        return arr.enumerated().compactMap { index, obj in
            guard let name = obj["full_name"] as? String ?? obj["name"] as? String else { return nil }
            let username = obj["username"] as? String ?? "devotee_\(index + 1)"
            let count = obj["total_count"] as? Int ?? (obj["count"] as? Int ?? 0)
            return LeaderboardDevotee(rank: index + 1, name: name, username: username, count: count)
        }
    }
    
    // MARK: - Bhajans
    public func fetchBhajans() async throws -> [BhajanTrack] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/bhajans.php?api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["bhajans"] as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int,
                  let title = obj["title"] as? String,
                  let filePath = obj["file_path"] as? String else { return nil }
            let artist = obj["artist"] as? String ?? "Santvani"
            let duration = obj["duration"] as? String ?? "04:30"
            let cover = obj["cover_image"] as? String
            let cat = obj["category"] as? String ?? "Bhajan"
            return BhajanTrack(id: id, title: title, artist: artist, audioUrl: filePath, duration: duration, coverImage: cover, category: cat)
        }
    }
    
    // MARK: - Events
    public func fetchEvents(userId: Int? = nil) async throws -> [SpiritualEvent] {
        var urlStr = "\(AppConfig.baseURL)/api/v1/events.php?action=upcoming&api_key=\(AppConfig.apiKey)"
        if let uid = userId {
            urlStr += "&user_id=\(uid)"
        }
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = (json["events"] ?? json["data"]) as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int, let title = obj["title"] as? String else { return nil }
            return SpiritualEvent(
                id: id,
                title: title,
                description: obj["description"] as? String,
                date: obj["event_date"] as? String ?? obj["date"] as? String,
                location: obj["location"] as? String,
                imageUrl: obj["image_url"] as? String,
                reactionsCount: obj["reactions"] as? Int ?? (obj["rsvps"] as? Int ?? 0),
                isAttending: obj["is_attending"] as? Bool ?? false
            )
        }
    }
    
    public func toggleEventReaction(eventId: Int, userId: Int) async throws -> Bool {
        let urlStr = "\(AppConfig.baseURL)/api/v1/events.php?action=react"
        let body: [String: Any] = ["event_id": eventId, "user_id": userId]
        let request = try createRequest(urlString: urlStr, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }
        return json["success"] as? Bool ?? false
    }
    
    // MARK: - Community Feed
    public func fetchFeed(userId: Int = 1) async throws -> [PostItem] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/feed.php?action=list&limit=30&user_id=\(userId)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["posts"] as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int,
                  let content = obj["content"] as? String else { return nil }
            return PostItem(
                id: id,
                devoteeName: obj["full_name"] as? String ?? "ભક્ત",
                devoteeAvatar: obj["avatar"] as? String,
                content: content,
                imageUrl: obj["image_path"] as? String,
                createdAt: obj["created_at"] as? String,
                likesCount: obj["likes_count"] as? Int ?? 0,
                commentsCount: obj["comments_count"] as? Int ?? 0,
                isLiked: obj["is_liked"] as? Bool ?? false
            )
        }
    }
    
    public func reactToPost(postId: Int, userId: Int) async throws -> Bool {
        let urlStr = "\(AppConfig.baseURL)/api/v1/feed.php?action=react"
        let body: [String: Any] = ["post_id": postId, "user_id": userId]
        let request = try createRequest(urlString: urlStr, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }
        return json["success"] as? Bool ?? false
    }
    
    public func fetchComments(postId: Int) async throws -> [FeedComment] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/feed.php?action=comments&post_id=\(postId)&api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["comments"] as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int,
                  let comment = obj["comment"] as? String else { return nil }
            return FeedComment(
                id: id,
                devoteeName: obj["user_name"] as? String ?? "ભક્ત",
                comment: comment,
                createdAt: obj["created_at"] as? String
            )
        }
    }
    
    public func addComment(postId: Int, userId: Int, comment: String) async throws -> Bool {
        let urlStr = "\(AppConfig.baseURL)/api/v1/feed.php?action=add_comment&api_key=\(AppConfig.apiKey)"
        let body: [String: Any] = ["post_id": postId, "user_id": userId, "comment": comment]
        let request = try createRequest(urlString: urlStr, method: "POST", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }
        return json["success"] as? Bool ?? false
    }
    
    // MARK: - Gallery
    public func fetchGallery() async throws -> [DarshanItem] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/gallery.php?api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = (json["gallery"] ?? json["items"]) as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int,
                  let title = obj["title"] as? String,
                  let img = obj["image_url"] as? String ?? obj["image"] as? String else { return nil }
            return DarshanItem(
                id: id,
                title: title,
                category: obj["category"] as? String,
                imageUrl: img,
                description: obj["description"] as? String
            )
        }
    }
    
    // MARK: - Notifications
    public func fetchNotifications(limit: Int = 20) async throws -> [BroadcastNotice] {
        let urlStr = "\(AppConfig.baseURL)/api/v1/notifications.php?limit=\(limit)&api_key=\(AppConfig.apiKey)"
        let request = try createRequest(urlString: urlStr)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["notifications"] as? [[String: Any]] else {
            return []
        }
        
        return arr.compactMap { obj in
            guard let id = obj["id"] as? Int,
                  let title = obj["title"] as? String else { return nil }
            return BroadcastNotice(
                id: id,
                title: title,
                body: obj["body"] as? String ?? "",
                createdAt: obj["created_at"] as? String
            )
        }
    }
}
