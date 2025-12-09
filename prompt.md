# Task: Build SmartTrim (System Integration Benchmark)

Context:
You are to build a macOS Menu Bar utility called SmartTrim. You must strictly follow the architectural rules and coding standards provided in the context (AGENTS.md), specifically using XcodeGen, Swift 6, LSUIElement architecture, and the required focus fixes.

The Input Data:
I have provided two files in the context: example1.txt and example2.txt. These contain real-world malformed text copied from AI agents.

The Problem:
The text has specific defects:
1. Ghost Indentation: Random non-breaking spaces or tabs at the start of lines.
2. Hard Wrapping: Sentences are broken by newlines in the middle of a thought.
3. Broken Lists: Bullet points are split across lines.

The Goal:
Build a headless menu bar app (no main window) that cleans clipboard text based on a smart heuristic derived from these files.

Requirements:

1. Heuristic Logic (Inference Required)
- Analyze example1.txt and example2.txt to derive a TextHealer class.
- It must intelligently fix broken paragraph wrapping and strip ghost indentation without merging valid lists or distinct paragraphs.
- Test Suite: You must write a Swift Testing suite (import Testing) that validates your heuristic against the provided examples before you build the app. The tests must pass.

2. User Interface (Menu Bar Only)
- The menu must be minimal:
-- Status Item: Auto-Trim: [On/Off] (Toggle)
-- Action Item: Trim Clipboard Now (Manual trigger)
-- Divider
-- Settings Item: Settings... (Opens a separate window)
-- Quit

3. Functionality Modes
- Auto-Trim Mode: If enabled, the app silently observes the clipboard. If it detects text matching the malformed pattern, it cleans it and updates the clipboard automatically.
- Manual Mode: The user copies text, then hits a Global Hotkey or clicks the menu item to clean the current clipboard content.

4. Settings Window (System Integration)
- Implement a dedicated Settings Window.
- Launch at Login: Use the modern SMAppService API (macOS 13+) to toggle this.
- Hotkey Configuration: Allow the user to record/define the Global Hotkey for the manual trim action.

5. Architecture
- Use XcodeGen for the project structure.
- Ensure Strict Concurrency (Swift 6).
- Use MenuBarExtra with .window style (or standard menu style if UI is not complex) but ensure the Settings window is handled via WindowGroup and properly activated.

Deliverable:
1. Analyze the text patterns in the files.
2. Write the TextHealer logic and Tests.
3. Generate the Project structure (project.yml) and implement the App.
