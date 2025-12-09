import Foundation

struct TextHealer: Sendable {

    func heal(_ text: String) -> String {
        guard !text.isEmpty else { return text }

        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var currentParagraph = ""

        for line in lines {
            let trimmed = stripGhostIndentation(line)

            if trimmed.isEmpty {
                if !currentParagraph.isEmpty {
                    result.append(currentParagraph)
                    currentParagraph = ""
                }
                result.append("")
                continue
            }

            let isListItem = isListStart(trimmed)
            let isNumberedItem = isNumberedListStart(trimmed)
            let isNewStructuralElement = isListItem || isNumberedItem

            if currentParagraph.isEmpty {
                currentParagraph = trimmed
            } else if isNewStructuralElement {
                result.append(currentParagraph)
                currentParagraph = trimmed
            } else if shouldJoinWithPrevious(previous: currentParagraph, current: trimmed, originalLine: line) {
                currentParagraph += " " + trimmed
            } else {
                result.append(currentParagraph)
                currentParagraph = trimmed
            }
        }

        if !currentParagraph.isEmpty {
            result.append(currentParagraph)
        }

        return result.joined(separator: "\n")
    }

    private func stripGhostIndentation(_ line: String) -> String {
        var result = line

        while let first = result.first, first.isWhitespace {
            if first == "\u{00A0}" || first == " " || first == "\t" {
                result.removeFirst()
            } else {
                break
            }
        }

        return result
    }

    private func isListStart(_ line: String) -> Bool {
        let patterns = ["• ", "- ", "* ", "‣ ", "◦ "]
        return patterns.contains { line.hasPrefix($0) }
    }

    private func isNumberedListStart(_ line: String) -> Bool {
        let pattern = #"^\d+\.\s"#
        return line.range(of: pattern, options: .regularExpression) != nil
    }

    private func shouldJoinWithPrevious(previous: String, current: String, originalLine: String) -> Bool {
        // Preserve shell backslash line continuations
        if previous.hasSuffix("\\") {
            return false
        }

        let hadIndentation = originalLine.first?.isWhitespace == true

        let sentenceEnders: [Character] = [".", "!", "?", ":", ";"]
        let previousEndsWithTerminator = previous.last.map { sentenceEnders.contains($0) } ?? false

        let currentStartsLowercase = current.first?.isLowercase == true

        let isContinuationIndent = hadIndentation && !isListStart(current) && !isNumberedListStart(current)

        if isContinuationIndent {
            return true
        }

        if !previousEndsWithTerminator && currentStartsLowercase {
            return true
        }

        if previous.last == "/" || previous.last == "-" {
            return true
        }

        if !previousEndsWithTerminator && !isListStart(current) && !isNumberedListStart(current) {
            let words = previous.split(separator: " ")
            if let lastWord = words.last {
                let incompleteIndicators = ["the", "a", "an", "and", "or", "with", "for", "to", "of", "in", "on", "at", "(", ","]
                if incompleteIndicators.contains(String(lastWord).lowercased()) {
                    return true
                }
            }
        }

        return false
    }

    func looksLikeMalformed(_ text: String) -> Bool {
        let lines = text.components(separatedBy: "\n")
        guard lines.count > 2 else { return false }

        var indentedLineCount = 0
        var midSentenceBreakCount = 0

        for (index, line) in lines.enumerated() {
            if line.first?.isWhitespace == true && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                indentedLineCount += 1
            }

            if index > 0 {
                let prevLine = lines[index - 1]
                let trimmedPrev = prevLine.trimmingCharacters(in: .whitespaces)
                let trimmedCurrent = line.trimmingCharacters(in: .whitespaces)

                if !trimmedPrev.isEmpty && !trimmedCurrent.isEmpty {
                    let endsWithTerminator = [".", "!", "?", ":", ";"].contains { trimmedPrev.hasSuffix(String($0)) }
                    let startsLowercase = trimmedCurrent.first?.isLowercase == true

                    if !endsWithTerminator && startsLowercase {
                        midSentenceBreakCount += 1
                    }
                }
            }
        }

        let indentRatio = Double(indentedLineCount) / Double(lines.count)
        let hasManyIndentedLines = indentRatio > 0.5
        let hasMidSentenceBreaks = midSentenceBreakCount >= 2

        return hasManyIndentedLines || hasMidSentenceBreaks
    }
}
