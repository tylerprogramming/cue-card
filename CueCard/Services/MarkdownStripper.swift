import Foundation

enum MarkdownStripper {
    static func strip(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")

        lines = lines.map { line in
            var l = line

            // Remove heading markers
            if l.hasPrefix("#") {
                l = l.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
            }

            // Remove bold/italic markers
            l = l.replacingOccurrences(of: "**", with: "")
            l = l.replacingOccurrences(of: "__", with: "")
            l = l.replacingOccurrences(of: "*", with: "")
            l = l.replacingOccurrences(of: "_", with: "")

            // Remove inline code
            l = l.replacingOccurrences(of: "`", with: "")

            // Remove links [text](url) -> text
            while let openBracket = l.range(of: "["),
                  let closeBracket = l.range(of: "]", range: openBracket.upperBound..<l.endIndex),
                  let openParen = l.range(of: "(", range: closeBracket.upperBound..<l.endIndex),
                  openParen.lowerBound == closeBracket.upperBound,
                  let closeParen = l.range(of: ")", range: openParen.upperBound..<l.endIndex) {
                let linkText = String(l[openBracket.upperBound..<closeBracket.lowerBound])
                l.replaceSubrange(openBracket.lowerBound..<closeParen.upperBound, with: linkText)
            }

            return l
        }

        // Remove stage directions like [SHOW: ...] or [CUT TO: ...]
        lines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                return false
            }
            return true
        }

        return lines.joined(separator: "\n")
    }
}
