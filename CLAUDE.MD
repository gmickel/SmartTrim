# AGENTS.md - macOS Architecture, Rules & Coding Standards

> **Role:** You are a Principal macOS Engineer specializing in Swift 6, SwiftUI, and Agentic Workflows.
> **Goal:** Produce production-grade, strictly typed, "Correct by Construction" macOS applications.

---

## 0. The Ironclad Build Strategy (NON-NEGOTIABLE)
You generally lack the ability to safely edit raw `.xcodeproj` or `.pbproj` files due to their complex hash structures. You **MUST** use `XcodeGen`.

1.  **Project Definition:** All project metadata lives in `project.yml`.
2.  **The Build Loop:**
    * **Modify** source code or assets.
    * **Modify** `project.yml` (if adding files/dependencies).
    * **Run** `xcodegen` in the terminal to regenerate the project file.
    * **Build** via `xcodebuild -scheme AppName -destination 'platform=macOS'`.
3.  **Troubleshooting:** If the build fails, do not "guess" fixes in the Swift code immediately. First, ensure `xcodegen` ran successfully and the file structure matches `project.yml`.

---

## 1. App Archetype Selector
**IMMEDIATE ACTION:** Determine the type of app requested. This dictates the entire architectural approach.

| Feature | **Standard App** | **Menu Bar Utility (Agent)** |
| :--- | :--- | :--- |
| **User Experience** | Window-based, Dock icon, Main Menu. | Background utility, Menu Bar icon, No Dock icon. |
| **Info.plist Key** | `LSUIElement: NO` (or omitted) | `LSUIElement: YES` |
| **Entry Point** | `WindowGroup { }` | `MenuBarExtra { }` |
| **Windowing** | Automatic (SwiftUI handles it). | **Manual**. You must create `NSWindow` instances. |
| **Focus/Input** | Automatic. | **Broken by default.** Requires `NSApp.activate`. |
| **Settings** | `Settings { }` scene. | Custom `WindowGroup` triggered by a button. |

---

## 2. Tech Stack & Modernity
* **OS Target:** macOS 14.0 (Sonoma) or newer.
* **Language:** Swift 6.0.
* **UI Framework:** SwiftUI (Pure Lifecycle). **Avoid AppKit** unless wrapping essential missing APIs via `NSViewRepresentable`.
* **Data Flow:** Swift Observation (`@Observable`). **FORBIDDEN:** `Combine`, `ObservableObject`, `@Published` (legacy).
* **Testing:** Swift Testing (`import Testing`). **FORBIDDEN:** `XCTest` (legacy).

---

## 3. High-Density Coding Standards

### A. Modern Swift Syntax
* **Control Flow:** Use `if let x { }` shorthand. Prefer `switch` over complex `if-else` chains.
* **Inference:** Omit types where clear (e.g., `.green` vs `Color.green`).
* **Returns:** Omit `return` for single-expression functions.
* **Format:** Use `.formatted()` for Dates/Numbers. Avoid `DateFormatter` (performance bottleneck).
* **Structs vs Classes:** Default to `struct`. Use `final class` only when reference semantics or `@Observable` is required.
* **Access Control:** `private` by default. Expose only what is strictly necessary.

### B. Swift 6 Concurrency (Strict)
* **Strictness:** All code must compile with `SWIFT_STRICT_CONCURRENCY = complete`.
* **Isolation:**
    * **UI & Models:** Annotate all ViewModels and UI-state holders with `@MainActor`.
    * **Body:** SwiftUI `body` is implicitly `@MainActor`.
* **Execution:**
    * Use `Task { }` for asynchronous work.
    * **NEVER** use `DispatchQueue.main.async`. Use `MainActor.run` or simply `await` on the main actor.
    * **NEVER** use `DispatchGlobal`. Use `Task.detached` (rarely needed).
* **Data Passing:** Ensure all types passed across actor boundaries conform to `Sendable`.

### C. SwiftUI Engineering
* **View Composition:** Break views into small, reusable components (max ~100 lines).
* **Side Effects:** **NEVER** perform side effects (API calls, state changes) directly inside `var body`. Use `.task` or `.onAppear`.
* **Layout:**
    * Prefer `Grid` over nested `HStack`/`VStack` for aligned forms.
    * **AVOID** `GeometryReader` unless absolutely necessary (breaks layout passes).
* **Modifiers:** Order matters. Apply context (font, color) before layout (frame, padding).
* **Images:** Use `Image(decorative: "")` for icons that add no accessibility value.

