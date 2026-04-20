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
	var html: String? = nil
	
	override func loadView() {
		self.view = NSView(frame: NSMakeRect(0, 0, 800, 600))
	}
	
	override func viewDidLoad() {
		self.web.frame = self.view.bounds
		self.web.autoresizingMask = [.width, .height]
		self.web.navigationDelegate = self
		self.view.addSubview(self.web)
	}
	
	func load(fromFile url: URL) throws {
		let md = try Markdown.Document(parsing: url)
		
		let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
		let buildVer = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
		
		self.url = url
		self.html = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" type="text/css" href="\(bundleFile(filename: "markdown", ext: "css"))" />
<link rel="stylesheet" type="text/css" href="\(bundleFile(filename: "style", ext: "css"))" />
</head>
<body class="markdown-body">
\(HTMLFormatter.format(md))

<footer>
relikd/QLMarkdown v\(ver) (\(buildVer))
</footer>
</body>
</html>
"""
		// write debug output
		//try? html!.write(to: URL.UserModDir!.appendingPathComponent("debug.html", isDirectory: false), atomically: true, encoding: .utf8)
		
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
