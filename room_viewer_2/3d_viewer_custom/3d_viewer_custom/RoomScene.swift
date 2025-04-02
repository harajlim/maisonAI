import SwiftUI
import SceneKit

class RoomScene: ObservableObject {
    @Published var scene: SCNScene
    @Published var selectedFile: URL?
    @Published var roomDimensions: RoomDimensions = RoomDimensions()
    
    init() {
        scene = SCNScene()
        setupScene()
    }
    
    struct RoomDimensions {
        var floorY: Double = 0
        var minX: Double = 0
        var maxX: Double = 0
        var minZ: Double = 0
        var maxZ: Double = 0
        var sofaX: Double = 0
        var sofaY: Double = 0
        var sofaZ: Double = 0
        var sofaWidth: Double = 0
        var sofaHeight: Double = 0
        var sofaLength: Double = 0
    }
    
    private func setupScene() {
        // Add ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Add directional light
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 1000
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.position = SCNVector3(x: CGFloat(5), y: CGFloat(5), z: CGFloat(5))
        scene.rootNode.addChildNode(directionalLightNode)
        
        // Add camera
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.name = "camera"  // Add name for camera node
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: CGFloat(0), y: CGFloat(2), z: CGFloat(5))
        cameraNode.eulerAngles = SCNVector3(x: -CGFloat.pi/6, y: CGFloat(0), z: CGFloat(0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func loadRoomFromJSON(url: URL) {
        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access the file")
                return
            }
            
            defer {
                // Make sure we release the security-scoped resource when finished
                url.stopAccessingSecurityScopedResource()
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let room = try decoder.decode(CapturedRoom.self, from: data)
            
            // Clear existing nodes
            scene.rootNode.childNodes.forEach { node in
                if node.light == nil && node.camera == nil {
                    node.removeFromParentNode()
                }
            }
            
            // Create room elements
            createFloors(room.floors)
            createWalls(room.walls)
            createWindows(room.windows)
            createDoors(room.doors)
            // createObjects(room.objects)
            
            // Update room dimensions
            updateRoomDimensions()
            // add a unit sphere at 0,0,0
            let sphere = SCNSphere(radius: 0.125)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
            sphereNode.position = SCNVector3(x: 0, y: -0.95, z: 0)
            
            // Convert local bounding box to world coordinates
            let localMin = sphereNode.boundingBox.min
            let localMax = sphereNode.boundingBox.max
            let worldMin = sphereNode.convertPosition(localMin, to: nil)
            let worldMax = sphereNode.convertPosition(localMax, to: nil)
            
            print("Sphere local bounds: min(\(localMin)), max(\(localMax))")
            print("Sphere world bounds: min(\(worldMin)), max(\(worldMax))")
            
            scene.rootNode.addChildNode(sphereNode)
            
        } catch {
            print("Error loading room JSON: \(error)")
        }
    }
    
    private func createFloors(_ floors: [Floor]) {
        for floor in floors {
            // Create a plane geometry for the floor
            let geometry = SCNPlane(width: CGFloat(floor.dimensions[0]),
                                  height: CGFloat(floor.dimensions[1]))
            
            let material = SCNMaterial()
            material.diffuse.contents = NSColor.lightGray
            material.lightingModel = .constant // Reduces shadow artifacts
            material.isDoubleSided = true // Make the floor visible from both sides
            geometry.materials = [material]
            
            let node = SCNNode(geometry: geometry)
            // Apply the transform which includes both position and orientation
            node.transform = floor.transform.toSCNMatrix4()
            node.name = "floor" // Store category as name
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func createWalls(_ walls: [Wall]) {
        for wall in walls {
            let geometry = SCNBox(width: CGFloat(wall.dimensions[0]),
                                height: CGFloat(wall.dimensions[1]),
                                length: CGFloat(0.1),
                                chamferRadius: CGFloat(0))
            
            let material = SCNMaterial()
            material.diffuse.contents = NSColor.white
            material.lightingModel = .constant // Reduces shadow artifacts
            geometry.materials = [material]
            
            let node = SCNNode(geometry: geometry)
            node.transform = wall.transform.toSCNMatrix4()
            node.name = "wall" // Store category as name
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func createWindows(_ windows: [Window]) {
        for window in windows {
            let geometry = SCNBox(width: CGFloat(window.dimensions[0]),
                                height: CGFloat(window.dimensions[1]),
                                length: CGFloat(0.2), // Slightly thicker
                                chamferRadius: CGFloat(0))
            
            let material = SCNMaterial()
            material.diffuse.contents = NSColor.green
            material.lightingModel = .constant // Reduces shadow artifacts
            geometry.materials = [material]
            
            let node = SCNNode(geometry: geometry)
            var transform = window.transform.toSCNMatrix4()
            // Move window slightly forward from wall
            transform.m43 += 0.05
            node.transform = transform
            node.name = "window" // Store category as name
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func createDoors(_ doors: [Door]) {
        for door in doors {
            let geometry = SCNBox(width: CGFloat(door.dimensions[0]),
                                height: CGFloat(door.dimensions[1]),
                                length: CGFloat(0.2), // Slightly thicker
                                chamferRadius: CGFloat(0))
            
            let material = SCNMaterial()
            material.diffuse.contents = NSColor.brown
            material.lightingModel = .constant // Reduces shadow artifacts
            geometry.materials = [material]
            
            let node = SCNNode(geometry: geometry)
            var transform = door.transform.toSCNMatrix4()
            // Move door slightly forward from wall
            transform.m43 += 0.05
            node.transform = transform
            node.name = "door" // Store category as name
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func createObjects(_ objects: [RoomObject]) {
        for object in objects {
            let geometry = SCNBox(width: CGFloat(object.dimensions[0]),
                                height: CGFloat(object.dimensions[1]),
                                length: CGFloat(object.dimensions[2]),
                                chamferRadius: CGFloat(0.05))
            
            let material = SCNMaterial()
            
            switch object.category {
            case .bed:
                material.diffuse.contents = NSColor.purple.withAlphaComponent(0.8)
            case .storage:
                material.diffuse.contents = NSColor.brown.withAlphaComponent(0.8)
            default:
                material.diffuse.contents = NSColor.gray.withAlphaComponent(0.8)
            }
            
            geometry.materials = [material]
            
            let node = SCNNode(geometry: geometry)
            node.transform = object.transform.toSCNMatrix4()
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func updateRoomDimensions() {
        var dimensions = RoomDimensions()
        var hasSetInitial = false
        
        print("Updating room dimensions...")
        print("Total nodes in scene: \(scene.rootNode.childNodes.count)")
        
        scene.rootNode.childNodes.forEach { node in
            print("Node name: \(node.name ?? "unnamed")")
            print("Node type: \(type(of: node.geometry))")
            
            // Get the node's transform matrix
            let transform = node.transform
            let position = SCNVector3(
                transform.m41,  // X translation
                transform.m42,  // Y translation
                transform.m43   // Z translation
            )
            
            // Get the node's dimensions from its geometry
            var nodeWidth: CGFloat = 0
            var nodeLength: CGFloat = 0
            
            if let box = node.geometry as? SCNBox {
                nodeWidth = box.width
                nodeLength = box.length
            } else if let plane = node.geometry as? SCNPlane {
                nodeWidth = plane.width
                nodeLength = plane.height
            }
            
            // Calculate the corners of the node in world space
            let halfWidth = nodeWidth / 2
            let halfLength = nodeLength / 2
            
            let corners = [
                SCNVector3(position.x - halfWidth, position.y, position.z - halfLength),
                SCNVector3(position.x + halfWidth, position.y, position.z - halfLength),
                SCNVector3(position.x - halfWidth, position.y, position.z + halfLength),
                SCNVector3(position.x + halfWidth, position.y, position.z + halfLength)
            ]
            
            // Update floor Y position
            if node.name == "floor" {
                dimensions.floorY = Double(position.y)
                print("Found floor at Y: \(dimensions.floorY)")
            }
            
            // Update bounds using the corners
            if !hasSetInitial {
                dimensions.minX = Double(corners.map { $0.x }.min() ?? 0)
                dimensions.maxX = Double(corners.map { $0.x }.max() ?? 0)
                dimensions.minZ = Double(corners.map { $0.z }.min() ?? 0)
                dimensions.maxZ = Double(corners.map { $0.z }.max() ?? 0)
                hasSetInitial = true
                print("Initial bounds set")
            } else {
                dimensions.minX = min(dimensions.minX, Double(corners.map { $0.x }.min() ?? 0))
                dimensions.maxX = max(dimensions.maxX, Double(corners.map { $0.x }.max() ?? 0))
                dimensions.minZ = min(dimensions.minZ, Double(corners.map { $0.z }.min() ?? 0))
                dimensions.maxZ = max(dimensions.maxZ, Double(corners.map { $0.z }.max() ?? 0))
            }
        }
        
        print("Final dimensions: \(dimensions)")
        roomDimensions = dimensions
    }
}

struct SceneView: NSViewRepresentable {
    let scene: SCNScene
    
    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = .black
        
        // Add debug options to help with development
        #if DEBUG
        view.debugOptions = [.showWireframe, .showBoundingBoxes]
        #endif
        
        return view
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.scene = scene
    }
} 