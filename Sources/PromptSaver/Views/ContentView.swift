import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DataStore
    @State private var sidebarSelection: SidebarSelection = .all
    @State private var selectedPrompt: Prompt?
    @State private var searchText: String = ""
    @State private var isShowingNewPrompt: Bool = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
                .environmentObject(store)
        } content: {
            PromptListView(
                selectedPrompt: $selectedPrompt,
                filter: promptFilter(for: sidebarSelection),
                searchText: searchText
            )
            .environmentObject(store)
            .navigationTitle("Prompts")
        } detail: {
            if let prompt = selectedPrompt {
                PromptDetailView(prompt: prompt)
                    .environmentObject(store)
            } else {
                ContentUnavailableView(
                    "No Prompt Selected",
                    systemImage: "doc.text",
                    description: Text("Select a prompt from the list or create a new one.")
                )
            }
        }
        .searchable(text: $searchText, placement: .sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Prompt", systemImage: "plus") {
                    isShowingNewPrompt = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            ToolbarItem(placement: .automatic) {
                if selectedPrompt != nil {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteSelectedPrompt()
                    }
                    .keyboardShortcut(.delete, modifiers: .command)
                }
            }
        }
        .sheet(isPresented: $isShowingNewPrompt) {
            PromptEditView(editingPrompt: nil)
                .environmentObject(store)
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
