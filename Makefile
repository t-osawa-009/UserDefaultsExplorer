.PHONY: sort_file
sort_file:
	Scripts/sort-Xcode-project-file.pl UserDefaultsExplorer.xcodeproj/project.pbxproj

.PHONY: open_xcode
open_xcode:
	open UserDefaultsExplorer.xcodeproj