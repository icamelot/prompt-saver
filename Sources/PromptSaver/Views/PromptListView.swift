import SwiftUI

struct PromptListView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selectedPrompt: Prompt?
    let filter: (Prompt) -> Bool
    let searchText: String

    @State private var renameTarget: Prompt?
    @State private var renameInput = ""
    @State private var showRenameAlert = false
    @State private var showNewPromptSheet = false

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
                    PromptRowView(prompt: prompt, groups: store.groups(for: prompt))
                        .tag(prompt)
                        .contextMenu {
                            Button(s.newPrompt) {
                                showNewPromptSheet = true
                            }
                            Divider()
                            Button(s.renamePrompt) {
                                renameTarget = prompt
                                renameInput = prompt.title
                                showRenameAlert = true
                            }
                            Button(s.duplicatePrompt) {
                                store.duplicatePrompt(prompt)
                            }
                            Divider()
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
        .contextMenu {
            Button(s.newPrompt) {
                showNewPromptSheet = true
            }
        }
        .alert(s.renamePrompt, isPresented: $showRenameAlert) {
            TextField(s.titlePlaceholder, text: $renameInput)
            Button(s.cancel, role: .cancel) {}
            Button(s.save) { renamePrompt() }
        }
        .sheet(isPresented: $showNewPromptSheet) {
            PromptEditView(editingPrompt: nil)
                .environmentObject(store)
                .environmentObject(localeManager)
        }
    }

    private func renamePrompt() {
        let name = renameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let target = renameTarget else { return }
        store.renamePrompt(target, to: name)
        renameTarget = nil
        renameInput = ""
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - Row Subview

private struct PromptRowView: View {
    let prompt: Prompt
    let groups: [Group]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(prompt.title)
                .font(.headline)
                .lineLimit(1)

            Text(prompt.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !groups.isEmpty {
                HStack(spacing: 4) {
                    ForEach(groups) { group in
                        Text(group.name)
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
