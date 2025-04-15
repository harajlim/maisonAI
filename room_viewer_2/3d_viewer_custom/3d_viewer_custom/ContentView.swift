//
//  ContentView.swift
//  3d_viewer_custom
//
//  Created by Marwan Harajli on 3/24/25.
//

import SwiftUI
import AppKit
import SceneKit
import UniformTypeIdentifiers

// Register USDZ file type
extension UTType {
    static var usdz: UTType {
        UTType(exportedAs: "com.pixar.universal-scene-description-mobile")
    }
}

struct ContentView: View {
    @StateObject private var roomScene = RoomScene()
    @State private var isFilePickerPresented = false
    @State private var isRoomPickerPresented = false
    @State private var hasRoomAdded = false
    @State private var isPlanView: Bool = false // State for view mode
    
    // State variables for object manipulation
    @State private var targetObjectName: String = "id_123" // Default to the hardcoded name
    @State private var displacementX: String = "0.0"
    @State private var displacementZ: String = "0.0"
    @State private var rotationY: String = "0.0" // Degrees
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                HStack {
                    Button("Select 3D Model") {
                        print("Select 3D Model button clicked")
                        print("hasRoomAdded = \(hasRoomAdded)")
                        selectUSDZFile()
                    }
                    .disabled(!hasRoomAdded)
                    .help(hasRoomAdded ? "Select a USDZ 3D model to add to the room" : "Please add a room first")
                    
                    Button("Add Room") {
                        print("Add Room button clicked")
                        selectJSONFile()
                    }
                    .help("Load a room layout from a JSON file")
                    .padding(.leading)
                }
                .padding(.horizontal)
                .padding(.top)

                // Add Toggle for Plan View
                Toggle("Plan View", isOn: $isPlanView)
                    .toggleStyle(.switch)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .disabled(!hasRoomAdded)
                    .onChange(of: isPlanView) { newValue in
                        roomScene.setPlanView(newValue)
                    }

