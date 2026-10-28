import SwiftUI

public struct SaakhiBookSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saakhis: [Saakhi] = []
    @State private var isLoading: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Opening Sacred Saakhi Book...")
                        .tint(Color.spiritualSaffron)
                } else if saakhis.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 44))
                            .foregroundColor(Color.spiritualTextSecondary.opacity(0.6))
                        Text("No archives recorded yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.spiritualTextSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(saakhis) { saakhi in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(saakhi.formattedDate ?? saakhi.date ?? "Sacred Saakhi")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(Color.spiritualSaffronDark)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.spiritualSaffronLight)
                                            .cornerRadius(12)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(Color.spiritualSaffron)
                                            Text("\(saakhi.reactionsCount)")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color.spiritualTextSecondary)
                                        }
                                    }
                                    
                                    Text("\"\(saakhi.content)\"")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color.spiritualTextPrimary)
                                        .lineSpacing(6)
                                }
                                .padding()
                                .background(Color.white)
                                .spiritualCard(cornerRadius: 14, elevation: 4)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await loadBook()
                    }
                }
            }
            .navigationTitle("Sacred Saakhi Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.spiritualSaffronDark)
                    .fontWeight(.semibold)
                }
            }
        }
        .task {
            await loadBook()
        }
    }
    
    private func loadBook() async {
        isLoading = true
        do {
            self.saakhis = try await APIService.shared.fetchRecentSaakhis()
        } catch {
            print("Failed to load saakhi book: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
