import Foundation

/// See <https://github.com/gjtorikian/html-pipeline/blob/f13a1534cb650ba17af400d1acd3a22c28004c09/lib/html/pipeline/toc_filter.rb#L30>
struct GithubSlugger {
	var previousSlugs = Set<String>()
	
	mutating func slugify(_ str: String) -> String {
		incr(Self.slugify(str))
	}
	
	mutating func incr(_ str: String) -> String {
		if !previousSlugs.contains(str) {
			previousSlugs.insert(str)
			return str
		}
		// else: increment index
		for i in 1..<999 {
			let nextTag = str + "-\(i)"
			if !previousSlugs.contains(nextTag) {
				previousSlugs.insert(nextTag)
				return nextTag
			}
		}
		return ""
	}
}

