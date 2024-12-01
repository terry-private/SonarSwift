import SwiftUI
import Feature

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeatureListView()
            }
        }
    }
}
