# SmartTrim

macOS menu bar utility that fixes mangled clipboard text from AI coding assistants.

You know the problem: you're deep in Claude Code, Cursor, or Copilot, copy some text, paste it into Slack or Notion, and it's full of ghost indentation, hard line breaks mid-sentence, and weird formatting artifacts.

SmartTrim sits in your menu bar and fixes it automatically.

## Features

- **Auto-Trim** — Monitors clipboard, automatically cleans malformed text
- **Manual Trim** — Global hotkey (⌘⇧.) or menu bar button
- **Smart Detection** — Only processes text that looks broken
- **Preserves Structure** — Keeps lists, paragraphs, and intentional formatting

## What It Fixes

| Problem | Example |
|---------|---------|
| Ghost indentation | `    text with invisible leading spaces` |
| Hard-wrapped lines | `This sentence was\nbroken mid-flow` |
| Mixed formatting | Bullet points with broken continuations |

## Install

Download from [Releases](https://github.com/gmickel/SmartTrim/releases) or build from source:

```bash
brew install xcodegen
git clone https://github.com/gmickel/SmartTrim.git
cd SmartTrim
xcodegen && xcodebuild -scheme SmartTrim -configuration Release
```

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel

## Settings

- **Launch at Login** — Start automatically
- **Auto-Trim** — Enable/disable clipboard monitoring
- **Hotkey** — Customize the manual trim shortcut

## Tech

Swift 6, SwiftUI, strict concurrency. No Electron. No dependencies. ~500 lines.

## Author

**Gordon Mickel** — [mickel.tech](https://mickel.tech)

## License

MIT
