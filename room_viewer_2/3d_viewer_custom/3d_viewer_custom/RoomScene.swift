import SwiftUI
import SceneKit

class RoomScene: ObservableObject {
    @Published var scene: SCNScene
    @Published var selectedFile: URL?
    @Published var roomDimensions: RoomDimensions = RoomDimensions()
    @Published var scnView: SCNView? // Reference to the SCNView
    
    // Store default camera state for perspective view
    private var defaultCameraPosition = SCNVector3(x: CGFloat(0), y: CGFloat(2), z: CGFloat(5))
    private var defaultCameraEulerAngles = SCNVector3(x: -CGFloat.pi/6, y: CGFloat(0), z: CGFloat(0))
    
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
        // Use stored defaults for initial setup
        cameraNode.position = defaultCameraPosition
        cameraNode.eulerAngles = defaultCameraEulerAngles
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
            
            // Clear existing non-essential nodes (lights, camera, axes, labels)
             let nodesToRemove = scene.rootNode.childNodes.filter { node in
                 // Keep lights and camera
                 if node.light != nil || node.camera != nil { return false }
                 // Keep nodes not related to axes/labels (e.g., loaded models, room geometry before it's re-added)
                 if node.name != "axisX" && node.name != "axisZ" && node.name != "axisXLabel" && node.name != "axisZLabel" {
                     // We also need to keep the actual room geometry nodes until they are replaced
                     // Assuming they have names like "floor", "wall", etc.
                     // Or perhaps better to clear *everything* except light/camera before creating room elements?
                     // For now, let's just target axes/labels explicitly for removal.
                     return false // Keep nodes that aren't axes or labels
                 }
                 // Otherwise, mark for removal (it's an axis or an axis label)
                 return true
             }
             nodesToRemove.forEach { $0.removeFromParentNode() }

            // Create room elements
            createFloors(room.floors)
            createWalls(room.walls)
            createWindows(room.windows)
            createDoors(room.doors)
            // createObjects(room.objects)
            
            // Update room dimensions
            updateRoomDimensions()
            // Add axes indicators
            createAxesIndicators()
            
            // add a unit sphere at 0,0,0
            // let sphere = SCNSphere(radius: 0.125)
            // let sphereNode = SCNNode(geometry: sphere)
            // sphereNode.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
            // sphereNode.position = SCNVector3(x: 0, y: -0.95, z: 0)
            
            // // Convert local bounding box to world coordinates
            // let localMin = sphereNode.boundingBox.min
            // let localMax = sphereNode.boundingBox.max
            // let worldMin = sphereNode.convertPosition(localMin, to: nil)
            // let worldMax = sphereNode.convertPosition(localMax, to: nil)
            
            // print("Sphere local bounds: min(\(localMin)), max(\(localMax))")
            // print("Sphere world bounds: min(\(worldMin)), max(\(worldMax))")
            
            // scene.rootNode.addChildNode(sphereNode)
            
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
        // Use optional Floats to handle the initial state correctly
        var calculatedMinX: CGFloat? = nil
        var calculatedMaxX: CGFloat? = nil
        var calculatedMinZ: CGFloat? = nil
        var calculatedMaxZ: CGFloat? = nil
        var calculatedFloorY: CGFloat? = nil // Use the minimum Y value encountered for floors

        print("Updating room dimensions...")
        print("Total nodes in scene: \(scene.rootNode.childNodes.count)")

        // Define the set of node names considered part of the room structure
        let relevantNodeNames = Set(["floor", "wall", "window", "door"])

