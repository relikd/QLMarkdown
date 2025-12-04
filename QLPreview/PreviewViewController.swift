import Cocoa
import Quartz // QLPreviewingController
import WebKit // WebView
import Markdown // Document, HTMLFormatter
//import os // OSLog
//
//private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "preview-plugin")

extension URL {
	/// Folder where user can mofifications to html template
	static let UserModDir: URL? =
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	
	/// Returns `true` if file or folder exists.
	@inlinable func exists() -> Bool {
		FileManager.default.fileExists(atPath: self.path)
	}
}


class PreviewViewController: NSViewController, QLPreviewingController, WKNavigationDelegate {
	var url: URL? = nil
	var html: String? = nil
	
	override var nibName: NSNib.Name? {
		return NSNib.Name("PreviewViewController")
	}
	
	/// Load resource file either from user documents dir (if exists) or app bundle (default).
	func bundleFile(filename: String, ext: String) throws -> URL {
		if let userFile = URL.UserModDir?.appendingPathComponent(filename + "." + ext, isDirectory: false), userFile.exists() {
			return userFile
		}
		return Bundle.main.url(forResource: filename, withExtension: ext)!
	}
	
	func preparePreviewOfFile(at url: URL) async throws {
		let cssUrl = try bundleFile(filename: "markdown", ext: "css")
		let md = try Document(parsing: url)
		self.url = url
		self.html = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" type="text/css" href="\(cssUrl)" />
</head>
<body class="markdown-body">
\(HTMLFormatter.format(md))
</body>
</html>
"""
		// write debug output
		//try? html!.write(to: URL.UserModDir!.appendingPathComponent("debug.html", isDirectory: false), atomically: true, encoding: .utf8)
		
		// create web view UI
		let web = WKWebView(frame: self.view.bounds)
		web.navigationDelegate = self
		web.autoresizingMask = [.width, .height]
		self.view.addSubview(web)
		
		// allow read access to all files under root "/"
		let emtpy = Bundle.main.url(forResource: "empty", withExtension: "txt")!
		web.loadFileURL(emtpy, allowingReadAccessTo: URL(string: "file:///")!)
		
		// loadHTMLString must wait until previous request is fully loaded
		// see delegate method below
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if webView.url?.lastPathComponent == "empty.txt" {
			webView.loadHTMLString(html!, baseURL: url)
			html = nil // free up memory
		}
	}
	
	// this should open links in external browser but it doesnt
//	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
//		if navigationAction.navigationType == .linkActivated,
//		   let url = navigationAction.request.url {
//			os_log(.debug, log: log, "open url %{public}@", String(describing: url))
//			NSWorkspace.shared.open(url)
//			decisionHandler(.cancel)
//		} else {
//			decisionHandler(.allow)
//		}
//	}
}
