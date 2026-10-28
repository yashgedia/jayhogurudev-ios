import SwiftUI

public struct BhajansView: View {
    @ObservedObject var audioManager = SpiritualAudioManager.shared
    @State private var bhajans: [BhajanTrack] = []
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    
    public init() {}
    
    private var categories: [String] {
        var set = Set<String>()
        set.insert("All")
        for b in bhajans {
            if let c = b.category, !c.isEmpty {
                set.insert(c)
            }
        }
        return Array(set).sorted()
    }
    
    private var filteredBhajans: [BhajanTrack] {
        bhajans.filter { track in
            let matchCat = (selectedCategory == "All") || (track.category == selectedCategory)
            let matchSearch = searchText.isEmpty ||
                track.title.localizedCaseInsensitiveContains(searchText) ||
                track.artist.localizedCaseInsensitiveContains(searchText)
            return matchCat && matchSearch
        }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.spiritualCreamBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.spiritualTextSecondary)
                        TextField("Search Bhajans, Artists, Kirtans...", text: $searchText)
                            .font(.system(size: 15))
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.spiritualTextSecondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spiritualDivider, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Category Filter Pills
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
                            .padding(.vertical, 10)
                        }
                    }
                    
                    // Bhajans List
                    if isLoading {
                        Spacer()
                        ProgressView("Loading sacred melodies...")
                            .tint(Color.spiritualSaffron)
                        Spacer()
                    } else if filteredBhajans.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 44))
                                .foregroundColor(Color.spiritualTextSecondary.opacity(0.6))
                            Text("No spiritual bhajans found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.spiritualTextSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(filteredBhajans.enumerated()), id: \.element.id) { index, track in
                                Button(action: {
                                    audioManager.setPlaylist(filteredBhajans)
                                    audioManager.playTrack(track)
                                }) {
                                    HStack(spacing: 14) {
                                        // Track number or playing equalizer icon
                                        ZStack {
                                            Circle()
                                                .fill(audioManager.currentTrack?.id == track.id ? Color.spiritualSaffron : Color.spiritualSaffronLight)
                                                .frame(width: 36, height: 36)
                                            
                                            if audioManager.currentTrack?.id == track.id {
                                                Image(systemName: audioManager.isPlaying ? "waveform" : "play.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                            } else {
                                                Text("\(index + 1)")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(Color.spiritualSaffronDark)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(track.title)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(audioManager.currentTrack?.id == track.id ? Color.spiritualSaffronDark : Color.spiritualTextPrimary)
                                                .lineLimit(1)
                                            
                                            Text(track.artist)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.spiritualTextSecondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        if let d = track.duration {
                                            Text(d)
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.spiritualTextSecondary)
                                        }
                                        
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color.spiritualSaffron)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(Color.spiritualDivider)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadBhajans()
                        }
                    }
                }
            }
            .navigationTitle("Divine Bhajans")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $audioManager.showFullPlayer) {
                FullPlayerSheet()
            }
        }
        .task {
            await loadBhajans()
        }
    }
    
    private func loadBhajans() async {
        isLoading = true
        do {
            let fetched = try await APIService.shared.fetchBhajans()
            self.bhajans = fetched
            audioManager.setPlaylist(fetched)
        } catch {
            print("Failed to load bhajans: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
