import SwiftUI

@main
@MainActor
struct ObservableObjectCaptureSessionApp: App {
    @State private var appDataModel = AppDataModel()
//    @StateObject private var appDataModel = AppDataModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDataModel)
//                .environmentObject(appDataModel)
        }
    }
}
