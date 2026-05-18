import SwiftUI

struct PromptEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var localeManager: LocaleManager

    let editingPrompt: Prompt?

    @State private var title: String
    @State private var content: String
    @State private var selectedGroupIds: Set<UUID>
    @State private var newGroupNameInput: String = ""

    private var s: LocalizedStrings { LocalizedStrings(localeManager.language) }

    private var availableGroups: [Group] {
        store.groups
            .filter { !selectedGroupIds.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    private var selectedGroups: [Group] {
        store.groups.filter { selectedGroupIds.contains($0.id) }
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
            || content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(editingPrompt: Prompt?) {
        self.editingPrompt = editingPrompt
        _title = State(initialValue: editingPrompt?.title ?? "")
        _content = State(initialValue: editingPrompt?.content ?? "")
        _selectedGroupIds = State(initialValue: editingPrompt?.groupIds ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(s.promptSection) {
                    TextField(s.titlePlaceholder, text: $title)
                        .font(.title2)

                    TextEditor(text: $content)
                        .font(.body)
                        .frame(minHeight: 250)
                }

                Section(s.groupsSection) {
                    if !selectedGroups.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(selectedGroups.sorted(by: { $0.name < $1.name })) { group in
                                TagPill(name: group.name) {
                                    selectedGroupIds.remove(group.id)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if !availableGroups.isEmpty {
                        Picker(s.addGroup, selection: $newGroupNameInput) {
                            Text(s.selectGroup).tag("")
                            ForEach(availableGroups) { group in
                                Text(group.name).tag(group.name)
                            }
                        }
                        .onChange(of: newGroupNameInput) { _, newValue in
                            if !newValue.isEmpty {
                                let group = store.addGroup(name: newValue)
                                selectedGroupIds.insert(group.id)
                                newGroupNameInput = ""
                            }
                        }
                    }

                    HStack {
                        TextField(s.newGroupName, text: $newGroupNameInput)
                            .onSubmit { addNewGroup() }
                        Button(s.add) { addNewGroup() }
                            .disabled(newGroupNameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(editingPrompt == nil ? s.newPrompt : s.editPrompt)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(s.save) { save() }
                        .disabled(isSaveDisabled)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 450)
    }

    private func addNewGroup() {
        let name = newGroupNameInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let group = store.addGroup(name: name)
        selectedGroupIds.insert(group.id)
        newGroupNameInput = ""
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedContent = content.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else { return }

        if let prompt = editingPrompt {
            store.updatePrompt(prompt, title: trimmedTitle, content: trimmedContent,
                               groupIds: selectedGroupIds)
        } else {
            store.addPrompt(title: trimmedTitle, content: trimmedContent,
                            groupIds: selectedGroupIds)
        }
        dismiss()
    }
}

// MARK: - Tag Pill Subview

private struct TagPill: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Simple Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return arrange(sizes: sizes, width: proposal.width ?? 0).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let result = arrange(sizes: sizes, width: bounds.width)
        for (index, offset) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(sizes: [CGSize], width: CGFloat) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0

        for size in sizes {
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += maxHeight + spacing
                maxHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        return (positions, CGSize(width: width, height: currentY + maxHeight))
    }
}
