import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localeManager: LocaleManager
    @State private var selectedLanguage: Language

    init() {
        _selectedLanguage = State(initialValue: .english)
    }

    var body: some View {
        let s = LocalizedStrings(selectedLanguage)

        TabView {
            Form {
                Section {
                    Picker(s.languageLabel, selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .onChange(of: selectedLanguage) { _, newValue in
                        localeManager.language = newValue
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("PromptSaver v1.0.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label(s.preferences, systemImage: "gearshape")
            }
            .onAppear {
                selectedLanguage = localeManager.language
            }
        }
        .frame(width: 400, height: 250)
    }
}
