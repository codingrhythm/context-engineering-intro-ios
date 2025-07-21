1. What’s New in Swift 6 Concurrency?
Swift 6 doubles down on strict concurrency checking to eliminate data races and undefined behavior. Key updates include:

Stricter @MainActor Enforcement: The compiler now aggressively flags UI updates not explicitly marked as @MainActor.
Complete Task Isolation: Functions and properties must declare actor isolation explicitly.
Global Actor Customization: Better control over global actors like @MainActor or custom ones.
Improved Diagnostics: Clearer warnings for thread-unsafe code.
2. Real-World Migration Challenges (Xcode 15 → 16)
When upgrading to Xcode 16, you’ll encounter new warnings and errors. Here’s how to handle common scenarios:

Example 1: Implicit @MainActor Warnings
Scenario: A view model updates UI elements but isn’t marked with @MainActor, leading to warnings like:
"Main actor-isolated property 'title' cannot be mutated from a non-isolated context".

Before Fix:
```swift
class ProfileViewModel {
    var title: String = "" // ❌ Warning: Not main actor-isolated
    
    func loadData() async {
        let data = await fetchData()
        title = data.title // ❌ Error: Mutation from non-isolated context
    }
}
```

After Fix:
```swift
@MainActor // Explicitly mark the entire class as main actor-isolated
class ProfileViewModel: ObservableObject {
    @Published var title: String = ""
    
    func loadData() async {
        let data = await fetchData()
        title = data.title // ✅ Executes on main thread
    }
}
```

Example 2: Thread-Hopping with DispatchQueue
Scenario: Legacy code uses DispatchQueue.main.async to update UI elements. Swift 6 flags this as unsafe if not wrapped in MainActor.

Before Fix:
```swift
func updateUI() {
    DispatchQueue.main.async { // ❌ Warning: Prefer MainActor.run
        self.label.text = "Hello"
    }
}
```

After Fix:
```swift
func updateUI() async {
    await MainActor.run { // ✅ Thread-safe
        self.label.text = "Hello"
    }
}
```

Example 3: Global State Without Isolation
Scenario: A shared UserDefaults manager is accessed from multiple threads, triggering warnings like:
"Shared mutable state accessed without concurrency protection".

Before Fix:
```swift
class SettingsManager {
    static let shared = SettingsManager()
    var theme: String = "light" // ❌ Warning: Not thread-safe
}
```

After Fix:
```swift
@globalActor
struct SettingsActor {
    actor ActorType { }
    static let shared = ActorType()
}

@SettingsActor // Custom global actor for thread safety
class SettingsManager {
    static let shared = SettingsManager()
    var theme: String = "light" // ✅ Isolated to SettingsActor
}
```

3. Common Warnings and Fixes
Warning 1: Non-sendable type used in @MainActor context
"Non-sendable type 'ViewController' passed in implicitly asynchronous call to main actor-isolated method"

Fix:
```swift
class ViewController: UIViewController {
    func onButtonTap() {
        Task { @MainActor in // ✅ Isolate the Task
            self.updateUI()
        }
    }
    
    @MainActor
    func updateUI() { ... }
}
```

Warning 2: Capturing self in a @Sendable closure
"Capture of 'self' with non-sendable type 'MyClass' in a @Sendable closure"

Fix:
```swift
Task { [weak self] in // ✅ Weak capture to avoid retain cycles
    guard let self else { return }
    await self.fetchData()
}
```

Warning 3: Non-Sendable type in concurrent context
"Function cannot be marked as '@Sendable' due to non-sendable parameter of type 'DataModel'"

Fix:
```swift
struct DataModel: Sendable { // ✅ Thread-safe
    let id: UUID
    let value: String
}
```

4. Debugging Concurrency in Xcode 16
Swift 6 introduces powerful tools to diagnose concurrency issues:

1. Thread Sanitizer (TSan) Enhancements
TSan now detects data races in Swift concurrency code. Enable it via:
Product > Scheme > Edit Scheme > Diagnostics > Thread Sanitizer.

2. Task Tracing
Visualize task lifecycles with:
```swift
await withTaskTracing {
    await fetchUserData()
}
```
3. -strict-concurrency Compiler Flag
Enable strict concurrency checking in Build Settings:

SWIFT_STRICT_CONCURRENCY = complete
5. Best Practices for Migrating Legacy Code
Incremental Adoption: Use @preconcurrency import for third-party libraries not yet updated for Swift 6.
Audit with Compiler Warnings: Treat warnings as errors (SWIFT_TREAT_WARNINGS_AS_ERRORS = YES).
Replace DispatchQueue with Actors: Migrate GCD-based code to Swift’s native actor or @MainActor.
Adopt Sendable Gradually: Mark thread-safe types as Sendable to enable compiler optimizations.
