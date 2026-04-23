import Foundation
import Markdown

// TODO: implement custom html walker to fix: checkmark lists

public struct HTML: MarkupWalker {
	/// The resulting HTML built up after printing.
	public private(set) var result = ""
	
	private var inTableHead = false
	private var tableColumnAlignments: [Table.ColumnAlignment?]? = nil
	private var currentTableColumn = 0
	private var slugger = GithubSlugger()
	
	/// Format HTML for the given markup tree.
	public static func from(_ markup: Markup) -> String {
		var walker = HTML()
		walker.visit(markup)
		return walker.result
	}
	
	// MARK: Block elements
	
	public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> () {
		result += "<blockquote>\n"
		descendInto(blockQuote)
		result += "</blockquote>\n"
	}
	
	public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
		let lang: String
		if let language = codeBlock.language {
			lang = " class=\"language-\(language)\""
		} else {
			lang = ""
		}
		result += "<pre><code\(lang)>\(codeBlock.code)</code></pre>\n"
	}
		
	private var anchor_icon: String {
		"<span aria-hidden=\"true\" class=\"octicon octicon-link\"></span>"
	}
	
	public mutating func visitHeading(_ heading: Heading) -> () {
		let slug = slugger.slugify(heading.plainText)
		result += "<h\(heading.level)>"
		result += "<a id=\"\(slug)\" class=\"anchor\" href=\"#\(slug)\" aria-hidden=\"true\">\(anchor_icon)</a>\n"
		descendInto(heading)
		result += "</h\(heading.level)>\n"
	}
	
	public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
		result += "<hr />\n"
	}
	
	public mutating func visitHTMLBlock(_ html: HTMLBlock) -> () {
		result += html.rawHTML
	}
	
	public mutating func visitListItem(_ listItem: ListItem) -> () {
		result += "<li>"
		if let checkbox = listItem.checkbox {
			result += "<input type=\"checkbox\" disabled=\"\""
			if checkbox == .checked {
				result += " checked=\"\""
			}
			result += " /> "
		}
		descendInto(listItem)
		result += "</li>\n"
	}
	
	public mutating func visitOrderedList(_ orderedList: OrderedList) -> () {
		let start = orderedList.startIndex != 1 ? " start=\"\(orderedList.startIndex)\"" : ""
		result += "<ol\(start)>\n"
		descendInto(orderedList)
		result += "</ol>\n"
	}
	
	public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> () {
		result += "<ul>\n"
		descendInto(unorderedList)
		result += "</ul>\n"
	}
	
	public mutating func visitParagraph(_ paragraph: Paragraph) -> () {
		result += "<p>"
		descendInto(paragraph)
		result += "</p>\n"
	}
	
	public mutating func visitTable(_ table: Table) -> () {
		result += "<table>\n"
		tableColumnAlignments = table.columnAlignments
		descendInto(table)
		tableColumnAlignments = nil
		result += "</table>\n"
	}
	
	public mutating func visitTableHead(_ tableHead: Table.Head) -> () {
		result += "<thead>\n<tr>\n"
		inTableHead = true
		currentTableColumn = 0
		descendInto(tableHead)
		inTableHead = false
		result += "</tr>\n</thead>\n"
	}
	
	public mutating func visitTableBody(_ tableBody: Table.Body) -> () {
		if !tableBody.isEmpty {
			result += "<tbody>\n"
			descendInto(tableBody)
			result += "</tbody>\n"
		}
	}
	
	public mutating func visitTableRow(_ tableRow: Table.Row) -> () {
		result += "<tr>\n"
		currentTableColumn = 0
		descendInto(tableRow)
		result += "</tr>\n"
	}
	
	public mutating func visitTableCell(_ tableCell: Table.Cell) -> () {
		guard let alignments = tableColumnAlignments, currentTableColumn < alignments.count else { return }
		guard tableCell.colspan > 0 && tableCell.rowspan > 0 else { return }
		
		let tag = inTableHead ? "th" : "td"
		result += "<\(tag)"
		
		if let alignment = alignments[currentTableColumn] {
			result += " align=\"\(alignment)\""
		}
		currentTableColumn += 1
		
		if tableCell.rowspan > 1 {
			result += " rowspan=\"\(tableCell.rowspan)\""
		}
		if tableCell.colspan > 1 {
			result += " colspan=\"\(tableCell.colspan)\""
		}
		result += ">"
		descendInto(tableCell)
		result += "</\(tag)>\n"
	}
	
	// MARK: Inline elements
	
	mutating func printInline(tag: String, _ content: Markup) {
		result += "<\(tag)>"
		descendInto(content)
		result += "</\(tag)>"
	}
	
	public mutating func visitInlineCode(_ inlineCode: InlineCode) -> () {
		result += "<code>\(inlineCode.code)</code>"
	}
	
	public mutating func visitEmphasis(_ emphasis: Emphasis) -> () {
		printInline(tag: "em", emphasis)
	}
	
	public mutating func visitStrong(_ strong: Strong) -> () {
		printInline(tag: "strong", strong)
	}
	
	public mutating func visitImage(_ image: Image) -> () {
		result += "<img"
		if let source = image.source, !source.isEmpty {
			result += " src=\"\(source)\""
		}
		if let title = image.title, !title.isEmpty {
			result += " title=\"\(title)\""
		}
		result += " />"
	}
	
	public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> () {
		result += inlineHTML.rawHTML
	}
	
	public mutating func visitLineBreak(_ lineBreak: LineBreak) -> () {
		result += "<br />\n"
	}
	
	public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> () {
		result += "\n"
	}
	
	public mutating func visitLink(_ link: Link) -> () {
		result += "<a"
		if let destination = link.destination {
			result += " href=\"\(destination)\""
		}
		result += ">"
		descendInto(link)
		result += "</a>"
	}
	
	public mutating func visitText(_ text: Text) -> () {
		result += text.string
	}
	
	public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> () {
		printInline(tag: "del", strikethrough)
	}
	
	public mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> () {
		if let destination = symbolLink.destination {
			result += "<code>\(destination)</code>"
		}
	}
	
	public mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> () {
		result += "<span data-attributes=\"\(attributes.attributes.replacingOccurrences(of: "\"", with: "\\\""))\">"
		descendInto(attributes)
		result += "</span>"
	}
}
