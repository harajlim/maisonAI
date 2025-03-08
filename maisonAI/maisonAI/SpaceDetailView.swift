import SwiftUI

struct SpaceDetailView: View {
    let space: Project
    @State private var isEditingGoals = false
    @State private var showingRoomPlanView = false
    
    // These would be populated from a real API in the future
    @State private var spaceGoals = "Create a minimalist, functional space with natural light and organic materials."
    @State private var inspirationImages = ["inspiration1", "inspiration2", "inspiration3"]
    @State private var designElements = [
        DesignElement(name: "Scandinavian Sofa", description: "Light oak frame with natural linen upholstery", image: "square.grid.2x2"),
        DesignElement(name: "Pendant Light", description: "Matte black metal with exposed bulb", image: "square.grid.3x3"),
        DesignElement(name: "Area Rug", description: "Hand-woven wool in neutral tones", image: "square.grid.4x3.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(space.name)
                        .font(.system(size: 28, weight: .light))
                        .tracking(1)
                    
                    Text("Last updated \(space.date, format: .dateTime.month().day().year())")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Space visualization section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Space Layout", actionTitle: "Edit") {
                        showingRoomPlanView = true
                    }
                    
                    // Placeholder for 3D model/floor plan
                    ZStack {
                        Rectangle()
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .frame(height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                        
                        VStack(spacing: 12) {
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("3D Model / Floor Plan")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Tap to view or edit")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                    }
                    .onTapGesture {
                        showingRoomPlanView = true
                    }
                }
                
                // Goals section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Design Goals", actionTitle: "Edit") {
                        isEditingGoals = true
                    }
                    
                    if isEditingGoals {
                        TextEditor(text: $spaceGoals)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                    } else {
                        Text(spaceGoals)
                            .font(.system(size: 16, weight: .light))
                            .lineSpacing(6)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                    
                    if isEditingGoals {
                        HStack {
                            Spacer()
                            Button("Save") {
                                isEditingGoals = false
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Inspiration images
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Inspiration", actionTitle: "Add") {
                        // Action to add inspiration images
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // In a real app, these would be actual images
                            ForEach(0..<3, id: \.self) { _ in
                                ZStack {
                                    Rectangle()
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                        .frame(width: 200, height: 150)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                        )
                                    
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Add inspiration button
                            ZStack {
                                Rectangle()
                                    .fill(Color(UIColor.tertiarySystemBackground))
                                    .frame(width: 100, height: 150)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                    )
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
                // Design elements/pieces
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Design Elements", actionTitle: "Add") {
                        // Action to add design elements
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(designElements) { element in
                            DesignElementRow(element: element)
                        }
                    }
                }
                
                // Generate design button
                Button(action: {
                    // Action for generating design
                }) {
                    Text("Generate Design")
                        .font(.system(size: 16, weight: .medium))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
                        )
                        .foregroundColor(.blue)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.vertical, 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Share or export action
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .sheet(isPresented: $showingRoomPlanView) {
            RoomPlanPlaceholderView()
        }
    }
}

// Supporting Views
struct SectionHeader: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .tracking(1)
            
            Spacer()
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
        }
    }
}

struct DesignElement: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String // In a real app, this would be an actual image
}

struct DesignElementRow: View {
    let element: DesignElement
    
    var body: some View {
        HStack(spacing: 16) {
            // Element image
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(width: 80, height: 80)
                
                Image(systemName: element.image)
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            
            // Element details
            VStack(alignment: .leading, spacing: 4) {
                Text(element.name)
                    .font(.system(size: 16, weight: .medium))
                
                Text(element.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Edit button
            Button(action: {
                // Edit action
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// Placeholder for RoomPlan API integration
struct RoomPlanPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("RoomPlan View")
                .font(.system(size: 24, weight: .medium))
            
            Text("This is where the 3D model from RoomPlan API would be displayed")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 100)
    }
}

// Preview
struct SpaceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpaceDetailView(space: sampleProjects[0])
        }
    }
} 