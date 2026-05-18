import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selection: SidebarSelection

    @State private var newNameInput = ""
    @State private var showNewGroupAlert = false

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    var body: some View {
        List(selection: $selection) {
            Label(s.allPrompts, systemImage: "tray.full")
                .tag(SidebarSelection.all)

            Section(s.groups) {
                ForEach(groupsSorted) { group in
                    Label(group.name, systemImage: "tag")
                        .badge(store.groupCount(for: group))
                        .tag(SidebarSelection.group(group))
                        .contextMenu {
                            Button(s.duplicateGroup) {
                                store.duplicateGroup(group)
                            }
                            Divider()
                            Button(s.deleteGroup, role: .destructive) {
                                deleteGroup(group)
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .contextMenu {
            Button(s.newGroup) {
                newNameInput = ""
                showNewGroupAlert = true
            }
        }
        .alert(s.newGroup, isPresented: $showNewGroupAlert) {
            TextField(s.newGroupName, text: $newNameInput)
            Button(s.cancel, role: .cancel) {}
            Button(s.add) { addGroup() }
        }
    }

    private var groupsSorted: [Group] {
        store.groups.sorted { $0.name < $1.name }
    }

    private func addGroup() {
        let name = newNameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = store.addGroup(name: name)
        newNameInput = ""
    }

    private func deleteGroup(_ group: Group) {
        store.deleteGroup(group)
        if case .group(let g) = selection, g.id == group.id {
            selection = .all
        }
    }
}
