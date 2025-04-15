import SwiftUI
import FirebaseFirestore // <-- Keep Firestore import

// --- ADD: Data Model --- 
struct ProblemHistoryItem: Identifiable {
    let id: String
    let imageBase64: String
    let solution: String
    let timestamp: Date
    let isBookmarked: Bool
    
    var image: UIImage? {
        guard let data = Data(base64Encoded: imageBase64) else { return nil }
        return UIImage(data: data)
    }
    
    init?(documentId: String, data: [String: Any]) {
        // Use Firestore field names: "image" and "bookmark"
        guard let imageBase64 = data["image"] as? String, // <-- Changed from "imageBase64"
              let solution = data["solution"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            print("ProblemHistoryItem Init Error: Missing or invalid field for doc \(documentId). Data: \(data)") // Added logging
            return nil
        }
        
        self.id = documentId
        self.imageBase64 = imageBase64
        self.solution = solution
        self.timestamp = timestamp.dateValue()
        // Use Firestore field name: "bookmark", provide default value
        self.isBookmarked = (data["bookmark"] as? Bool) ?? false // <-- Changed from "isBookmarked"
    }
}
// --- END: Data Model --- 

struct HistoryView: View {
    @State private var selectedTab = 0 // 0 for All, 1 for Bookmarks
    
    // --- State for fetched data --- 
    @State private var historyItems: [ProblemHistoryItem] = []
    @State private var isLoadingHistory: Bool = false
    @State private var fetchError: String? = nil
    
    // --- Define Colors using Neon Purple ---
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)
    let darkBg = Color.black
    let activeTabColor = Color(red: 0.6, green: 0.0, blue: 1.0) // Neon Purple for active tab
    let inactiveTabColor = Color.gray
    let cardBackgroundColor = Color.white.opacity(0.1)
    let accentGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.6, green: 0.0, blue: 1.0), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing) // Purple Gradient

    // Placeholder for points - replace with actual data source later
    @State private var points: Int = 0

    var body: some View {
        NavigationView {
            ZStack {
                darkBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- Custom Segmented Control (Tabs at Top) ---
                    HStack(spacing: 0) {
                        SegmentButton(title: "All", tag: 0, selection: $selectedTab, activeColor: activeTabColor, inactiveColor: inactiveTabColor)
                        SegmentButton(title: "Bookmarks", tag: 1, selection: $selectedTab, activeColor: activeTabColor, inactiveColor: inactiveTabColor)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.top, 5)
                    
                    // --- Content Area ---
                    TabView(selection: $selectedTab) {
                        // Pass ALL history items to the All tab
                        HistoryContentView(
                            historyItems: historyItems, // <-- Pass the unfiltered list
                            isLoading: isLoadingHistory,
                            error: fetchError,
                            tabType: .all
                        )
                        .tag(0)
                        
                        // Bookmarks tab - Keep the filter here
                        HistoryContentView(
                            historyItems: historyItems.filter { $0.isBookmarked },
                            isLoading: isLoadingHistory,
                            error: fetchError,
                            tabType: .bookmarks
                        )
                        .tag(1)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            // Style the Navigation Bar for Dark Mode
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(darkBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            // Fetch history when the view appears
            fetchHistory()
        }
    }
    
    // --- ADD: Firestore Fetch Function --- 
    private func fetchHistory() {
        isLoadingHistory = true
        fetchError = nil
        let db = Firestore.firestore()
        let deviceId = GlobalContent.shared.deviceId
        
        print("HistoryView: Fetching history for deviceId: \(deviceId)")

        guard !deviceId.starts(with: "unknown-") else {
            print("HistoryView: Invalid device ID, cannot fetch history.")
            fetchError = "Invalid Device ID. Cannot load history."
            isLoadingHistory = false
            return
        }

        let problemsRef = db.collection("solutions")
                            .document(deviceId)
                            .collection("problems")
                            .order(by: "timestamp", descending: true) // Order latest first

        // Use a snapshot listener for real-time updates (optional, can use getDocuments once)
        problemsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("HistoryView: Error fetching history: \(error.localizedDescription)")
                fetchError = "Error loading history: \(error.localizedDescription)"
                isLoadingHistory = false
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("HistoryView: No history documents found.")
                self.historyItems = []
                isLoadingHistory = false
                return
            }

            print("HistoryView: Received \(documents.count) history documents.")
            // Map Firestore documents to ProblemHistoryItem
            self.historyItems = documents.compactMap { doc -> ProblemHistoryItem? in
                let data = doc.data()
                let id = doc.documentID
                
                // Call the correct initializer
                return ProblemHistoryItem(documentId: id, data: data)
            }
            
            isLoadingHistory = false
            fetchError = nil // Clear error on success
            print("HistoryView: Successfully mapped \(self.historyItems.count) items.")
        }
    }
    // --- END: Firestore Fetch Function --- 
}

