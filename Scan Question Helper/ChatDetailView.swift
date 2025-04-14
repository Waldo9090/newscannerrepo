import SwiftUI
import AVFoundation

struct MathChatMessage: Identifiable, Codable {
    let id: UUID = UUID()
    let role: String  // "user" or "assistant"
    let content: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [MathChatMessage] = []
    @Published var isLoading: Bool = false
    
    init() {
        let initialMessage = MathChatMessage(
            role: "assistant",
            content: "Hi! I'm your math assistant. Ask me any math question, and I'll help you solve it step by step."
        )
        self.messages = [initialMessage]
    }
    
    func sendMessage(_ text: String) {
        let userMessage = MathChatMessage(role: "user", content: text)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
            self.isLoading = true
        }
        
        let systemPrompt = """
        You are an expert math tutor assistant.
        Provide clear, step-by-step explanations for mathematical problems.
        Break down complex concepts into simpler parts.
        Use mathematical notation when appropriate.
        If a question is unclear, ask for clarification.
        Always show your work and explain your reasoning.
        """
        
        let requestMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": text]
        ]
        
        let jsonBody: [String: Any] = [
            "model": "gpt-4",
            "messages": requestMessages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.messages.append(MathChatMessage(role: "assistant", content: "Error: Could not serialize request body."))
            }
            return
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.messages.append(MathChatMessage(role: "assistant", content: "Error: Invalid URL."))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let assistantReply = decodedResponse.choices.first?.message.content {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.messages.append(MathChatMessage(role: "assistant", content: assistantReply))
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.messages.append(MathChatMessage(role: "assistant", content: "Error: No reply from assistant."))
                        }
                    }
                } else {
                    let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.messages.append(MathChatMessage(role: "assistant", content: "Error: \(errorResponse)"))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.messages.append(MathChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)"))
                }
            }
        }
    }
}

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @State private var userInput = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Math Assistant")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.black)
            
            // Chat messages list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        if message.role == "assistant" {
                            HStack(alignment: .top, spacing: 8) {
                                // Bot avatar
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                    .frame(width: 28, height: 28)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                
                                // Bot message
                                Text(message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .foregroundColor(.white)
                                    .background(Color.gray.opacity(0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        } else {
                            // User message with neon purple background
                            HStack {
                                Spacer()
                                Text(message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .foregroundColor(.black)
                                    .background(Color(red: 0.8, green: 0.2, blue: 1.0))  // Bright neon purple
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if viewModel.isLoading {
                        HStack(alignment: .center, spacing: 8) {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.purple.opacity(0.8))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.purple.opacity(0.6))
                                .frame(width: 8, height: 8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical)
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Ask your math question...", text: $userInput)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.35))
                    .foregroundColor(.white)
                    .accentColor(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        HStack {
                            Spacer()
                            if !userInput.isEmpty {
                                Button(action: {
                                    userInput = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 12)
                                }
                            }
                        }
                    )
                
                Button(action: {
                    let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    viewModel.sendMessage(text)
                    userInput = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.7))
                        .clipShape(Circle())
                        .shadow(color: Color.white.opacity(0.2), radius: 5, x: 0, y: 3)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.black)
        }
        .background(Color.black)
    }
}

// MARK: - OpenAI Response Model
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView()
    }
} 
