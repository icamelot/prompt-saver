import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selection: SidebarSelection

    @State private var inputName = ""
    @State private var showNewGroupAlert = false
    @State private var renameTarget: Group?
    @State private var showRenameAlert = false

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
                            Button(s.renameGroup) {
                                renameTarget = group
                                inputName = group.name
                                showRenameAlert = true
                            }
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
                inputName = ""
                showNewGroupAlert = true
            }
        }
        .alert(s.newGroup, isPresented: $showNewGroupAlert) {
            TextField(s.newGroupName, text: $inputName)
            Button(s.cancel, role: .cancel) {}
            Button(s.add) { addGroup() }
        }
        .alert(s.renameGroup, isPresented: $showRenameAlert) {
            TextField(s.newGroupName, text: $inputName)
            Button(s.cancel, role: .cancel) {}
            Button(s.save) { renameGroup() }
        }
    }

    private var groupsSorted: [Group] {
        store.groups.sorted { $0.name < $1.name }
    }

    private func addGroup() {
        let name = inputName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = store.addGroup(name: name)
        inputName = ""
    }

    private func renameGroup() {
        let name = inputName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let target = renameTarget else { return }
        store.renameGroup(target, to: name)
        renameTarget = nil
        inputName = ""
    }

    private func deleteGroup(_ group: Group) {
        store.deleteGroup(group)
        if case .group(let g) = selection, g.id == group.id {
            selection = .all
        }
    }
}
