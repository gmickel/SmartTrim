import Testing
@testable import SmartTrim

@Suite("TextHealer Tests")
struct TextHealerTests {

    let healer = TextHealer()

    @Test("Strips ghost indentation from lines")
    func stripGhostIndentation() {
        let input = "  Hello World"
        let result = healer.heal(input)
        #expect(result == "Hello World")
    }

    @Test("Rejoins hard-wrapped sentences")
    func rejoinHardWrappedSentences() {
        let input = """
          thanks again for the two very productive sessions on template acceleration and the SDLC / Copilot review. The
          combination of the Nova lane plus the SDLC uplift looks like a strong fit.
        """
        let result = healer.heal(input)
        #expect(result.contains("review. The combination"))
        #expect(!result.contains("review. The\n"))
    }

    @Test("Preserves paragraph breaks")
    func preserveParagraphBreaks() {
        let input = """
          First paragraph here.

          Second paragraph here.
        """
        let result = healer.heal(input)
        #expect(result.contains("\n\n"))
    }

    @Test("Preserves bullet list structure")
    func preserveBulletLists() {
        let input = """
          - First item
          - Second item
          - Third item
        """
        let result = healer.heal(input)
        let lines = result.components(separatedBy: "\n")
        #expect(lines.count == 3)
        #expect(lines[0].hasPrefix("- "))
        #expect(lines[1].hasPrefix("- "))
    }

    @Test("Preserves numbered list structure")
    func preserveNumberedLists() {
        let input = """
          1. First item
          2. Second item
          3. Third item
        """
        let result = healer.heal(input)
        let lines = result.components(separatedBy: "\n")
        #expect(lines.count == 3)
        #expect(lines[0].hasPrefix("1. "))
    }

    @Test("Rejoins continuation lines in lists")
    func rejoinListContinuations() {
        let input = """
          - Goal: get a clear baseline on idea→deploy, bug rates, and current AI usage (Copilot, prompts, instruction
            files), then design an agentic SDLC flow that actually fits how your teams work.
        """
        let result = healer.heal(input)
        #expect(result.contains("instruction files)"))
        #expect(!result.contains("instruction\n"))
    }

    @Test("Heals example1 malformed text correctly")
    func healExample1() {
        let input = """
          Hi Peter,

          thanks again for the two very productive sessions on template acceleration and the SDLC / Copilot review. The
          combination of the Nova lane plus the SDLC uplift looks like a strong fit.

          Quick recap of where we landed and a proposal for next steps:

          1. Starting lane – SDLC assessment (Jan)
              - Focus: non‑SAP lane (Nova / TypeScript) first, keep MSB/ABAP as a follow‑on.
              - Goal: get a clear baseline on idea→deploy, bug rates, and current AI usage (Copilot, prompts, instruction
                files), then design an agentic SDLC flow that actually fits how your teams work.
        """
        let result = healer.heal(input)

        #expect(result.hasPrefix("Hi Peter,"))
        #expect(result.contains("review. The combination"))
        #expect(result.contains("instruction files)"))
    }

    @Test("Heals example2 malformed text correctly")
    func healExample2() {
        let input = """
          Betreff: Nächste Schritte SDLC-Pilot – Terminvorschläge erbeten

          Hallo Peter,

          kurz zum Stand nach unserem Meeting vom 25.11.:

          Wir bereiten gerade den Assessmentplan (5–15 Tage) inkl. KPIs vor – Fokus auf Idea-to-Deploy-Zeit,
           Bug-Raten, AI-Adoption. Ziel bleibt Start im Januar.
        """
        let result = healer.heal(input)

        #expect(result.hasPrefix("Betreff:"))
        #expect(result.contains("Idea-to-Deploy-Zeit, Bug-Raten"))
    }

    @Test("Detects malformed text patterns")
    func detectMalformedText() {
        let malformed = """
          This is indented text that wraps
          across multiple lines without
          proper sentence endings
        """
        #expect(healer.looksLikeMalformed(malformed))

        let clean = "This is clean text on a single line."
        #expect(!healer.looksLikeMalformed(clean))
    }

    @Test("Handles empty input")
    func handleEmptyInput() {
        let result = healer.heal("")
        #expect(result == "")
    }

    @Test("Handles single line without changes")
    func handleSingleLine() {
        let input = "Single line without issues."
        let result = healer.heal(input)
        #expect(result == input)
    }

    @Test("Handles lines ending with slash or hyphen")
    func handleSlashHyphenContinuation() {
        let input = """
          - We'll draft a 5–15 day SDLC assessment scope (incl. KPIs, concrete workshop agenda, and the data/
            tooling we'll need from your side).
        """
        let result = healer.heal(input)
        #expect(result.contains("data/ tooling") || result.contains("data/tooling"))
    }

    @Test("Preserves bullet marker types")
    func preserveBulletMarkerTypes() {
        let input = """
        • Subject: Test
        - Another item
        * Star item
        """
        let result = healer.heal(input)
        #expect(result.contains("• Subject"))
        #expect(result.contains("- Another"))
        #expect(result.contains("* Star"))
    }

    @Test("Preserves shell backslash line continuations")
    func preserveBackslashContinuations() {
        let input = """
        curl -X POST https://api.example.com/upload \\
            --header "Content-Type: application/json" \\
            --header "Authorization: Bearer TOKEN" \\
            --data '{"name": "test"}'
        """
        let result = healer.heal(input)
        // Should preserve line breaks for shell commands
        let lines = result.components(separatedBy: "\n")
        #expect(lines.count == 4, "Shell commands with backslash continuations should preserve line breaks")
        #expect(lines[0].hasSuffix("\\"), "First line should end with backslash")
        #expect(lines[1].hasSuffix("\\"), "Second line should end with backslash")
    }

    @Test("Does not mangle multi-line shell commands")
    func doesNotMangleShellCommands() {
        let input = """
        docker run -d \\
            --name mycontainer \\
            --volume /host:/container \\
            myimage:latest
        """
        let result = healer.heal(input)
        // Should NOT join into single line with embedded backslashes
        #expect(!result.contains("\\ --name"), "Should not join backslash lines into single line")
        #expect(result.contains("\\"), "Should preserve backslashes")
    }
}
