import Foundation

/// Represents an everyday activity whose last completion date is tracked.
struct Activity: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var lastCompletedAt: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        lastCompletedAt: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastCompletedAt = lastCompletedAt
        self.createdAt = createdAt
    }
}
