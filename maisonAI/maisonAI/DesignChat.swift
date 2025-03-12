import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct DesignChat: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @FocusState private var isInputFocused: Bool
    @State private var splitPosition: CGFloat = 0.7 // Default split at 70%
    @GestureState private var dragState: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Chat UI in top portion
                    VStack {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(messages) { message in
                                        ChatBubble(message: message)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .onAppear {
                                scrollProxy = proxy
                                // Add welcome message
                                if messages.isEmpty {
                                    messages.append(ChatMessage(
                                        content: "Hi! I'm your AI design assistant. I can help you design your space and answer any questions about the 3D model below. What would you like to know?",
                                        isUser: false,
                                        timestamp: Date()
                                    ))
                                }
                            }
                        }
                        
                        // Message input
                        HStack(spacing: 12) {
                            TextField("Message", text: $newMessage)
                                .padding(12)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                )
                                .focused($isInputFocused)
                            
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                            .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemBackground))
                    }
                    .frame(height: geometry.size.height * splitPosition)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                    
                    // Draggable divider
                    DraggableDivider()
                        .gesture(
                            DragGesture()
                                .updating($dragState) { value, state, _ in
                                    state = value.translation.height
                                }
                                .onEnded { value in
                                    let heightChange = value.translation.height
                                    let totalHeight = geometry.size.height
                                    let newSplitPosition = splitPosition + (heightChange / totalHeight)
                                    
                                    // Limit the split position between 30% and 90%
                                    splitPosition = min(max(newSplitPosition, 0.3), 0.9)
                                }
                        )
                    
                    // 3D Model viewer in bottom portion
                    RoomModelViewControllerRepresentable()
                        .frame(height: geometry.size.height * (1 - splitPosition))
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MaisonAI")
                        .font(.system(size: 20, weight: .semibold))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: trimmedMessage, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear input and dismiss keyboard
        newMessage = ""
        isInputFocused = false
        
        // Scroll to bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(userMessage.id, anchor: .bottom)
            }
        }
        
        // TODO: Add AI response handling here
        // For now, just add a mock response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiMessage = ChatMessage(
                content: "I understand you're interested in designing this space. I can see the 3D model and help you make the most of it. What specific aspects would you like to focus on?",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            
            // Scroll to bottom again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    scrollProxy?.scrollTo(aiMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(UIColor.tertiarySystemBackground))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

// Custom draggable divider view
struct DraggableDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 4)
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)
            )
            .overlay(
                Image(systemName: "minus")
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold))
            )
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Makes the entire area draggable
    }
}

#Preview {
    DesignChat()
} 