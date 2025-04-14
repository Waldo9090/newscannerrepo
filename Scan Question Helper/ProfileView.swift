import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Profile Header
            VStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                Text("Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Sign in to access all features")
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            // Stats Section
            HStack(spacing: 30) {
                StatItem(value: "0", title: "Solutions")
                StatItem(value: "0", title: "Bookmarks")
                StatItem(value: "0", title: "Points")
            }
            .padding(.vertical, 20)
            
            // Action Buttons
            VStack(spacing: 15) {
                ActionButton(title: "Sign In", icon: "person.fill", action: {})
                ActionButton(title: "Settings", icon: "gear", action: {})
                ActionButton(title: "Help Center", icon: "questionmark.circle", action: {})
                ActionButton(title: "About", icon: "info.circle", action: {})
            }
            .padding()
            
            Spacer()
        }
        .background(Color.black)
        .navigationTitle("Profile")
    }
}

struct StatItem: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
} 