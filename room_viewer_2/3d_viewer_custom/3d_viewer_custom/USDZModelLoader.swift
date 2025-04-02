import Foundation
import SceneKit

class USDZModelLoader {
    static func loadUSDZ(from url: URL) -> SCNNode? {
        print("Attempting to load USDZ file from: \(url.path)")
        
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access the USDZ file")
            return nil
        }
        
        defer {
            // Make sure we release the security-scoped resource when finished
            url.stopAccessingSecurityScopedResource()
            print("Released security-scoped resource")
        }
        
        do {
            print("Creating SCNScene from USDZ file...")
            let scene = try SCNScene(url: url, options: nil)
            print("Successfully created SCNScene")
            print("Scene root node has \(scene.rootNode.childNodes.count) child nodes")
            return scene.rootNode
        } catch {
            print("Error loading USDZ file: \(error)")
            print("Error details: \(error.localizedDescription)")
            return nil
        }
    }
} 