import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var content: String
    var appName: String?
    var contentType: String
    var usageCount: Int
    var vectorId: UUID?
    var tags: [String] // AI-generated semantic tags for better retrieval
    
    init(timestamp: Date, content: String = "", appName: String? = nil, contentType: String = "text") {
        self.timestamp = timestamp
        self.content = content
        self.appName = appName
        self.contentType = contentType
        self.usageCount = 0
        self.tags = []
    }
}
