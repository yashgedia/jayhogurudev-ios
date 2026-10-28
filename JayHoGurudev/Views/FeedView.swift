import SwiftUI

public struct FeedView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var posts: [PostItem] = []
    @State private var isLoading: Bool = true
    @State private var activeCommentPost: PostItem? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Connecting to Devotee Satsang...")
                        .tint(Color.spiritualSaffron)
                } else if posts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color.spiritualTextSecondary.opacity(0.5))
                        Text("No community posts yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                postCardView(post: post)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .refreshable {
                        await loadPosts()
                    }
                }
            }
            .navigationTitle("Community Satsang")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activeCommentPost) { post in
                CommentsSheet(post: post)
            }
        }
        .task {
            await loadPosts()
        }
    }
    
    // MARK: - Post Card
    private func postCardView(post: PostItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.spiritualSaffronLight)
                        .frame(width: 42, height: 42)
                    
                    Text(post.devoteeName.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.spiritualSaffronDark)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.devoteeName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.spiritualTextPrimary)
                    
                    if let t = post.createdAt {
                        Text(t)
                            .font(.system(size: 12))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Content Text
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(Color.spiritualTextPrimary)
                .lineSpacing(4)
            
            // Post Image Attachment (if available)
            if let imgPath = post.imageUrl, !imgPath.isEmpty {
                let resolvedURL: URL? = imgPath.starts(with: "http") ? URL(string: imgPath) : URL(string: "\(AppConfig.baseURL)/\(imgPath)")
                if let url = resolvedURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.spiritualSaffronLight)
                                .frame(height: 200)
                                .overlay(ProgressView().tint(Color.spiritualSaffron))
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: 250)
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
            
            // Interactions Row (Jay Ho, Comments, Share)
            HStack(spacing: 20) {
                // Jay Ho reaction
                Button(action: { toggleReaction(post: post) }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : Color.spiritualSaffronDark)
                        Text("જય હો (\(post.likesCount))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.spiritualTextPrimary)
                    }
                }
                
                // Comments button
                Button(action: { activeCommentPost = post }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(Color.spiritualTextSecondary)
                        Text("Comments (\(post.commentsCount))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                }
                
                Spacer()
                
                // Share
                Button(action: {
                    ShareSheetHelper.shareTextAndImage(text: post.content, image: nil)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color.spiritualTextSecondary)
                }
            }
            .font(.system(size: 14))
        }
        .padding(16)
        .background(Color.white)
        .spiritualCard(cornerRadius: 16, elevation: 4)
    }
    
    private func loadPosts() async {
        isLoading = true
        let userId = authManager.currentUser?.id ?? 1
        do {
            self.posts = try await APIService.shared.fetchFeed(userId: userId)
        } catch {
            print("Feed error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func toggleReaction(post: PostItem) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        HapticManager.beadTap()
        
        let willLike = !posts[index].isLiked
        posts[index].isLiked = willLike
        posts[index].likesCount += (willLike ? 1 : -1)
        
        let userId = authManager.currentUser?.id ?? 1
        Task {
            _ = try? await APIService.shared.reactToPost(postId: post.id, userId: userId)
        }
    }
}
