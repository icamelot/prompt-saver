import SwiftUI

struct PromptEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DataStore

    let editingPrompt: Prompt?

    @State private var title: String
    @State private var content: String
    @State private var selectedTagIds: Set<UUID>
    @State private var newTagName: String = ""

    private var availableTags: [Tag] {
        store.tags
            .filter { !selectedTagIds.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    private var selectedTags: [Tag] {
        store.tags.filter { selectedTagIds.contains($0.id) }
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
            || content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(editingPrompt: Prompt?) {
        self.editingPrompt = editingPrompt
        _title = State(initialValue: editingPrompt?.title ?? "")
        _content = State(initialValue: editingPrompt?.content ?? "")
        _selectedTagIds = State(initialValue: editingPrompt?.tagIds ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Prompt") {
                    TextField("Title", text: $title)
                        .font(.title2)

                    TextEditor(text: $content)
                        .font(.body)
                        .frame(minHeight: 250)
                }

                Section("Tags") {
                    if !selectedTags.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(selectedTags.sorted(by: { $0.name < $1.name })) { tag in
                                TagPill(name: tag.name) {
                                    selectedTagIds.remove(tag.id)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if !availableTags.isEmpty {
                        Picker("Add Tag", selection: $newTagName) {
                            Text("Select a tag...").tag("")
                            ForEach(availableTags) { tag in
                                Text(tag.name).tag(tag.name)
                            }
                        }
                        .onChange(of: newTagName) { _, newValue in
                            if !newValue.isEmpty {
                                let tag = store.addTag(name: newValue)
                                selectedTagIds.insert(tag.id)
                                newTagName = ""
                            }
                        }
                    }

                    HStack {
                        TextField("New tag name", text: $newTagName)
                            .onSubmit { addNewTag() }
                        Button("Add") { addNewTag() }
                            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(editingPrompt == nil ? "New Prompt" : "Edit Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaveDisabled)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 450)
    }

    private func addNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let tag = store.addTag(name: name)
        selectedTagIds.insert(tag.id)
        newTagName = ""
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedContent = content.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else { return }

        if let prompt = editingPrompt {
            store.updatePrompt(prompt, title: trimmedTitle, content: trimmedContent, tagIds: selectedTagIds)
        } else {
            store.addPrompt(title: trimmedTitle, content: trimmedContent, tagIds: selectedTagIds)
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
