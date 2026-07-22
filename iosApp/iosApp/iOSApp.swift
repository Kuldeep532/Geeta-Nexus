import SwiftUI
import shared  // KMP shared framework — built via ./gradlew shared:assembleReleaseXCFramework

@main
struct GeetaNexusApp: App {

    init() {
        // Inject Ed25519 private key from Info.plist / build settings
        // Add ED25519_PRIVATE_KEY to your Xcode scheme's environment variables
        // or embed it via a build phase script. NEVER hardcode here.
        if let key = Bundle.main.object(forInfoDictionaryKey: "ED25519PrivateKey") as? String {
            AppConfig.shared.ED25519_PRIVATE_KEY_BASE64 = key
        }

        KoinInitializerKt.doInitKoin()  // Start Koin DI for shared module
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
