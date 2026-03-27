import Foundation

enum MarkdownStripper {
    static func strip(_ text: String) -> String {
        text.components(separatedBy: "\n").compactMap { line in
            var l = line

            if l.hasPrefix("#") {
                l = l.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
            }

            l = l.replacingOccurrences(of: "**", with: "")
            l = l.replacingOccurrences(of: "__", with: "")
            l = l.replacingOccurrences(of: "*", with: "")
            l = l.replacingOccurrences(of: "_", with: "")
            l = l.replacingOccurrences(of: "`", with: "")

            while let openBracket = l.range(of: "["),
                  let closeBracket = l.range(of: "]", range: openBracket.upperBound..<l.endIndex),
                  let openParen = l.range(of: "(", range: closeBracket.upperBound..<l.endIndex),
                  openParen.lowerBound == closeBracket.upperBound,
                  let closeParen = l.range(of: ")", range: openParen.upperBound..<l.endIndex) {
                let linkText = String(l[openBracket.upperBound..<closeBracket.lowerBound])
                l.replaceSubrange(openBracket.lowerBound..<closeParen.upperBound, with: linkText)
            }

            // Filter out stage directions like [SHOW: ...] or [CUT TO: ...]
            let trimmed = l.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") { return nil }

            return l
        }.joined(separator: "\n")
    }
}
