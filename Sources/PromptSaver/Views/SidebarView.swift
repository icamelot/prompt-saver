import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager
    @Binding var selection: SidebarSelection

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    var body: some View {
        List(selection: $selection) {
            Label(s.allPrompts, systemImage: "tray.full")
                .tag(SidebarSelection.all)

            Section(s.tags) {
                ForEach(store.tags.sorted(by: { $0.name < $1.name })) { tag in
                    Label(tag.name, systemImage: "tag")
                        .badge(store.tagCount(for: tag))
                        .tag(SidebarSelection.tag(tag))
                        .contextMenu {
                            Button(s.deleteTag, role: .destructive) {
                                deleteTag(tag)
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func deleteTag(_ tag: Tag) {
        store.deleteTag(tag)
        if case .tag(let selected) = selection, selected.id == tag.id {
            selection = .all
        }
    }
}
