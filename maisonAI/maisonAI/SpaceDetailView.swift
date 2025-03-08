import SwiftUI
import UIKit
import QuickLook
import UniformTypeIdentifiers

struct SpaceDetailView: View {
    @State private var space: Project
    @State private var isEditingName = false
    @State private var showingRoomScan = false
    @State private var showingQuickLook = false
    
    // These would be populated from a real API in the future
    @State private var spaceGoals = "Create a minimalist, functional space with natural light and organic materials."
    @State private var inspirationImages = ["inspiration1", "inspiration2", "inspiration3"]
    @State private var designElements: [DesignElement] = []
    
    init(space: Project) {
        _space = State(initialValue: space)
        
        // Only populate design elements for existing spaces (not "New Space")
        if space.name != "New Space" {
            _designElements = State(initialValue: [
                DesignElement(name: "Scandinavian Sofa", description: "Light oak frame with natural linen upholstery", image: "square.grid.2x2"),
                DesignElement(name: "Pendant Light", description: "Matte black metal with exposed bulb", image: "square.grid.3x3"),
                DesignElement(name: "Area Rug", description: "Hand-woven wool in neutral tones", image: "square.grid.4x3.fill")
            ])
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                // Header with editable name
                VStack(alignment: .leading, spacing: 8) {
                    if isEditingName {
                        TextField("Space Name", text: $space.name)
                            .font(.system(size: 28, weight: .light))
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                            .onSubmit {
                                isEditingName = false
                            }
                    } else {
                        Text(space.name)
                            .font(.system(size: 28, weight: .light))
                            .tracking(1)
                            .onTapGesture {
                                isEditingName = true
                            }
                    }
                    
                    Text("Last updated \(space.date, format: .dateTime.month().day().year())")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Space visualization section
                VStack(alignment: .leading, spacing: 24) {
                    // Section header with space layout title
                    HStack(alignment: .center) {
                        Text("Space Layout")
                            .font(.system(size: 20, weight: .medium))
                            .tracking(1)
                        
                        Spacer()
                        
                        // Manual entry as small CTA
                        Button(action: {
                            // Action for manual entry
                        }) {
                            Text("Manual Entry")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Primary scan button
                    Button(action: {
                        showingRoomScan = true
                    }) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 16, weight: .medium))
                            Text("Start Room Scan")
                                .font(.system(size: 16, weight: .medium))
                                .tracking(0.5)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
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
                    .fullScreenCover(isPresented: $showingRoomScan) {
                        RoomScanView(isPresented: $showingRoomScan)
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
                        
                        if FileManager.default.fileExists(atPath: getUSDZFilePath().path) {
                            Button(action: {
                                showingQuickLook = true
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "cube.transparent.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    
                                    Text("View 3D Model")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                    
                                    Text("Tap to view your scanned room")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .sheet(isPresented: $showingQuickLook) {
                                QuickLookPreview(url: getUSDZFilePath())
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "cube.transparent")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("3D Model / Floor Plan")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("Create a floor plan to visualize your space")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                
                // Goals section - directly editable
                VStack(alignment: .leading, spacing: 16) {
                    Text("Design Goals")
                        .font(.system(size: 20, weight: .medium))
                        .tracking(1)
                    
                    TextEditor(text: $spaceGoals)
                        .font(.system(size: 16, weight: .light))
                        .lineSpacing(6)
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
                
                // Curated items section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Curated For You", actionTitle: designElements.isEmpty ? "" : "Add") {
                        // Action to add design elements
                    }
                    
                    if !designElements.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(designElements) { element in
                                DesignElementRow(element: element)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No items curated yet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text("Add design goals and inspiration to get personalized recommendations")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                
                // Generate/Update design button
                Button(action: {
                    // Action for generating/updating design
                }) {
                    Text(designElements.isEmpty ? "Curate For Me" : "Update Curated Items")
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
    }
    
    private func getUSDZFilePath() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("roomscan_processed.usdz")
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
            
            if !actionTitle.isEmpty {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
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

// Simple wrapper for RoomScanViewController
struct RoomScanView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: RoomScanView
        var roomScanVC: RoomScanViewController!
        
        init(_ parent: RoomScanView) {
            self.parent = parent
        }
        
        @objc func dismissView() {
            roomScanVC.closeButtonTapped(roomScanVC)
            parent.isPresented = false
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Create a container view that will hold both the RoomScanViewController and the close button
        let roomScanVC = RoomScanViewController()
        context.coordinator.roomScanVC = roomScanVC
        viewController.addChild(roomScanVC)
        roomScanVC.view.frame = viewController.view.bounds
        viewController.view.addSubview(roomScanVC.view)
        roomScanVC.didMove(toParent: viewController)
        
        // Start the room scan
        roomScanVC.startRoomScanButtonTapped(roomScanVC)
        
        // Add a close button directly to the view controller's view
        let closeButton = UIButton(frame: CGRect(x: 20, y: 60, width: 60, height: 60))
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 30
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 4
        closeButton.layer.shadowOpacity = 0.5
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.dismissView), for: .touchUpInside)
        
        viewController.view.addSubview(closeButton)
        viewController.view.bringSubviewToFront(closeButton)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update
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

// Replace with a nicer QuickLook preview with better styling
struct QuickLookPreview: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark background instead of white
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // QuickLook preview with styling
            QuickLookWrapper(url: url)
            
            // Overlay a dismiss button at the top-left with improved visibility
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .shadow(color: .black, radius: 3)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50) // Push it down from the very top
                        .padding(.leading, 20)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                Spacer()
                
                // Add a footer with instructions
                Text("Pinch to zoom • Drag to rotate")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Enhanced wrapper for QuickLook
struct QuickLookWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        
        // Force dark appearance for the QuickLook controller
        controller.overrideUserInterfaceStyle = .dark
        
        // Apply styling to make the background dark
        controller.view.backgroundColor = .black
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookWrapper
        
        init(_ parent: QuickLookWrapper) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as QLPreviewItem
        }
    }
} 