//
//  TabBarView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI
import SuperwallKit

struct TabBarView: View {
    @State private var selectedTab: Int = 0
    @State private var showCameraView = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Discover Tab
                NavigationStack {
                    DiscoverView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "square.stack.fill" : "square.stack")
                        Text("Discover")
                    }
                }
                .tag(0)
                
                // Chat Tab
                NavigationStack {
                    ChatListView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                        Text("Chat")
                    }
                }
                .tag(1)
                
                // History Tab
                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                        Text("History")
                    }
                }
                .tag(2)
                
                // Profile Tab
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        Text("Profile")
                    }
                }
                .tag(3)
            }
            .accentColor(.purple)
            .onAppear {
                // Register Superwall event
                Superwall.shared.register(placement: "campaign_trigger")
                
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = .black
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Custom center scan button overlay
            Button(action: {
                showCameraView = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 2)
                    
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30)
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView()
            }
        }
    }
}

// Discover View
struct DiscoverView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to Solvo")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your AI-powered learning assistant")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
                
                // Study Tools Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Study Tools", subtitle: "Essential tools for your learning journey")
                    
                    HStack(spacing: 15) {
                        ToolCard(
                            icon: "viewfinder",
                            title: "Smart Scanner",
                            subtitle: "Solve problems\nby photo",
                            color: Color.purple.opacity(0.8)
                        )
                        
                        ToolCard(
                            icon: "bubble.left.and.bubble.right",
                            title: "AI Chat",
                            subtitle: "Get step-by-step\nhelp instantly",
                            color: Color.blue.opacity(0.8)
                        )
                    }
                }
                .padding(.horizontal)
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Quick Actions", subtitle: "Solve problems instantly")
                    
                    VStack(spacing: 12) {
                        QuickActionButton(
                            title: "Math Problems",
                            icon: "function",
                            color: Color(hex: "#FF6B6B"),
                            description: "Algebra, Calculus & more"
                        )
                        
                        QuickActionButton(
                            title: "Physics & Chemistry",
                            icon: "atom",
                            color: Color(hex: "#4ECDC4"),
                            description: "Formulas & reactions"
                        )
                        
                        QuickActionButton(
                            title: "Essay Writing",
                            icon: "text.quote",
                            color: Color(hex: "#9B5DE5"),
                            description: "Essays & analysis"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Featured Tools Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Featured Tools", subtitle: "Popular learning resources")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            FeaturedToolCard(
                                title: "Step-by-Step Solutions",
                                icon: "list.bullet.rectangle",
                                color: Color(hex: "#FF9F1C")
                            )
                            
                            FeaturedToolCard(
                                title: "Practice Questions",
                                icon: "pencil.and.outline",
                                color: Color(hex: "#2EC4B6")
                            )
                            
                            FeaturedToolCard(
                                title: "Study Notes",
                                icon: "note.text",
                                color: Color(hex: "#E71D36")
                            )
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
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(color)
            .cornerRadius(15)
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
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

// History View


// Profile View


// Helper Views
struct ToolItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SubjectItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.8))
        .cornerRadius(15)
    }
}

struct ChatSolveItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(color.opacity(0.8))
            .cornerRadius(15)
        }
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

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
