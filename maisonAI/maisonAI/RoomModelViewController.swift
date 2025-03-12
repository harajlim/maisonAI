import UIKit
import RoomPlan
import SceneKit

class RoomModelViewController: UIViewController {
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
        sceneView.backgroundColor = .lightGray 
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .orbitTurntable 
        sceneView.defaultCameraController.maximumVerticalAngle = 85
        
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
        exitButton.tintColor = .white
        exitButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        exitButton.layer.cornerRadius = 22
        exitButton.layer.shadowColor = UIColor.black.cgColor
        exitButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        exitButton.layer.shadowRadius = 3
        exitButton.layer.shadowOpacity = 1.0
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        // Make sure button stays in top-left corner
        exitButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        view.addSubview(exitButton)
    }
    
    @objc private func exitButtonTapped() {
        // If this VC was presented modally:
        dismiss(animated: true)
        
        // If it was pushed onto a navigation stack:
        // navigationController?.popViewController(animated: true)
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
            // Show an alert to the user
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
        
        // Create walls
        for surface in room.walls {
            let wallGeometry = createWallGeometry(from: surface)
            let wallNode = SCNNode(geometry: wallGeometry)
            wallNode.simdTransform = surface.transform
            roomNode.addChildNode(wallNode)
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
        
        // Position camera to view the entire room
        positionCamera()
    }
    
    private func createWallGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.1, // Thin wall
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.transparency = 0.8
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createDoorGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.05, // Thinner than walls
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.8)
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createWindowGeometry(from surface: CapturedRoom.Surface) -> SCNGeometry {
        let width = surface.dimensions.x  // width
        let height = surface.dimensions.y // height
        
        let geometry = SCNBox(width: CGFloat(width),
                            height: CGFloat(height),
                            length: 0.05, // Thinner than walls
                            chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green.withAlphaComponent(0.8)
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
        
        // Create label node with larger text
        let labelText = SCNText(string: "\(object.category)", extrusionDepth: 0)
        labelText.font = UIFont.boldSystemFont(ofSize: 0.8)  // Much bigger font
        let labelNode = SCNNode(geometry: labelText)
        
        // Position label in the center of the object
        labelNode.position = SCNVector3(x: 0, y: 0, z: 0)
        // Adjust scale for larger appearance while maintaining proportion
        labelNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        // Center the text geometry itself (SCNText's origin is at the text's baseline)
        let textGeometry = labelText.boundingBox
        let textWidth = CGFloat(textGeometry.max.x - textGeometry.min.x)
        let textHeight = CGFloat(textGeometry.max.y - textGeometry.min.y)
        labelNode.position = SCNVector3(
            x: -Float(textWidth) * 0.15,  // Adjust 0.15 to fine-tune horizontal centering
            y: -Float(textHeight) * 0.15, // Adjust 0.15 to fine-tune vertical centering
            z: 0
        )
        
        // Make label always face the camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        labelNode.constraints = [billboardConstraint]
        
        node.addChildNode(labelNode)
        
        return node
    }
    
    private func positionCamera() {
        // Position camera to view the entire room
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.pointOfView = cameraNode
    }
} 