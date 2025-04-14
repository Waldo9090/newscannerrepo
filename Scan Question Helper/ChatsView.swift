//
//  ChatsView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI

struct Chat: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let subject: String? // Optional, for subject-specific chats
}

struct ChatsView: View {
    @State private var chats: [Chat] = [
        // For testing, you might add some sample chats:
        // Uncomment the below line to test the “non-empty” state.
        // Chat(name: "Math Tutor", icon: "plus.circle", color: .blue, subject: "Mathematics")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Top header with improved styling
                HStack {
                    Spacer()
                    Text("Your Chats")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                Spacer()
                
                if chats.isEmpty {
                    VStack {
                        Spacer()
                        Text("Begin a new AI chat to get help with homework or questions.\nJust start a chat to begin!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding()
                        
                        NavigationLink(destination: CreateChatsView(chats: $chats)
                                        .navigationBarBackButtonHidden(true)) {
                            Text("New Chat")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                } else {
                    // Chat list
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(chats) { chat in
                                NavigationLink(destination: ChatBotView(
                                    systemPrompt: tutorPrompt(for: chat),
                                    initialMessage: "Hello! I'm here to help with \(chat.subject ?? chat.name). What do you need assistance with today?",
                                    existingChatHistory: nil
                                )) {
                                    HStack {
                                        Image(systemName: chat.icon)
                                            .foregroundColor(chat.color)
                                            .font(.title2) // Smaller icon size
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chat.name)
                                                .font(.title3.weight(.semibold)) // Slightly smaller title
                                                .foregroundColor(.white)
                                            
                                            if let subject = chat.subject {
                                                Text(subject)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Right arrow indicator
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(UIColor.darkGray))
                                    .cornerRadius(10)
                                    .padding(.horizontal) // Optional: adds some horizontal spacing around each cell
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // "New Chat" button appears here as well
                    NavigationLink(destination: CreateChatsView(chats: $chats)
                                    .navigationBarBackButtonHidden(true)) {
                        Text("New Chat")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
    
    /// Returns the system prompt for ChatBotView based on the chat subject.
    private func tutorPrompt(for chat: Chat) -> String {
        if let subject = chat.subject, !subject.isEmpty {
            return "You are a tutor for \(subject). Please give a step-by-step explanation for each solution you give and explain it to the user."
        } else {
            return "You are a tutor. Please give a step-by-step explanation for each solution you give and explain it to the user."
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
