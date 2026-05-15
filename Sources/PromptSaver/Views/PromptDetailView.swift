import SwiftUI

struct PromptDetailView: View {
    @EnvironmentObject private var store: DataStore
    let prompt: Prompt
    @State private var isEditing = false
    @State private var showCopiedFeedback = false

    private var promptTags: [Tag] {
        store.tags(for: prompt)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(prompt.title)
                    .font(.largeTitle)
                    .bold()

                if !promptTags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(promptTags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                }

                Divider()

                Text(prompt.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    copyToClipboard()
                } label: {
                    Label(
                        showCopiedFeedback ? "Copied" : "Copy",
                        systemImage: showCopiedFeedback ? "checkmark" : "doc.on.doc"
                    )
                }
                .disabled(showCopiedFeedback)

                Button("Edit", systemImage: "pencil") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PromptEditView(editingPrompt: prompt)
                .environmentObject(store)
        }
        .navigationTitle(prompt.title)
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt.content, forType: .string)
        showCopiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedFeedback = false
        }
    }
}
