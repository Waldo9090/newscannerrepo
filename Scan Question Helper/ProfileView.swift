import SwiftUI

struct ProfileView: View {
    @State private var showCameraView = false
    let deviceId = GlobalContent.shared.deviceId
    
    var body: some View {
        List {
            // Device ID Section
            Section {
                HStack {
                    Text("Device ID")
                        .foregroundColor(.white)
                    Spacer()
                    Text(deviceId)
                        .foregroundColor(.gray)
                        .font(.system(.body, design: .monospaced))
                }
            } header: {
                Text("Device Information")
                    .foregroundColor(.gray)
            }
            
            // Settings Section
            Section {
                NavigationLink(destination: Text("Terms of Use")) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.purple)
                        Text("Terms of Use")
                            .foregroundColor(.white)
                    }
                }
                
                NavigationLink(destination: Text("Privacy Policy")) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.purple)
                        Text("Privacy Policy")
                            .foregroundColor(.white)
                    }
                }
                
                NavigationLink(destination: Text("Contact Us")) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.purple)
                        Text("Contact Us")
                            .foregroundColor(.white)
                    }
                }
            } header: {
                Text("Settings")
                    .foregroundColor(.gray)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.black)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
} 
