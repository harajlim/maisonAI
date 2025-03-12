import UIKit
import RoomPlan

class RoomScanViewController: UIViewController {
    
    // Keep a reference to the roomCaptureView
    private var roomCaptureView: RoomCaptureView?
    
    @IBAction func startRoomScanButtonTapped(_ sender: Any) {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView?.delegate = self  // Set the delegate
        print("Delegate set: \(String(describing: roomCaptureView?.delegate))")
        let configuration = RoomCaptureSession.Configuration()
        
        view.addSubview(roomCaptureView!)
        roomCaptureView?.captureSession.run(configuration: configuration)
        print("Scan session started")
    }
    
    @IBAction func stopRoomScanButtonTapped(_ sender: Any) {
        roomCaptureView?.captureSession.stop()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        print("Close button tapped - stopping room capture session")
        roomCaptureView?.captureSession.stop()
        print("Called stop on capture session")
        
        // Wait a moment before dismissing to allow for processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - RoomCaptureView Delegate
extension RoomScanViewController: RoomCaptureViewDelegate {
    
    // Standard delegate methods
    func roomCaptureView(_ roomCaptureView: RoomCaptureView, didUpdate capturedRoom: CapturedRoom) {
        print("Room capture update received")
    }
    
    func roomCaptureView(_ roomCaptureView: RoomCaptureView, didComplete capturedRoom: CapturedRoom) {
        print("Room capture completed")
        
        // Create a URL in the Documents directory to save the scan
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let scanURL = documentsPath.appendingPathComponent("roomscan.usdz")
        
        // Export the scan with proper error handling
        do {
            try capturedRoom.export(to: scanURL)
            print("Scan successfully saved to: \(scanURL)")
        } catch {
            print("Error exporting scan: \(error)")
        }
    }
    
    // Demo-style methods (these may be custom extensions or from an older API version)
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        print("shouldPresent called - deciding whether to process results")
        // Return true to opt-in to post processed scan results
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        print("didPresent called - handling final processed results")
        
        if let error = error {
            print("Error processing room data: \(error)")
            return
        }
        
        // Create a URL in the Documents directory to save the scan
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let scanURL = documentsPath.appendingPathComponent("roomscan_processed.usdz")
        
        // Export the scan with proper error handling
        do {
            try processedResult.export(to: scanURL)
            print("Processed scan successfully saved to: \(scanURL)")
        } catch {
            print("Error exporting processed scan: \(error)")
        }

        // Save to the app's shared documents directory (visible in Files app)
        guard let sharedPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error getting shared documents path")
            return
        }
        
        let jsonURL = sharedPath.appendingPathComponent("room_data.json")
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted  // Makes the JSON readable
            let jsonData = try jsonEncoder.encode(processedResult)
            try jsonData.write(to: jsonURL)
            print("Room data saved and accessible in Files app at: \(jsonURL)")
        } catch {
            print("Error archiving room data as JSON: \(error)")
        }
    }
} 