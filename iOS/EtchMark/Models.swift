import Foundation

struct Run: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var title: String
    var plateType: String
    var inkPaper: String
    var editionSize: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), title: String = "", plateType: String = "", inkPaper: String = "", editionSize: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.plateType = plateType
        self.inkPaper = inkPaper
        self.editionSize = editionSize
        self.notes = notes
    }
}
