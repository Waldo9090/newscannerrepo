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
    @State var lastMessage: String = ""
    @State var isTyping: Bool = false
    @State var showCursor: Bool = true
}

struct ChatsView: View {
    @State private var chats: [Chat] = []
    @State private var welcomeText = ""
    @State private var isTyping = true
    @State private var showCursor = true
    let fullText = "Begin a new AI chat to get help with homework or questions.\nJust start a chat to begin!"
    
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
                        HStack(alignment: .top, spacing: 0) {
                            Text(welcomeText)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                            
                            if isTyping {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 2, height: 20)
                                    .opacity(showCursor ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: showCursor)
                            }
                        }
                        .padding()
                        .onAppear {
                            startTypingAnimation()
                            startCursorAnimation()
                        }
                        
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
                                            .font(.title2)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chat.name)
                                                .font(.title3.weight(.semibold))
                                                .foregroundColor(.white)
                                            
                                            if let subject = chat.subject {
                                                Text(subject)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            if chat.isTyping {
                                                HStack(alignment: .top, spacing: 0) {
                                                    Text(chat.lastMessage)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    
                                                    Rectangle()
                                                        .fill(Color.gray)
                                                        .frame(width: 2, height: 12)
                                                        .opacity(chat.showCursor ? 1 : 0)
                                                        .animation(.easeInOut(duration: 0.5).repeatForever(), value: chat.showCursor)
                                                }
                                                .onAppear {
                                                    startCursorAnimation(for: chat)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(UIColor.darkGray))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
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
    
    private func startTypingAnimation() {
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                welcomeText += String(fullText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTyping = false
            }
        }
    }
    
    private func startCursorAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                showCursor.toggle()
            }
            if !isTyping {
                timer.invalidate()
            }
        }
    }
    
    private func startCursorAnimation(for chat: Chat) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                chat.showCursor.toggle()
            }
            if !chat.isTyping {
                timer.invalidate()
            }
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