        scene.rootNode.childNodes.forEach { node in
            // 1. Filter Nodes: Only consider nodes with geometry whose names are in the relevant set
            guard let nodeName = node.name, relevantNodeNames.contains(nodeName), node.geometry != nil else {
                // print("Skipping node: \(node.name ?? "unnamed") (Not relevant or no geometry)")
                return // Skip this node
            }

            print("Processing node: \(nodeName)")

            // 2. Get Node Bounding Box (Local)
            let (minLocal, maxLocal) = node.boundingBox

            // Create the 8 corners of the local bounding box
            let cornersLocal = [
                SCNVector3(minLocal.x, minLocal.y, minLocal.z), // 0 ---
                SCNVector3(minLocal.x, minLocal.y, maxLocal.z), // 1 --+
                SCNVector3(minLocal.x, maxLocal.y, minLocal.z), // 2 -+-
                SCNVector3(minLocal.x, maxLocal.y, maxLocal.z), // 3 -++
                SCNVector3(maxLocal.x, minLocal.y, minLocal.z), // 4 +--
                SCNVector3(maxLocal.x, minLocal.y, maxLocal.z), // 5 +-+
                SCNVector3(maxLocal.x, maxLocal.y, minLocal.z), // 6 ++-
                SCNVector3(maxLocal.x, maxLocal.y, maxLocal.z)  // 7 +++
            ]

            // 3. Convert to World Space
            // Apply the node's full transform (position, rotation, scale) to each corner
            let cornersWorld = cornersLocal.map { node.convertPosition($0, to: nil) }

            // 4. Update Dimensions
            // Find the min/max X and Z from the 8 world-space corners of this node
            // Use guard to safely unwrap the min/max results
            guard let nodeMinX = cornersWorld.map({ $0.x }).min(),
                  let nodeMaxX = cornersWorld.map({ $0.x }).max(),
                  let nodeMinZ = cornersWorld.map({ $0.z }).min(),
                  let nodeMaxZ = cornersWorld.map({ $0.z }).max(),
                  let nodeMinY = cornersWorld.map({ $0.y }).min() // Also get min Y for floor calculation
            else {
                print("Warning: Could not get min/max coordinates for node \(nodeName)")
                return // Skip if calculation failed
            }

            // Update overall min/max X and Z
            if calculatedMinX == nil { // First relevant node initializes the bounds
                calculatedMinX = nodeMinX
                calculatedMaxX = nodeMaxX
                calculatedMinZ = nodeMinZ
                calculatedMaxZ = nodeMaxZ
                print("Initial bounds set by \(nodeName): minX=\(nodeMinX), maxX=\(nodeMaxX), minZ=\(nodeMinZ), maxZ=\(nodeMaxZ)")
            } else {
                calculatedMinX = min(calculatedMinX!, nodeMinX)
                calculatedMaxX = max(calculatedMaxX!, nodeMaxX)
                calculatedMinZ = min(calculatedMinZ!, nodeMinZ)
                calculatedMaxZ = max(calculatedMaxZ!, nodeMaxZ)
            }

            // Specifically find the lowest Y value among all nodes named "floor"
            // This handles cases where multiple floor segments might exist
            if nodeName == "floor" {
                 if calculatedFloorY == nil || nodeMinY < calculatedFloorY! {
                     calculatedFloorY = nodeMinY
                     print("Found potential floor at Y: \(nodeMinY) from node \(nodeName)")
                 }
            }
        }

        // Assign the calculated values to the @Published property
        // Use 0 as a default if no relevant nodes were found
        var finalDimensions = RoomDimensions()
        finalDimensions.minX = Double(calculatedMinX ?? 0)
        finalDimensions.maxX = Double(calculatedMaxX ?? 0)
        finalDimensions.minZ = Double(calculatedMinZ ?? 0)
        finalDimensions.maxZ = Double(calculatedMaxZ ?? 0)
        // Default floorY to 0 if no floor node was found or processed
        finalDimensions.floorY = Double(calculatedFloorY ?? 0)

