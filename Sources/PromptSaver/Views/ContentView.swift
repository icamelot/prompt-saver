import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @State private var sidebarSelection: SidebarSelection = .all
    @State private var selectedPrompt: Prompt?
    @State private var searchText: String = ""
    @State private var isShowingNewPrompt: Bool = false

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
                .environmentObject(store)
                .environmentObject(localeManager)
        } content: {
            PromptListView(
                selectedPrompt: $selectedPrompt,
                filter: promptFilter(for: sidebarSelection),
                searchText: searchText
            )
            .environmentObject(store)
            .environmentObject(localeManager)
            .navigationTitle(s.prompts)
        } detail: {
            if let prompt = selectedPrompt {
                PromptDetailView(prompt: prompt)
                    .environmentObject(store)
                    .environmentObject(localeManager)
            } else {
                ContentUnavailableView(
                    s.noPromptSelected,
                    systemImage: "doc.text",
                    description: Text(s.selectPromptHint)
                )
            }
        }
        .searchable(text: $searchText, placement: .sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(s.newPrompt, systemImage: "plus") {
                    isShowingNewPrompt = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            ToolbarItem(placement: .automatic) {
                if selectedPrompt != nil {
                    Button(s.delete, systemImage: "trash", role: .destructive) {
                        deleteSelectedPrompt()
                    }
                    .keyboardShortcut(.delete, modifiers: .command)
                }
            }
        }
        .sheet(isPresented: $isShowingNewPrompt) {
            PromptEditView(editingPrompt: nil)
                .environmentObject(store)
                .environmentObject(localeManager)
        }
    }

    private func promptFilter(for selection: SidebarSelection) -> (Prompt) -> Bool {
        switch selection {
        case .all:
            return { _ in true }
        case .tag(let tag):
            return { $0.tagIds.contains(tag.id) }
        }
    }

    private func deleteSelectedPrompt() {
        guard let prompt = selectedPrompt else { return }
        store.deletePrompt(prompt)
        selectedPrompt = nil
    }
}

enum SidebarSelection: Hashable {
    case all
    case tag(Tag)
}
