import SwiftUI

// Example of your first page view
struct FirstPageView: View {
    var body: some View {
        VStack {
            Text("Welcome to the First Page!")
                .font(.largeTitle)
                .padding()
            // Add your first page UI here
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    // Use AppStorage to keep track of the sign in state
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    // State variable to trigger navigation to FirstPageView
    @State private var navigateToFirstPage: Bool = false
    
    // Define the URLs for Terms & Conditions and Privacy Policy
    private let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyPolicyURL = URL(string: "https://waldo9090.github.io/Privacy-Policy/")!
    
    // If you want to dismiss the current view (if it is pushed onto a NavigationStack)
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Legal Section with Terms & Conditions and Privacy Policy
                    Section(header: Text("Legal")
                                .font(.headline)
                                .foregroundColor(.white)) {
                        Button(action: {
                            openURL(termsOfUseURL)
                        }) {
                            HStack {
                                Text("Terms & Conditions")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        Button(action: {
                            openURL(privacyPolicyURL)
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.black)
                    
                    // Account Section
                    // Add your Account-related views here
                }
                .scrollContentBackground(.hidden)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .listStyle(InsetGroupedListStyle())
                
                // Customized Capsule "Delete Account" Button
                Button(action: {
                    // Update user defaults to reflect the sign out state
                    isSignedIn = false
                    
                    // Trigger navigation to FirstPageView
                    navigateToFirstPage = true
                    
                    // Optionally, if this view was pushed, you can dismiss it:
                    // presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.black)
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 2)
                )
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                // Hidden NavigationLink that becomes active when navigateToFirstPage is true.
                NavigationLink(destination: StartPageView().navigationBarBackButtonHidden(true),
                               isActive: $navigateToFirstPage) {
                    EmptyView()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
