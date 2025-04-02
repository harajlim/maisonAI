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
                .padding()
                
                if hasRoomAdded {
                    SceneView(scene: roomScene.scene)
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
                .frame(width: 200)
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
                .padding()
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
