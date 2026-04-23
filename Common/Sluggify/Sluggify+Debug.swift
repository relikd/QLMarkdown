import Foundation

#if DEBUG && false

private extension GithubSlugger {
	/// Download fixture from <https://github.com/Flet/github-slugger/blob/master/test/fixtures.json>
	static func testVerify(debug: Bool = true) throws {
		var slugger = GithubSlugger()
		let path = Bundle.main.url(forResource: "fixtures", withExtension: "json")!
		let json = try JSONSerialization.jsonObject(with: Data(contentsOf: path)) as! [[String: String]]
		for x in json {
			let test_name = x["name"]!
			let input = x["input"]!
			let expected = x["expected"]!
			let slug = slugger.slugify(input)
			if debug {
//				if test_name == "Unassigned" { continue }
				
				print("testing \(test_name) ", terminator: "")
				if slug == expected {
					print("✅")
				} else {
					print("❌")
					print("==== expected =========================")
					print(expected)
					print("==== actual ===========================")
					print(slug)
					print("==== character diff ===================")
					zip(expected, slug).filter { $0 != $1 }.prefix(6).forEach {
						print("should be: \($0) [\($0.unicodeString)], but got: \($1) [\($1.unicodeString)]")
					}
					return
				}
			}
		}
		if debug {
			print("done. success.")
		}
	}
}

private extension Character {
	var unicodeString: String {
		unicodeScalars.map{ "\\u{" + String($0.value, radix: 16) + "}" }.joined()
	}
}

// MARK: entry point

func sluggerVerifyCorrectness() {
	try? GithubSlugger.testVerify()
}

func sluggerVerifyPerformance() {
	let ts = Date().timeIntervalSince1970
	for _ in 0...99 {
		try? GithubSlugger.testVerify(debug: false)
	}
	print(Date().timeIntervalSince1970 - ts)
}

#endif
