import SwiftUI

struct PromptListView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selectedPrompt: Prompt?
    let filter: (Prompt) -> Bool
    let searchText: String

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    private var filteredPrompts: [Prompt] {
        store.prompts
            .sorted { $0.updatedAt > $1.updatedAt }
            .filter { prompt in
                guard filter(prompt) else { return false }
                guard !searchText.isEmpty else { return true }
                return prompt.title.localizedCaseInsensitiveContains(searchText)
                    || prompt.content.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        List(selection: $selectedPrompt) {
            if filteredPrompts.isEmpty && !store.prompts.isEmpty {
                ContentUnavailableView(
                    s.noMatches,
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(s.noMatchesHint)
                )
            } else if store.prompts.isEmpty {
                ContentUnavailableView(
                    s.noPromptsYet,
                    systemImage: "tray",
                    description: Text(s.createFirstHint)
                )
            } else {
                ForEach(filteredPrompts) { prompt in
                    PromptRowView(prompt: prompt, tags: store.tags(for: prompt))
                        .tag(prompt)
                        .contextMenu {
                            Button(s.copyContent, systemImage: "doc.on.doc") {
                                copyToClipboard(prompt.content)
                            }
                            Divider()
                            Button(s.delete, systemImage: "trash", role: .destructive) {
                                store.deletePrompt(prompt)
                                if selectedPrompt == prompt { selectedPrompt = nil }
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let prompt = filteredPrompts[index]
                        store.deletePrompt(prompt)
                        if selectedPrompt == prompt { selectedPrompt = nil }
                    }
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - Row Subview

private struct PromptRowView: View {
    let prompt: Prompt
    let tags: [Tag]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(prompt.title)
                .font(.headline)
                .lineLimit(1)

            Text(prompt.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(tags) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
