import UIKit
import RoomPlan
import SceneKit

class RoomPlanViewController: UIViewController {
    private var sceneView: SCNView!
    private var scene: SCNScene!
    private var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupExitButton()
        loadRoomData()
    }
    
    private func setupScene() {
        // Create a new SceneKit view
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        
        // Create a new scene
        scene = SCNScene()
        sceneView.scene = scene
        
        // Configure the view
        sceneView.backgroundColor = .white
        sceneView.allowsCameraControl = false // Lock camera for plan view
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        directionalLight.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func setupExitButton() {
        exitButton = UIButton(frame: CGRect(x: 20, y: 50, width: 44, height: 44))
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        exitButton.tintColor = .black
        exitButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        exitButton.layer.cornerRadius = 22
        exitButton.layer.shadowColor = UIColor.black.cgColor
        exitButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        exitButton.layer.shadowRadius = 3
        exitButton.layer.shadowOpacity = 0.3
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        exitButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        view.addSubview(exitButton)
    }
    
    @objc private func exitButtonTapped() {
        dismiss(animated: true)
    }
    
    private func loadRoomData() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory")
            return
        }
        
        let jsonURL = documentsPath.appendingPathComponent("room_data.json")
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let capturedRoom = try decoder.decode(CapturedRoom.self, from: jsonData)
            
            // Create 3D representation of the room
            createRoomGeometry(from: capturedRoom)
            
        } catch {
            print("Error loading room data: \(error)")
            let alert = UIAlertController(
                title: "Error",
                message: "Could not load room data: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func createRoomGeometry(from room: CapturedRoom) {
        // Create a node to hold all room geometry
        let roomNode = SCNNode()
        
        // Find the longest wall first
        var longestWall: CapturedRoom.Surface? = nil
        var maxLength: Float = 0
        
        for wall in room.walls {
            let length = wall.dimensions.x
            if length > maxLength {
                maxLength = length
                longestWall = wall
            }
        }
        
        // Create walls
        for surface in room.walls {
            let wallGeometry = createWallGeometry(from: surface)
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.simdTransform = surface.transform
            
            // If this is the longest wall, make it red
            // if surface.dimensions.x == maxLength {
            //     let material = SCNMaterial()
            //     material.diffuse.contents = UIColor.red
            //     wallGeometry.materials = [material]
            // }
            
            // Add dimension label
            let length = surface.dimensions.x
            let labelText = SCNText(string: String(format: "%.2fm", length), extrusionDepth: 0)
            labelText.font = UIFont.systemFont(ofSize: 0.2)
            labelText.firstMaterial?.diffuse.contents = UIColor.red
            
            let labelNode = SCNNode(geometry: labelText)
            
            // Position label at the center of the wall
            let transform = surface.transform
            let wallCenter = SCNVector3(
                transform.columns.3.x,
                transform.columns.3.y, // Slightly above the wall
                transform.columns.3.z
            )
            labelNode.position = wallCenter
            
            // Make label always face the camera
            let billboardConstraint = SCNBillboardConstraint()
            labelNode.constraints = [billboardConstraint]
            
            // Center the text
            // let (min, max) = labelText.boundingBox
            // labelNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x)/2, 0, 0)
            
            roomNode.addChildNode(wallNode)
            roomNode.addChildNode(labelNode)
        }
        
        // Create doors
        for surface in room.doors {
            let doorGeometry = createDoorGeometry(from: surface)
            let doorNode = SCNNode(geometry: doorGeometry)
            doorNode.simdTransform = surface.transform
            roomNode.addChildNode(doorNode)
        }
        
        // Create windows
        for surface in room.windows {
            let windowGeometry = createWindowGeometry(from: surface)
            let windowNode = SCNNode(geometry: windowGeometry)
            windowNode.simdTransform = surface.transform
            roomNode.addChildNode(windowNode)
        }
        
        // Create objects
        for object in room.objects {
            let objectNode = createObjectNode(from: object)
            roomNode.addChildNode(objectNode)
        }
        
        // Add the room node to the scene
        scene.rootNode.addChildNode(roomNode)
        
        // Position camera for top view
        setupTopCamera()
    }
    
    private func createWallGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.1,
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createDoorGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.05,
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createWindowGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.05,
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.lightGray
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createObjectNode(from object: CapturedRoom.Object) -> SCNNode {
        let width = object.dimensions.x   // width
        let height = object.dimensions.y  // height
        let length = object.dimensions.z  // length
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: CGFloat(length),
                            chamferRadius: 0.05)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.6)
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.simdTransform = object.transform
        
        // Add label
        let labelText = SCNText(string: "\(object.category)", extrusionDepth: 0)
        labelText.font = UIFont.boldSystemFont(ofSize: 0.8)
        let labelNode = SCNNode(geometry: labelText)
        
        labelNode.position = SCNVector3(x: 0, y: 0, z: 0)
        labelNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let textGeometry = labelText.boundingBox
        let textWidth = CGFloat(textGeometry.max.x - textGeometry.min.x)
        let textHeight = CGFloat(textGeometry.max.y - textGeometry.min.y)
        labelNode.position = SCNVector3(
            x: -Float(textWidth) * 0.15,
            y: -Float(textHeight) * 0.15,
            z: 0
        )
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        labelNode.constraints = [billboardConstraint]
        
        node.addChildNode(labelNode)
        
        return node
    }
    
    private func setupTopCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Find the longest wall from the CapturedRoom data
        var longestWall: CapturedRoom.Surface? = nil
        var maxLength: Float = 0
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory")
            return
        }
        let jsonURL = documentsPath.appendingPathComponent("room_data.json")
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let capturedRoom = try decoder.decode(CapturedRoom.self, from: jsonData)
            
            // Find the longest wall
            for wall in capturedRoom.walls {
                let length = wall.dimensions.x
                if length > maxLength {
                    maxLength = length
                    longestWall = wall
                }
            }
            
            // Position camera directly above and looking straight down
            cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
            cameraNode.eulerAngles = SCNVector3(x: -Float.pi/2, y: 0, z: 0)
            
            // Calculate rotation from the longest wall's transform
            if let wall = longestWall {
                let transform = wall.transform
                let dirX = transform.columns.2.x
                let dirZ = transform.columns.2.z
                
                let angle = atan2(dirX, dirZ) + .pi/2  // Add 90 degrees to make it vertical
                cameraNode.eulerAngles.y = angle
                
                // Debug prints
                print("Wall direction vector: (\(dirX), \(dirZ))")
                print("Raw angle: \(atan2(dirX, dirZ) * 180 / .pi)°")
                print("Final angle with adjustment: \(angle * 180 / .pi)°")
            }
            
        } catch {
            print("Error loading room data: \(error)")
        }
        
        // Set up orthographic camera for true top-down view
        let camera = cameraNode.camera!
        camera.usesOrthographicProjection = true
        
        // Calculate the bounds of the room
        let boundingBox = scene.rootNode.boundingBox
        let width = boundingBox.max.x - boundingBox.min.x
        let length = boundingBox.max.z - boundingBox.min.z
        
        // Calculate the required scale to fit the room with some padding
        let padding = Float(1.2) // 20% padding
        let scale = max(width, length) * padding
        camera.orthographicScale = Double(scale)
        
        // Center the camera over the room
        let centerX = (boundingBox.max.x + boundingBox.min.x) / 2
        let centerZ = (boundingBox.max.z + boundingBox.min.z) / 2
        cameraNode.position = SCNVector3(x: centerX, y: 15, z: centerZ)
        
        camera.zNear = 0.1
        camera.zFar = 100
        
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        sceneView.allowsCameraControl = false
    }
} 