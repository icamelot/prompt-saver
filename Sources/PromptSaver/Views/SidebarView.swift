import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selection: SidebarSelection

    @State private var newNameInput = ""
    @State private var showNewSessionAlert = false
    @State private var showNewGroupAlert = false

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    var body: some View {
        List(selection: $selection) {
            Label(s.allPrompts, systemImage: "tray.full")
                .tag(SidebarSelection.all)

            Section(s.sessions) {
                ForEach(sessionsSorted) { session in
                    Label(session.name, systemImage: "folder")
                        .badge(store.sessionPromptCount(for: session))
                        .tag(SidebarSelection.session(session))
                        .contextMenu {
                            Button(s.deleteSession, role: .destructive) {
                                deleteSession(session)
                            }
                        }
                }
            }

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
            Button(s.newSession) {
                newNameInput = ""
                showNewSessionAlert = true
            }
            Button(s.newGroup) {
                newNameInput = ""
                showNewGroupAlert = true
            }
        }
        .alert(s.newSession, isPresented: $showNewSessionAlert) {
            TextField(s.newGroupName, text: $newNameInput)
            Button(s.cancel, role: .cancel) {}
            Button(s.add) { addSession() }
        }
        .alert(s.newGroup, isPresented: $showNewGroupAlert) {
            TextField(s.newGroupName, text: $newNameInput)
            Button(s.cancel, role: .cancel) {}
            Button(s.add) { addGroup() }
        }
    }

    private var sessionsSorted: [Session] {
        store.sessions.sorted { $0.createdAt > $1.createdAt }
    }

    private var groupsSorted: [Group] {
        store.groups.sorted { $0.name < $1.name }
    }

    private func addSession() {
        let name = newNameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = store.addSession(name: name)
        newNameInput = ""
    }

    private func addGroup() {
        let name = newNameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = store.addGroup(name: name)
        newNameInput = ""
    }

    private func deleteSession(_ session: Session) {
        store.deleteSession(session)
        if case .session(let s) = selection, s.id == session.id {
            selection = .all
        }
    }

    private func deleteGroup(_ group: Group) {
        store.deleteGroup(group)
        if case .group(let g) = selection, g.id == group.id {
            selection = .all
        }
    }
}
