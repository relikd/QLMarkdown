[![macOS 10.15+](https://img.shields.io/badge/macOS-10.15+-888)](#)
[![Current release](https://img.shields.io/github/release/relikd/QLMarkdown)](https://github.com/relikd/QLMarkdown/releases/latest)
[![All downloads](https://img.shields.io/github/downloads/relikd/QLMarkdown/total)](https://github.com/relikd/QLMarkdown/releases)

<img src="resources/AppIcon.svg" width="180" height="180">


QLMarkdown
==========

QuickLook plugin for Markdown files.

![screenshot](resources/screenshot.jpg)

Stupidly simple.
No configuration options, just Github flavored Markdown.
But if you insist on modifying the stylesheet, you have full control over that.


Installation
------------

Requires macOS Catalina (10.15) or higher.

```sh
brew install --cask relikd/tap/relikd-qlmarkdown
xattr -d com.apple.quarantine /Applications/QLMarkdown.app
```

or download from [releases](https://github.com/relikd/QLMarkdown/releases/latest).


Features
--------

- Small app size (6 MB)
- Dark Mode
- Auto-reload on file change (in App)
- Customizable html output

![auto-reload on file change](resources/auto-reload.gif)


### How to customize CSS

1. Right click on the app and select "Show Package Contents"
2. Open `Contents/Resources` and copy `style.css` (or `markdown.css`)
3. Open `~/Library/Containers/de.relikd.QLMarkdown.Preview/Data/Documents/`
4. Paste the previous file(s) and modify it to your liking (e.g. change text colors)

To modify the app preview, the procedure is mostly the same, except in step 3 the path is:
```
~/Library/Containers/de.relikd.QLMarkdown/Data/Documents/
```


Scope of this project
---------------------

This plugin is a wrapper around `swift-markdown` (which uses `cmark-gfm`) to convert markdown into html.
No external binary is bundled into the app, everything is compiled directly into the app bundle.
Output of the convert is passed, as is, to the preview window.
Styling is applied via CSS (customizable) and mimics the GitHub stylesheet.

There wont be any configuration options, nor finetuning which options are active, and no additional features.
If you want customizations, you can write your own css file.


Dependencies
------------

- <https://github.com/swiftlang/swift-markdown> (Apache 2.0)
- <https://github.com/sindresorhus/github-markdown-css> (MIT)


Privacy & Security
------------------

Entitlements for the plugin allows access to all files (see [App Sandbox Temporary Exception Entitlements](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html)).
This enables referencing local files (e.g., image, etc).

However, this is also a privacy risk.
A malicious QL plugin could send arbitrary file contents to a remote server.
Be careful what plugins you install. Especially if it has both entitlements `com.apple.security.temporary-exception.files` and `com.apple.security.network.client`.
Lucky for you, this open source project is very small and easy to review.
