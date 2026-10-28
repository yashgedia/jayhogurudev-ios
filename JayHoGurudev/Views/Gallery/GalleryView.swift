import SwiftUI

public struct GalleryView: View {
    @State private var items: [DarshanItem] = []
    @State private var isLoading: Bool = true
    @State private var selectedCategory: String = "All"
    @State private var selectedViewerIndex: Int = 0
    @State private var isViewerPresented: Bool = false
    @State private var isSlideshowMode: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init() {}
    
    private var categories: [String] {
        var set = Set<String>()
        set.insert("All")
        for item in items {
            if let cat = item.category, !cat.isEmpty {
                set.insert(cat)
            }
        }
        return Array(set).sorted()
    }
    
    private var filteredItems: [DarshanItem] {
        if selectedCategory == "All" { return items }
        return items.filter { $0.category == selectedCategory }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar with Slideshow Trigger
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sacred Darshan")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(Color.spiritualTextPrimary)
                            Text("Divine Ashram Moments & Vigraha Darshan")
                                .font(.system(size: 12))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if !filteredItems.isEmpty {
                                selectedViewerIndex = 0
                                isSlideshowMode = true
                                isViewerPresented = true
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.circle.fill")
                                Text("Slideshow")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(SpiritualGradients.saffron)
                            .cornerRadius(20)
                            .shadow(color: Color.spiritualSaffron.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .disabled(filteredItems.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    
                    // Category Chips
                    if categories.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        Text(cat)
                                            .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == cat ? Color.spiritualSaffron : Color.white)
                                            .foregroundColor(selectedCategory == cat ? .white : Color.spiritualTextPrimary)
                                            .cornerRadius(20)
                                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spiritualDivider, lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                    }
                    
                    // Grid of Darshan Photos
                    if isLoading {
                        Spacer()
                        ProgressView("Receiving sacred darshan...")
                            .tint(Color.spiritualSaffron)
                        Spacer()
                    } else if filteredItems.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 44))
                                .foregroundColor(Color.spiritualTextSecondary.opacity(0.5))
                            Text("No darshan photos available right now.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                    Button(action: {
                                        selectedViewerIndex = index
                                        isSlideshowMode = false
                                        isViewerPresented = true
                                    }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            AsyncImage(url: item.resolvedImageURL) { phase in
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
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color.spiritualSaffronLight)
                                                        .frame(height: 160)
                                                        .overlay(
                                                            Image(systemName: "sparkles")
                                                                .foregroundColor(Color.spiritualSaffronDark)
                                                        )
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .cornerRadius(12)
                                            
                                            Text(item.title)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Color.spiritualTextPrimary)
                                                .lineLimit(1)
                                                .padding(.horizontal, 6)
                                                .padding(.bottom, 6)
                                        }
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .spiritualCard(cornerRadius: 12, elevation: 4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            await loadGallery()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isViewerPresented) {
                DarshanViewerModal(items: filteredItems, initialIndex: selectedViewerIndex, startSlideshow: isSlideshowMode)
            }
        }
        .task {
            await loadGallery()
        }
    }
    
    private func loadGallery() async {
        isLoading = true
        do {
            let fetched = try await APIService.shared.fetchGallery()
            self.items = fetched
        } catch {
            print("Failed to load gallery: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
