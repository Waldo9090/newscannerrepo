import SwiftUI
import UIKit
import FirebaseFirestore

// MARK: - PreferenceKey for ScrollView Bottom Detection
struct ScrollViewBottomReachedPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - Message Model

/// A simple model representing a message in the chat.
/// It supports text messages and/or an image (stored as Data).

// MARK: - MathChatView

struct MathChatView: View {
    let selectedImage: UIImage

    @State private var messages: [Message] = []
    @State private var isLoading: Bool = false
    /// The ID of the bot message currently receiving streaming text.
    @State private var currentBotMessageID: UUID? = nil
    @State private var isBookmarked: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isAtBottom: Bool = false // State to track scroll position

    // Define Neon Purple Color
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // --- Wrap entire content in a ScrollView --- 
            ScrollViewReader { scrollProxy in // Keep ScrollViewReader if needed for scrolling to specific messages
                ScrollView { 
                    VStack(spacing: 0) { // Main content VStack
                        // --- Display Image Directly at Top --- 
                        if let userMessage = messages.first(where: { $0.isUser && $0.imageData != nil }),
                           let uiImage = userMessage.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.3) // Limit image height
                                .padding(.horizontal)
                                .padding(.top) // Padding above image
                                .padding(.bottom, 8) // Reduced padding below image
                        }

                        // --- Solution Section --- 
                        VStack(alignment: .leading, spacing: 8) { 
                            // --- Solution Title --- 
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow) // Changed color for dark mode
                                Text("Solution")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white) // Changed color for dark mode
                                Spacer()
                            }
                            .padding([.top, .horizontal])
                            .padding(.bottom, 4)

                            // --- Chat messages directly in VStack (NO inner ScrollView) --- 
                            LazyVStack(alignment: .leading, spacing: 15) { 
                                // Solution messages
                                ForEach(messages.filter { !$0.isUser }) { message in
                                    messageContentView(message: message)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .id(message.id)
                                }
                                
                                // Loading Indicator
                                if isLoading && currentBotMessageID == nil {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.leading)
                                        Text("Analyzing your problem...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.vertical)
                                }
                            }
                            .padding(.horizontal) 
                            .padding(.bottom) 
                            
                            // --- ADDED: Action Buttons --- 
                            HStack(spacing: 25) { // Adjust spacing as needed
                                Spacer() // Push buttons to the right initially, or distribute with spacers
                                
                                Button(action: { 
                                    // TODO: Implement Regenerate Action
                                    print("Regenerate tapped")
                                    regenerateSolution()
                                }) { 
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: { 
                                    // TODO: Implement Thumbs Up Action
                                    print("Thumbs Up tapped")
                                }) { 
                                    Image(systemName: "hand.thumbsup")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: { 
                                    // TODO: Implement Thumbs Down Action
                                    print("Thumbs Down tapped")
                                }) { 
                                    Image(systemName: "hand.thumbsdown")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: { 
                                    // TODO: Implement Copy Action
                                    copySolutionToClipboard()
                                    print("Copy tapped")
                                }) { 
                                    Image(systemName: "doc.on.doc") // Copy icon
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: { 
                                    // TODO: Implement Share Action
                                    shareSolution()
                                    print("Share tapped")
                                }) { 
                                    Image(systemName: "square.and.arrow.up") // Share icon
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                Spacer() // Balance spacer
                            }
                            .padding(.horizontal) // Padding for the button row
                            .padding(.top, 5) // Space above the buttons
                            // --- END ADDED: Action Buttons ---

                        }
                        .cornerRadius(16) 
                        .padding(.horizontal) 
                        .padding(.bottom, 80) 

                        // --- GeometryReader for scroll detection (Moved inside outer ScrollView's content) --- 
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollViewBottomReachedPreferenceKey.self,
                                            value: geometry.frame(in: .global).maxY < UIScreen.main.bounds.height + 20) 
                        }
                        .frame(height: 1)
                        .padding(.bottom, 80) // Add padding at the very bottom for the button area
                    } // End Main content VStack
                    .onChange(of: messages) { _ in // Keep onChange attached to the content?
                        if let lastMessage = messages.last { 
                            withAnimation { 
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                } // End Outer ScrollView
                // Apply preference change listener to the ScrollView
                .onPreferenceChange(ScrollViewBottomReachedPreferenceKey.self) { reachedBottom in
                    self.isAtBottom = reachedBottom
                }
            } // End ScrollViewReader
            
            // --- Conditional Bottom Button --- 
            VStack { 
                Spacer() // Pushes to bottom
                if isAtBottom { 
                    HStack { 
                        Button(action: { 
                            print("Next Problem Tapped - Attempting Dismissal") 
                            presentationMode.wrappedValue.dismiss()
                        }) { 
                            HStack { 
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                                Text("Next Problem")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(neonPurple) // Use neon purple
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: neonPurple.opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Add animation
                }
            }
            .animation(.easeInOut, value: isAtBottom) // Animate the button appearance
        }
        .navigationTitle("Math Solution") // Changed Title
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isBookmarked.toggle()
                    updateBookmarkInFirestore()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? neonPurple : .white)
                }
            }
        }
        .preferredColorScheme(.dark) // Request dark mode for navigation bar
        .onAppear { 
            addUserImageMessage()
            fetchSolution()
            checkBookmarkStatus()
        }
    }
    
    /// Returns a view displaying either text or an image for a message.
    @ViewBuilder
    private func messageContentView(message: Message) -> some View {
        if let image = message.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .frame(maxWidth: 200, maxHeight: 200)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        } else if let text = message.text {
            if message.isUser {
                Text(text)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            } else {
                // --- Assistant message styling with individual background --- 
                Text(text)
                    .padding()
                    // Apply background here instead of container
                    .background(Color.gray.opacity(0.2)) 
                    .foregroundColor(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes width
            }
        }
    }
    
    /// Adds the user's image as a chat bubble.
    private func addUserImageMessage() {
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let userMessage = Message(text: nil, isUser: true, imageData: imageData)
            messages.append(userMessage)
            
            // Also add a placeholder text message so the assistant can refer to it.
            let placeholder = Message(text: "Help me solve this problem.", isUser: true)
            messages.append(placeholder)
        }
    }
    
    /// Calls the GPT‑4 API with the image encoded in the prompt.
    private func fetchSolution() {
        // Encode the image
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            updateBotMessage(with: "Could not encode image.")
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        // --- Load API Key using shared function ---
        guard let apiKey = loadAPIKey() else {
            updateBotMessage(with: "API Key not found. Please check Secrets.plist.")
            // Ensure loading state is reset if key loading fails
            isLoading = false
            currentBotMessageID = nil
            return
        }
        // --- End Load API Key ---
        
        isLoading = true
        
        // Build the system message.
        let systemMessage: [String: Any] = [
            "role": "system",
            "content": "You are a Mathematics tutor. Provide a detailed, step-by-step solution with explanations."
        ]
        
        // Build the user message as an array of content objects.
        let userContent: [[String: Any]] = [
            [
                "type": "text",
                "text": "This image contains a math problem. Please analyze and provide a detailed explanation."
            ],
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64Image)"
                ]
            ]
        ]
        
        let userMessage: [String: Any] = [
            "role": "user",
            "content": userContent
        ]
        
        let apiMessages = [systemMessage, userMessage]
        
        // Add a placeholder assistant message for streaming response.
        let botPlaceholder = Message(text: "", isUser: false)
        messages.append(botPlaceholder)
        currentBotMessageID = botPlaceholder.id
        
        // Build the URL and URLRequest.
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            updateBotMessage(with: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Use the loaded apiKey from Secrets.plist via loadAPIKey()
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",  // Use vision-capable model
            "messages": apiMessages,
            "temperature": 0.2,
            "stream": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            updateBotMessage(with: "Error encoding request: \(error.localizedDescription)")
            return
        }
        
        // Use the globally accessible StreamingDelegate
        let delegate = StreamingDelegate { chunk in
            // Append each chunk to the bot message text.
            if let index = messages.firstIndex(where: { $0.id == self.currentBotMessageID }) {
                // Use self explicitly in closure
                self.messages[index].text = (self.messages[index].text ?? "") + chunk
            }
        } onCompletion: {
            // Use self explicitly in closure
            self.isLoading = false
            self.currentBotMessageID = nil
        }
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }

    
    /// Updates the current bot message in case of error.
    private func updateBotMessage(with text: String) {
        if let index = messages.firstIndex(where: { $0.id == currentBotMessageID }) {
            messages[index].text = text
        } else {
            // Avoid adding duplicate error messages if key load failed
            if !messages.contains(where: { $0.text == text && !$0.isUser }) {
                 messages.append(Message(text: text, isUser: false))
            }
        }
        isLoading = false
        currentBotMessageID = nil
    }

    // --- ADDED: Placeholder functions for new actions --- 
    private func regenerateSolution() {
        // Clear previous bot messages and fetch again
        messages.removeAll { !$0.isUser } // Keep user image/prompt
        fetchSolution()
    }

    private func copySolutionToClipboard() {
        let solutionText = messages.filter { !$0.isUser }.compactMap { $0.text }.joined(separator: "\n\n")
        if !solutionText.isEmpty {
            UIPasteboard.general.string = solutionText
            // Optionally show a confirmation to the user
        }
    }

    private func shareSolution() {
        let solutionText = messages.filter { !$0.isUser }.compactMap { $0.text }.joined(separator: "\n\n")
        if !solutionText.isEmpty {
            let activityViewController = UIActivityViewController(activityItems: [solutionText], applicationActivities: nil)
            
            // Find the current key window scene to present the share sheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let rootViewController = window.rootViewController {
                // Find the most presented view controller
                var topController = rootViewController
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    // Add new function to check bookmark status
    private func checkBookmarkStatus() {
        let deviceId = GlobalContent.shared.deviceId
        guard !deviceId.starts(with: "unknown-") else { return }
        
        let db = Firestore.firestore()
        let problemsRef = db.collection("solutions")
                            .document(deviceId)
                            .collection("problems")
        
        // Query for the most recent document with this image
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            
            problemsRef
                .whereField("image", isEqualTo: base64Image)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error checking bookmark status: \(error)")
                        return
                    }
                    
                    if let document = querySnapshot?.documents.first {
                        if let bookmark = document.data()["bookmark"] as? Bool {
                            isBookmarked = bookmark
                        }
                    }
                }
        }
    }

    // Add new function to update bookmark in Firestore
    private func updateBookmarkInFirestore() {
        let deviceId = GlobalContent.shared.deviceId
        guard !deviceId.starts(with: "unknown-") else { return }
        
        let db = Firestore.firestore()
        let problemsRef = db.collection("solutions")
                            .document(deviceId)
                            .collection("problems")
        
        // Find and update the document with this image
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            
            problemsRef
                .whereField("image", isEqualTo: base64Image)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error finding document to update: \(error)")
                        return
                    }
                    
                    if let document = querySnapshot?.documents.first {
                        document.reference.updateData([
                            "bookmark": isBookmarked
                        ]) { error in
                            if let error = error {
                                print("Error updating bookmark: \(error)")
                            }
                        }
                    }
                }
        }
    }
    // --- END ADDED placeholder functions ---
}

// MARK: - Preview

struct MathChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            // Replace "MathPlaceholder" with an actual image asset name.
            MathChatView(selectedImage: UIImage(named: "MathPlaceholder") ?? UIImage())
        }
        .preferredColorScheme(.dark)
    }
}
