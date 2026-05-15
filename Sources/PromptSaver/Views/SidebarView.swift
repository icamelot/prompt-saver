import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: DataStore
    @Binding var selection: SidebarSelection

    var body: some View {
        List(selection: $selection) {
            Label("All Prompts", systemImage: "tray.full")
                .tag(SidebarSelection.all)

            Section("Tags") {
                ForEach(store.tags.sorted(by: { $0.name < $1.name })) { tag in
                    Label(tag.name, systemImage: "tag")
                        .badge(store.tagCount(for: tag))
                        .tag(SidebarSelection.tag(tag))
                        .contextMenu {
                            Button("Delete Tag", role: .destructive) {
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
