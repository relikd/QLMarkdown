# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project does adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.2] – 2026-04-27
Fixed:
- Escape html code in code blocks (e.g. `&lt;&amp;&gt;`)


## [1.1.1] – 2026-04-25
Fixed:
- Escape html code in text (e.g. `&lt;&amp;&gt;`)


## [1.1.0] – 2026-04-24
Added:
- Drag-n-drop onto document to open another document
- Support for `.markdown-alert`
	```md
	> [!INFO]
	> your note
	```

Fixed:
- Links inside of headings
- Slugs for headings to allow fragment links
- Styling of checkmark lists

Changed:
- Modern app icon


## [1.0.0] – 2026-04-22
Added:
- Open Markdown files with the companion app
- Auto-reload on file change (in App)
- Open file for editing in another app (⌘E)
- Save as HTML


## [0.9.2] – 2025-12-12
Changed:
- Remove github link from preview footer. Too distracting / too prominent. A version note should be discreet and not get in the way.


## [0.9.1] – 2025-12-04
Added:
- Plugin version in preview footer
- Separate `style.css` to make overwrites easier


## [0.9.0] – 2025-12-04
Initial release


[1.1.2]: https://github.com/relikd/QLMarkdown/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/relikd/QLMarkdown/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/relikd/QLMarkdown/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/relikd/QLMarkdown/compare/v0.9.2...v1.0.0
[0.9.2]: https://github.com/relikd/QLMarkdown/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/relikd/QLMarkdown/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/relikd/QLMarkdown/tree/v0.9.0
