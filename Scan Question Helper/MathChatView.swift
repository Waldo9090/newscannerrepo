import SwiftUI
import UIKit

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

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        // Use a ZStack to layer the background color
        ZStack {
            // Lighter overall background color
            Color(red: 1.0, green: 0.99, blue: 0.96) // Slightly lighter peach
                .ignoresSafeArea()
            
            // Main content VStack
            VStack(spacing: 16) { // Added spacing between sections
                // Problem Section in a white blurb - Title now inside
                VStack(alignment: .leading, spacing: 12) {
                    // Title moved inside this VStack
                    HStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        Text("Problem")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding([.top, .horizontal]) // Padding for the title
                    
                    // Divider after title (optional)
                    // Divider().padding(.horizontal)

                    if let userMessage = messages.first(where: { $0.isUser && $0.imageData != nil }),
                       let uiImage = userMessage.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal) // Padding for the image
                            .padding(.bottom) // Padding below image
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top)
                
                // Solution Section in a white blurb - Title now inside
                VStack(alignment: .leading, spacing: 12) {
                     // Title moved inside this VStack
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        Text("Solution")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding([.top, .horizontal]) // Padding for the title

                    // Divider after title (optional)
                    // Divider().padding(.horizontal)

                    // Chat messages scroll view
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(messages.filter { !$0.isUser }) { message in
                                    VStack(alignment: .leading, spacing: 8) {
                                        messageContentView(message: message)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                                    }
                                    .padding(.horizontal)
                                    .id(message.id)
                                }
                                
                                if isLoading && currentBotMessageID == nil {
                                    HStack {
                                        ProgressView()
                                            .padding()
                                        Text("Analyzing your problem...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                }
                                
                                // Add padding at the bottom
                                Spacer()
                                    .frame(height: 80)
                            }
                            .onChange(of: messages) { _ in
                                if let lastMessage = messages.last {
                                    withAnimation {
                                        scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Persistent bottom tab with Rescan button
            VStack(spacing: 0) {
                Spacer() // Pushes button to bottom
                
                HStack { // Wrap button in HStack for padding
                    Button(action: {
                        // Simply dismiss the current view.
                        // If ScanView was presented modally by HomeView,
                        // this *should* eventually dismiss the whole cover.
                        print("Next Problem Tapped - Attempting Dismissal") // Add log
                        presentationMode.wrappedValue.dismiss()
                        
                        // Removed NotificationCenter post - no longer needed for this navigation goal
                        // DispatchQueue.main.async {
                        //     presentationMode.wrappedValue.dismiss()
                        //     NotificationCenter.default.post(name: NSNotification.Name("ResetCameraView"), object: nil)
                        // }
                    }) {
                        HStack {
                            // Correct Icon
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                            // Correct Text
                            Text("Next Problem")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12) // Standard bottom padding
                .background(
                     Color(red: 1.0, green: 0.99, blue: 0.96) // Match the main background
                         .edgesIgnoringSafeArea(.bottom)
                 )
            }
        }
        .navigationTitle("Math Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            addUserImageMessage()
            fetchSolution()
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
                Text(text)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
}

// MARK: - Preview

struct MathChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            // Replace "MathPlaceholder" with an actual image asset name.
            MathChatView(selectedImage: UIImage(named: "MathPlaceholder") ?? UIImage())
        }
        .preferredColorScheme(.light)
    }
}
