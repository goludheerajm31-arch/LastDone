import SwiftUI

@main
struct LastDoneApp: App {
    @StateObject private var store = ActivityStore()

    var body: some Scene {
        WindowGroup {
            ActivityListView()
                .environmentObject(store)
        }
    }
}
