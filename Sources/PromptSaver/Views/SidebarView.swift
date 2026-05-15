import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selection: SidebarSelection

    @State private var isShowingNewTagAlert = false
    @State private var newTagNameInput = ""

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    var body: some View {
        List(selection: $selection) {
            Label(s.allPrompts, systemImage: "tray.full")
                .tag(SidebarSelection.all)

            Section {
                ForEach(store.tags.sorted(by: { $0.name < $1.name })) { tag in
                    Label(tag.name, systemImage: "tag")
                        .badge(store.tagCount(for: tag))
                        .tag(SidebarSelection.tag(tag))
                        .contextMenu {
                            Button(s.newTag) {
                                newTagNameInput = ""
                                isShowingNewTagAlert = true
                            }
                            Divider()
                            Button(s.deleteTag, role: .destructive) {
                                deleteTag(tag)
                            }
                        }
                }
            } header: {
                HStack {
                    Text(s.tags)
                    Spacer()
                    Button {
                        newTagNameInput = ""
                        isShowingNewTagAlert = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help(s.newTag)
                }
            }
        }
        .listStyle(.sidebar)
        .alert(s.newTag, isPresented: $isShowingNewTagAlert) {
            TextField(s.newTagPrompt, text: $newTagNameInput)
            Button(s.cancel, role: .cancel) {}
            Button(s.add) { addNewTag() }
        }
    }

    private func addNewTag() {
        let name = newTagNameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = store.addTag(name: name)
        newTagNameInput = ""
    }

    private func deleteTag(_ tag: Tag) {
        store.deleteTag(tag)
        if case .tag(let selected) = selection, selected.id == tag.id {
            selection = .all
        }
    }
}
