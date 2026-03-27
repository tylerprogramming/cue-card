import Foundation

struct Script: Codable, Identifiable {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var lastUsedAt: Date

    init(id: UUID = UUID(), title: String = "Untitled", body: String = "", createdAt: Date = .now, lastUsedAt: Date = .now) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }
}
