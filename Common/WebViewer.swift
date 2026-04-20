import WebKit
import Markdown // Document, HTMLFormatter
//import os // OSLog
//
//private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "preview-plugin")

extension URL {
	/// Folder for user modified html templates
	static let UserModDir: URL? =
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

/// Load resource file either from user documents dir (if exists) or app bundle (default).
func bundleFile(filename: String, ext: String) -> URL {
	if let userFile = URL.UserModDir?.appendingPathComponent(filename + "." + ext, isDirectory: false),
	   FileManager.default.fileExists(atPath: userFile.path) {
		return userFile
	}
	return Bundle.main.url(forResource: filename, withExtension: ext)!
}

class WebViewer: NSViewController, WKNavigationDelegate {
	let web = WKWebView()
	var url: URL? = nil
	let scapegoat = Bundle.main.url(forResource: "empty", withExtension: "txt")!
	
	override func loadView() {
		self.view = NSView(frame: NSMakeRect(0, 0, 800, 600))
	}
	
	override func viewDidLoad() {
		self.web.frame = self.view.bounds
		self.web.autoresizingMask = [.width, .height]
		self.web.navigationDelegate = self
		self.web.allowsBackForwardNavigationGestures = true
		self.view.addSubview(self.web)
	}
	
	func load(fromFile url: URL) throws {
		self.url = url
		// allow read access to all files under root "/"
		web.loadFileURL(scapegoat, allowingReadAccessTo: URL(string: "file:///")!)
		// loadHTMLString must wait until this request is fully loaded
		// see delegate method below
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if webView.url == scapegoat {
			try? reload()
		}
	}
	
	func reloadKeepScrollPosition() {
		web.evaluateJavaScript("window.pageYOffset") { pos, _ in
			try? self.reload(scrollTo: pos as? Int ?? 0)
		}
	}
	
	func reload(scrollTo: Int = 0) throws {
		guard let url else {
			return
		}
		let md = try Markdown.Document(parsing: url)
		let html = _html(md, footer: _footer(), scrollTo: scrollTo)
		// write debug output
		//try? html!.write(to: URL.UserModDir!.appendingPathComponent("debug.html", isDirectory: false), atomically: true, encoding: .utf8)
		web.loadHTMLString(html, baseURL: url)
	}
	
	// this should open links in external browser but it doesnt
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
		if UserDefaults.standard.bool(forKey: "openLinksInBrowser"),
		   navigationAction.navigationType == .linkActivated,
		   let url = navigationAction.request.url {
//			os_log(.debug, log: log, "open url %{public}@", String(describing: url))
			NSWorkspace.shared.open(url)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	// MARK: - Content
	
	private func _html(_ body: Markdown.Document, footer: String = "", scrollTo: Int = 0) -> String {
		"""
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" type="text/css" href="\(bundleFile(filename: "markdown", ext: "css"))" />
<link rel="stylesheet" type="text/css" href="\(bundleFile(filename: "style", ext: "css"))" />
</head>
<body class="markdown-body">
\(HTMLFormatter.format(body))
\(footer)
</body>
\(scrollTo > 0 ? "<script>scrollTo(0,\(scrollTo))</script>" : "")
</html>
"""
	}
	
	private func _footer() -> String {
		let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
		let buildVer = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
		return "<footer>relikd/QLMarkdown v\(ver) (\(buildVer))</footer>"
	}
}
