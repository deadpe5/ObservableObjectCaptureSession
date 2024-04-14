import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppDataModel.self) private var appDataModel
//    @EnvironmentObject private var appDataModel: AppDataModel
    
    @State private var count = 0
    
    var body: some View {
        VStack {
            ZStack {
                if appDataModel.state == .capturing {
                    if let session = appDataModel.objectCaptureSession {
                        ObjectCaptureView(session: session)
                    }
                }
                
                VStack {
                    Button("Tapped \(count) times") {
                        print("Tapped!")
                        count += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