        print("Final calculated dimensions: MinX=\(finalDimensions.minX), MaxX=\(finalDimensions.maxX), MinZ=\(finalDimensions.minZ), MaxZ=\(finalDimensions.maxZ), FloorY=\(finalDimensions.floorY)")
        roomDimensions = finalDimensions // Update the @Published property which triggers UI updates
    }

    // MARK: - Camera Control

    func setPlanView(_ isPlan: Bool) {
        guard let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true), let camera = cameraNode.camera else {
            print("Error: Camera node or camera not found.")
            return
        }

        if isPlan {
            print("Switching to Plan View")
            // Configure for orthographic top-down view
            camera.usesOrthographicProjection = true
            self.scnView?.allowsCameraControl = false // Disable user control

            // Calculate orthographic scale based on room dimensions
            let roomWidth = abs(roomDimensions.maxX - roomDimensions.minX)
            let roomDepth = abs(roomDimensions.maxZ - roomDimensions.minZ)
            // Scale defines half the height visible, so use the larger dimension
            let largerDimension = max(roomWidth, roomDepth)
            // Add some padding to the scale
            camera.orthographicScale = (largerDimension / 2.0) * 1.1
            // Prevent scale from being zero if dimensions are zero
            if camera.orthographicScale < 1 { camera.orthographicScale = 10 } 

            // Position camera above the center of the room
            let centerX = (roomDimensions.minX + roomDimensions.maxX) / 2.0
            let centerZ = (roomDimensions.minZ + roomDimensions.maxZ) / 2.0
            let cameraHeight: Double = 10.0 // Adjust height as needed
            cameraNode.position = SCNVector3(centerX, cameraHeight, centerZ)

            // Point camera straight down
            cameraNode.eulerAngles = SCNVector3(x: -CGFloat.pi / 2, y: 0, z: 0)

            // --- Debugging: Print camera state AFTER setting plan view ---
            print("  Plan View - Target Position: \(SCNVector3(centerX, cameraHeight, centerZ))")
            print("  Plan View - Target EulerAngles: \(SCNVector3(x: -CGFloat.pi / 2, y: 0, z: 0))")
            print("  Plan View - Actual Position: \(cameraNode.position)")
            print("  Plan View - Actual EulerAngles: \(cameraNode.eulerAngles)")
            print("  Plan View - Actual Orthographic: \(camera.usesOrthographicProjection)")
            print("  Plan View - Actual Ortho Scale: \(camera.orthographicScale)")
            // -----------------------------------------------------------

            // Explicitly set the SCNView's pointOfView
            self.scnView?.pointOfView = cameraNode

        } else {
            print("Switching to Perspective View")
            // Restore perspective settings
            camera.usesOrthographicProjection = false
            self.scnView?.allowsCameraControl = true // Re-enable user control
            // Reset position and orientation to defaults
            cameraNode.position = defaultCameraPosition
            cameraNode.eulerAngles = defaultCameraEulerAngles

            // Explicitly set the SCNView's pointOfView
            self.scnView?.pointOfView = cameraNode
        }
    }

    private func createAxesIndicators() {
        let length: CGFloat = 1.0
        let thickness: CGFloat = 0.02
        let axisYOffset: Float = 0.01 // Slightly above the floor
        let textOffset: CGFloat = 0.1 // How far beyond the line end to place text
        let textSize: CGFloat = 0.5 // Size of the text geometry

        // Use the calculated min corner as the origin, slightly elevated
        let origin = SCNVector3(roomDimensions.maxX, roomDimensions.floorY + Double(axisYOffset), roomDimensions.maxZ)

        // Create a billboard constraint to make text face the camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .all // Only rotate around Y to stay upright

        // --- X Axis Line (Green) ---
        let xAxisGeo = SCNBox(width: length, height: thickness, length: thickness, chamferRadius: 0)
        let xMaterial = SCNMaterial()
        xMaterial.diffuse.contents = NSColor.green
        xMaterial.lightingModel = .constant
        xAxisGeo.materials = [xMaterial]

        let xAxisNode = SCNNode(geometry: xAxisGeo)
        // Position the center of the box correctly
        xAxisNode.position = SCNVector3(origin.x + CGFloat(length / 2.0), origin.y, origin.z)
        xAxisNode.name = "axisX"
        scene.rootNode.addChildNode(xAxisNode)

        // --- X Axis Label ("X") ---
        let xText = SCNText(string: "X", extrusionDepth: 0.01)
        xText.font = NSFont.systemFont(ofSize: textSize)
        xText.flatness = 0.1 // Lower flatness for smoother curves if needed
        let xTextMaterial = SCNMaterial()
        xTextMaterial.diffuse.contents = NSColor.green // Match line color
        xTextMaterial.lightingModel = .constant
        xText.materials = [xTextMaterial]

        let xTextNode = SCNNode(geometry: xText)
        // Position slightly past the end of the X line
        // We need to account for the text geometry's own bounding box to center it roughly
        let (minText, maxText) = xText.boundingBox
        let textWidthX = maxText.x - minText.x
        let textHeightX = maxText.y - minText.y
        xTextNode.position = SCNVector3(
            origin.x + CGFloat(length) + CGFloat(textWidthX / 2.0) + CGFloat(textOffset),
            origin.y - CGFloat(textHeightX / 2.0), // Align vertically with the axis line
            origin.z
        )
        xTextNode.name = "axisXLabel"
        xTextNode.constraints = [billboardConstraint] // Make it face the camera
        scene.rootNode.addChildNode(xTextNode)


        // --- Z Axis Line (Red) ---
        let zAxisGeo = SCNBox(width: thickness, height: thickness, length: length, chamferRadius: 0)
        let zMaterial = SCNMaterial()
        zMaterial.diffuse.contents = NSColor.red
        zMaterial.lightingModel = .constant
        zAxisGeo.materials = [zMaterial]

        let zAxisNode = SCNNode(geometry: zAxisGeo)
        // Position the center of the box correctly
        zAxisNode.position = SCNVector3(origin.x, origin.y, origin.z + CGFloat(length / 2.0))
        zAxisNode.name = "axisZ"
        scene.rootNode.addChildNode(zAxisNode)

        // --- Z Axis Label ("Z") ---
         let zText = SCNText(string: "Z", extrusionDepth: 0.01)
         zText.font = NSFont.systemFont(ofSize: textSize)
         zText.flatness = 0.1
         let zTextMaterial = SCNMaterial()
         zTextMaterial.diffuse.contents = NSColor.red // Match line color
         zTextMaterial.lightingModel = .constant
         zText.materials = [zTextMaterial]

         let zTextNode = SCNNode(geometry: zText)
         // Position slightly past the end of the Z line
         let (minZText, maxZText) = zText.boundingBox
         let textWidthZ = maxZText.x - minZText.x // Text width is along its local X axis
         zTextNode.position = SCNVector3(
             origin.x,
             origin.y, // Align vertically with the axis line
             origin.z + CGFloat(length) + CGFloat(textWidthZ / 2.0) + CGFloat(textOffset) // Offset along Z
         )
         zTextNode.name = "axisZLabel"
         zTextNode.constraints = [billboardConstraint] // Make it face the camera
         scene.rootNode.addChildNode(zTextNode)

        print("Added axes indicators and labels at origin: \(origin)")
    }
}

struct SceneView: NSViewRepresentable {
    // Add roomScene reference
    @ObservedObject var roomScene: RoomScene
    let scene: SCNScene
    
    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        // Assign the view back to the RoomScene
        DispatchQueue.main.async { // Use async to avoid modifying during view creation
            roomScene.scnView = view
        }
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = .black
        
        // Add debug options to help with development
        #if DEBUG
        // view.debugOptions = [.showWireframe, .showBoundingBoxes]
        #endif
        
        return view
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.scene = scene
    }
} 