import Foundation

struct ScriptSection: Identifiable, Equatable {
    let id: Int
    let title: String?
    let body: String
}

enum MarkdownStripper {
    static func strip(_ text: String) -> String {
        sections(from: text).map { $0.body }.joined(separator: "\n\n")
    }

    static func sections(from text: String) -> [ScriptSection] {
        let lines = text.components(separatedBy: "\n")
        var sections: [ScriptSection] = []
        var currentTitle: String? = nil
        var currentLines: [String] = []
        var index = 0

        func flushSection() {
            let body = stripLines(currentLines)
            if !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sections.append(ScriptSection(id: index, title: currentTitle, body: body))
                index += 1
            }
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Section break on ## headings or ---
            if trimmed.hasPrefix("##") || (trimmed == "---" || trimmed == "***" || trimmed == "___") {
                flushSection()
                if trimmed.hasPrefix("##") {
                    currentTitle = trimmed.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
                } else {
                    currentTitle = nil
                }
                currentLines = []
                continue
            }

            currentLines.append(line)
        }

        flushSection()

        if sections.isEmpty {
            sections.append(ScriptSection(id: 0, title: nil, body: ""))
        }

        return sections
    }

    private static func stripLines(_ lines: [String]) -> String {
        lines.compactMap { line in
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

            let trimmed = l.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") { return nil }

            return l
        }.joined(separator: "\n")
    }
}
