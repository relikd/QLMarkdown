import Cocoa

class Document: NSDocument, NSWindowDelegate {
	let web = WebViewer()
	
	override var isInViewingMode: Bool {true}
	override nonisolated class var autosavesInPlace: Bool {true}
	
	override func makeWindowControllers() {
		let window = NSWindow(contentViewController: web)
		addWindowController(NSWindowController(window: window))
		restoreWindowSize(window)
		window.makeKeyAndOrderFront(nil)
		window.delegate = self
	}
	
	func windowDidResize(_ notification: Notification) {
		persistWindowSize(notification.object as! NSWindow)
	}
	
	override nonisolated func read(from url: URL, ofType typeName: String) throws {
		try MainActor.assumeIsolated {
			try web.load(fromFile: url)
		}
	}
	
	// MARK: - Window resize
	
	/// Save current window size to user-defaults
	func persistWindowSize(_ win: NSWindow) {
		UserDefaults.standard.set(Int(win.frame.width), forKey: "winSizeW")
		UserDefaults.standard.set(Int(win.frame.height), forKey: "winSizeH")
	}
	
	/// Restore previous window size
	func restoreWindowSize(_ win: NSWindow) {
		let w = UserDefaults.standard.integer(forKey: "winSizeW")
		let h = UserDefaults.standard.integer(forKey: "winSizeH")
		if w > 0 && h > 0 {
			win.setFrame(CGRect(origin: win.frame.origin, size: .init(width: w, height: h)), display: true)
		}
	}
}

