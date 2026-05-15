APP_NAME = PromptSaver
BUNDLE_ID = com.icamelot.PromptSaver

.PHONY: build run release clean bundle

build:
	swift build

run:
	swift run

release:
	swift build -c release

clean:
	swift package clean
	rm -rf .build build tmp

# Create a proper .app bundle for distribution
bundle: release
	@mkdir -p "build/$(APP_NAME).app/Contents/MacOS"
	@mkdir -p "build/$(APP_NAME).app/Contents/Resources"
	@cp ".build/release/$(APP_NAME)" "build/$(APP_NAME).app/Contents/MacOS/"
	@cp "Resources/Info.plist" "build/$(APP_NAME).app/Contents/"
	@cp "Resources/AppIcon.icns" "build/$(APP_NAME).app/Contents/Resources/"
	@echo "Created build/$(APP_NAME).app"
	@echo "Run: open build/$(APP_NAME).app"
