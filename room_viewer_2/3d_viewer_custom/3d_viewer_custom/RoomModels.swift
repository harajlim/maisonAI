import Foundation
import SceneKit

struct CapturedRoom: Codable {
    let coreModel: String
    let objects: [RoomObject]
    let floors: [Floor]
    let walls: [Wall]
    let openings: [Opening]
    let windows: [Window]
    let doors: [Door]
    let sections: [Section]
    let version: Int
    let story: Int
    let referenceOriginTransform: [Double]
}

struct RoomObject: Codable {
    let transform: [Double]
    let attributes: [String: String]
    let confidence: Confidence
    let identifier: String
    let category: Category
    let story: Int
    let parentIdentifier: String?
    let dimensions: [Double]
}

struct Floor: Codable {
    let parentIdentifier: String?
    let completedEdges: [String]
    let transform: [Double]
    let confidence: Confidence
    let identifier: String
    let polygonCorners: [[Double]]
    let category: Category
    let story: Int
    let curve: String?
    let dimensions: [Double]
}

struct Wall: Codable {
    let parentIdentifier: String?
    let completedEdges: [String]
    let transform: [Double]
    let confidence: Confidence
    let identifier: String
    let polygonCorners: [[Double]]
    let category: Category
    let story: Int
    let curve: String?
    let dimensions: [Double]
}

struct Opening: Codable {
    let parentIdentifier: String?
    let completedEdges: [String]
    let transform: [Double]
    let confidence: Confidence
    let identifier: String
    let polygonCorners: [[Double]]
    let category: Category
    let story: Int
    let curve: String?
    let dimensions: [Double]
}

struct Window: Codable {
    let parentIdentifier: String?
    let completedEdges: [String]
    let transform: [Double]
    let confidence: Confidence
    let identifier: String
    let polygonCorners: [[Double]]
    let category: Category
    let story: Int
    let curve: String?
    let dimensions: [Double]
}

struct Door: Codable {
    let parentIdentifier: String?
    let completedEdges: [String]
    let transform: [Double]
    let confidence: Confidence
    let identifier: String
    let polygonCorners: [[Double]]
    let category: Category
    let story: Int
    let curve: String?
    let dimensions: [Double]
    
    var isOpen: Bool {
        if case .door(let details) = category {
            return details.isOpen ?? false
        }
        return false
    }
}

struct Section: Codable {
    let label: String
    let center: [Double]
    let story: Int
}

struct Confidence: Codable {
    let low: Empty?
    let medium: Empty?
    let high: Empty?
}

struct Empty: Codable {}

enum Category: Codable {
    case storage(StorageDetails)
    case bed(Empty)
    case floor(Empty)
    case wall(Empty)
    case window(Empty)
    case door(DoorDetails)
    
    private enum CodingKeys: String, CodingKey {
        case storage, bed, floor, wall, window, door
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let storageDetails = try? container.decode(StorageDetails.self, forKey: .storage) {
            self = .storage(storageDetails)
        } else if let bedDetails = try? container.decode(Empty.self, forKey: .bed) {
            self = .bed(bedDetails)
        } else if let floorDetails = try? container.decode(Empty.self, forKey: .floor) {
            self = .floor(floorDetails)
        } else if let wallDetails = try? container.decode(Empty.self, forKey: .wall) {
            self = .wall(wallDetails)
        } else if let windowDetails = try? container.decode(Empty.self, forKey: .window) {
            self = .window(windowDetails)
        } else if let doorDetails = try? container.decode(DoorDetails.self, forKey: .door) {
            self = .door(doorDetails)
        } else {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unknown category",
                underlyingError: nil
            )
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .storage(let details):
            try container.encode(details, forKey: .storage)
        case .bed(let details):
            try container.encode(details, forKey: .bed)
        case .floor(let details):
            try container.encode(details, forKey: .floor)
        case .wall(let details):
            try container.encode(details, forKey: .wall)
        case .window(let details):
            try container.encode(details, forKey: .window)
        case .door(let details):
            try container.encode(details, forKey: .door)
        }
    }
}

struct StorageDetails: Codable {
    let StorageType: String?
}

struct DoorDetails: Codable {
    let isOpen: Bool?
}

// Helper extension to convert transform array to SCNMatrix4
extension Array where Element == Double {
    func toSCNMatrix4() -> SCNMatrix4 {
        guard self.count >= 16 else { return SCNMatrix4Identity }
        return SCNMatrix4(
            m11: CGFloat(self[0]), m12: CGFloat(self[1]), m13: CGFloat(self[2]), m14: CGFloat(self[3]),
            m21: CGFloat(self[4]), m22: CGFloat(self[5]), m23: CGFloat(self[6]), m24: CGFloat(self[7]),
            m31: CGFloat(self[8]), m32: CGFloat(self[9]), m33: CGFloat(self[10]), m34: CGFloat(self[11]),
            m41: CGFloat(self[12]), m42: CGFloat(self[13]), m43: CGFloat(self[14]), m44: CGFloat(self[15])
        )
    }
} 