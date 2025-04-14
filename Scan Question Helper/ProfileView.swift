import SwiftUI

struct ProfileView: View {
    // Define colors
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)
    let darkGray = Color(white: 0.12) // Slightly darker for better contrast
    let cardShadow = Color.purple.opacity(0.3)
    
    @State private var animateStats = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(white: 0.08)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Stats Section with animation
                        HStack(spacing: 0) {
                            ForEach(["solved tasks", "invited friends", "free requests"].indices, id: \.self) { index in
                                StatItem(
                                    value: "0",
                                    title: ["solved tasks", "invited friends", "free requests"][index],
                                    icon: ["checkmark.circle.fill", "person.2.fill", "sparkles"][index],
                                    delay: Double(index) * 0.2
                                )
                                .opacity(animateStats ? 1 : 0)
                                .offset(y: animateStats ? 0 : 20)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Premium Section
                        VStack(spacing: 1) {
                            ListButton(
                                title: "Get Unlimited Access",
                                subtitle: "Unlock all features",
                                icon: "gift.fill",
                                color: neonPurple
                            )
                            ListButton(
                                title: "Get More Requests",
                                subtitle: "Add solving credits",
                                icon: "arrow.clockwise",
                                color: neonPurple
                            )
                        }
                        .background(darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: cardShadow, radius: 8)
                        .padding(.horizontal)
                        
                        // Support Section
                        VStack(spacing: 1) {
                            Group {
                                ListButton(title: "Contact Us", subtitle: "Get help and support", icon: "bubble.left.fill", color: neonPurple)
                                Divider().background(Color.white.opacity(0.1))
                                ListButton(title: "Rate Us", subtitle: "Share your feedback", icon: "star.fill", color: neonPurple)
                                Divider().background(Color.white.opacity(0.1))
                                ListButton(title: "Restore Purchase", subtitle: "Recover your purchases", icon: "cart.fill", color: neonPurple)
                                Divider().background(Color.white.opacity(0.1))
                                ListButton(title: "Terms of Use", subtitle: "Read our terms", icon: "doc.text.fill", color: neonPurple)
                                Divider().background(Color.white.opacity(0.1))
                                ListButton(title: "Privacy Policy", subtitle: "View our policy", icon: "shield.fill", color: neonPurple)
                            }
                        }
                        .background(darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: cardShadow, radius: 8)
                        .padding(.horizontal)
                        
                        // Social Section
                        VStack(spacing: 1) {
                            ListButton(
                                title: "Follow Us on TikTok",
                                subtitle: "Watch our latest content",
                                icon: "play.circle.fill",
                                color: neonPurple
                            )
                        }
                        .background(darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: cardShadow, radius: 8)
                        .padding(.horizontal)
                        
                        // Invite Banner
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Want 10 free answers?")
                                    .font(.headline)
                                Text("Just invite a friend to Solvo!")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Invite")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .pink, neonPurple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: cardShadow, radius: 8)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateStats = true
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let title: String
    let icon: String
    let delay: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.6, green: 0.0, blue: 1.0))
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: true)
    }
}

struct ListButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
} 