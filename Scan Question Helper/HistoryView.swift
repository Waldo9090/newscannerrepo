import SwiftUI

struct HistoryView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Segmented Control
            Picker("", selection: $selectedTab) {
                Text("All").tag(0)
                Text("Bookmarks").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Empty State
            VStack(spacing: 20) {
                Image(systemName: "book.closed")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("Solutions Go Here")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You haven't solved any tasks yet. Let's change that!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Button(action: {
                    // Handle start solving action
                }) {
                    HStack {
                        Text("Start Solving")
                        Image(systemName: "sparkles")
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
            .padding()
            Spacer()
        }
        .background(Color.black)
        .navigationTitle("History")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
        }
    }
} 