                if hasRoomAdded {
                    SceneView(roomScene: roomScene, scene: roomScene.scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Text("No room selected")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Text("Please click 'Add Room' to load a room layout first")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
            }
            
            if hasRoomAdded {
                VStack(spacing: 20) { // Added spacing between panels
                    // --- Room Dimensions Panel ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Room Dimensions")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            DimensionRow(label: "Floor Y:", value: roomScene.roomDimensions.floorY)
                            DimensionRow(label: "Min X:", value: roomScene.roomDimensions.minX)
                            DimensionRow(label: "Max X:", value: roomScene.roomDimensions.maxX)
                            DimensionRow(label: "Min Z:", value: roomScene.roomDimensions.minZ)
                            DimensionRow(label: "Max Z:", value: roomScene.roomDimensions.maxZ)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            Text("Sofa Position")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            
                            DimensionRow(label: "X:", value: roomScene.roomDimensions.sofaX)
                            DimensionRow(label: "Y:", value: roomScene.roomDimensions.sofaY)
                            DimensionRow(label: "Z:", value: roomScene.roomDimensions.sofaZ)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            Text("Sofa Dimensions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            
                            DimensionRow(label: "Width:", value: roomScene.roomDimensions.sofaWidth)
                            DimensionRow(label: "Height:", value: roomScene.roomDimensions.sofaHeight)
                            DimensionRow(label: "Length:", value: roomScene.roomDimensions.sofaLength)
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                    // Removed bottom padding to move it up
                    
                    // --- Object Manipulation Panel ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Object Manipulation")
                            .font(.headline)
                        
                        TextField("Object Name", text: $targetObjectName)
                        
                        HStack {
                            Text("Disp. X:")
                            TextField("0.0", text: $displacementX)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Disp. Z:")
                            TextField("0.0", text: $displacementZ)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Rot. Y (°):")
                            TextField("0.0", text: $rotationY)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Button("Apply Transformation") {
                            applyTransformation()
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // Center button
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                    
                    Spacer() // Pushes panels towards the top
                }
                .padding() // Add padding around the VStack containing both panels
                .frame(width: 250) // Increased width for the side panel
            }
        }
    }
    
    private func selectUSDZFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.usdz]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                print("Selected USDZ file: \(url.path)")
                if let modelNode = USDZModelLoader.loadUSDZ(from: url) {
                    print("Successfully loaded USDZ model")
                    print("Model bounds: \(modelNode.boundingBox)")
                    print("Model position: \(modelNode.position)")
                    
                    let boundingBox = modelNode.boundingBox
                    let center = SCNVector3(
                        (boundingBox.max.x + boundingBox.min.x) / 2,
                        (boundingBox.max.y + boundingBox.min.y) / 2,
                        (boundingBox.max.z + boundingBox.min.z) / 2
                    )
                    
                    // Scale the model if needed
                    let scale = 1.0  // or whatever scaling logic you want
                    modelNode.scale = SCNVector3(scale, scale, scale)
                    
                    // Calculate the scaled offset from origin to bottom
                    let bottomOffset = boundingBox.min.y * scale
                    
                    // Position the model with automatic bottom alignment
                    let position = SCNVector3(
                        x: -center.x * scale,
                        y: roomScene.roomDimensions.floorY - bottomOffset, // This automatically adjusts for any origin position
                        z: -center.z * scale
                    )
                    modelNode.position = position
                    
                    // Store sofa coordinates
                    roomScene.roomDimensions.sofaX = Double(position.x)
                    roomScene.roomDimensions.sofaY = Double(position.y)
                    roomScene.roomDimensions.sofaZ = Double(position.z)
                    
                    // Store sofa dimensions
                    roomScene.roomDimensions.sofaWidth = Double((boundingBox.max.x - boundingBox.min.x) * scale)
                    roomScene.roomDimensions.sofaHeight = Double((boundingBox.max.y - boundingBox.min.y) * scale)
                    roomScene.roomDimensions.sofaLength = Double((boundingBox.max.z - boundingBox.min.z) * scale)
                    // give model a name
                    modelNode.name = "id_123"
                    // Set the default target name when a new model is loaded
                    targetObjectName = modelNode.name ?? "id_123"
                    roomScene.scene.rootNode.addChildNode(modelNode)
                    
                    // Adjust camera to view the model
                    if let cameraNode = roomScene.scene.rootNode.childNode(withName: "camera", recursively: true) {
                        cameraNode.position = SCNVector3(x: 0, y: 2, z: 5)
                        cameraNode.eulerAngles = SCNVector3(x: -CGFloat.pi/6, y: 0, z: 0)
                    }
                } else {
                    print("Failed to load USDZ model")
                    // Show error to user
                    let alert = NSAlert()
                    alert.messageText = "Failed to Load Model"
                    alert.informativeText = "The selected file could not be loaded as a USDZ model. Please make sure you selected a valid USDZ file."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }
    
    private func selectJSONFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                roomScene.selectedFile = url
                roomScene.loadRoomFromJSON(url: url)
                hasRoomAdded = true
                print("Room added, hasRoomAdded set to \(hasRoomAdded)")
            }
        }
    }
    
    private func applyTransformation() {
        guard let node = roomScene.scene.rootNode.childNode(withName: targetObjectName, recursively: true) else {
            print("Error: Node with name '\(targetObjectName)' not found.")
            // Optionally show an alert to the user
            return
        }

        // Use NumberFormatter for safer string-to-double conversion
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let dx = formatter.number(from: displacementX)?.doubleValue ?? 0.0
        let dz = formatter.number(from: displacementZ)?.doubleValue ?? 0.0
        let rotYDegrees = formatter.number(from: rotationY)?.doubleValue ?? 0.0

        // Convert degrees to radians for SceneKit
        let rotYRadians = CGFloat(rotYDegrees * .pi / 180.0)

        print("Applying transformation to node '\(targetObjectName)':")
        print("  Current Position: \(node.position)")
        print("  Displacement: (X: \(dx), Z: \(dz))")
        print("  Current Euler Angles: \(node.eulerAngles)")
        print("  Rotation Y (degrees): \(rotYDegrees)")

        // Apply relative translation
        let translation = SCNVector3(dx, 0, dz) // Only displace in X and Z
        node.localTranslate(by: translation)

        // Apply relative rotation around the Y axis
        // Create a rotation quaternion around the Y axis
        let rotationQuaternion = SCNQuaternion(x: 0, y: sin(rotYRadians / 2), z: 0, w: cos(rotYRadians / 2))
        // Combine with existing rotation
        node.localRotate(by: rotationQuaternion)

        print("  New Position: \(node.position)")
        print("  New Euler Angles: \(node.eulerAngles)")

        // Update the displayed Sofa Position (if the transformed object IS the sofa)
        // This assumes the manipulated object's position should update the display.
        // You might need more robust logic if multiple objects can be manipulated.
        if targetObjectName == "id_123" { // Or however you identify the "sofa"
             // Update the RoomDimensions based on the node's *world* position after transformation
             let worldPosition = node.worldPosition
             roomScene.roomDimensions.sofaX = Double(worldPosition.x)
             roomScene.roomDimensions.sofaY = Double(worldPosition.y)
             roomScene.roomDimensions.sofaZ = Double(worldPosition.z)
         }
    }
}

struct DimensionRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f", value))
                .monospacedDigit()
        }
    }
}

#Preview {
    ContentView()
}
