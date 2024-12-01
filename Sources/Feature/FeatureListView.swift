import SwiftUI

public struct FeatureListView: View {
    public init() {}
    public var body: some View {
        List {
            NavigationLink("GCD") {
                GCDView()
            }
        }
        .navigationBarTitle("Feature List")
    }
}
