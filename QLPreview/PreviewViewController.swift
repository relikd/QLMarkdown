import Cocoa
import Quartz // QLPreviewingController

class PreviewViewController: WebViewer, QLPreviewingController {
	func preparePreviewOfFile(at url: URL) async throws {
		try load(fromFile: url)
	}
}