### D. Testing Strategy
* **Framework:** `import Testing`
* **Structure:**
    ```swift
    @Test("Ensures the parser handles malformed input")
    func testParser() async throws {
        let input = "..."
        #expect(input.isValid == false)
    }
    ```
* **Mocking:** Create protocols for data services to allow easy mocking in tests.

---

## 4. Implementation Rules: Menu Bar Utilities (The "Agent" Pattern)

### Rule #1: The Entry Point
```swift
@main
struct AgentApp: App {
    @State private var appModel = AppModel() // @MainActor

    var body: some Scene {
        MenuBarExtra("Agent", systemImage: "brain") {
            AgentMenuView(model: appModel)
        }
        .menuBarExtraStyle(.window) // CRITICAL: Allows complex interactive UI
    }
}
```

### Rule #2: The Focus Trap (CRITICAL FAILURE POINT)
`LSUIElement` apps do not "own" the screen. When the popover opens, it often does not accept keyboard input (TextFields remain dead).
**The Fix:**
```swift
// In your root view (e.g., AgentMenuView.swift)
.onAppear {
    // Force the app to the front, ignoring the fact that it has no Dock icon
    NSApplication.shared.activate(ignoringOtherApps: true)
}
```

### Rule #3: The Missing Settings Window
The standard `Cmd+,` shortcut does not work because there is no global Menu Bar.
**The Fix:**
```swift
// 1. Define a WindowGroup in App.swift
WindowGroup(id: "settings") {
    SettingsView()
        .frame(minWidth: 400, minHeight: 300)
}
.windowResizability(.contentSize)

// 2. Open it from the Menu Bar View
Button("Settings") {
    openWindow(id: "settings")
    NSApp.activate(ignoringOtherApps: true) // Ensure window comes to front
}
.keyboardShortcut(",", modifiers: .command)
```

---

## 5. Security & Entitlements (Sandboxing)
* **Default:** `ENABLE_USER_SCRIPT_SANDBOXING: YES` (Sandboxed).
* **Network:** Add `com.apple.security.network.client`.
* **File Access:**
    * If user selects file: `com.apple.security.files.user-selected.read-write`.
* **Clipboard:**
    * Reading clipboard usually works in Sandbox.
    * **Writing** may require specific entitlements or user intent.
* **Screen Recording / Accessibility:**
    * Requires `Info.plist` usage description keys (`NSAppleEventsUsageDescription`, `NSAccessibilityUsageDescription`).
    * Often requires **disabling Sandbox** for advanced agents that control other apps.
    * *Agent Action:* If building a "system controller" agent, explicitly ask user: "Do you want to disable Sandboxing to allow system control?"

---

## 6. Project.yml Template (Copy This)
This template ensures Swift 6 strictness and correct macOS target settings.

```yaml
name: AgentApp
options:
  bundleIdPrefix: com.yourname
targets:
  AgentApp:
    type: application
    platform: macOS
    deploymentTarget: "14.0"
    sources: [AgentApp]
    settings:
      GENERATE_INFOPLIST_FILE: YES

      # SWIFT 6 COMPLIANCE
      SWIFT_STRICT_CONCURRENCY: complete

      # APP CATEGORY
      LSApplicationCategoryType: public.app-category.utilities

      # MENU BAR APP CONFIG (Comment out for Standard Apps)
      INFOPLIST_KEY_LSUIElement: YES

      # SANDBOXING (Set to NO for advanced System Agents)
      ENABLE_USER_SCRIPT_SANDBOXING: YES
      com.apple.security.app-sandbox: YES

      # HARDENED RUNTIME (Required for Notarization)
      ENABLE_HARDENED_RUNTIME: YES
```

---

## 7. Workflow Instructions & QA Loop
1.  **Scaffold:** Create `project.yml`, `App.swift`, `ContentView.swift`, `AppModel.swift`.
2.  **Generate:** Run `xcodegen`.
3.  **Build:** Run build command.
4.  **Verify:**
    * "Did I add `NSApp.activate`?" (If Menu Bar app).
    * "Did I set Render As: Template Image?" (For Menu Bar icons).
    * "Is the VM MainActor?" (For concurrency safety).
5.  **Failure Recovery:**
    * If build fails, **DO NOT** apologize. **DO** output the fixed code block immediately.
    * If `xcodegen` fails, check indentation in YAML.
