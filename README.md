Trying to update AppDataModel from GuidedCapture demo app to use @Observable macro

---

The original [demo app](https://developer.apple.com/documentation/realitykit/guided-capture-sample) provided by Apple. The code uses old approach for observation using the Observable Object protocol.

I wanted to upgrade the code to use new approach with @Observable macro using [guide](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro) provided by Apple and everything works fine except one thing.

When the user touches an empty area of the screen, and the code uses the AppDataModel with the @Observable macro, all other gesture events are blocked by the ObjectCaptureView. This behavior continues until the user clicks the "Start over" button. After that, everything seems to work as expected.

However, there is no such behavior when using the ObservableObject protocol. Moreover, when trying to add AppDataModel as @State to ContentView like this: “@State private var appDataModel = AppDataModel.instance”, everything seems to be working fine as well.

I have created three branches - *@Observable*, *ObservableObject*, and *AppDataModel-inside-ContentView-as-@State* which contain the code with the appropriate approach to observe the AppDataModel.
