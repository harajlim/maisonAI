import SwiftUI

struct LandingView: View {
    @State private var showMenu = false
    @State private var projects: [Project] = sampleProjects
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Artistic background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Abstract artistic element
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AbstractArtView()
                            .frame(width: 300, height: 300)
                            .opacity(0.15)
                            .offset(x: 50, y: 50)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        // Header with minimalist title
                        VStack(spacing: 16) {
                            Text("MaisonAI")
                                .font(.system(size: 38, weight: .light, design: .default))
                                .tracking(4)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("Creating spaces that inspire, where every detail tells your story.")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 70)
                        .padding(.bottom, 30)
                        
                        // New Project Button - minimalist
                        NavigationLink {
                            SpaceDetailView(space: Project(name: "New Space", date: Date(), thumbnail: "square.grid.2x2", color: .black))
                        } label: {
                            HStack {
                                Text("Design New Space")
                                    .font(.system(size: 16, weight: .medium))
                                    .tracking(1)
                                Spacer()
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 22)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        Color(red: 0.85, green: 0.78, blue: 0.7)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.75, green: 0.68, blue: 0.6), lineWidth: 1.5)
                            )
                            .foregroundColor(Color(red: 0.25, green: 0.22, blue: 0.2))
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.bottom, 30)
                        
                        // Projects Section - minimalist grid
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Your Designed Spaces")
                                .font(.system(size: 20, weight: .medium))
                                .tracking(1)
                                .padding(.top, 20)
                            
                            if projects.isEmpty {
                                EmptyProjectsView()
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 20)], spacing: 20) {
                                    ForEach(projects) { project in
                                        NavigationLink {
                                            SpaceDetailView(space: project)
                                        } label: {
                                            ProjectCard(project: project)
                                                .frame(height: 200)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showMenu) {
                MenuView()
            }
        }
    }
}

// Supporting Views and Models
struct Project: Identifiable {
    var id = UUID()
    var name: String
    var date: Date
    var thumbnail: String // System image name
    var color: Color
}

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Project thumbnail - minimalist
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(height: 140)
                
                Image(systemName: project.thumbnail)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(project.color.opacity(0.8))
                    .padding(16)
            }
            
            // Project details - minimalist
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Text(project.date, style: .date)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("No spaces yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Text("Begin crafting the spaces that reflect your vision")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(["Spaces", "Gallery", "Materials", "Settings", "About Us"], id: \.self) { item in
                    Text(item)
                        .font(.system(size: 18, weight: .light))
                        .tracking(1)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(30)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

// Abstract art view for background
struct AbstractArtView: View {
    var body: some View {
        ZStack {
            // Circle elements
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.2),
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 100 + CGFloat(i * 60))
            }
            
            // Line elements
            ForEach(0..<5) { i in
                let angle = Double(i) * 36.0
                Line()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: 200, height: 1)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// Custom button style with subtle scale effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Sample data
let sampleProjects = [
    Project(name: "Daughter's Bedroom", date: Date().addingTimeInterval(-86400 * 2), thumbnail: "bed.double.fill", color: .black),
    // Project(name: "Urban Retreat", date: Date().addingTimeInterval(-86400 * 7), thumbnail: "square.grid.3x3", color: .black),
    // Project(name: "Creative Haven", date: Date().addingTimeInterval(-86400 * 14), thumbnail: "square.grid.4x3.fill", color: .black),
    // Project(name: "Minimalist Oasis", date: Date().addingTimeInterval(-86400 * 21), thumbnail: "square.grid.2x2.fill", color: .black)
]

#Preview {
    LandingView()
} 
