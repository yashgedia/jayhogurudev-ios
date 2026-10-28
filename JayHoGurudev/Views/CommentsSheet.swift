import SwiftUI

public struct CommentsSheet: View {
    let post: PostItem
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var comments: [FeedComment] = []
    @State private var newCommentText: String = ""
    @State private var isLoading: Bool = true
    @State private var isSubmitting: Bool = false
    
    public init(post: PostItem) {
        self.post = post
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Comments List
                    if isLoading {
                        Spacer()
                        ProgressView("Loading comments...").tint(Color.spiritualSaffron)
                        Spacer()
                    } else if comments.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundColor(Color.spiritualTextSecondary.opacity(0.5))
                            Text("Be the first devotee to comment 🙏")
                                .font(.system(size: 15))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(comments) { c in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(c.devoteeName)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color.spiritualTextPrimary)
                                        Spacer()
                                        if let t = c.createdAt {
                                            Text(t)
                                                .font(.system(size: 11))
                                                .foregroundColor(Color.spiritualTextSecondary)
                                        }
                                    }
                                    
                                    Text(c.comment)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.spiritualTextPrimary.opacity(0.9))
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(Color.spiritualDivider)
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    // Comment Input Bar
                    HStack(spacing: 10) {
                        TextField("Write your divine thoughts...", text: $newCommentText)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spiritualDivider, lineWidth: 1))
                        
                        Button(action: submitComment) {
                            ZStack {
                                Circle()
                                    .fill(SpiritualGradients.saffron)
                                    .frame(width: 44, height: 44)
                                
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .offset(x: -1, y: 1)
                                }
                            }
                        }
                        .disabled(isSubmitting || newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                }
            }
            .navigationTitle("Satsang Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.spiritualSaffronDark)
                }
            }
        }
        .task {
            await loadComments()
        }
    }
    
    private func loadComments() async {
        isLoading = true
        do {
            self.comments = try await APIService.shared.fetchComments(postId: post.id)
        } catch {
            print("Failed to load comments: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func submitComment() {
        let clean = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let userId = authManager.currentUser?.id ?? 1
        isSubmitting = true
        
        Task {
            let success = try? await APIService.shared.addComment(postId: post.id, userId: userId, comment: clean)
            if success == true {
                newCommentText = ""
                await loadComments()
            }
            isSubmitting = false
        }
    }
}
