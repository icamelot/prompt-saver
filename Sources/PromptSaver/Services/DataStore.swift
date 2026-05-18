import Foundation
import Combine

@MainActor
final class DataStore: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var groups: [Group] = []
    @Published var sessions: [Session] = []

    private let promptsURL: URL
    private let groupsURL: URL
    private let sessionsURL: URL

    init() {
        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/PromptSaver")
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        promptsURL = base.appendingPathComponent("prompts.json")
        groupsURL = base.appendingPathComponent("groups.json")
        sessionsURL = base.appendingPathComponent("sessions.json")
        load()
        ensureUncategorized()
    }

    // MARK: - Persistence

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            try encoder.encode(prompts).write(to: promptsURL, options: .atomic)
            try encoder.encode(groups).write(to: groupsURL, options: .atomic)
            try encoder.encode(sessions).write(to: sessionsURL, options: .atomic)
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        let base = promptsURL.deletingLastPathComponent()

        // Migrate old tags.json -> groups.json
        let oldTagsURL = base.appendingPathComponent("tags.json")
        if !FileManager.default.fileExists(atPath: groupsURL.path),
           FileManager.default.fileExists(atPath: oldTagsURL.path) {
            try? FileManager.default.moveItem(at: oldTagsURL, to: groupsURL)
        }

        if let data = try? Data(contentsOf: promptsURL) {
            if let decoded = try? decoder.decode([Prompt].self, from: data) {
                prompts = decoded
            } else if let decoded = try? decoder.decode([LegacyPrompt].self, from: data) {
                prompts = decoded.map { Prompt(id: $0.id, title: $0.title, content: $0.content,
                                               groupIds: $0.tagIds, sessionId: nil) }
                // Fix timestamps
                for i in prompts.indices {
                    prompts[i].createdAt = decoded[i].createdAt
                    prompts[i].updatedAt = decoded[i].updatedAt
                }
            }
        }
        if let data = try? Data(contentsOf: groupsURL) {
            if let decoded = try? decoder.decode([Group].self, from: data) {
                groups = decoded
            } else if let decoded = try? decoder.decode([LegacyTag].self, from: data) {
                groups = decoded.map { Group(id: $0.id, name: $0.name, isDefault: false) }
            }
        }
        if let data = try? Data(contentsOf: sessionsURL),
           let decoded = try? decoder.decode([Session].self, from: data) {
            sessions = decoded
        }
        save()
    }

    private func ensureUncategorized() {
        if !groups.contains(where: { $0.isDefault }) {
            let uncategorized = Group(name: "Uncategorized", isDefault: true)
            groups.insert(uncategorized, at: 0)
            save()
        }
    }

    // MARK: - Prompt operations

    func addPrompt(title: String, content: String, groupIds: Set<UUID>, sessionId: UUID? = nil) {
        let prompt = Prompt(title: title, content: content, groupIds: groupIds, sessionId: sessionId)
        prompts.append(prompt)
        save()
    }

    func updatePrompt(_ prompt: Prompt, title: String, content: String, groupIds: Set<UUID>, sessionId: UUID? = nil) {
        guard let index = prompts.firstIndex(where: { $0.id == prompt.id }) else { return }
        prompts[index].title = title
        prompts[index].content = content
        prompts[index].groupIds = groupIds
        prompts[index].sessionId = sessionId
        prompts[index].updatedAt = Date()
        save()
    }

    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        save()
    }

    // MARK: - Group operations

    func addGroup(name: String) -> Group {
        if let existing = groups.first(where: { $0.name == name }) {
            return existing
        }
        let group = Group(name: name)
        groups.append(group)
        save()
        return group
    }

    func duplicateGroup(_ group: Group) {
        let baseName = group.name
        let existingNames = Set(groups.map(\.name))
        var copyName = baseName
        var counter = 1
        while existingNames.contains(copyName) {
            copyName = "\(baseName) \(counter)"
            counter += 1
        }
        _ = addGroup(name: copyName)
    }

    func deleteGroup(_ group: Group) {
        groups.removeAll { $0.id == group.id }
        for i in prompts.indices {
            prompts[i].groupIds.remove(group.id)
        }
        save()
    }

    func groupCount(for group: Group) -> Int {
        prompts.filter { $0.groupIds.contains(group.id) }.count
    }

    func groups(for prompt: Prompt) -> [Group] {
        groups.filter { prompt.groupIds.contains($0.id) }
    }

    // MARK: - Session operations

    func addSession(name: String) -> Session {
        let session = Session(name: name)
        sessions.append(session)
        save()
        return session
    }

    func deleteSession(_ session: Session) {
        sessions.removeAll { $0.id == session.id }
        for i in prompts.indices where prompts[i].sessionId == session.id {
            prompts[i].sessionId = nil
        }
        save()
    }

    func sessionPromptCount(for session: Session) -> Int {
        prompts.filter { $0.sessionId == session.id }.count
    }
}

// MARK: - Legacy migration types

private struct LegacyTag: Codable {
    var id: UUID
    var name: String
}

private struct LegacyPrompt: Codable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tagIds: Set<UUID>
}
