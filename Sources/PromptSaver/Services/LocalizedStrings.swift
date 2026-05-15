struct LocalizedStrings {
    let language: Language

    init(_ language: Language) {
        self.language = language
    }

    // MARK: - Sidebar

    var allPrompts: String {
        switch language {
        case .english: return "All Prompts"
        case .chinese: return "全部提示词"
        }
    }

    var tags: String {
        switch language {
        case .english: return "Tags"
        case .chinese: return "标签"
        }
    }

    var deleteTag: String {
        switch language {
        case .english: return "Delete Tag"
        case .chinese: return "删除标签"
        }
    }

    var newTag: String {
        switch language {
        case .english: return "New Tag"
        case .chinese: return "新建标签"
        }
    }

    var newTagPrompt: String {
        switch language {
        case .english: return "Enter tag name:"
        case .chinese: return "输入标签名称："
        }
    }

    // MARK: - Content / List

    var noPromptSelected: String {
        switch language {
        case .english: return "No Prompt Selected"
        case .chinese: return "未选择提示词"
        }
    }

    var selectPromptHint: String {
        switch language {
        case .english: return "Select a prompt from the list or create a new one."
        case .chinese: return "从列表中选择一个提示词，或创建一个新的。"
        }
    }

    var noMatches: String {
        switch language {
        case .english: return "No Matches"
        case .chinese: return "无匹配结果"
        }
    }

    var noMatchesHint: String {
        switch language {
        case .english: return "No prompts match your search or filter."
        case .chinese: return "没有提示词匹配您的搜索或筛选条件。"
        }
    }

    var noPromptsYet: String {
        switch language {
        case .english: return "No Prompts Yet"
        case .chinese: return "暂无提示词"
        }
    }

    var createFirstHint: String {
        switch language {
        case .english: return "Press Cmd+N to create your first prompt."
        case .chinese: return "按 Cmd+N 创建您的第一个提示词。"
        }
    }

    var copyContent: String {
        switch language {
        case .english: return "Copy Content"
        case .chinese: return "复制内容"
        }
    }

    var delete: String {
        switch language {
        case .english: return "Delete"
        case .chinese: return "删除"
        }
    }

    var prompts: String {
        switch language {
        case .english: return "Prompts"
        case .chinese: return "提示词"
        }
    }

    // MARK: - Detail

    var copied: String {
        switch language {
        case .english: return "Copied"
        case .chinese: return "已复制"
        }
    }

    var copy: String {
        switch language {
        case .english: return "Copy"
        case .chinese: return "复制"
        }
    }

    var edit: String {
        switch language {
        case .english: return "Edit"
        case .chinese: return "编辑"
        }
    }

    // MARK: - Edit Sheet

    var newPrompt: String {
        switch language {
        case .english: return "New Prompt"
        case .chinese: return "新建提示词"
        }
    }

    var editPrompt: String {
        switch language {
        case .english: return "Edit Prompt"
        case .chinese: return "编辑提示词"
        }
    }

    var promptSection: String {
        switch language {
        case .english: return "Prompt"
        case .chinese: return "提示词"
        }
    }

    var titlePlaceholder: String {
        switch language {
        case .english: return "Title"
        case .chinese: return "标题"
        }
    }

    var tagsSection: String {
        switch language {
        case .english: return "Tags"
        case .chinese: return "标签"
        }
    }

    var addTag: String {
        switch language {
        case .english: return "Add Tag"
        case .chinese: return "添加标签"
        }
    }

    var selectTag: String {
        switch language {
        case .english: return "Select a tag..."
        case .chinese: return "选择标签..."
        }
    }

    var newTagName: String {
        switch language {
        case .english: return "New tag name"
        case .chinese: return "新标签名称"
        }
    }

    var add: String {
        switch language {
        case .english: return "Add"
        case .chinese: return "添加"
        }
    }

    var cancel: String {
        switch language {
        case .english: return "Cancel"
        case .chinese: return "取消"
        }
    }

    var save: String {
        switch language {
        case .english: return "Save"
        case .chinese: return "保存"
        }
    }

    // MARK: - Settings

    var preferences: String {
        switch language {
        case .english: return "Preferences"
        case .chinese: return "偏好设置"
        }
    }

    var languageLabel: String {
        switch language {
        case .english: return "Language"
        case .chinese: return "语言"
        }
    }

    var searchPlaceholder: String {
        switch language {
        case .english: return "Search prompts..."
        case .chinese: return "搜索提示词..."
        }
    }
}
