import SwiftUI
import UIKit
import QuickLook
import UniformTypeIdentifiers

struct SpaceDetailView: View {
    @State private var space: Project
    @State private var isEditingName = false
    @State private var showingRoomScan = false
    @State private var showingQuickLook = false
    @State private var showingJSONPopup = false
    @State private var jsonData: String = "Loading JSON data..."
    @State private var selectedRoomType: String = "Living Room"
    @State private var roomTypes = ["Bedroom", "Bathroom", "Living Room", "Home Office"]
    
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
                VStack(alignment: .leading, spacing: 16) {
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
                        HStack(alignment: .center, spacing: 8) {
                            Text(space.name)
                                .font(.system(size: 28, weight: .light))
                                .tracking(1)
                            
                            // Edit indicator
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .opacity(0.8)
                        }
                        .onTapGesture {
                            isEditingName = true
                        }
                    }
                    
                    // Room type dropdown
                    Menu {
                        ForEach(roomTypes, id: \.self) { roomType in
                            Button(action: {
                                selectedRoomType = roomType
                            }) {
                                Text(roomType)
                                if selectedRoomType == roomType {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedRoomType)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                        )
                    }
                    
                    Text("Last updated \(space.date, format: .dateTime.month().day().year())")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                )
                .padding(.bottom, 20)
                
                // Space visualization section
                VStack(alignment: .leading, spacing: 24) {
                    // Section header with space layout title
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Space Layout")
                                .font(.system(size: 20, weight: .medium))
                                .tracking(1)
                            Text("Your Architectural Drawings")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Manual entry as small CTA
                        Button(action: {
                            // Action for manual entry
                        }) {
                            Text("Manual Entry")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.9), lineWidth: 0.5)
                                )
                        }
                    }
                    
                    // Primary scan button
                    Button(action: {
                        showingRoomScan = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Start Room Scan")
                                .font(.system(size: 20, weight: .semibold))
                                .tracking(0.5)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                        .background(
                            Color(red: 0.45, green: 0.45, blue: 0.45)
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.vertical, 8)
                    .fullScreenCover(isPresented: $showingRoomScan) {
                        RoomScanView(isPresented: $showingRoomScan)
                    }
                    
                    // Visualization options
                    ZStack {
                        Rectangle()
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .frame(height: 280)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.9), lineWidth: 1)
                            )
                        
                        VStack(spacing: 12) {
                            // 3D Model Button
                            Button(action: {
                                showingQuickLook = true
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "cube.transparent.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("3D Model")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.blue)
                                        
                                        Text("View scanned room")
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .sheet(isPresented: $showingQuickLook) {
                                QuickLookPreview(url: getUSDZFilePath())
                            }
                            
                            // Detailed 3D Model Button
                            Button(action: {
                                let jsonURL = getJSONFilePath()
                                showJSONViewer(for: jsonURL)
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "cube.transparent")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Detailed 3D")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.green)
                                        
                                        Text("Scanned Room With Objects")
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .sheet(isPresented: $showingJSONPopup) {
                                JSONDataView(jsonString: jsonData, isPresented: $showingJSONPopup)
                            }
                            
                            // Plan View Button
                            Button(action: {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    let planViewController = RoomPlanViewController()
                                    planViewController.modalPresentationStyle = .fullScreen
                                    rootViewController.present(planViewController, animated: true)
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "square.split.2x2")
                                        .font(.system(size: 24))
                                        .foregroundColor(.purple)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Plan View")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.purple)
                                        
                                        Text("2D floor plan")
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.purple.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.purple.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.purple.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground).opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                )
                
                // Chat to an AI Designer button (moved above Curated For You section)
                Button(action: {
                    // Action for chatting with AI designer
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                        
                        Text("Lets Design Your Space")
                            .font(.system(size: 16, weight: .medium))
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.85, green: 0.78, blue: 0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.75, green: 0.68, blue: 0.6), lineWidth: 1.5)
                    )
                    .foregroundColor(Color(red: 0.25, green: 0.22, blue: 0.2))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.vertical, 20)
                
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
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground).opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                )
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
    
    private func getJSONFilePath() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("room_data.json")
    }
    
    private func showJSONViewer(for url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            let viewController = UIHostingController(rootView: 
                JSONViewerView(jsonURL: url)
                    .edgesIgnoringSafeArea(.all)
            )
            
            // Present the view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(viewController, animated: true)
            }
        } else {
            // Show an alert that the file doesn't exist
            print("JSON file not found at: \(url.path)")
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

// JSON Data View
struct JSONDataView: View {
    let jsonString: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                if jsonString.starts(with: "Loading") {
                    VStack(spacing: 20) {
                        ProgressView()
                            .padding()
                        Text("Loading JSON data...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if jsonString.starts(with: "Error") || jsonString.starts(with: "JSON file not found") {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(jsonString)
                            .font(.system(.body))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    Text(jsonString)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationBarTitle("Room Data JSON", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
            .onAppear {
                print("JSONDataView appeared with data: \(jsonString.prefix(100))...")
            }
        }
    }
}

// JSON Viewer View
struct JSONViewerView: View {
    let jsonURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        RoomModelViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
    }
}

// SwiftUI wrapper for RoomModelViewController
struct RoomModelViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RoomModelViewController {
        return RoomModelViewController()
    }
    
    func updateUIViewController(_ uiViewController: RoomModelViewController, context: Context) {
        // No updates needed
    }
} 