import Foundation
import Combine

@MainActor
final class DataStore: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var tags: [Tag] = []

    private let promptsURL: URL
    private let tagsURL: URL

    init() {
        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/PromptSaver")
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        promptsURL = base.appendingPathComponent("prompts.json")
        tagsURL = base.appendingPathComponent("tags.json")
        load()
    }

    // MARK: - Persistence

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            try encoder.encode(prompts).write(to: promptsURL, options: .atomic)
            try encoder.encode(tags).write(to: tagsURL, options: .atomic)
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: promptsURL),
           let decoded = try? decoder.decode([Prompt].self, from: data) {
            prompts = decoded
        }
        if let data = try? Data(contentsOf: tagsURL),
           let decoded = try? decoder.decode([Tag].self, from: data) {
            tags = decoded
        }
    }

    // MARK: - Prompt operations

    func addPrompt(title: String, content: String, tagIds: Set<UUID>) {
        let prompt = Prompt(title: title, content: content, tagIds: tagIds)
        prompts.append(prompt)
        save()
    }

    func updatePrompt(_ prompt: Prompt, title: String, content: String, tagIds: Set<UUID>) {
        guard let index = prompts.firstIndex(where: { $0.id == prompt.id }) else { return }
        prompts[index].title = title
        prompts[index].content = content
        prompts[index].tagIds = tagIds
        prompts[index].updatedAt = Date()
        save()
    }

    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        save()
    }

    // MARK: - Tag operations

    func addTag(name: String) -> Tag {
        if let existing = tags.first(where: { $0.name == name }) {
            return existing
        }
        let tag = Tag(name: name)
        tags.append(tag)
        save()
        return tag
    }

    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        for i in prompts.indices {
            prompts[i].tagIds.remove(tag.id)
        }
        save()
    }

    func tagCount(for tag: Tag) -> Int {
        prompts.filter { $0.tagIds.contains(tag.id) }.count
    }

    func tags(for prompt: Prompt) -> [Tag] {
        tags.filter { prompt.tagIds.contains($0.id) }
    }
}
