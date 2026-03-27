import Foundation

@Observable
final class ScriptStorage {
    var scripts: [Script] = []
    var currentScript: Script?

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("CueCard", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("scripts.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Script].self, from: data) else { return }
        scripts = decoded
        currentScript = scripts.first
    }

    func save(script: Script) {
        if let idx = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[idx] = script
        } else {
            scripts.insert(script, at: 0)
        }
        currentScript = script
        persist()
    }

    func delete(id: UUID) {
        scripts.removeAll { $0.id == id }
        if currentScript?.id == id {
            currentScript = scripts.first
        }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(scripts) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