// MARK: - Helper Views

struct SegmentButton: View {
    let title: String
    let tag: Int
    @Binding var selection: Int
    let activeColor: Color
    let inactiveColor: Color
    
    var isSelected: Bool { selection == tag }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = tag
            }
        }) {
            VStack(spacing: 8) { // Add spacing for underline
                Text(title)
                    .font(.system(size: 16, weight: .bold)) // Always bold
                    .foregroundColor(isSelected ? activeColor : inactiveColor) // Active color for text
                
                // Underline
                Rectangle()
                    .fill(isSelected ? activeColor : Color.clear) // Show underline only if selected
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Ensure whole area is tappable
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}

enum HistoryTabType { case all, bookmarks }

// Updated Content View to accept theme color and gradient
struct HistoryContentView: View {
    let historyItems: [ProblemHistoryItem]
    let isLoading: Bool
    let error: String?
    let tabType: HistoryTabType
    
    @State private var selectedItem: ProblemHistoryItem?
    @State private var showingDetail = false
    
    // Function to toggle bookmark
    func toggleBookmark(for itemId: String) {
        let db = Firestore.firestore()
        let deviceId = GlobalContent.shared.deviceId

        let docRef = db.collection("solutions").document(deviceId)
            .collection("problems").document(itemId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentBookmarkState = document.data()?["bookmark"] as? Bool ?? false
                docRef.updateData([
                    "bookmark": !currentBookmarkState
                ]) { err in
                    if let err = err {
                        print("Error updating bookmark: \(err)")
                    } else {
                        print("Bookmark status updated successfully for \(itemId)")
                    }
                }
            }
        }
    }
    
    var body: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        } else {
            if let errorMessage = error {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if historyItems.isEmpty {
                EmptyStateView(tabType: tabType)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(historyItems) { item in
                            VStack(alignment: .leading, spacing: 12) {
                                if let image = item.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .cornerRadius(12)
                                        .clipped()
                                }
                                
                                Text(item.solution)
                                    .lineLimit(3)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Label(
                                        timeAgoString(from: item.timestamp),
                                        systemImage: "clock"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        toggleBookmark(for: item.id)
                                    }) {
                                        Image(systemName: item.isBookmarked ? "bookmark.fill" : "bookmark")
                                            .foregroundColor(item.isBookmarked ? .yellow : .gray)
                                            .font(.system(size: 18))
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(16)
                            .onTapGesture {
                                selectedItem = item
                                showingDetail = true
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.black)
                .sheet(isPresented: $showingDetail) {
                    if let selectedItem = selectedItem {
                        HistoryDetailView(item: selectedItem)
                    }
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct HistoryCard: View {
    let item: ProblemHistoryItem
    let themeColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let uiImage = item.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.solution)
                    .lineLimit(2)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack {
                    Label(
                        timeAgoString(from: item.timestamp),
                        systemImage: "clock"
                    )
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if item.isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(themeColor)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(white: 0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: themeColor.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color(red: 0.6, green: 0.0, blue: 1.0), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Loading...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error Loading History")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

struct EmptyStateView: View {
    let tabType: HistoryTabType
    let themeColor = Color(red: 0.6, green: 0.0, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: tabType == .all ? "clock.fill" : "bookmark.fill")
                    .font(.system(size: 32))
                    .foregroundColor(themeColor)
            }
            
            VStack(spacing: 8) {
                Text(tabType == .all ? "No History Yet" : "No Bookmarks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(tabType == .all ? "Your solved problems will appear here" : "Save your favorite solutions for quick access")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if tabType == .bookmarks {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Text("Start Solving")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(themeColor)
                    .cornerRadius(20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// --- MODIFIED: HistoryDetailView --- 
struct HistoryDetailView: View {
    let item: ProblemHistoryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(16)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Solution")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(item.solution)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Label(
                            timeAgoString(from: item.timestamp),
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: item.isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(item.isBookmarked ? .yellow : .gray)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .preferredColorScheme(.dark)
    }
} 
