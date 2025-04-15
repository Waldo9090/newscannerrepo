import SwiftUI

struct DiscoverView: View {
    @State private var showCameraView = false
    @State private var showChatView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Study Tools Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Study Tools", subtitle: "Essential tools for your learning journey")
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            showCameraView = true
                        }) {
                            ToolCard(
                                icon: "viewfinder",
                                title: "Smart Scanner",
                                subtitle: "Solve problems\nby photo",
                                color: Color.purple.opacity(0.8)
                            )
                        }
                        
                        Button(action: {
                            showChatView = true
                        }) {
                            ToolCard(
                                icon: "bubble.left.and.bubble.right",
                                title: "AI Chat",
                                subtitle: "Get step-by-step\nhelp instantly",
                                color: Color.blue.opacity(0.8)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Quick Actions", subtitle: "Solve problems instantly")
                    
                    VStack(spacing: 12) {
                        QuickActionButton(
                            title: "Math",
                            icon: "function",
                            color: Color(hex: "#FF6B6B"),
                            action: { showChatView = true }
                        )
                        
                        QuickActionButton(
                            title: "Physics",
                            icon: "atom",
                            color: Color(hex: "#4ECDC4"),
                            action: { showChatView = true }
                        )
                        
                        QuickActionButton(
                            title: "Chemistry",
                            icon: "flask",
                            color: Color(hex: "#9B5DE5"),
                            action: { showChatView = true }
                        )
                        
                        QuickActionButton(
                            title: "Biology",
                            icon: "leaf",
                            color: Color(hex: "#00B4D8"),
                            action: { showChatView = true }
                        )
                        
                        QuickActionButton(
                            title: "History",
                            icon: "book",
                            color: Color(hex: "#FF9F1C"),
                            action: { showChatView = true }
                        )
                        
                        QuickActionButton(
                            title: "Literature",
                            icon: "text.quote",
                            color: Color(hex: "#E71D36"),
                            action: { showChatView = true }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Featured Tools Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Featured Tools", subtitle: "Popular learning resources")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            Button(action: {
                                showChatView = true
                            }) {
                                FeaturedToolCard(
                                    title: "Step-by-Step Solutions",
                                    icon: "list.bullet.rectangle",
                                    color: Color(hex: "#FF9F1C")
                                )
                            }
                            
                            Button(action: {
                                showChatView = true
                            }) {
                                FeaturedToolCard(
                                    title: "Practice Questions",
                                    icon: "pencil.and.outline",
                                    color: Color(hex: "#2EC4B6")
                                )
                            }
                            
                            Button(action: {
                                showChatView = true
                            }) {
                                FeaturedToolCard(
                                    title: "Study Notes",
                                    icon: "note.text",
                                    color: Color(hex: "#E71D36")
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .navigationTitle("Discover")
        .fullScreenCover(isPresented: $showCameraView) {
            CameraView()
        }
        .fullScreenCover(isPresented: $showChatView) {
            ChatDetailView()
        }
    }
}

struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color)
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(color)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

struct FeaturedToolCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(width: 160)
        .padding()
        .background(color)
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

// Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
