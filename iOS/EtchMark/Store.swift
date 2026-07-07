import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Run] = []
    @Published var isProUnlocked: Bool = false

    /// Free-tier cap. Seed data ships with 3 items, so this is set well above
    /// that to guarantee a fresh install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("EtchMark", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("runs.json")
        load()
    }

    var isAtFreeLimit: Bool {
        !isProUnlocked && items.count >= Store.freeLimit
    }

    func canAdd() -> Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: Run) {
        guard canAdd() else { return }
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Run) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Run) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Run].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static let seedData: [Run] = [
        Run(title: "Harbor at Dusk", plateType: "Copper Etching", inkPaper: "Charbonnel Black / Hahnemuhle", editionSize: "25", notes: "Aquatint tone, 3 states"),
        Run(title: "Fern Study", plateType: "Linocut", inkPaper: "Oil-based / Kozo paper", editionSize: "40", notes: "Reduction print, 2 layers"),
        Run(title: "City Grid", plateType: "Screen Print", inkPaper: "Speedball / Cotton Rag", editionSize: "15", notes: "4-color separation")
    ]
}
