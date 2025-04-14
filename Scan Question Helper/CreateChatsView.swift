import SwiftUI

struct CreateChatsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var chats: [Chat]
    
    @State private var selectedTab: Int = 0
    @State private var chatName: String = ""
    @State private var selectedSubjects: Set<String> = []
    
    let subjects = [
        ("Math", "sum"),
        ("Science", "flask"),
        ("History", "book"),
        ("Music", "music.note"),
        ("Art", "paintpalette"),
        ("PE", "sportscourt"),
        ("Language", "globe"),
        ("Computer Science", "desktopcomputer")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with Back Button and Title
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.purple)
                            .font(.title2)
                    }
                    Spacer()
                    Text("Create Chat")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    // Invisible element to balance the layout
                    Image(systemName: "arrow.left")
                        .opacity(0)
                        .font(.title2)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Segmented Control for Chat Types
                Picker("Chat Type", selection: $selectedTab) {
                    Text("General Chats").tag(0)
                    Text("Subjects Chats").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Chat Icon
                Image(systemName: "text.bubble.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.purple)
                    .padding(.top)
                
                // Chat Name TextField with a Card-like background
                TextField("Enter chat name", text: $chatName)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Subjects Selection (only for Subject Chats)
                if selectedTab == 1 {
                    ScrollView {
                        // Using a LazyVGrid for a grid-like layout
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(subjects, id: \.0) { subject in
                                Button(action: {
                                    toggleSelection(for: subject.0)
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: subject.1)
                                            .font(.title)
                                            .foregroundColor(selectedSubjects.contains(subject.0) ? .purple : .gray)
                                        Text(subject.0)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSubjects.contains(subject.0) ? Color.purple.opacity(0.2) : Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
                
                // Create Button
                Button(action: {
                    // If it's a subject chat, pass the first selected subject (adjust as needed)
                    let subject = selectedTab == 1 ? selectedSubjects.first : nil
                    let newChat = Chat(name: chatName, icon: "text.bubble.fill", color: .purple, subject: subject)
                    chats.append(newChat)
                    dismiss()
                }) {
                    Text("Create")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(chatName.isEmpty ? Color.gray : Color.purple)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(chatName.isEmpty)
            }
            .padding(.vertical)
            .background(Color.black.ignoresSafeArea())
        }
        // Use a stack navigation view style to keep the design consistent on iPad and iPhone.
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func toggleSelection(for subject: String) {
        if selectedSubjects.contains(subject) {
            selectedSubjects.remove(subject)
        } else {
            selectedSubjects.insert(subject)
        }
    }
}
