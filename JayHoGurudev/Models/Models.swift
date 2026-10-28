import Foundation

// MARK: - Devotee User & Auth
public struct User: Codable, Identifiable, Equatable {
    public let id: Int
    public var fullName: String
    public var username: String
    public var email: String
    public var avatar: String?
    public var token: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case username
        case email
        case avatar
        case token
    }
}

// MARK: - Daily Saakhi & Wisdom
public struct Saakhi: Codable, Identifiable {
    public let id: Int
    public let content: String
    public let date: String?
    public let formattedDate: String?
    public var reactionsCount: Int
    public var isReacted: Bool
    public var streakDays: Int
    public var streakRank: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content = "text"
        case date
        case formattedDate = "formatted_date"
        case reactionsCount = "reactions"
        case isReacted = "is_reacted"
        case streakDays = "streak_days"
        case streakRank = "streak_rank"
    }
    
    public init(id: Int, content: String, date: String?, formattedDate: String?, reactionsCount: Int = 0, isReacted: Bool = false, streakDays: Int = 0, streakRank: String = "ભક્ત") {
        self.id = id
        self.content = content
        self.date = date
        self.formattedDate = formattedDate
        self.reactionsCount = reactionsCount
        self.isReacted = isReacted
        self.streakDays = streakDays
        self.streakRank = streakRank
    }
}

// MARK: - Bhajan Audio Track
public struct BhajanTrack: Codable, Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let artist: String
    public let audioUrl: String
    public let duration: String?
    public let coverImage: String?
    public let category: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case audioUrl = "file_path"
        case duration
        case coverImage = "cover_image"
        case category
    }
    
    public var resolvedAudioURL: URL? {
        if audioUrl.starts(with: "http://") || audioUrl.starts(with: "https://") {
            return URL(string: audioUrl)
        }
        let cleanPath = audioUrl.starts(with: "/") ? String(audioUrl.dropFirst()) : audioUrl
        return URL(string: "\(AppConfig.baseURL)/\(cleanPath)")
    }
}

// MARK: - Spiritual Events
public struct SpiritualEvent: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String?
    public let date: String?
    public let location: String?
    public let imageUrl: String?
    public var reactionsCount: Int
    public var isAttending: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date = "event_date"
        case location
        case imageUrl = "image_url"
        case reactionsCount = "reactions"
        case isAttending = "is_attending"
    }
}

// MARK: - Devotee Community Feed
public struct PostItem: Codable, Identifiable {
    public let id: Int
    public let devoteeName: String
    public let devoteeAvatar: String?
    public let content: String
    public let imageUrl: String?
    public let createdAt: String?
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case devoteeName = "full_name"
        case devoteeAvatar = "avatar"
        case content
        case imageUrl = "image_path"
        case createdAt = "created_at"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isLiked = "is_liked"
    }
}

// MARK: - Feed Comment
public struct FeedComment: Codable, Identifiable {
    public let id: Int
    public let devoteeName: String
    public let comment: String
    public let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case devoteeName = "user_name"
        case comment
        case createdAt = "created_at"
    }
}

// MARK: - Darshan Gallery
public struct DarshanItem: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let category: String?
    public let imageUrl: String
    public let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case imageUrl = "image_url"
        case description
    }
    
    public var resolvedImageURL: URL? {
        if imageUrl.starts(with: "http://") || imageUrl.starts(with: "https://") {
            return URL(string: imageUrl)
        }
        let cleanPath = imageUrl.starts(with: "/") ? String(imageUrl.dropFirst()) : imageUrl
        return URL(string: "\(AppConfig.baseURL)/\(cleanPath)")
    }
}

// MARK: - Broadcast Notice
public struct BroadcastNotice: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let body: String
    public let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case createdAt = "created_at"
    }
}

// MARK: - Jap Chants Stats & Leaderboard
public struct JapStats: Codable {
    public let totalJap: Int
    public let todayJap: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let rank: String?
    
    enum CodingKeys: String, CodingKey {
        case totalJap = "total_jap"
        case todayJap = "today_jap"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case rank
    }
}

public struct LeaderboardDevotee: Codable, Identifiable {
    public var id: String { username }
    public let rank: Int
    public let name: String
    public let username: String
    public let count: Int
    
    enum CodingKeys: String, CodingKey {
        case rank
        case name = "full_name"
        case username
        case count = "total_count"
    }
}
